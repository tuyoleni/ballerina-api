import ballerina/io;
import ballerina/lang.'float as langfloat;
import ballerina/lang.'int as langint;
import ballerina/random;

OnlineShoppingServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    printHeader();
    while true {
        printMenu();
        string choice = io:readln("\nEnter your choice: ");

        match choice {
            "1" => {
                check addProduct();
            }
            "2" => {
                check updateProduct();
            }
            "3" => {
                check removeProduct();
            }
            "4" => {
                check listAvailableProducts();
            }
            "5" => {
                check searchProduct();
            }
            "6" => {
                check addToCart();
            }
            "7" => {
                check placeOrder();
            }
            "8" => {
                check createUsers();
            }
            "9" => {
                io:println("Exiting the program. Goodbye!");
                return;
            }
            _ => {
                io:println("Invalid choice. Please try again.");
            }
        }
    }
}

function printHeader() {
    io:println("\n+===============================================+");
    io:println("|          Online Shopping CLI System           |");
    io:println("+===============================================+");
}

function printMenu() {
    io:println("\n+------------------- Menu ---------------------+");
    io:println("|  1. Add Product                              |");
    io:println("|  2. Update Product                           |");
    io:println("|  3. Remove Product                           |");
    io:println("|  4. List Available Products                  |");
    io:println("|  5. Search Product                           |");
    io:println("|  6. Add to Cart                              |");
    io:println("|  7. Place Order                              |");
    io:println("|  8. Create Users                             |");
    io:println("|  9. Exit                                     |");
    io:println("+----------------------------------------------+");
}

function addProduct() returns error? {
    Product addProductRequest = {
        name: promptForInput("Enter product name: "),
        description: promptForInput("Enter product description: "),
        price: check toFloat(promptForInput("Enter product price: ")),
        stock_quantity: check toInt(promptForInput("Enter stock quantity: ")),
        sku: randomSKU(),
        status: promptForInput("Enter product status: ")
    };

    ProductResponse response = check ep->addProduct(addProductRequest);
    io:println(response);

    return;
}

function updateProduct() returns error? {
    ProductUpdate updateProductRequest = {
        sku: promptForInput("Enter SKU to update: "),
        product: {
            name: promptForInput("Enter new product name: "),
            description: promptForInput("Enter new description: "),
            price: check toFloat(promptForInput("Enter new price: ")),
            stock_quantity: check toInt(promptForInput("Enter new stock quantity: ")),
            sku: promptForInput("Enter new SKU: "),
            status: promptForInput("Enter new status: ")
        }
    };
    ProductResponse response = check ep->updateProduct(updateProductRequest);
    io:println(response);
}

function removeProduct() returns error? {
    ProductId removeProductRequest = {sku: promptForInput("Enter SKU to remove: ")};
    ProductList response = check ep->removeProduct(removeProductRequest);
    io:println(response);
}

function listAvailableProducts() returns error? {
    Empty request = {};
    ProductList response = check ep->listAvailableProducts(request);
    io:println(response);
}

function searchProduct() returns error? {
    ProductId searchProductRequest = {sku: promptForInput("Enter SKU to search: ")};
    ProductResponse response = check ep->searchProduct(searchProductRequest);
    io:println(response);
}

function addToCart() returns error? {
    CartRequest addToCartRequest = {
        user_id: promptForInput("Enter user ID: "),
        sku: promptForInput("Enter SKU to add to cart: ")
    };
    CartResponse response = check ep->addToCart(addToCartRequest);
    io:println(response);
}

function placeOrder() returns error? {
    OrderRequest placeOrderRequest = {user_id: promptForInput("Enter user ID to place order: ")};
    OrderResponse response = check ep->placeOrder(placeOrderRequest);
    io:println(response);
}

function createUsers() returns error? {
    User createUsersRequest = {
        user_id: promptForInput("Enter user ID: "),
        name: promptForInput("Enter user name: "),
        role: promptForInput("Enter user role: ")
    };

    CreateUsersStreamingClient createUsersStreamingClient = check ep->createUsers();

    check createUsersStreamingClient->sendUser(createUsersRequest);

    check createUsersStreamingClient->complete();

    UserResponse? createUsersResponse = check createUsersStreamingClient->receiveUserResponse();

    if createUsersResponse is UserResponse {
        io:println(createUsersResponse);
    } else {
        io:println("No response received.");
    }
}

function promptForInput(string prompt) returns string {
    return io:readln(prompt).trim();
}

function toInt(string value) returns int|error {
    return langint:fromString(value);
}

function toFloat(string value) returns float|error {
    return langfloat:fromString(value);
}

function randomSKU() returns string {
    float randomValue = random:createDecimal();
    return randomValue.toString();
}
