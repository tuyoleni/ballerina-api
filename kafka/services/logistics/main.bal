import ballerina/io;
import ballerina/lang.value;
import ballerinax/kafka;
import ballerinax/mongodb;

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

    io:println("Logistics service started. Waiting for requests...");

    while (true) {
        kafka:BytesConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach var rec in records {
            do {
                byte[] valueBytes = rec.value;
                string valueString = check string:fromBytes(valueBytes);
                json valueJson = check value:fromJsonString(valueString);

                string topic = rec.offset.partition.topic;

                io:println("Received record from topic: ", topic);
                io:println("Record data: ", valueJson);

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
                        io:println("Unknown topic: ", topic);
                    }
                }
            } on fail error e {
                if e is DeliveryRequestError {
                    io:println("Error processing delivery request: ", e.message());
                } else if e is TrackingRequestError {
                    io:println("Error processing tracking request: ", e.message());
                } else if e is DeliveryConfirmationError {
                    io:println("Error processing delivery confirmation: ", e.message());
                } else {
                    io:println("Unexpected error: ", e.message());
                }
            }
        }
    }
}

function processDeliveryRequest(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);

    io:println("\n--- Processing Delivery Request ---");
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
    io:println("Request stored in database.");

    match request.shipmentType {
        "standard" => {
            check forwardToService("standard-delivery", request);
            io:println("Request forwarded to standard delivery service.");
        }
        "express" => {
            check forwardToService("express-delivery", request);
            io:println("Request forwarded to express delivery service.");
        }
        "international" => {
            check forwardToService("international-delivery", request);
            io:println("Request forwarded to international delivery service.");
        }
        _ => {
            io:println("Error: Invalid shipment type");
            return error("Invalid shipment type");
        }
    }

    io:println("Delivery request processed successfully.");
    io:println("-----------------------------------\n");
}

function processTrackingRequest(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);
    string requestId = check request.requestId;

    io:println("\n--- Processing Tracking Request ---");
    io:println("Tracking Request ID: ", requestId);

    mongodb:Database logistics = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logistics->getCollection("requests");
    record {|anydata...;|}? result = check requests->findOne({"requestId": requestId});

    if result is record {|anydata...;|} {
        io:println("Tracking information found:");
        io:println(result.toJsonString());
    } else {
        io:println("No tracking information found for request " + requestId);
    }

    io:println("-----------------------------------\n");
}

function processDeliveryConfirmation(string confirmationStr) returns error? {
    json confirmation = check value:fromJsonString(confirmationStr);
    string requestId = check confirmation.requestId;

    io:println("\n--- Processing Delivery Confirmation ---");
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

    io:println("Delivery confirmation processed and database updated.");
    io:println("-----------------------------------\n");
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
    io:println("Delivery status updated for request ", requestId, ": ", status);
}

type DeliveryRequestError distinct error<record {|string message;|}>;

type TrackingRequestError distinct error<record {|string message;|}>;

type DeliveryConfirmationError distinct error<record {|string message;|}>;
