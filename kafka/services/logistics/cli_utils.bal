import ballerina/io;

// ANSI color codes
const string RESET = "\u{001B}[0m";
const string RED = "\u{001B}[31m";
const string GREEN = "\u{001B}[32m";
const string YELLOW = "\u{001B}[33m";
const string BLUE = "\u{001B}[34m";
const string MAGENTA = "\u{001B}[35m";
const string CYAN = "\u{001B}[36m";

// Styling functions
public function colorPrint(string text, string color) {
    io:println(color + text + RESET);
}

public function printHeader(string text) {
    io:println("\n" + BLUE + "=== " + text + " ===" + RESET);
}

public function printSuccess(string text) {
    io:println(GREEN + "✓ " + text + RESET);
}

public function printError(string text) {
    io:println(RED + "✗ " + text + RESET);
}

public function printPrompt(string text) returns string {
    return io:readln(CYAN + text + RESET);
}

public function printMenu(string[] options) {
    foreach var [index, option] in options.enumerate() {
        io:println(YELLOW + (index + 1).toString() + ". " + RESET + option);
    }
}