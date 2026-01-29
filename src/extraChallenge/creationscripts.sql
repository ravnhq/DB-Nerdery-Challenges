CREATE TYPE order_status AS ENUM ('PENDING', 'PAID', 'CANCELLED');
CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCEEDED', 'FAILED');
CREATE TYPE webhook_status AS ENUM ('RECEIVED', 'PROCESSED', 'FAILED');
CREATE TYPE cart_status AS ENUM ('ACTIVE', 'CHECKED_OUT', 'ABANDONED');

CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  entity VARCHAR(50) NOT NULL,
  entity_id BIGINT,
  action VARCHAR(100) NOT NULL,
  message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- it seems that user is a keyword in some SQL dialects, so in order to create the table
-- it must be quoted


CREATE TABLE role (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE "user" (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id BIGINT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP,
  CONSTRAINT fk_user_role
    FOREIGN KEY (role_id)
    REFERENCES role(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE address (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  street VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100),
  country VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20) NOT NULL,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_address_user
    FOREIGN KEY (user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE password_reset_token (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  token VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  is_used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_password_reset_user
    FOREIGN KEY (user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE category (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  stock INT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_by_user_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP,
  CONSTRAINT fk_product_creator
    FOREIGN KEY (created_by_user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE product_category (
  product_id BIGINT NOT NULL,
  category_id BIGINT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  CONSTRAINT fk_pc_product
    FOREIGN KEY (product_id)
    REFERENCES product(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_pc_category
    FOREIGN KEY (category_id)
    REFERENCES category(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE product_image (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL,
  image_url TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_product_image_product
    FOREIGN KEY (product_id)
    REFERENCES product(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE product_like (
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, product_id),
  CONSTRAINT fk_like_user
    FOREIGN KEY (user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_like_product
    FOREIGN KEY (product_id)
    REFERENCES product(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE cart (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL UNIQUE,
  status cart_status NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  checked_out_at TIMESTAMP,
  CONSTRAINT fk_cart_user
    FOREIGN KEY (user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE cart_item (
  id BIGSERIAL PRIMARY KEY,
  cart_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  CONSTRAINT uq_cart_product UNIQUE (cart_id, product_id),
  CONSTRAINT fk_cart_item_cart
    FOREIGN KEY (cart_id)
    REFERENCES cart(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_cart_item_product
    FOREIGN KEY (product_id)
    REFERENCES product(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE discount (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  percentage INT NOT NULL CHECK (percentage > 0 AND percentage <= 100),
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "order" (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL,
  cart_id BIGINT UNIQUE,
  address_id BIGINT NOT NULL,
  discount_id BIGINT,
  status order_status NOT NULL,
  total_amount NUMERIC(10,2) NOT NULL,
  discount_amount NUMERIC(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_order_user
    FOREIGN KEY (user_id)
    REFERENCES "user"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_order_cart
    FOREIGN KEY (cart_id)
    REFERENCES cart(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_order_address
    FOREIGN KEY (address_id)
    REFERENCES address(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_order_discount
    FOREIGN KEY (discount_id)
    REFERENCES discount(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE order_item (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  price_at_purchase NUMERIC(10,2) NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  CONSTRAINT fk_order_item_order
    FOREIGN KEY (order_id)
    REFERENCES "order"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_order_item_product
    FOREIGN KEY (product_id)
    REFERENCES product(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

CREATE TABLE payment (
  id BIGSERIAL PRIMARY KEY,
  order_id BIGINT NOT NULL UNIQUE,
  stripe_payment_intent_id VARCHAR(255) NOT NULL,
  status payment_status NOT NULL,
  amount NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_order
    FOREIGN KEY (order_id)
    REFERENCES "order"(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


CREATE TABLE stripe_webhook (
  id BIGSERIAL PRIMARY KEY,
  payment_id BIGINT,
  stripe_event_id VARCHAR(255) NOT NULL UNIQUE,
  event_type VARCHAR(100) NOT NULL,
  payload JSONB NOT NULL,
  received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP,
  status webhook_status NOT NULL,
  CONSTRAINT fk_webhook_payment
    FOREIGN KEY (payment_id)
    REFERENCES payment(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- triggers logic (extra points of the challenge)
-- in a real scenario this should be managed by the business code logic
CREATE OR REPLACE FUNCTION trg_stock_reaches_three()
RETURNS TRIGGER AS $$
DECLARE notify_user BIGINT;
BEGIN
  IF NEW.stock = 3 AND OLD.stock > 3 THEN

    SELECT user_id
    INTO notify_user
    FROM product_like pl
    WHERE pl.product_id = NEW.id
      AND NOT EXISTS (
        SELECT 1 FROM order_item oi
        JOIN "order" o ON o.id = oi.order_id
        WHERE oi.product_id = NEW.id
          AND o.user_id = pl.user_id
          AND o.status = 'PAID'
      )
    ORDER BY liked_at DESC
    LIMIT 1;

    INSERT INTO audit_log (entity, entity_id, action)
    VALUES ('product', NEW.id, 'STOCK_REACHED_3');

    IF notify_user IS NOT NULL THEN
      INSERT INTO audit_log (entity, entity_id, action)
      VALUES ('user', notify_user, 'SEND_EMAIL_STOCK_LOW');
    END IF;

    RAISE LOG 'Product % stock is low', NEW.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER stock_reaches_three_trigger
AFTER UPDATE OF stock ON product
FOR EACH ROW
EXECUTE FUNCTION trg_stock_reaches_three();

CREATE OR REPLACE FUNCTION trg_password_changed()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.password_hash <> OLD.password_hash THEN
    INSERT INTO audit_log (entity, entity_id, action, message)
    VALUES ('user', NEW.id, 'PASSWORD_CHANGED', 'User password was changed');
    RAISE LOG  'Password changed for user %', NEW.id;
    RETURN NEW; 
  ELSE
    RAISE EXCEPTION 'Password must be different from previous password for user %', NEW.id;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER password_change_trigger
BEFORE UPDATE OF password_hash ON "user"
FOR EACH ROW
EXECUTE FUNCTION trg_password_changed();