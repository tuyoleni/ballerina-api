import ballerinax/kafka;
import ballerina/io;

kafka:ProducerConfiguration producerConfigs = {
    clientId: "ballerina-producer",
    acks: "all",
    retryCount: 3,
    batchSize: 16384,
    linger: 1,
    compressionType: kafka:COMPRESSION_SNAPPY,
    enableIdempotence: true
};

kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);

public function main() returns error? {
    string message = "Hello, Kafka!";
    check kafkaProducer->send({
        topic: "test-topic",
        value: message.toBytes()
    });
    io:println("Message sent successfully");
}
