# Inventory Management System

A comprehensive MySQL database system for tracking inventory, managing suppliers, processing orders, and maintaining accurate stock levels for small to medium-sized businesses.

## 📋 Project Overview

This project implements a fully-featured relational database for inventory management using MySQL. The system is designed to help businesses efficiently track products across multiple warehouses, manage relationships with suppliers, process customer orders, and maintain optimal inventory levels.

![Inventory Management System](https://github.com/user-attachments/assets/df05f0f2-5598-4e29-ac29-a1bb0a0970be)

## ✨ Features

- **Multi-warehouse Inventory Tracking**
  - Monitor stock levels across different physical locations
  - Set minimum and maximum stock thresholds for automatic reordering
  - Track full history of inventory movements

- **Supplier Management**
  - Store comprehensive supplier information
  - Associate suppliers with specific warehouses
  - Track supplier performance and order history

- **Customer Order Processing**
  - Manage customer information and order history
  - Automatic inventory allocation from optimal warehouses
  - Order status tracking from creation to delivery

- **Purchase Order Management**
  - Generate purchase orders automatically for low stock
  - Track received items with expected vs. actual delivery
  - Update inventory levels when items are received

- **Comprehensive Reporting**
  - Pre-built views for common reporting needs
  - Low stock alerts with supplier contact information
  - Inventory valuation by category, supplier, or warehouse

- **Business Process Automation**
  - Triggers for inventory updates when orders are shipped
  - Automatic inventory transfers between warehouses
  - Historical tracking of product price changes

## 📊 Database Structure

The database includes the following main entities:

- **Products**: Core product information with pricing
- **Categories**: Product categorization and hierarchy
- **Inventory**: Current stock levels by product and location
- **Warehouses**: Physical locations for inventory storage
- **Suppliers**: Vendor information and contact details
- **Purchase Orders**: Orders to suppliers with line items
- **Customers**: Customer information and contact details
- **Orders**: Customer orders with line items
- **Inventory Transactions**: Complete audit trail of all inventory movements

## 🛠️ Technical Components

- **Tables**: 13 fully normalized tables with proper relationships
- **Views**: 4 pre-built views for common reporting needs
- **Stored Procedures**: 5 procedures for common business operations
- **Triggers**: 3 triggers for maintaining data integrity and automation
- **Indexes**: Strategic indexes for optimal query performance
- **Sample Data**: Included for immediate testing and demonstration

## 📥 Setup Instructions

### Prerequisites

- MySQL Server 8.0 or higher
- MySQL Client or MySQL Workbench

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/inventory-management-system.git
   cd inventory-management-system
   ```

2. Import the database:
   ```bash
   mysql -u username -p < inventory_management_db.sql
   ```

   Alternatively, using MySQL Workbench:
   - Open MySQL Workbench
   - Connect to your MySQL Server
   - Go to Server > Data Import
   - Choose "Import from Self-Contained File" and select the SQL file
   - Start Import

3. Verify installation:
   ```sql
   USE inventory_management;
   SHOW TABLES;
   SELECT * FROM vw_product_inventory_summary;
   ```

## 🔍 Usage Examples

### View Low Stock Products

```sql
SELECT * FROM vw_low_stock_products;
```

### Generate Inventory Report by Category

```sql
CALL sp_generate_inventory_report(1, NULL);  -- Category ID 1, All Warehouses
```

### Process a Customer Order

```sql
CALL sp_process_order(1);  -- Order ID 1
```

### Transfer Inventory Between Warehouses

```sql
CALL sp_transfer_inventory(1, 1, 2, 10, 'System');  -- Product 1, from Warehouse 1 to 2, Qty 10
```

### Reorder Low Stock Items

```sql
CALL sp_reorder_low_stock_items();
```

## 🔄 Entity Relationship Diagram

```
Categories ──┐
             │
Suppliers ───┼── Products ─── Inventory
     │       │       │
     │       │       │
     v       │       v
Warehouses<──┘   Purchase Orders   Orders
     ^                │               │
     │                v               v
     └───── Purchase Order Items   Order Items
                                      │
                                      v
                                  Customers
```

## 📊 Business Intelligence

The system includes several pre-built views for business intelligence:

- **vw_low_stock_products**: Products that need to be reordered
- **vw_product_inventory_summary**: Overall product inventory status and value
- **vw_purchase_order_summary**: Summary of all purchase orders with status
- **vw_order_summary**: Summary of all customer orders with status

## 🔒 Data Integrity

The database employs several mechanisms to ensure data integrity:

- **Foreign Key Constraints**: Prevent orphaned records
- **Check Constraints**: Ensure data validity (e.g., quantities must be positive)
- **Triggers**: Automatically update related records when data changes
- **Stored Procedures**: Encapsulate complex operations to ensure consistency

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📧 Contact

For any questions or suggestions, please reach out to:
- Email: jamesmuritu254@gmail.com
- GitHub: Sir James Muritu (https://github.com/sir-jamesmuritu)

---

© 2025 James_Tech
