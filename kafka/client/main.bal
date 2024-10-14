import ballerina/io;
import ballerinax/kafka;
import ballerina/uuid;



public function main() returns error? {
    io:println("Welcome To The Logistics System");

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
                check trackShipment();
            }
            3 => {
                io:println("Thank you for using the Logistics System. Goodbye!");
                return;
            }
            _ => {
                io:println("Invalid option. Please Try Again.");
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
    string preferredPickupTime = io:readln("Enter preferred pickup time (YYYY-MM-DD HH:MM): ");
    string preferredDeliveryTime = io:readln("Enter preferred delivery time (YYYY-MM-DD HH:MM): ");
    string firstName = io:readln("Enter first name: ");
    string lastName = io:readln("Enter last name: ");
    string contactNumber = io:readln("Enter contact number: ");

    string requestId = uuid:createType1AsString();

    json payload = {
        "requestId": requestId,
        "shipmentType": shipmentType,
        "pickupLocation": pickupLocation,
        "deliveryLocation": deliveryLocation,
        "preferredPickupTime": preferredPickupTime,
        "preferredDeliveryTime": preferredDeliveryTime,
        "firstName": firstName,
        "lastName": lastName,
        "contactNumber": contactNumber
    };

    check sendToKafka(payload);

    io:println("Delivery Request Submitted Successfully!");
    io:println("Your Tracking Number is: " + requestId);
    io:println("You can use this tracking number to check the status of your shipment.");
}

function trackShipment() returns error? {
    string trackingNumber = io:readln("Enter Tracking Number: ");
    
    json trackingRequest = {
        "requestId": trackingNumber
    };

    check sendToKafka(trackingRequest, "tracking-requests");

    io:println("Tracking information for " + trackingNumber + " has been requested.");
    io:println("Please Check Back Later For Updates On Your Shipment.");
}

function sendToKafka(json payload, string topic = "delivery-requests") returns error? {
    kafka:ProducerConfiguration producerConfigs = {
        clientId: "logistics-client",
        acks: "all",
        retryCount: 3
    };

    kafka:Producer kafkaProducer = check new (kafka:DEFAULT_URL, producerConfigs);

    byte[] serializedMsg = payload.toJsonString().toBytes();

    kafka:BytesProducerRecord producerRecord = {
        topic: topic,
        value: serializedMsg
    };
    check kafkaProducer->send(producerRecord);
    check kafkaProducer->'flush();
    check kafkaProducer->'close();
}
