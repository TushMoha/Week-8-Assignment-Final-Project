
CREATE DATABASE ecommercedb;
USE ecommercedb;

/* ============================================================
   Table: customers
   Stores customer information.
   - customer_id: primary key (auto-increment)
   - email: unique (no duplicate customer emails)
============================================================ */
CREATE TABLE customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(60) NOT NULL,
  last_name VARCHAR(60) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  phone VARCHAR(30),
  address TEXT,
  city VARCHAR(60),
  country VARCHAR(60),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* ============================================================
   Table: products
   Stores product catalog.
   - product_id: primary key
   - sku: unique stock keeping unit
   - buy_price: price supplier charges
   - sell_price: price we sell to customer
   - quantity_in_stock: current inventory level
============================================================ */
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(50) NOT NULL UNIQUE,
  product_name VARCHAR(150) NOT NULL,
  description TEXT,
  buy_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  sell_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  quantity_in_stock INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* ============================================================
   Table: categories
   Product categories for grouping/catalog
============================================================ */
CREATE TABLE IF NOT EXISTS categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT
);

/* ============================================================
   Table: product_categories (many-to-many join table)
   Links products and categories (a product can have many categories
   and a category can contain many products)
============================================================ */
CREATE TABLE product_categories (
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE ON UPDATE CASCADE
);

/* ============================================================
   Table: orders
   One-to-many relationship: one customer -> many orders
   - total_amount can be stored or calculated at application time;
     stored here to simplify reporting (ensure application keeps it correct)
============================================================ */
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  shipped_date DATETIME NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'Pending', -- e.g., Pending, Processing, Shipped, Cancelled
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_order_customer (customer_id),
  INDEX idx_order_date (order_date)
);

/* ============================================================
   Table: order_items
   Stores line items for an order (one-to-many: order -> items)
   - price_each: copy of product sell_price at time of order
   - quantity: number of units ordered
   - total_price: quantity * price_each (stored for convenience; can be computed)
============================================================ */
CREATE TABLE order_items (
  order_item_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  price_each DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_order_items_order (order_id),
  INDEX idx_order_items_product (product_id)
);

/* ============================================================
   Optional: audit table for product stock movements (good practice)
   Shows adjustments to inventory (purchase, sale, manual adjust)
============================================================ */
CREATE TABLE IF NOT EXISTS inventory_movements (
  movement_id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  change_amount INT NOT NULL, -- positive or negative
  reason VARCHAR(100),        -- 'sale', 'purchase', 'adjustment', etc.
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);






