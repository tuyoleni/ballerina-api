import ballerina/io;
import ballerinax/kafka;
import ballerina/uuid;

// ANSI color codes for better UI presentation
const string RESET = "\u{001B}[0m}";
const string RED = "\u{001B}[31m}";
const string GREEN = "\u{001B}[32m}";
const string YELLOW = "\u{001B}[33m}";
const string BLUE = "\u{001B}[34m}";
const string CYAN = "\u{001B}[36m}";

// Function to print the header with better borders and alignment
function printHeader() {
    io:println(CYAN + "\n+===============================================+\n" +
                     "|                                               |\n" +
                     "|              ✈ Logistics System CLI ✈          |\n" +
                     "|                                               |\n" +
                     "+===============================================+" + RESET);
}

// Function to print a more appealing menu with symbols
function printMenu() {
    io:println(GREEN + "\n+------------------ Main Menu ------------------+\n" +
                      "| 1️⃣  → Submit a new delivery request             |\n" +
                      "| 2️⃣  → Track a shipment                          |\n" +
                      "| 3️⃣  → Exit                                      |\n" +
                      "+-----------------------------------------------+" + RESET);
}

public function main() returns error? {
    printHeader();

    while (true) {
        printMenu();

        int option = check int:fromString(io:readln(CYAN + "👉 Enter your choice (1-3): " + RESET));
        match option {
            1 => {
                check submitDeliveryRequest();
            }
            2 => {
                check trackShipment();
            }
            3 => {
                io:println(GREEN + "\n+===============================================+\n" +
                                   "|            🚚 Thank you for using             |\n" +
                                   "|        the Logistics System CLI! Goodbye!     |\n" +
                                   "+===============================================+" + RESET);
                return;
            }
            _ => {
                io:println(RED + "\n+---------------- Invalid Option ---------------+\n" +
                                   "|  ⚠ Invalid option. Please try again.          |\n" +
                                   "+-----------------------------------------------+" + RESET);
            }
        }
    }
}

// Enhanced function to submit delivery requests with more visual feedback
function submitDeliveryRequest() returns error? {
    io:println(CYAN + "\n+===============================================+\n" +
                     "|            📦 Submitting Delivery Request      |\n" +
                     "+===============================================+" + RESET);

    io:println(YELLOW + "\n+---------------- Shipment Type ----------------+\n" +
                        "| 1️⃣  → Standard                                 |\n" +
                        "| 2️⃣  → Express                                  |\n" +
                        "| 3️⃣  → International                            |\n" +
                        "+-----------------------------------------------+" + RESET);

    int shipmentChoice = check int:fromString(io:readln("👉 Enter your choice (1-3): "));
    string shipmentType;

    match shipmentChoice {
        1 => { shipmentType = "standard"; }
        2 => { shipmentType = "express"; }
        3 => { shipmentType = "international"; }
        _ => {
            io:println(RED + "\n+---------------- Invalid Choice ---------------+\n" +
                               "|  ⚠ Invalid choice. Defaulting to standard.    |\n" +
                               "+-----------------------------------------------+" + RESET);
            shipmentType = "standard";
        }
    }

    string pickupLocation = io:readln(CYAN + "🏠 Enter pickup location: " + RESET);
    string deliveryLocation = io:readln(CYAN + "📍 Enter delivery location: " + RESET);
    string preferredPickupTime = io:readln(CYAN + "⏰ Enter preferred pickup time (YYYY-MM-DD HH:MM): " + RESET);
    string preferredDeliveryTime = io:readln(CYAN + "⏰ Enter preferred delivery time (YYYY-MM-DD HH:MM): " + RESET);
    string firstName = io:readln(CYAN + "👤 Enter first name: " + RESET);
    string lastName = io:readln(CYAN + "👤 Enter last name: " + RESET);
    string contactNumber = io:readln(CYAN + "📞 Enter contact number: " + RESET);

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

    // Simulate processing with loading dots
    io:print(YELLOW + "\n⏳ Processing");
 
    io:println(RESET);

    check sendToKafka(payload);

    io:println(GREEN + "\n+===============================================+\n" +
                      "|        ✅ Delivery Request Submitted!          |\n" +
                      "+===============================================+" + RESET);
    io:println(CYAN + "📦 Your tracking number is: " + requestId + RESET);
    io:println("ℹ️ Use this tracking number to check the status of your shipment.");
}

// Enhanced tracking shipment UI with more clarity
function trackShipment() returns error? {
    string trackingNumber = io:readln(CYAN + "📦 Enter tracking number: " + RESET);
    
    json trackingRequest = {
        "requestId": trackingNumber
    };

    io:print(YELLOW + "\n⏳ Sending tracking request");
  
    io:println(RESET);

    check sendToKafka(trackingRequest, "tracking-requests");

    io:println(GREEN + "\n+===============================================+\n" +
                      "|     🔍 Tracking request sent for:             |\n" +
                      "|     📦 " + trackingNumber + "                  |\n" +
                      "+===============================================+" + RESET);
    io:println("ℹ️ Please check back later for updates on your shipment.");
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
