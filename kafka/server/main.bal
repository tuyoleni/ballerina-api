import ballerinax/kafka;
import ballerina/io;

kafka:ConsumerConfiguration consumerConfigs = {
    groupId: "ballerina-consumer-group",
    topics: ["test-topic"],
    pollingInterval: 1,
    autoCommit: false,
    sessionTimeout: 45000,
    offsetReset: kafka:OFFSET_RESET_EARLIEST,
    maxPollRecords: 100
};

kafka:Consumer kafkaConsumer = check new (kafka:DEFAULT_URL, consumerConfigs);

public function main() returns error? {
    while true {
        kafka:BytesConsumerRecord[] records = check kafkaConsumer->poll(1);
        foreach var rec in records {
            byte[] messageBytes = rec.value;
            string message = check string:fromBytes(messageBytes);
            io:println("Received message: ", message);
            io:println("Topic: ", rec.headers.get("topic"));
            io:println("Partition: ", rec.headers.get("partition"));
            io:println("Offset: ", rec.headers.get("offset"));
            io:println("Timestamp: ", rec.headers.get("timestamp"));
        }
        check kafkaConsumer->commit();
    }
}
