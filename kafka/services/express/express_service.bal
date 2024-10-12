import ballerinax/kafka;
import ballerina/lang.value;
import ballerina/log;

configurable string groupId = "express-delivery-group";
configurable string consumeTopic = "express-delivery";
configurable string produceTopic = "delivery-confirmations";

public function main() returns error? {
    kafka:ConsumerConfiguration consumerConfigs = {
        groupId: groupId,
        topics: [consumeTopic],
        pollingInterval: 1,
        offsetReset: "earliest"
    };
    
    kafka:Consumer kafkaConsumer = check new (kafka:DEFAULT_URL, consumerConfigs);
    log:printInfo("Express delivery service started. Waiting for requests...");

    while (true) {
        kafka:AnydataConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach kafka:AnydataConsumerRecord rec in records {
            byte[] byteValue = check rec.value.ensureType();
            string stringValue = check string:fromBytes(byteValue);
            check processExpressDelivery(stringValue);
        }               
    }
}

function processExpressDelivery(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);
    log:printInfo("Processing express delivery request: " + request.toJsonString());
    check sendConfirmation(request);
}

function sendConfirmation(json request) returns error? {
    kafka:ProducerConfiguration producerConfigs = {
        clientId: "express-delivery-service",
        acks: "all",
        retryCount: 3
    };
    
    kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);
    
    json confirmation = {
        "requestId": check request.requestId,
        "status": "confirmed",
        "pickupTime": "2023-05-10T10:00:00Z",
        "estimatedDeliveryTime": "2023-05-11T14:00:00Z"  // Faster delivery for express
    };
    
    byte[] serializedMsg = confirmation.toJsonString().toBytes();
    check kafkaProducer->send({
        topic: produceTopic,
        value: serializedMsg
    });
    
    check kafkaProducer->'flush();
    check kafkaProducer->'close();
}