import ballerina/grpc;
import ballerina/sql;

listener grpc:Listener ep = new (9090);

type Order record {
    string orderId;
    string customerId;
    string orderDate;
    string status; //("Pending", "Shipped", "Delivered")
    map<anydata> items;
    decimal totalAmount;
};

@grpc:Descriptor {value: SERVICE_INTERFACE_DESC}
service "OnlineShoppingService" on ep {

    remote function addProduct(Product value) returns ProductResponse|error {
        _ = check db->execute(`
            INSERT INTO Product (sku, name, description, price, stock_quantity, status)
            VALUES (${value.sku}, ${value.name}, ${value.description}, ${value.price}, ${value.stock_quantity}, ${value.status})
        `);

        stream<Product, sql:Error?> productStream = db->query(`
            SELECT * FROM Product WHERE sku = ${value.sku}
        `);

        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        if (productList.length() == 0) {
            return error("Error adding Product");
        }

        return {message: "Product added successfully", product: productList[0]};
    }

    remote function updateProduct(ProductUpdate value) returns ProductResponse|error {
        boolean updated = false;

        if value.product.name != "" {
            _ = check db->execute(`UPDATE Product SET name = ${value.product.name} WHERE sku = ${value.sku}`);
            updated = true;
        }
        if value.product.description != "" {
            _ = check db->execute(`UPDATE Product SET description = ${value.product.description} WHERE sku = ${value.sku}`);
            updated = true;
        }
        if value.product.price > 0.0 {
            _ = check db->execute(`UPDATE Product SET price = ${value.product.price} WHERE sku = ${value.sku}`);
            updated = true;
        }
        if value.product.stock_quantity >= 0 {
            _ = check db->execute(`UPDATE Product SET stock_quantity = ${value.product.stock_quantity} WHERE sku = ${value.sku}`);
            updated = true;
        }
        if value.product.status != "" {
            _ = check db->execute(`UPDATE Product SET status = ${value.product.status} WHERE sku = ${value.sku}`);
            updated = true;
        }

        if !updated {
            return error("No fields provided for update");
        }

        stream<Product, sql:Error?> productStream = db->query(`
            SELECT * FROM Product WHERE sku = ${value.sku}
        `);

        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        return {message: "Product updated successfully", product: productList[0]};
    }

    remote function removeProduct(ProductId value) returns ProductList|error {
        stream<Product, sql:Error?> productStream = db->query(`
            SELECT * FROM Product WHERE sku = ${value.sku}
        `);

        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        if productList.length() == 0 {
            return error("Product not found.");
        }

        _ = check db->execute(`DELETE FROM Product WHERE sku = ${value.sku}`);

        return {products: productList};
    }

    remote function listAvailableProducts(Empty value) returns ProductList|error {
        stream<Product, sql:Error?> productStream = db->query(`SELECT * FROM Product`);

        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        return {products: productList};
    }

    remote function searchProduct(ProductId value) returns ProductResponse|error {
        stream<Product, sql:Error?> productStream = db->query(`
            SELECT * FROM Product WHERE sku = ${value.sku}
        `);

        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        if productList.length() == 0 {
            return error("Product not found.");
        }

        return {message: "Product found", product: productList[0]};
    }

    remote function addToCart(CartRequest value) returns CartResponse|error {
        // Check if the product exists and has sufficient stock
        stream<Product, sql:Error?> productStream = db->query(`
            SELECT * FROM Product WHERE sku = ${value.sku}
        `);
        Product[] productList = [];
        check from Product product in productStream
            do {
                productList.push(product);
            };

        if (productList.length() == 0) {
            return error("Product not found");
        }

        Product product = productList[0];
        if product.stock_quantity <= 0 {
            return error("Not enough stock available");
        }

        // Insert into cart
        _ = check db->execute(`
            INSERT INTO Cart (user_id, sku) 
            VALUES (${value.user_id}, ${value.sku})
        `);

        return {message: "Product added to cart"};
    }

    remote function placeOrder(OrderRequest value) returns OrderResponse|error {
        // Create a new order
        _ = check db->execute(`
        INSERT INTO Orders (user_id) 
        VALUES (${value.user_id})
    `);

        // Retrieve the last inserted order ID
        stream<record {int order_id;}, sql:Error?> orderStream = db->query(`
        SELECT LAST_INSERT_ID() as order_id
    `);

        int orderId;

        // Extract the order ID from the stream
        check from record {int order_id;} Order in orderStream
            do {
                orderId = Order.order_id;
            };

        // Insert all cart items into the OrderItems table
        _ = check db->execute(`
        INSERT INTO OrderItems (order_id, sku)
        SELECT ${orderId}, sku 
        FROM Cart 
        WHERE user_id = ${value.user_id}
    `);

        // Remove the items from the Cart after placing the order
        _ = check db->execute(`
        DELETE FROM Cart 
        WHERE user_id = ${value.user_id}
    `);

        // Retrieve the ordered products
        stream<Product, sql:Error?> orderedProductStream = db->query(`
        SELECT p.* FROM Product p
        JOIN OrderItems oi ON p.sku = oi.sku
        WHERE oi.order_id = ${orderId}
    `);

        // Collect the ordered products
        Product[] orderedProductList = [];
        check from Product product in orderedProductStream
            do {
                orderedProductList.push(product);
            };

        return {message: "Order placed successfully", products: orderedProductList};
    }

    remote function createUsers(stream<User, grpc:Error?> clientStream) returns UserResponse|error {
        // Handle user creation from the stream
        User[] users = [];
        check from User user in clientStream
            do {
                users.push(user);
                _ = check db->execute(`
                    INSERT INTO User (user_id, name, role)
                    VALUES (${user.user_id}, ${user.name}, ${user.role})
                `);
            };

        return {message: "Users created successfully"};
    }
}
