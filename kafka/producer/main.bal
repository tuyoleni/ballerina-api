import ballerinax/kafka;
import ballerina/io;

kafka:ProducerConfiguration producerConfigs = {
    clientId: "ballerina-producer",
    acks: "all",
    retryCount: 3,
    batchSize: 16384,
    linger: 1,
    enableIdempotence: true
};

kafka:Producer kafkaProducer = check new ("localhost:29092", producerConfigs);

public function main() returns error? {
    string message = "Hello, Kafka!";
    check kafkaProducer->send({
        topic: "topic",
        value: message.toBytes()
    });
    io:println("Message sent successfully");

    // Close the producer
    check kafkaProducer->close();
}
