import ballerina/io;
import ballerina/lang.value;
import ballerinax/kafka;
import ballerinax/mongodb;

const string RESET = "\u{001B}[0m";
const string RED = "\u{001B}[31m";
const string GREEN = "\u{001B}[32m";
const string YELLOW = "\u{001B}[33m";
const string BLUE = "\u{001B}[34m";
const string CYAN = "\u{001B}[36m";


mongodb:Client mongoClient = check new ({
    connection: {
        serverAddress: {
            host: "localhost",
            port: 27017
        },
        auth: <mongodb:ScramSha256AuthCredential>{
            username: "tuyoleni",
            password: "mango.tuyoleni",
            database: "admin"
        }
    }
});

public function main() returns error? {
    kafka:ConsumerConfiguration consumerConfigs = {
        groupId: "logistics-group",
        topics: ["delivery-requests", "tracking-requests", "delivery-confirmations"],
        pollingInterval: 1,
        autoCommit: false
    };

    kafka:Consumer kafkaConsumer = check new (kafka:DEFAULT_URL, consumerConfigs);

    io:println(CYAN + "\n+===============================================+\n" +
                     "|        Logistics service started.             |\n" +
                     "|      Waiting for requests...                  |\n" +
                     "+===============================================+" + RESET);

    while (true) {
        kafka:BytesConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach var rec in records {
            do {
                byte[] valueBytes = rec.value;
                string valueString = check string:fromBytes(valueBytes);
                json valueJson = check value:fromJsonString(valueString);

                string topic = rec.offset.partition.topic;

                io:println(GREEN + "\n+------------------ Request Received ------------------+\n" +
                                  "| Topic: " + topic + RESET);

                match topic {
                    "delivery-requests" => {
                        check processDeliveryRequest(valueString);
                    }
                    "tracking-requests" => {
                        check processTrackingRequest(valueString);
                    }
                    "delivery-confirmations" => {
                        check processDeliveryConfirmation(valueString);
                    }
                    _ => {
                        io:println(RED + "\n+------------------- Unknown Topic --------------------+\n" +
                                           "| Unknown topic: " + topic + RESET);
                    }
                }
            } on fail error e {
                if e is DeliveryRequestError {
                    io:println(RED + "\n+------------------- Error --------------------+\n" +
                                       "| Error processing delivery request: " + e.message() + RESET);
                } else if e is TrackingRequestError {
                    io:println(RED + "\n+------------------- Error --------------------+\n" +
                                       "| Error processing tracking request: " + e.message() + RESET);
                } else if e is DeliveryConfirmationError {
                    io:println(RED + "\n+------------------- Error --------------------+\n" +
                                       "| Error processing delivery confirmation: " + e.message() + RESET);
                } else {
                    io:println(RED + "\n+------------------- Unexpected Error --------------------+\n" +
                                       "| Error: " + e.message() + RESET);
                }
            }
        }
    }
}

function processDeliveryRequest(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);

    io:println(BLUE + "\n+------------------ Processing Delivery Request ------------------+" + RESET);
    io:println("Request ID: ", request.requestId);
    io:println("Shipment Type: ", request.shipmentType);
    io:println("Pickup Location: ", request.pickupLocation);
    io:println("Delivery Location: ", request.deliveryLocation);
    io:println("Preferred Pickup Time: ", request.preferredPickupTime);
    io:println("Preferred Delivery Time: ", request.preferredDeliveryTime);
    io:println("Customer: ", request.firstName, " ", request.lastName);
    io:println("Contact Number: ", request.contactNumber);

    mongodb:Database logistics = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logistics->getCollection("requests");
    _ = check requests->insertOne(<map<json>>request);
    io:println(GREEN + "Request stored in database." + RESET);

    match request.shipmentType {
        "standard" => {
            check forwardToService("standard-delivery", request);
            io:println(GREEN + "Request forwarded to standard delivery service." + RESET);
        }
        "express" => {
            check forwardToService("express-delivery", request);
            io:println(GREEN + "Request forwarded to express delivery service." + RESET);
        }
        "international" => {
            check forwardToService("international-delivery", request);
            io:println(GREEN + "Request forwarded to international delivery service." + RESET);
        }
        _ => {
            io:println(RED + "Error: Invalid shipment type" + RESET);
            return error("Invalid shipment type");
        }
    }

    io:println(GREEN + "Delivery request processed successfully." + RESET);
    io:println(BLUE + "+-----------------------------------------------------------------+\n" + RESET);
}

function processTrackingRequest(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);
    string requestId = check request.requestId;

    io:println(BLUE + "\n+------------------ Processing Tracking Request ------------------+" + RESET);
    io:println("Tracking Request ID: ", requestId);

    mongodb:Database logistics = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logistics->getCollection("requests");
    record {|anydata...;|}? result = check requests->findOne({"requestId": requestId});

    if result is record {|anydata...;|} {
        io:println(GREEN + "Tracking information found:" + RESET);
        io:println(result.toJsonString());
    } else {
        io:println(RED + "No tracking information found for request " + requestId + RESET);
    }

    io:println(BLUE + "+-----------------------------------------------------------------+\n" + RESET);
}

function processDeliveryConfirmation(string confirmationStr) returns error? {
    json confirmation = check value:fromJsonString(confirmationStr);
    string requestId = check confirmation.requestId;

    io:println(BLUE + "\n+-------------- Processing Delivery Confirmation --------------+" + RESET);
    io:println("Request ID: ", requestId);
    io:println("Status: ", confirmation.status);
    io:println("Pickup Time: ", confirmation.pickupTime);
    io:println("Estimated Delivery Time: ", confirmation.estimatedDeliveryTime);

    mongodb:Database logistics = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logistics->getCollection("requests");

    mongodb:Update update = {
        "$set": {
            "status": check confirmation.status,
            "pickupTime": check confirmation.pickupTime,
            "estimatedDeliveryTime": check confirmation.estimatedDeliveryTime
        }
    };
    _ = check requests->updateOne({"requestId": requestId}, update);

    io:println(GREEN + "Delivery confirmation processed and database updated." + RESET);
    io:println(BLUE + "+-----------------------------------------------------------------+\n" + RESET);
}

function forwardToService(string topic, json request) returns error? {
    kafka:ProducerConfiguration producerConfigs = {
        clientId: "logistics-service",
        acks: "all",
        retryCount: 3
    };

    kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);

    byte[] serializedMsg = request.toJsonString().toBytes();
    check kafkaProducer->send({
        topic: topic,
        value: serializedMsg
    });

    check kafkaProducer->'flush();
    check kafkaProducer->'close();
}

function getDeliveryRequests() returns stream<record {}, error?>|error {
    mongodb:Database logisticsDb = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logisticsDb->getCollection("requests");
    return requests->find();
}

function updateDeliveryStatus(string requestId, string status) returns error? {
    mongodb:Database logisticsDb = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logisticsDb->getCollection("requests");
    mongodb:Update update = {
        "$set": {
            "status": status
        }
    };
    _ = check requests->updateOne({"requestId": requestId}, update);
    io:println(GREEN + "Delivery status updated for request " + requestId + ": " + status + RESET);
}

type DeliveryRequestError distinct error<record {|string message;|}>;
type TrackingRequestError distinct error<record {|string message;|}>;
type DeliveryConfirmationError distinct error<record {|string message;|}>;
