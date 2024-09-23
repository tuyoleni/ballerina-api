import ballerina/io;
import ballerina/http;

const string BASE_URL = "http://localhost:3000/api";

http:Client httpClient = check new (BASE_URL);

public function main() returns error? {
    printHeader();
    while true {
        printMenu();
        string choice = io:readln("\nEnter your choice: ");

        match choice {
            "1" => { check getReviewDue(); }
            "2" => { check deleteProgramme(); }
            "3" => { check getFacultyProgrammes(); }
            "4" => { check addProgramme(); }
            "5" => { check updateProgramme(); }
            "6" => { check getProgrammesInUnit(); }
            "7" => { 
                printBoxedText("Exiting the program. Goodbye!", "yellow");
                return;
            }
            _ => { printBoxedText("Invalid choice. Please try again.", "red"); }
        }
    }
}

function printHeader() {
    io:println(color("cyan", "\n+===============================================+\n" +
                            "|                                               |\n" +
                            "|       Programme Management CLI System         |\n" +
                            "|                                               |\n" +
                            "+===============================================+\n"));
}

function printMenu() {
    io:println(color("green", "\n+------------------- Menu ---------------------+\n" +
                            "|                                              |\n" +
                            "|  1. Get programmes due for review            |\n" +
                            "|  2. Delete a programme                       |\n" +
                            "|  3. Get programmes by faculty                |\n" +
                            "|  4. Add a new programme                      |\n" +
                            "|  5. Update a programme                       |\n" +
                            "|  6. Get programmes in a unit                 |\n" +
                            "|  7. Exit                                     |\n" +
                            "|                                              |\n" +
                            "+----------------------------------------------+\n"));
}


function getReviewDue() returns error? {
    printBoxedText("Fetching programmes due for review...", "blue");
    json response = check httpClient->get("/review_due");
    printJsonResponse(response);
}

function deleteProgramme() returns error? {
    string programmeCode = promptForInput("Enter programme code to delete: ");
    printBoxedText("Deleting programme...", "blue");
    json response = check httpClient->delete("/delete_programme/" + programmeCode);
    printJsonResponse(response);
}

function getFacultyProgrammes() returns error? {
    string faculty = promptForInput("Enter faculty name: ");
    printBoxedText("Fetching programmes for faculty...", "blue");
    json response = check httpClient->get("/faculty_programme/" + faculty);
    printJsonResponse(response);
}

function addProgramme() returns error? {
    printBoxedText("Adding new programme", "blue");
    json programme = {
        "programme_code": promptForInput("Enter programme code: "),
        "programme_name": promptForInput("Enter programme name: "),
        "NQF_level": promptForInput("Enter NQF level: "),
        "faculty": promptForInput("Enter faculty: "),
        "department": promptForInput("Enter department: ")
    };
    json response = check httpClient->post("/add_programme", programme);
    printJsonResponse(response);
}

function updateProgramme() returns error? {
    string programmeCode = promptForInput("Enter programme code to update: ");
    printBoxedText("Updating programme", "blue");
    map<string> programme = {};

    addToMapIfNotEmpty(programme, "programme_name", "Enter new programme name (press Enter to skip): ");
    addToMapIfNotEmpty(programme, "NQF_level", "Enter new NQF level (press Enter to skip): ");
    addToMapIfNotEmpty(programme, "faculty", "Enter new faculty (press Enter to skip): ");
    addToMapIfNotEmpty(programme, "department", "Enter new department (press Enter to skip): ");

    if programme.length() == 0 {
        printBoxedText("No updates provided. Skipping update operation.", "yellow");
        return;
    }

    json response = check httpClient->put("/update_programme/" + programmeCode, programme.toJson());
    printJsonResponse(response);
}

function getProgrammesInUnit() returns error? {
    string unit = promptForInput("Enter unit (faculty or department): ");
    printBoxedText("Fetching programmes in unit...", "blue");
    json response = check httpClient->get("/get_programmes_in_unit/" + unit);
    printJsonResponse(response);
}

// Helper functions
function promptForInput(string prompt) returns string {
    return io:readln(color("cyan", prompt)).trim();
}

function addToMapIfNotEmpty(map<string> m, string key, string prompt) {
    string? value = promptForInput(prompt);
    if value is string && value != "" {
        m[key] = value;
    }
}

function printJsonResponse(json response) {
    io:println("\nResponse:");
    io:println(color("green", response.toJsonString()));
}

function color(string color, string text) returns string {
    match color {
        "red" => { return "\u{001b}[31m" + text + "\u{001b}[0m"; }
        "green" => { return "\u{001b}[32m" + text + "\u{001b}[0m"; }
        "yellow" => { return "\u{001b}[33m" + text + "\u{001b}[0m"; }
        "blue" => { return "\u{001b}[34m" + text + "\u{001b}[0m"; }
        "magenta" => { return "\u{001b}[35m" + text + "\u{001b}[0m"; }
        "cyan" => { return "\u{001b}[36m" + text + "\u{001b}[0m"; }
        _ => { return text; }
    }
}

function printBoxedText(string text, string boxColor) {
    int width = text.length() + 4;
    string horizontalBorder = createBorder(width);
    
    io:println(color(boxColor, "+" + horizontalBorder + "+"));
    io:println(color(boxColor, "|  " + text + "  |"));
    io:println(color(boxColor, "+" + horizontalBorder + "+"));
}

function createBorder(int width) returns string {
    string border = "";
    int i = 0;
    while i < width {
        border = border + "-";
        i = i + 1;
    }
    return border;
}