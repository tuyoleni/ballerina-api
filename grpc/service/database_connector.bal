import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client db = check new (
    host = "database.cdemes626wkl.eu-north-1.rds.amazonaws.com",
    user = "admin",
    password = "hofcuv-teWtu6-ferzeb",
    port = 3306,
    database = "OnlineShoppingService"
);
