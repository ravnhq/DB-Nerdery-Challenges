-- Util
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE
OR REPLACE FUNCTION update_updated_at_column() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- User
CREATE TYPE user_type AS ENUM ('MANAGER', 'CLIENT');
CREATE TABLE "user" (
  user_id BIGSERIAL PRIMARY KEY NOT NULL,
  user_type USER_TYPE NOT NULL,
  first_name VARCHAR(100) NOT NULL CHECK (char_length(first_name) > 1),
  last_name VARCHAR(100) NOT NULL CHECK (char_length(last_name) > 1),
  email VARCHAR(254) UNIQUE NOT NULL CHECK (position('@' IN email) > 1),
  password TEXT NOT NULL,
  created_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TRIGGER update_user_updated_at BEFORE
UPDATE
  ON "user" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Credentials recovery
CREATE TYPE user_credential_type AS ENUM ('PASSWORD');
CREATE TABLE "user_credential_recovery" (
  user_id BIGINT NOT NULL,
  user_credential_type USER_CREDENTIAL_TYPE NOT NULL,
  token TEXT NOT NULL CHECK (char_length(token) > 1),
  used_at TIMESTAMP(3) WITH TIME ZONE DEFAULT NULL,
  FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, user_credential_type)
);

-- Currency [short_name = ISO 4217]
CREATE TABLE "currency" (
  currency_id BIGINT PRIMARY KEY NOT NULL,
  short_name VARCHAR(3), name TEXT
);
INSERT INTO currency
VALUES
  (1, 'PEN', 'Peruvian soles'),
  (2, 'USD', 'American dollar');

-- Products
CREATE TABLE "product" (
  product_id BIGSERIAL PRIMARY KEY NOT NULL,
  name TEXT UNIQUE NOT NULL CHECK (char_length(name) > 1),
  description TEXT NOT NULL CHECK (char_length(description) > 1),
  price NUMERIC(12, 2) NOT NULL CHECK (price >= 0),
  enabled BOOLEAN DEFAULT TRUE,
  archived BOOLEAN DEFAULT FALSE,
  featured BOOLEAN DEFAULT FALSE,
  stock INT CHECK (stock >= 0) NOT NULL,
  created_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE INDEX index_product_on_name ON product USING gin (name gin_trgm_ops);
CREATE TRIGGER update_product_updated_at BEFORE
UPDATE
  ON "product" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE "product_image" (
  product_image_id BIGSERIAL PRIMARY KEY NOT NULL,
  product_id BIGINT NOT NULL,
  url TEXT NOT NULL CHECK (char_length(url) > 1),
  number INT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES "product"(product_id) ON DELETE CASCADE
);

-- Category
CREATE TABLE "category" (
  category_id BIGSERIAL PRIMARY KEY NOT NULL,
  name TEXT UNIQUE NOT NULL CHECK (char_length(name) > 1),
  featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TRIGGER update_category_updated_at BEFORE
UPDATE
  ON "category" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE "category_image" (
  category_image_id BIGSERIAL PRIMARY KEY NOT NULL,
  category_id BIGINT NOT NULL,
  url TEXT NOT NULL CHECK (char_length(url) > 1),
  number INT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES "category"(category_id) ON DELETE CASCADE
);

CREATE TABLE "category_product" (
  product_id BIGINT NOT NULL,
  category_id BIGINT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES "product"(product_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES "category"(category_id) ON DELETE CASCADE,
  UNIQUE (product_id, category_id)
);

-- Order
CREATE TYPE order_status_type AS ENUM ('PENDING', 'PAID', 'FAILED');
CREATE TABLE "order" (
  order_id BIGSERIAL PRIMARY KEY NOT NULL,
  user_id BIGINT NOT NULL,
  order_status_type ORDER_STATUS_TYPE NOT NULL,
  currency_id BIGINT NOT NULL,
  amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
  created_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
  FOREIGN KEY (currency_id) REFERENCES "currency"(currency_id) ON DELETE CASCADE
);
CREATE TRIGGER update_order_updated_at BEFORE
UPDATE
  ON "order" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE "order_item" (
  order_item_id BIGSERIAL PRIMARY KEY NOT NULL,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  name TEXT NOT NULL CHECK (char_length(name) > 1),
  unit_price NUMERIC(12, 2) NOT NULL CHECK (unit_price >= 0),
  quantity INT CHECK (quantity >= 1) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES "product"(product_id) ON DELETE CASCADE
);

-- Payment
CREATE TYPE payment_method_type AS ENUM ('CARD');
CREATE TABLE "payment_provider" (
  payment_provider_id BIGINT PRIMARY KEY NOT NULL,
  payment_method_type PAYMENT_METHOD_TYPE NOT NULL,
  name TEXT NOT NULL,
  enabled BOOLEAN NOT NULL
);
INSERT INTO payment_provider
VALUES
  (1, 'CARD', 'STRIPE', true);

CREATE TYPE payment_status_type AS ENUM ('PENDING', 'PAID', 'FAILED', 'CANCELED');
CREATE TABLE "payment" (
  payment_id BIGSERIAL PRIMARY KEY NOT NULL,
  order_id BIGINT NOT NULL,
  payment_provider_id BIGINT NOT NULL,
  payment_status_type PAYMENT_STATUS_TYPE NOT NULL,
  initialization_data JSONB,
  transaction_data JSONB,
  created_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP(3) WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  paid_at TIMESTAMP(3) WITH TIME ZONE,
  FOREIGN KEY (order_id) REFERENCES "order"(order_id),
  FOREIGN KEY (payment_provider_id) REFERENCES "payment_provider"(payment_provider_id)
);
CREATE TRIGGER update_payment_updated_at BEFORE
UPDATE
  ON "payment" FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Shopping Cart
CREATE TABLE "shopping_cart" (
  shopping_cart_id BIGSERIAL PRIMARY KEY NOT NULL,
  user_id BIGINT UNIQUE NOT NULL,
  FOREIGN KEY (user_id) REFERENCES "user"(user_id)
);
CREATE TABLE "shopping_cart_item" (
  shopping_cart_item_id BIGSERIAL PRIMARY KEY NOT NULL,
  shopping_cart_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT NOT NULL CHECK (quantity >= 1),
  number INT NOT NULL CHECK (number >= 0),
  FOREIGN KEY (shopping_cart_id) REFERENCES "shopping_cart"(shopping_cart_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES "product"(product_id) ON DELETE CASCADE
);

-- Like
CREATE TABLE "product_like" (
  product_id BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES "product"(product_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES "user"(user_id) ON DELETE CASCADE,
  UNIQUE (product_id, user_id)
);
