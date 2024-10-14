import ballerinax/kafka;
import ballerina/lang.value;
import ballerina/log;

configurable string groupId = "international-delivery-group";
configurable string consumeTopic = "international-delivery";
configurable string produceTopic = "delivery-confirmations";

public function main() returns error? {
    kafka:ConsumerConfiguration consumerConfigs = {
        groupId: groupId,
        topics: [consumeTopic],
        offsetReset: "earliest"
    };
    
    kafka:Consumer kafkaConsumer = check new (kafka:DEFAULT_URL, consumerConfigs);
    log:printInfo("International delivery service started. Waiting for requests...");

    while (true) {
       kafka:AnydataConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach kafka:AnydataConsumerRecord rec in records {
            byte[] byteValue = check rec.value.ensureType();
            string stringValue = check string:fromBytes(byteValue);
            check processInternationalDelivery(stringValue);
        }               
    }
}

function processInternationalDelivery(string requestStr) returns error? {
    json request = check value:fromJsonString(requestStr);
    log:printInfo("Processing international delivery request: " + request.toJsonString());
    
    check sendConfirmation(request);
}

function sendConfirmation(json request) returns error? {
    kafka:ProducerConfiguration producerConfigs = {
        clientId: "international-delivery-service",
        acks: "all",
        retryCount: 3
    };
    
    kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);
    
    json confirmation = {
        "requestId": check request.requestId,
        "status": "confirmed",
        "pickupTime": "2023-05-10T10:00:00Z",
        "estimatedDeliveryTime": "2023-05-15T14:00:00Z"  // Longer delivery time for international
    };
    
    byte[] serializedMsg = confirmation.toJsonString().toBytes();
    check kafkaProducer->send({
        topic: produceTopic,
        value: serializedMsg
    });
    
    check kafkaProducer->'flush();
    check kafkaProducer->'close();
    
}
