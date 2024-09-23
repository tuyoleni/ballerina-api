import ballerina/grpc;
import ballerina/protobuf;

public const string SERVICE_INTERFACE_DESC = "0A17736572766963655F696E746572666163652E70726F746F1211736572766963655F696E7465726661636522A6010A0750726F6475637412120A046E616D6518012001280952046E616D6512200A0B6465736372697074696F6E180220012809520B6465736372697074696F6E12140A0570726963651803200128025205707269636512250A0E73746F636B5F7175616E74697479180420012805520D73746F636B5175616E7469747912100A03736B751805200128095203736B7512160A06737461747573180620012809520673746174757322570A0D50726F6475637455706461746512100A03736B751801200128095203736B7512340A0770726F6475637418022001280B321A2E736572766963655F696E746572666163652E50726F64756374520770726F64756374221D0A0950726F64756374496412100A03736B751801200128095203736B7522610A0F50726F64756374526573706F6E736512180A076D65737361676518012001280952076D65737361676512340A0770726F6475637418022001280B321A2E736572766963655F696E746572666163652E50726F64756374520770726F6475637422450A0B50726F647563744C69737412360A0870726F647563747318012003280B321A2E736572766963655F696E746572666163652E50726F64756374520870726F647563747322470A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522280A0C55736572526573706F6E736512180A076D65737361676518012001280952076D65737361676522380A0B436172745265717565737412170A07757365725F6964180120012809520675736572496412100A03736B751802200128095203736B7522280A0C43617274526573706F6E736512180A076D65737361676518012001280952076D65737361676522270A0C4F726465725265717565737412170A07757365725F6964180120012809520675736572496422610A0D4F72646572526573706F6E736512180A076D65737361676518012001280952076D65737361676512360A0870726F647563747318022003280B321A2E736572766963655F696E746572666163652E50726F64756374520870726F647563747322070A05456D707479329B050A154F6E6C696E6553686F7070696E6753657276696365124C0A0A61646450726F64756374121A2E736572766963655F696E746572666163652E50726F647563741A222E736572766963655F696E746572666163652E50726F64756374526573706F6E736512550A0D75706461746550726F6475637412202E736572766963655F696E746572666163652E50726F647563745570646174651A222E736572766963655F696E746572666163652E50726F64756374526573706F6E7365124D0A0D72656D6F766550726F64756374121C2E736572766963655F696E746572666163652E50726F6475637449641A1E2E736572766963655F696E746572666163652E50726F647563744C69737412490A0B637265617465557365727312172E736572766963655F696E746572666163652E557365721A1F2E736572766963655F696E746572666163652E55736572526573706F6E7365280112510A156C697374417661696C61626C6550726F647563747312182E736572766963655F696E746572666163652E456D7074791A1E2E736572766963655F696E746572666163652E50726F647563744C69737412510A0D73656172636850726F64756374121C2E736572766963655F696E746572666163652E50726F6475637449641A222E736572766963655F696E746572666163652E50726F64756374526573706F6E7365124C0A09616464546F43617274121E2E736572766963655F696E746572666163652E43617274526571756573741A1F2E736572766963655F696E746572666163652E43617274526573706F6E7365124F0A0A706C6163654F72646572121F2E736572766963655F696E746572666163652E4F72646572526571756573741A202E736572766963655F696E746572666163652E4F72646572526573706F6E7365620670726F746F33";

public isolated client class OnlineShoppingServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, SERVICE_INTERFACE_DESC);
    }

    isolated remote function addProduct(Product|ContextProduct req) returns ProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        Product message;
        if req is ContextProduct {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/addProduct", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ProductResponse>result;
    }

    isolated remote function addProductContext(Product|ContextProduct req) returns ContextProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        Product message;
        if req is ContextProduct {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/addProduct", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ProductResponse>result, headers: respHeaders};
    }

    isolated remote function updateProduct(ProductUpdate|ContextProductUpdate req) returns ProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        ProductUpdate message;
        if req is ContextProductUpdate {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/updateProduct", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ProductResponse>result;
    }

    isolated remote function updateProductContext(ProductUpdate|ContextProductUpdate req) returns ContextProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        ProductUpdate message;
        if req is ContextProductUpdate {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/updateProduct", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ProductResponse>result, headers: respHeaders};
    }

    isolated remote function removeProduct(ProductId|ContextProductId req) returns ProductList|grpc:Error {
        map<string|string[]> headers = {};
        ProductId message;
        if req is ContextProductId {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/removeProduct", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ProductList>result;
    }

    isolated remote function removeProductContext(ProductId|ContextProductId req) returns ContextProductList|grpc:Error {
        map<string|string[]> headers = {};
        ProductId message;
        if req is ContextProductId {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/removeProduct", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ProductList>result, headers: respHeaders};
    }

    isolated remote function listAvailableProducts(Empty|ContextEmpty req) returns ProductList|grpc:Error {
        map<string|string[]> headers = {};
        Empty message;
        if req is ContextEmpty {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/listAvailableProducts", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ProductList>result;
    }

    isolated remote function listAvailableProductsContext(Empty|ContextEmpty req) returns ContextProductList|grpc:Error {
        map<string|string[]> headers = {};
        Empty message;
        if req is ContextEmpty {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/listAvailableProducts", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ProductList>result, headers: respHeaders};
    }

    isolated remote function searchProduct(ProductId|ContextProductId req) returns ProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        ProductId message;
        if req is ContextProductId {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/searchProduct", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ProductResponse>result;
    }

    isolated remote function searchProductContext(ProductId|ContextProductId req) returns ContextProductResponse|grpc:Error {
        map<string|string[]> headers = {};
        ProductId message;
        if req is ContextProductId {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/searchProduct", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ProductResponse>result, headers: respHeaders};
    }

    isolated remote function addToCart(CartRequest|ContextCartRequest req) returns CartResponse|grpc:Error {
        map<string|string[]> headers = {};
        CartRequest message;
        if req is ContextCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/addToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CartResponse>result;
    }

    isolated remote function addToCartContext(CartRequest|ContextCartRequest req) returns ContextCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        CartRequest message;
        if req is ContextCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/addToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CartResponse>result, headers: respHeaders};
    }

    isolated remote function placeOrder(OrderRequest|ContextOrderRequest req) returns OrderResponse|grpc:Error {
        map<string|string[]> headers = {};
        OrderRequest message;
        if req is ContextOrderRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/placeOrder", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <OrderResponse>result;
    }

    isolated remote function placeOrderContext(OrderRequest|ContextOrderRequest req) returns ContextOrderResponse|grpc:Error {
        map<string|string[]> headers = {};
        OrderRequest message;
        if req is ContextOrderRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("service_interface.OnlineShoppingService/placeOrder", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <OrderResponse>result, headers: respHeaders};
    }

    isolated remote function createUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("service_interface.OnlineShoppingService/createUsers");
        return new CreateUsersStreamingClient(sClient);
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveUserResponse() returns UserResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <UserResponse>payload;
        }
    }

    isolated remote function receiveContextUserResponse() returns ContextUserResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <UserResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public isolated client class OnlineShoppingServiceProductResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProductResponse(ProductResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProductResponse(ContextProductResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class OnlineShoppingServiceProductListCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendProductList(ProductList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextProductList(ContextProductList response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class OnlineShoppingServiceCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCartResponse(CartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCartResponse(ContextCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class OnlineShoppingServiceUserResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserResponse(UserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserResponse(ContextUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class OnlineShoppingServiceOrderResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendOrderResponse(OrderResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextOrderResponse(ContextOrderResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextProductList record {|
    ProductList content;
    map<string|string[]> headers;
|};

public type ContextUserResponse record {|
    UserResponse content;
    map<string|string[]> headers;
|};

public type ContextProductUpdate record {|
    ProductUpdate content;
    map<string|string[]> headers;
|};

public type ContextEmpty record {|
    Empty content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextOrderRequest record {|
    OrderRequest content;
    map<string|string[]> headers;
|};

public type ContextCartRequest record {|
    CartRequest content;
    map<string|string[]> headers;
|};

public type ContextProduct record {|
    Product content;
    map<string|string[]> headers;
|};

public type ContextProductResponse record {|
    ProductResponse content;
    map<string|string[]> headers;
|};

public type ContextProductId record {|
    ProductId content;
    map<string|string[]> headers;
|};

public type ContextOrderResponse record {|
    OrderResponse content;
    map<string|string[]> headers;
|};

public type ContextCartResponse record {|
    CartResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type ProductList record {|
    Product[] products = [];
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type UserResponse record {|
    string message = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type ProductUpdate record {|
    string sku = "";
    Product product = {};
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type Empty record {|
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string role = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type OrderRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type CartRequest record {|
    string user_id = "";
    string sku = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type Product record {|
    string name = "";
    string description = "";
    float price = 0.0;
    int stock_quantity = 0;
    string sku = "";
    string status = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type ProductResponse record {|
    string message = "";
    Product product = {};
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type ProductId record {|
    string sku = "";
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type OrderResponse record {|
    string message = "";
    Product[] products = [];
|};

@protobuf:Descriptor {value: SERVICE_INTERFACE_DESC}
public type CartResponse record {|
    string message = "";
|};

