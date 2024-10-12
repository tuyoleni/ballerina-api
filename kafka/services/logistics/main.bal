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
        topics: ["delivery-requests"],
        pollingInterval: 1,
        autoCommit: false
    };

    kafka:Consumer kafkaConsumer = check new (kafka:DEFAULT_URL, consumerConfigs);

    io:println("Logistics service started. Waiting for delivery requests...");

    while (true) {
        kafka:BytesConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach var rec in records {
            var result = processDeliveryRequest(check string:fromBytes(rec.value));
            if result is error {
                io:println("Error processing delivery request: ", result.message());
            } else {
                io:println("Delivery request processed successfully.");
            }
        }
    }
}

function processDeliveryRequest(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);

    mongodb:Database logistics = check mongoClient->getDatabase("logistics");
    mongodb:Collection requests = check logistics->getCollection("requests");
    _ = check requests->insertOne(<map<json>>request);

    match request.shipmentType {
        "standard" => {
            check forwardToService("standard-delivery", request);
        }
        "express" => {
            check forwardToService("express-delivery", request);
        }
        "international" => {
            check forwardToService("international-delivery", request);
        }
        _ => {
            return error("Invalid shipment type");
        }
    }
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

function insertDeliveryRequest(json request) returns error? {
    mongodb:Database logisticsDb = check mongoClient->getDatabase("database");
    mongodb:Collection requests = check logisticsDb->getCollection("requests");
    _ = check requests->insertOne(<map<json>>request);
}

function getDeliveryRequests() returns stream<record {}, error?>|error {
    mongodb:Database logisticsDb = check mongoClient->getDatabase("database");
    mongodb:Collection requests = check logisticsDb->getCollection("requests");
    return requests->find();
}

function updateDeliveryStatus(string requestId, string status) returns error? {
    mongodb:Database logisticsDb = check mongoClient->getDatabase("database");
    mongodb:Collection requests = check logisticsDb->getCollection("requests");
    mongodb:Update update = {
        "$set": {
            "status": status
        }
    };
    _ = check requests->updateOne({"_id": requestId}, update);
}
