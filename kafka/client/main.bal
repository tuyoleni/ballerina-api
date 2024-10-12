import ballerina/io;
import ballerinax/kafka;



public function main() returns error? {
    io:println("Welcome to the Logistics System");

    while (true) {
        io:println("\nPlease select an option:");
        io:println("1. Submit a new delivery request");
        io:println("2. Track a shipment");
        io:println("3. Exit");

        int option = check int:fromString(io:readln("Enter your choice (1-3): "));
        match option {
            1 => {
                check submitDeliveryRequest();
            }
            2 => {
                trackShipment();
            }
            3 => {
                io:println("Thank you for using the Logistics System. Goodbye!");
                return;
            }
            _ => {
                io:println("Invalid option. Please try again.");
            }
        }
    }
}

function submitDeliveryRequest() returns error? {
    io:println("\nSubmitting a new delivery request");

    io:println("\nSelect shipment type:");
    io:println("1. Standard");
    io:println("2. Express");
    io:println("3. International");

    int shipmentChoice = check int:fromString(io:readln("Enter your choice (1-3): "));
    string shipmentType;

    match shipmentChoice {
        1 => { shipmentType = "standard"; }
        2 => { shipmentType = "express"; }
        3 => { shipmentType = "international"; }
        _ => {
            io:println("Invalid choice. Defaulting to standard shipment.");
            shipmentType = "standard";
        }
    }

    string pickupLocation = io:readln("Enter pickup location: ");
    string deliveryLocation = io:readln("Enter delivery location: ");
    string firstName = io:readln("Enter first name: ");
    string lastName = io:readln("Enter last name: ");
    string contactNumber = io:readln("Enter contact number: ");

    json payload = {
        "shipmentType": shipmentType,
        "pickupLocation": pickupLocation,
        "deliveryLocation": deliveryLocation,
        "firstName": firstName,
        "lastName": lastName,
        "contactNumber": contactNumber
    };

    check sendToKafka(payload);

    io:println("Delivery request submitted successfully!");
}

function trackShipment() {
    string trackingNumber = io:readln("Enter tracking number: ");
    io:println("Tracking information for " + trackingNumber + " will be displayed here.");
}

function sendToKafka(json payload) returns error? {
    kafka:ProducerConfiguration producerConfigs = {
        clientId: "logistics-client",
        acks: "all",
        retryCount: 3
    };

    kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);

    byte[] serializedMsg = payload.toJsonString().toBytes();

    kafka:BytesProducerRecord producerRecord = {
        topic: "delivery-requests",
        value: serializedMsg
    };
    check kafkaProducer->send(producerRecord);
    check kafkaProducer->'flush();
    check kafkaProducer->'close();
}
