-- -----------------------------------------------------
-- Schema inventory_management
-- -----------------------------------------------------
DROP DATABASE IF EXISTS inventory_management;
CREATE DATABASE inventory_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inventory_management;

-- -----------------------------------------------------
-- Table `categories`
-- -----------------------------------------------------
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `suppliers`
-- -----------------------------------------------------
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    website VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_name (company_name)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `products`
-- -----------------------------------------------------
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT,
    supplier_id INT,
    cost_price DECIMAL(10,2) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    min_stock_level INT DEFAULT 10,
    max_stock_level INT DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    INDEX idx_product_name (name),
    INDEX idx_product_sku (sku)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `inventory`
-- -----------------------------------------------------
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    location VARCHAR(100),
    last_stock_check DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE KEY unique_product_location (product_id, location)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `warehouses`
-- -----------------------------------------------------
CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    manager_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `suppliers_warehouses` (M:M relationship)
-- -----------------------------------------------------
CREATE TABLE suppliers_warehouses (
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    PRIMARY KEY (supplier_id, warehouse_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `purchase_orders`
-- -----------------------------------------------------
CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(50) NOT NULL UNIQUE,
    supplier_id INT,
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    status ENUM('pending', 'ordered', 'partial', 'complete', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL,
    INDEX idx_po_number (po_number),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `purchase_order_items`
-- -----------------------------------------------------
CREATE TABLE purchase_order_items (
    po_item_id INT AUTO_INCREMENT PRIMARY KEY,
    po_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    received_quantity INT DEFAULT 0,
    warehouse_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(po_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `customers`
-- -----------------------------------------------------
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_name (last_name, first_name)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `orders`
-- -----------------------------------------------------
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    customer_id INT,
    order_date DATE NOT NULL,
    shipping_date DATE,
    delivery_date DATE,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    payment_status ENUM('unpaid', 'partial', 'paid') DEFAULT 'unpaid',
    shipping_address TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL,
    INDEX idx_order_number (order_number),
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `order_items`
-- -----------------------------------------------------
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    warehouse_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `inventory_transactions`
-- -----------------------------------------------------
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT,
    quantity INT NOT NULL, -- positive for additions, negative for removals
    transaction_type ENUM('purchase', 'sale', 'adjustment', 'transfer', 'return') NOT NULL,
    reference_id INT, -- could be po_id, order_id, etc.
    reference_type VARCHAR(50), -- 'purchase_order', 'sale_order', etc.
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL,
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_transaction_type (transaction_type)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Table `product_price_history`
-- -----------------------------------------------------
CREATE TABLE product_price_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    old_cost_price DECIMAL(10,2) NOT NULL,
    new_cost_price DECIMAL(10,2) NOT NULL,
    old_selling_price DECIMAL(10,2) NOT NULL,
    new_selling_price DECIMAL(10,2) NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100),
    reason TEXT,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- Triggers
-- -----------------------------------------------------

-- Trigger to update inventory when purchase order items are received
DELIMITER $$
CREATE TRIGGER after_po_item_update 
AFTER UPDATE ON purchase_order_items 
FOR EACH ROW
BEGIN
    DECLARE qty_difference INT;
    
    IF NEW.received_quantity > OLD.received_quantity THEN
        SET qty_difference = NEW.received_quantity - OLD.received_quantity;
        
        -- Insert a record in inventory_transactions
        INSERT INTO inventory_transactions 
            (product_id, warehouse_id, quantity, transaction_type, reference_id, reference_type, notes)
        VALUES
            (NEW.product_id, NEW.warehouse_id, qty_difference, 'purchase', NEW.po_id, 'purchase_order', 'Purchase order item received');
            
        -- Update inventory quantity
        INSERT INTO inventory 
            (product_id, quantity, location, last_stock_check)
        VALUES
            (NEW.product_id, qty_difference, (SELECT name FROM warehouses WHERE warehouse_id = NEW.warehouse_id), CURDATE())
        ON DUPLICATE KEY UPDATE
            quantity = quantity + qty_difference,
            last_stock_check = CURDATE();
    END IF;
END$$

-- Trigger to update inventory when order items are shipped
CREATE TRIGGER after_order_status_change
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'shipped' AND OLD.status != 'shipped' THEN
        -- For each item in the order, reduce inventory
        INSERT INTO inventory_transactions 
            (product_id, warehouse_id, quantity, transaction_type, reference_id, reference_type, notes)
        SELECT 
            oi.product_id, 
            oi.warehouse_id,
            -oi.quantity, -- negative to reduce inventory
            'sale',
            NEW.order_id,
            'sale_order',
            'Order shipped'
        FROM 
            order_items oi
        WHERE 
            oi.order_id = NEW.order_id;
            
        -- Update inventory quantities
        UPDATE 
            inventory i
        JOIN 
            order_items oi ON i.product_id = oi.product_id 
                AND (i.location = (SELECT name FROM warehouses WHERE warehouse_id = oi.warehouse_id))
        SET 
            i.quantity = i.quantity - oi.quantity,
            i.last_stock_check = CURDATE()
        WHERE 
            oi.order_id = NEW.order_id;
    END IF;
END$$

-- Trigger to track product price changes
CREATE TRIGGER before_product_price_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.cost_price != OLD.cost_price OR NEW.selling_price != OLD.selling_price THEN
        INSERT INTO product_price_history
            (product_id, old_cost_price, new_cost_price, old_selling_price, new_selling_price)
        VALUES
            (OLD.product_id, OLD.cost_price, NEW.cost_price, OLD.selling_price, NEW.selling_price);
    END IF;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- Sample Data Insertion
-- -----------------------------------------------------

-- Insert sample categories
INSERT INTO categories (name, description) VALUES
('Electronics', 'Electronic devices and accessories'),
('Furniture', 'Home and office furniture'),
('Clothing', 'Apparel and fashion items'),
('Books', 'Books and publications'),
('Toys', 'Children toys and games');

-- Insert sample suppliers
INSERT INTO suppliers (company_name, contact_name, email, phone, address, city, state, postal_code, country) VALUES
('Tech Suppliers Inc.', 'John Smith', 'john@techsuppliers.com', '555-123-4567', '123 Tech St', 'Silicon Valley', 'CA', '94025', 'USA'),
('Furniture World', 'Maria Garcia', 'maria@furnitureworld.com', '555-234-5678', '456 Wood Ave', 'Grand Rapids', 'MI', '49503', 'USA'),
('Fashion Forward', 'Robert Lee', 'robert@fashionforward.com', '555-345-6789', '789 Style Blvd', 'New York', 'NY', '10001', 'USA');

-- Insert sample warehouses
INSERT INTO warehouses (name, address, city, state, postal_code, country, manager_name, phone) VALUES
('Main Warehouse', '1000 Storage Dr', 'Chicago', 'IL', '60007', 'USA', 'Michael Johnson', '555-111-2222'),
('East Coast Hub', '2000 Port Way', 'Newark', 'NJ', '07101', 'USA', 'Sarah Williams', '555-333-4444'),
('West Coast Hub', '3000 Bay Dr', 'Oakland', 'CA', '94607', 'USA', 'David Chen', '555-555-6666');

-- Connect suppliers to warehouses
INSERT INTO suppliers_warehouses (supplier_id, warehouse_id) VALUES
(1, 1), (1, 3), -- Tech Suppliers serves Main and West Coast
(2, 1), (2, 2), -- Furniture World serves Main and East Coast
(3, 1), (3, 2), (3, 3); -- Fashion Forward serves all warehouses

-- Insert sample products
INSERT INTO products (sku, name, description, category_id, supplier_id, cost_price, selling_price) VALUES
('ELEC-001', 'Smartphone X1', 'Latest model smartphone with 6.5" display', 1, 1, 300.00, 699.99),
('ELEC-002', 'Laptop Pro', '15" professional laptop with SSD', 1, 1, 600.00, 1299.99),
('FURN-001', 'Office Desk', 'Wooden office desk with drawers', 2, 2, 150.00, 349.99),
('FURN-002', 'Ergonomic Chair', 'Adjustable office chair', 2, 2, 100.00, 249.99),
('CLTH-001', 'T-Shirt Basic', 'Cotton t-shirt in various colors', 3, 3, 5.00, 19.99),
('BOOK-001', 'SQL for Beginners', 'Learn SQL database management', 4, 1, 10.00, 29.99);

-- Insert initial inventory
INSERT INTO inventory (product_id, quantity, location, last_stock_check) VALUES
(1, 50, 'Main Warehouse', CURDATE()),
(2, 30, 'Main Warehouse', CURDATE()),
(3, 20, 'Main Warehouse', CURDATE()),
(4, 25, 'Main Warehouse', CURDATE()),
(5, 100, 'Main Warehouse', CURDATE()),
(6, 40, 'Main Warehouse', CURDATE()),
(1, 25, 'East Coast Hub', CURDATE()),
(2, 15, 'East Coast Hub', CURDATE()),
(5, 50, 'East Coast Hub', CURDATE()),
(1, 25, 'West Coast Hub', CURDATE()),
(3, 15, 'West Coast Hub', CURDATE());

-- Insert sample customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, postal_code, country) VALUES
('Jane', 'Doe', 'jane.doe@email.com', '555-987-6543', '123 Main St', 'Anytown', 'CA', '91234', 'USA'),
('Bob', 'Johnson', 'bob.johnson@email.com', '555-876-5432', '456 Oak Ave', 'Somewhere', 'NY', '10987', 'USA'),
('Alice', 'Smith', 'alice.smith@email.com', '555-765-4321', '789 Pine Rd', 'Nowhere', 'TX', '75432', 'USA');

-- Insert sample purchase order
INSERT INTO purchase_orders (po_number, supplier_id, order_date, expected_delivery_date, status, total_amount, payment_status, created_by) VALUES
('PO-2025-001', 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'ordered', 18000.00, 'unpaid', 'System Admin');

-- Insert purchase order items
INSERT INTO purchase_order_items (po_id, product_id, quantity, unit_price, warehouse_id) VALUES
(1, 1, 20, 300.00, 1), -- 20 Smartphones to Main Warehouse
(1, 2, 15, 600.00, 1); -- 15 Laptops to Main Warehouse

-- Insert sample order
INSERT INTO orders (order_number, customer_id, order_date, status, total_amount, payment_status, shipping_address) VALUES
('ORD-2025-001', 1, CURDATE(), 'pending', 699.99, 'paid', '123 Main St, Anytown, CA 91234');

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, warehouse_id) VALUES
(1, 1, 1, 699.99, 1); -- 1 Smartphone from Main Warehouse

-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------

-- Low stock products view
CREATE VIEW vw_low_stock_products AS
SELECT 
    p.product_id,
    p.sku,
    p.name,
    c.name AS category,
    i.quantity,
    i.location,
    p.min_stock_level,
    p.supplier_id,
    s.company_name AS supplier_name,
    s.contact_name,
    s.email AS supplier_email,
    s.phone AS supplier_phone
FROM 
    products p
JOIN 
    inventory i ON p.product_id = i.product_id
LEFT JOIN 
    categories c ON p.category_id = c.category_id
LEFT JOIN 
    suppliers s ON p.supplier_id = s.supplier_id
WHERE 
    i.quantity <= p.min_stock_level;

-- Product inventory summary view
CREATE VIEW vw_product_inventory_summary AS
SELECT 
    p.product_id,
    p.sku,
    p.name,
    c.name AS category,
    SUM(i.quantity) AS total_quantity,
    COUNT(distinct i.location) AS warehouse_count,
    p.min_stock_level,
    p.max_stock_level,
    p.cost_price,
    p.selling_price,
    (SUM(i.quantity) * p.cost_price) AS inventory_value
FROM 
    products p
JOIN 
    inventory i ON p.product_id = i.product_id
LEFT JOIN 
    categories c ON p.category_id = c.category_id
GROUP BY 
    p.product_id, p.sku, p.name, c.name, p.min_stock_level, p.max_stock_level, p.cost_price, p.selling_price;

-- Purchase order summary view
CREATE VIEW vw_purchase_order_summary AS
SELECT 
    po.po_id,
    po.po_number,
    po.order_date,
    po.expected_delivery_date,
    po.actual_delivery_date,
    po.status,
    po.payment_status,
    s.company_name AS supplier_name,
    COUNT(poi.po_item_id) AS total_items,
    SUM(poi.quantity) AS total_quantity,
    SUM(poi.total_price) AS total_amount,
    SUM(poi.received_quantity) AS total_received,
    CASE 
        WHEN SUM(poi.quantity) = SUM(poi.received_quantity) THEN 'Complete'
        WHEN SUM(poi.received_quantity) > 0 THEN 'Partial'
        ELSE 'Not Received'
    END AS receipt_status
FROM 
    purchase_orders po
JOIN 
    suppliers s ON po.supplier_id = s.supplier_id
LEFT JOIN 
    purchase_order_items poi ON po.po_id = poi.po_id
GROUP BY 
    po.po_id, po.po_number, po.order_date, po.expected_delivery_date, 
    po.actual_delivery_date, po.status, po.payment_status, s.company_name;

-- Order summary view
CREATE VIEW vw_order_summary AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_date,
    o.shipping_date,
    o.delivery_date,
    o.status,
    o.payment_status,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email AS customer_email,
    COUNT(oi.order_item_id) AS total_items,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.total_price) AS subtotal,
    SUM(oi.discount_amount) AS total_discount,
    o.total_amount
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
LEFT JOIN 
    order_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.order_id, o.order_number, o.order_date, o.shipping_date, 
    o.delivery_date, o.status, o.payment_status, customer_name, c.email, o.total_amount;

-- -----------------------------------------------------
-- Stored Procedures
-- -----------------------------------------------------

-- Procedure to reorder low stock items
DELIMITER $$
CREATE PROCEDURE sp_reorder_low_stock_items()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id INT;
    DECLARE v_supplier_id INT;
    DECLARE v_quantity INT;
    DECLARE v_cost_price DECIMAL(10,2);
    DECLARE v_po_id INT;
    DECLARE v_po_number VARCHAR(50);
    
    -- Cursor for low stock products
    DECLARE cur CURSOR FOR 
        SELECT 
            p.product_id,
            p.supplier_id,
            (p.max_stock_level - COALESCE(SUM(i.quantity), 0)) AS reorder_quantity,
            p.cost_price
        FROM 
            products p
        LEFT JOIN 
            inventory i ON p.product_id = i.product_id
        GROUP BY 
            p.product_id, p.supplier_id, p.max_stock_level, p.cost_price
        HAVING 
            (p.max_stock_level - COALESCE(SUM(i.quantity), 0)) > 0
            AND p.is_active = TRUE;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Create a temporary table to group products by supplier
    CREATE TEMPORARY TABLE temp_reorders (
        supplier_id INT,
        product_id INT,
        quantity INT,
        unit_price DECIMAL(10,2)
    );
    
    -- Collect all products to reorder
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_supplier_id, v_quantity, v_cost_price;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Add product to temp table
        INSERT INTO temp_reorders (supplier_id, product_id, quantity, unit_price)
        VALUES (v_supplier_id, v_product_id, v_quantity, v_cost_price);
    END LOOP;
    
    CLOSE cur;
    
    -- Create purchase orders by supplier
    SELECT DISTINCT supplier_id FROM temp_reorders;
    SET done = FALSE;
    
    -- Cursor for suppliers
    DECLARE sup_cur CURSOR FOR 
        SELECT DISTINCT supplier_id FROM temp_reorders;
    
    OPEN sup_cur;
    
    sup_loop: LOOP
        FETCH sup_cur INTO v_supplier_id;
        IF done THEN
            LEAVE sup_loop;
        END IF;
        
        -- Generate PO number
        SET v_po_number = CONCAT('PO-', DATE_FORMAT(NOW(), '%Y-%m'), '-', LPAD((SELECT COUNT(*) + 1 FROM purchase_orders), 3, '0'));
        
        -- Create purchase order
        INSERT INTO purchase_orders (po_number, supplier_id, order_date, expected_delivery_date, status, created_by)
        VALUES (v_po_number, v_supplier_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'pending', 'System');
        
        SET v_po_id = LAST_INSERT_ID();
        
        -- Add items to purchase order
        INSERT INTO purchase_order_items (po_id, product_id, quantity, unit_price, warehouse_id)
        SELECT 
            v_po_id,
            product_id,
            quantity,
            unit_price,
            (SELECT warehouse_id FROM warehouses WHERE name = 'Main Warehouse' LIMIT 1)
        FROM 
            temp_reorders
        WHERE 
            supplier_id = v_supplier_id;
            
        -- Update total amount on purchase order
        UPDATE purchase_orders
        SET total_amount = (
            SELECT SUM(quantity * unit_price) 
            FROM purchase_order_items 
            WHERE po_id = v_po_id
        )
        WHERE po_id = v_po_id;
    END LOOP;
    
    CLOSE sup_cur;
    
    -- Clean up
    DROP TEMPORARY TABLE IF EXISTS temp_reorders;
END$$

-- Procedure to fulfill an order from inventory
CREATE PROCEDURE sp_process_order(IN p_order_id INT)
BEGIN
    DECLARE v_success BOOLEAN DEFAULT TRUE;
    DECLARE v_error_message TEXT;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Check if all items are available in inventory
    SELECT 
        NOT EXISTS (
            SELECT 1
            FROM order_items oi
            LEFT JOIN (
                SELECT product_id, SUM(quantity) as total_quantity
                FROM inventory
                GROUP BY product_id
            ) i ON oi.product_id = i.product_id
            WHERE oi.order_id = p_order_id
            AND (i.total_quantity IS NULL OR i.total_quantity < oi.quantity)
        ) INTO v_success;
    
    IF v_success THEN
        -- Assign warehouses to order items based on availability
        UPDATE order_items oi
        JOIN (
            SELECT 
                oi.order_item_id,
                (
                    SELECT warehouse_id 
                    FROM warehouses w
                    JOIN inventory i ON w.name = i.location
                    WHERE i.product_id = oi.product_id
                    AND i.quantity >= oi.quantity
                    ORDER BY i.quantity DESC
                    LIMIT 1
                ) as best_warehouse_id
            FROM order_items oi
            WHERE oi.order_id = p_order_id
        ) wh ON oi.order_item_id = wh.order_item_id
        SET oi.warehouse_id = wh.best_warehouse_id;
        
        -- Update order status
        UPDATE orders
        SET status = 'processing'
        WHERE order_id = p_order_id;
        
        -- Commit transaction
        COMMIT;
    ELSE
        -- Get error details
        SELECT GROUP_CONCAT(
            CONCAT(p.name, ': Required - ', oi.quantity, ', Available - ', COALESCE(i.total_quantity, 0))
            SEPARATOR '; '
        ) INTO v_error_message
        FROM order_items oi
        JOIN products p ON oi.product_id = p.product_id
        LEFT JOIN (
            SELECT product_id, SUM(quantity) as total_quantity
            FROM inventory
            GROUP BY product_id
        ) i ON oi.product_id = i.product_id
        WHERE oi.order_id = p_order_id
        AND (i.total_quantity IS NULL OR i.total_quantity < oi.quantity);
        
        -- Rollback transaction
        ROLLBACK;
        
        -- Return error
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = v_error_message;
    END IF;
END$$

-- Procedure to perform inventory adjustment
CREATE PROCEDURE sp_adjust_inventory(
    IN p_product_id INT,
    IN p_location VARCHAR(100),
    IN p_quantity INT,
    IN p_reason TEXT,
    IN p_created_by VARCHAR(100)
)
BEGIN
    DECLARE v_warehouse_id INT;
    
    -- Get warehouse ID from location name
    SELECT warehouse_id INTO v_warehouse_id
    FROM warehouses
    WHERE name = p_location
    LIMIT 1;
    
    -- Record the adjustment transaction
    INSERT INTO inventory_transactions
        (product_id, warehouse_id, quantity, transaction_type, reference_type, notes, created_by)
    VALUES
        (p_product_id, v_warehouse_id, p_quantity, 'adjustment', 'manual', p_reason, p_created_by);
        
    -- Update inventory
    INSERT INTO inventory
        (product_id, quantity, location, last_stock_check)
    VALUES
        (p_product_id, p_quantity, p_location, CURDATE())
    ON DUPLICATE KEY UPDATE
        quantity = quantity + p_quantity,
        last_stock_check = CURDATE();
END$

-- Procedure to generate inventory reports
CREATE PROCEDURE sp_generate_inventory_report(
    IN p_category_id INT,
    IN p_warehouse_id INT
)
BEGIN
    SELECT 
        p.sku,
        p.name,
        c.name AS category,
        i.quantity,
        i.location,
        p.cost_price,
        p.selling_price,
        (i.quantity * p.cost_price) AS inventory_value,
        s.company_name AS supplier
    FROM 
        inventory i
    JOIN 
        products p ON i.product_id = p.product_id
    LEFT JOIN 
        categories c ON p.category_id = c.category_id
    LEFT JOIN 
        suppliers s ON p.supplier_id = s.supplier_id
    LEFT JOIN 
        warehouses w ON i.location = w.name
    WHERE 
        (p_category_id IS NULL OR p.category_id = p_category_id)
        AND
        (p_warehouse_id IS NULL OR w.warehouse_id = p_warehouse_id)
    ORDER BY 
        c.name, p.name, i.location;
END$

-- Procedure to transfer inventory between warehouses
CREATE PROCEDURE sp_transfer_inventory(
    IN p_product_id INT,
    IN p_source_warehouse_id INT,
    IN p_destination_warehouse_id INT,
    IN p_quantity INT,
    IN p_created_by VARCHAR(100)
)
BEGIN
    DECLARE v_source_location VARCHAR(100);
    DECLARE v_destination_location VARCHAR(100);
    DECLARE v_available_quantity INT;
    
    -- Get warehouse names
    SELECT name INTO v_source_location
    FROM warehouses
    WHERE warehouse_id = p_source_warehouse_id;
    
    SELECT name INTO v_destination_location
    FROM warehouses
    WHERE warehouse_id = p_destination_warehouse_id;
    
    -- Check if sufficient inventory exists at source
    SELECT quantity INTO v_available_quantity
    FROM inventory
    WHERE product_id = p_product_id AND location = v_source_location;
    
    IF v_available_quantity >= p_quantity THEN
        -- Start transaction
        START TRANSACTION;
        
        -- Reduce inventory at source
        UPDATE inventory
        SET quantity = quantity - p_quantity,
            last_stock_check = CURDATE()
        WHERE product_id = p_product_id AND location = v_source_location;
        
        -- Add inventory at destination
        INSERT INTO inventory
            (product_id, quantity, location, last_stock_check)
        VALUES
            (p_product_id, p_quantity, v_destination_location, CURDATE())
        ON DUPLICATE KEY UPDATE
            quantity = quantity + p_quantity,
            last_stock_check = CURDATE();
            
        -- Record transactions
        INSERT INTO inventory_transactions
            (product_id, warehouse_id, quantity, transaction_type, reference_type, notes, created_by)
        VALUES
            (p_product_id, p_source_warehouse_id, -p_quantity, 'transfer', 'outbound', 
             CONCAT('Transfer to ', v_destination_location), p_created_by);
             
        INSERT INTO inventory_transactions
            (product_id, warehouse_id, quantity, transaction_type, reference_type, notes, created_by)
        VALUES
            (p_product_id, p_destination_warehouse_id, p_quantity, 'transfer', 'inbound', 
             CONCAT('Transfer from ', v_source_location), p_created_by);
             
        -- Commit transaction
        COMMIT;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Insufficient inventory at source location';
    END IF;
END$

DELIMITER ;

-- -----------------------------------------------------
-- Indexes for Performance Optimization
-- -----------------------------------------------------
CREATE INDEX idx_inventory_product_location ON inventory(product_id, location);
CREATE INDEX idx_transaction_product_date ON inventory_transactions(product_id, transaction_date);
CREATE INDEX idx_po_supplier_date ON purchase_orders(supplier_id, order_date);
CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_product_category ON products(category_id);
CREATE INDEX idx_product_supplier ON products(supplier_id);
