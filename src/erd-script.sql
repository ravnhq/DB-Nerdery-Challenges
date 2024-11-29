CREATE SCHEMA IF NOT EXISTS pet_haven_schema;

SET
  SEARCH_PATH TO pet_haven_schema;

-- Role Table
CREATE TABLE roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL
);

-- Insert default roles
INSERT INTO
  roles (name)
VALUES
  ('Admin'),
  ('Manager'),
  ('Client');

-- Users Table
CREATE TABLE users (
  id BIGINT PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role_id INT NOT NULL,
  avatar_url VARCHAR(255),
  is_enabled BOOLEAN NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles (id)
);

-- Auth Tokens Table
CREATE TABLE auth_tokens (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  token TEXT NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Activation Code Table
CREATE TABLE activation_code (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  key VARCHAR(255),
  expiration_date TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Categories Table
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(255),
  last_modified_by VARCHAR(255)
);

-- Products Table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  public_id UUID DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  alias VARCHAR(255),
  description TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  category_id INT NOT NULL,
  stock INT NOT NULL,
  is_stock BOOLEAN DEFAULT TRUE,
  is_disabled BOOLEAN DEFAULT FALSE,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(255),
  last_modified_by VARCHAR(255),
  FOREIGN KEY (category_id) REFERENCES categories (id),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Product Images Table
CREATE TABLE product_images (
  id SERIAL PRIMARY KEY,
  product_id INT NOT NULL,
  image_url TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products (id)
);

CREATE TYPE ORDER_STATUS AS ENUM ('PENDING', 'COMPLETED', 'CANCELLED');

-- Shopping Cart Table
CREATE TABLE shopping_cart (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Cart Items Table
CREATE TABLE shopping_cart_items (
  id SERIAL PRIMARY KEY,
  cart_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  price_at_time DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (cart_id, product_id),
  FOREIGN KEY (cart_id) REFERENCES shopping_cart (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Orders Table
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  client_id INT NOT NULL,
  total_amount DECIMAL(10, 2) NOT NULL,
  status ORDER_STATUS NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES users (id)
);

-- Order Items Table
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Liked Products Table
CREATE TABLE liked_products (
  id SERIAL PRIMARY KEY,
  client_id INT NOT NULL,
  product_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES users (id),
  FOREIGN KEY (product_id) REFERENCES products (id)
);

-- Enum for payment status
CREATE TYPE PAYMENT_STATUS AS ENUM (
  'PENDING',
  'PAID',
  'FAILED',
  'REFUNDED',
  'CANCELED'
);

-- Enum for payment method
CREATE TYPE PAYMENT_METHOD AS ENUM (
  'CREDIT_CARD',
  'DEBIT_CARD',
  'BANK_TRANSFER',
  'PAYPAL',
  'CASH',
  'CRYPTO'
);

-- Stripe Payments table
CREATE TABLE stripe_payments (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL,
  stripe_payment_intent_id VARCHAR(255) NOT NULL,
  status PAYMENT_STATUS NOT NULL DEFAULT 'PENDING',
  payment_method PAYMENT_METHOD NOT NULL,
  payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders (id)
);

-- Webhook log table to track Stripe events
CREATE TABLE stripe_webhooks (
  id SERIAL PRIMARY KEY,
  event_id VARCHAR(255) UNIQUE NOT NULL,
  event_type VARCHAR(255) NOT NULL,
  payload JSONB,
  processed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to update stock and send email when stock reaches 3 for liked products
CREATE
OR REPLACE FUNCTION notify_user_when_stock_is_low() RETURNS TRIGGER AS $ $ DECLARE last_user_id INT;

BEGIN -- Get the last user who liked the product but hasn't purchased it
SELECT
  client_id INTO last_user_id
FROM
  liked_products
WHERE
  product_id = NEW.product_id
  AND client_id NOT IN (
    SELECT
      client_id
    FROM
      order_items
    WHERE
      product_id = NEW.product_id
  )
ORDER BY
  created_at DESC
LIMIT
  1;

-- If the last user exists and stock is 3, send an email notification
IF last_user_id IS NOT NULL
AND NEW.stock = 3 THEN -- Simulate email sending (you can integrate your email service here)
RAISE NOTICE 'Notify user % about low stock for product %',
last_user_id,
NEW.product_id;

END IF;

RETURN NEW;

END;

$ $ LANGUAGE plpgsql;

-- Create the trigger on product updates (stock reaching 3)
CREATE TRIGGER check_stock_before_update
AFTER
UPDATE
  OF stock ON products FOR EACH ROW
  WHEN (NEW.stock = 3) EXECUTE FUNCTION notify_user_when_stock_is_low();

-- Trigger for logging password changes
CREATE
OR REPLACE FUNCTION log_password_change() RETURNS TRIGGER AS $ $ BEGIN -- Simulate email sending (you can integrate your email service here)
RAISE NOTICE 'Send email to user % about password change',
NEW.id;

RETURN NEW;

END;

$ $ LANGUAGE plpgsql;

-- Create the trigger on password update
CREATE TRIGGER password_change_notify
AFTER
UPDATE
  OF password_hash ON users FOR EACH ROW EXECUTE FUNCTION log_password_change();
