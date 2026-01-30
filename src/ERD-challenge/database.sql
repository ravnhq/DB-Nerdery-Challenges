-- USER DATA

CREATE TYPE role_enum AS ENUM ('MANAGER', 'CLIENT', 'WAREHOUSE', 'SHIPPING');
CREATE TYPE shopping_cart_status_enum AS ENUM ('ACTIVE', 'DELETED', 'PROCESSED');
CREATE TYPE email_status_enum AS ENUM ('sent', 'not_sent');
CREATE TYPE person_document_type_enum AS ENUM ('PERSON', 'BUSINESS');
CREATE TYPE email_type_enum AS ENUM ('password_recovery', 'product_liked_alert');

CREATE TABLE IF NOT EXISTS role (
    id SERIAL PRIMARY KEY,
    name role_enum NOT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS person (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES sys_user(id) ON DELETE SET NULL,
    role_id INT REFERENCES role(id) ON DELETE RESTRICT,

    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),

    document VARCHAR(20)
    document_type
    
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sys_user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated_password TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_refresh_token (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES sys_user(id) ON DELETE CASCADE,

    refresh_token VARCHAR(255) UNIQUE NOT NULL,
    token_expiry TIMESTAMP NOT NULL,
    device_info JSON,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PRODUCT DATA

CREATE TABLE IF NOT EXISTS category (
    id SERIAL PRIMARY KEY,
    created_by INT REFERENCES sys_user(id) ON DELETE SET NULL,
    
    name VARCHAR(100) NOT NULL,
    description TEXT,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_category (
    product_id INT REFERENCES product(id) ON DELETE CASCADE,
    category_id INT REFERENCES category(id) ON DELETE CASCADE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, category_id)
)

CREATE TABLE IF NOT EXISTS product (
    id SERIAL PRIMARY KEY,
    created_by INT REFERENCES sys_user(id) ON DELETE SET NULL,

    name VARCHAR(500) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP DEFAULT NULL -- "Hard delete" flag
);

CREATE TABLE IF NOT EXISTS tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_tag (
    product_id INT REFERENCES product(id) ON DELETE CASCADE,
    tag_id INT REFERENCES tag(id) ON DELETE CASCADE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, tag_id)
);


CREATE TABLE IF NOT EXISTS product_changes_log (
    product_id INT REFERENCES product(id) ON DELETE CASCADE,
    change_description TEXT NOT NULL,

    changed_by INT REFERENCES sys_user(id) ON DELETE SET NULL,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, changed_at)
);

CREATE TABLE IF NOT EXISTS product_image (
    id SERIAL PRIMARY KEY,
    product_id INT REFERENCES product(id) ON DELETE CASCADE,
    created_by INT REFERENCES sys_user(id) ON DELETE SET NULL,

    image_url TEXT NOT NULL,
    is_primary_image BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS warehouse (
    id SERIAL PRIMARY KEY,
    created_by INT REFERENCES sys_user(id) ON DELETE SET NULL,

    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),

    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_stock (
    product_id INT REFERENCES product(id) ON DELETE CASCADE,
    warehouse_id INT REFERENCES warehouse(id) ON DELETE CASCADE,

    quantity INT NOT NULL CHECK (quantity >= 0),

    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id, warehouse_id)
);


-- CLIENT DATA

CREATE TABLE IF NOT EXISTS client_address (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES person(id) ON DELETE CASCADE,

    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'Peru',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ORDER DATA

CREATE TABLE IF NOT EXISTS shopping_cart (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES person(id) ON DELETE CASCADE,

    status shopping_cart_status_enum NOT NULL DEFAULT 'ACTIVE',
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS shopping_cart_details (
    id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES shopping_cart(id) ON DELETE CASCADE,
    product_id INT REFERENCES product(id) ON DELETE CASCADE,

    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    total DECIMAL(10, 2) GENERATED ALWAYS AS (price * quantity) STORED,

    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product_liked (
    user_id INT REFERENCES sys_user(id) ON DELETE CASCADE,
    product_id INT REFERENCES product(id) ON DELETE CASCADE,

    has_been_notified BOOLEAN DEFAULT FALSE,

    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id)
);

CREATE TABLE IF NOT EXISTS sale_order (
    id SERIAL PRIMARY KEY,
    client_id INT REFERENCES person(id) ON DELETE CASCADE,
    shopping_cart_id INT REFERENCES shopping_cart(id) ON DELETE SET NULL,
    warehouse_id INT REFERENCES warehouse(id) ON DELETE SET NULL,
    
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS order_bill (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sale_order(id) ON DELETE CASCADE NOT NULL,

    document_type document_type_enum NOT NULL,
    document_number VARCHAR(100) UNIQUE NOT NULL,
    tax_percent INT NOT NULL DEFAULT 18,
    total_amount DECIMAL(10, 2) NOT NULL,
    delivery_fee DECIMAL(10, 2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10, 2) NOT NULL GENERATED ALWAYS AS ( (total_amount + delivery_fee) - ((total_amount + delivery_fee) / 1.18) ) STORED,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_details (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sale_order(id) ON DELETE CASCADE,
    product_id INT REFERENCES product(id) ON DELETE CASCADE,

    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    tax_percent INT NOT NULL DEFAULT 18,
    total_amount DECIMAL(10, 2) GENERATED ALWAYS AS (price * quantity) STORED,
    tax_amount DECIMAL(10, 2) NOT NULL GENERATED ALWAYS AS ( (price * quantity) - ((price * quantity) / 1.18)) STORED
);

CREATE TABLE IF NOT EXISTS stripe_payment (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sale_order(id) ON DELETE CASCADE,
    
    stripe_payment_id VARCHAR(255) UNIQUE NOT NULL,
    client_secret_key VARCHAR(255) NOT NULL,
    
    payment_method VARCHAR(100) NOT NULL,
    payment_method_types JSON NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    payment_status VARCHAR(50) NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stripe_payment_event_log (
    id SERIAL PRIMARY KEY,
    payment_id INT REFERENCES stripe_payment(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL,
    status VARCHAR(50),
    event_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS carrier (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_info TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS delivery_status (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    step_order INT UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS delivery_tracking (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES sale_order(id) ON DELETE CASCADE,
    address_id INT REFERENCES client_address(id) ON DELETE SET NULL,
    carrier_id INT REFERENCES carrier(id) ON DELETE SET NULL,
    assigned_to INT REFERENCES sys_user(id) ON DELETE SET NULL,
    status_id  INT REFERENCES delivery_status(id) ON DELETE SET NULL,

    tracking_number VARCHAR(100) UNIQUE NOT NULL,
    estimated_delivery_date TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_tracking_log (
    id SERIAL PRIMARY KEY,
    delivery_tracking_id INT REFERENCES delivery_tracking(id) ON DELETE CASCADE,
    previous_status_id INT REFERENCES delivery_status(id) ON DELETE SET NULL,
    new_status_id INT REFERENCES delivery_status(id) ON DELETE SET NULL,
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Table for emails sent when liked product has 3 remaining stock
-- And for the password recovery emails

CREATE TABLE IF NOT EXISTS email_log (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES sys_user(id) ON DELETE CASCADE,

    recipient_email VARCHAR(100) NOT NULL,
    cc VARCHAR(100),
    bcc VARCHAR(100),
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    status email_status_enum NOT NULL,
    email_type email_type_enum NOT NULL,

    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS password_recovery_token (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES sys_user(id) ON DELETE CASCADE,

    recovery_token VARCHAR(255) UNIQUE NOT NULL,
    token_expiry TIMESTAMP NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- We can later add product variants and better audit logging 

-- INDEXES
CREATE INDEX idx_active_order_client ON sale_order(is_active, client_id);
CREATE INDEX idx_document_type_order_bill ON order_bill(document_type, is_active);
CREATE INDEX idx_document_number_order_bill ON order_bill(order_id, document_number);
CREATE INDEX idx_carrier_delivery_tracking ON delivery_tracking(carrier_id, status_id);
CREATE INDEX idx_status_delivery_tracking ON delivery_tracking(status_id);


-- TRIGGERS

-- Create a register of product_stock for all warehouses when a new product is added
CREATE OR REPLACE FUNCTION create_warehouse_stock_for_new_product()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO product_stock (product_id, warehouse_id, quantity, last_updated)
    SELECT NEW.id, w.id, 0, CURRENT_TIMESTAMP
    FROM warehouse w;
    RETURN NEW;
END;
$$

CREATE TRIGGER trigger_create_warehouse_stock
AFTER INSERT 
ON product
FOR EACH ROW
EXECUTE PROCEDURE create_warehouse_stock_for_new_product();



-- Create a register of product_stock for all products when a new warehouse is added 
CREATE OR REPLACE FUNCTION create_warehouse_stock_for_new_warehouse()
    RETURNS TRIGGER 
    LANGUAGE PLPGSQL
AS $$
BEGIN
    INSERT INTO product_stock (product_id, warehouse_id, quantity, last_updated)
    SELECT p.id, NEW.id, 0, CURRENT_TIMESTAMP
    FROM product p;
    RETURN NEW;
END;
$$

CREATE TRIGGER trigger_create_product_stock
AFTER INSERT 
ON warehouse
FOR EACH ROW
EXECUTE PROCEDURE create_warehouse_stock_for_new_warehouse();



