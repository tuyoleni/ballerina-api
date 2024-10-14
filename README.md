# Distributed Systems and Applications - Assignment 1

## Group Members
- Simeon Tuyoleni (222129298)
- Lorraine Mwoyounotsva (222119578)
- Simeon T. Shileka (218053444)
- Raimiaeo C. Dausab (214063151)
- Erastus Shindinge (222044438)
- Shapopi Phellep (20088934)

## Assignment Overview

### Question 1: Restful API for Programme Development Unit

The goal of this task is to develop a **Restful API** for managing programme development and review workflows within the Programme Development Unit at the Namibia University of Science and Technology (NUST). 

#### Key Features:
1. **Add a new programme**.
2. **Retrieve a list of all programmes** within the Programme Development Unit.
3. **Update programme information** using the programme code.
4. **Retrieve details** of a specific programme by programme code.
5. **Delete a programme** using its programme code.
6. **Retrieve all programmes due for review**.
7. **Retrieve programmes by faculty**.

Each programme includes attributes like the programme code, NQF level, faculty, department name, and associated courses. The API is built using the **Ballerina Language**, and **MySQL** is used as the database to store programme information.

#### Database:
- We used **MySQL** for persistent data storage.
- Programmes and their associated courses are stored in relational tables.
- All CRUD operations interact with the MySQL database to retrieve and modify data.

#### Deliverables:
- RESTful API that performs CRUD operations and manages programme review schedules.
- **Client Implementation** in Ballerina to interact with the API.

### Question 2: Remote Invocation using gRPC for an Online Shopping System

In this task, we designed and implemented an **Online Shopping System** using gRPC with two types of users: **Customers** and **Admins**. 

#### Admin Features:
- **add_product**: Add a new product with details like name, description, price, stock, and status.
- **update_product**: Update product information.
- **remove_product**: Remove a product from the inventory.
- **list_orders**: List all placed orders.

#### Customer Features:
- **list_available_products**: View all available products.
- **search_product**: Search for a product by its SKU.
- **add_to_cart**: Add products to a cart by providing user ID and SKU.
- **place_order**: Place an order for the products in the cart.

#### Deliverables:
- Protocol Buffers contract for defining gRPC remote methods.
- **gRPC Server** and **Client** implementation in Ballerina.

## Project Structure
The project is divided into two main parts:
1. **RESTful API for Programme Development**:
   - API endpoints and client implementation.
   - MySQL is used as the backend database for storing programme and course data.
   
2. **gRPC Online Shopping System**:
   - Protocol Buffer definitions.
   - gRPC Server and Client logic.

## Setup Instructions

### Prerequisites:
- **Ballerina Language** installed on your system.
- **MySQL** for the database setup.
- **Git** for version control.

### Steps:
1. Clone the repository:
   ```bash
   https://github.com/tuyoleni/ballerina-api.git
   cd your-repository
