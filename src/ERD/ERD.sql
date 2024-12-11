CREATE TABLE product (
  product_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  stock NUMERIC,
  is_active BOOLEAN DEFAULT TRUE,
  price NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE product_category (
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  FOREIGN KEY (product_id) REFERENCES product(product_id),
  FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE category (
  category_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  description TEXT,
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE product_image (
  product_id INT REFERENCES product(product_id),
  url TEXT NOT NULL
);

CREATE TABLE product_like (
  product_id INT REFERENCES product(product_id),
  user_id INT REFERENCES customer_user(user_id),
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE cart (
  user_id INT REFERENCES customer_user(user_id),
  PRIMARY KEY (user_id)
);

CREATE TABLE cart_detail (
  cart_id INT REFERENCES cart(user_id),
  product_id INT REFERENCES product(product_id),
  quantity INT,
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE customer_user (
  user_id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  phone_number TEXT,
  username TEXT,
  password TEXT,
  address TEXT,
  verificated_at TIMESTAMP(3) WITHOUT TIME ZONE,
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP(3) WITHOUT TIME ZONE,
  verification_token TEXT,
  verification_expires_at TIMESTAMP,
  reset_password_token TEXT,
  reset_password_expires_at TIMESTAMP
);

CREATE TABLE role (
  role_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description TEXT
);

CREATE TABLE user_role (
  role_id INT NOT NULL REFERENCES role(role_id),
  user_id INT NOT NULL REFERENCES customer_user(user_id),
  PRIMARY KEY (role_id, user_id)
);

CREATE TABLE sale (
  sale_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES customer_user(user_id),
  total NUMERIC,
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TABLE sale_detail (
  sale_detail_id INT,
  sale_id INT REFERENCES sale(sale_id),
  product_id INT REFERENCES product(product_id),
  quantity INT,
  unit_price NUMERIC,
  subtotal NUMERIC
);

CREATE TYPE payment_enum AS ENUM ('paid', 'pending');

CREATE TABLE payment (
  id SERIAL PRIMARY KEY,
  sale_id INT REFERENCES sale(sale_id),
  stripe_payment_id VARCHAR(255) UNIQUE NOT NULL,
  amount NUMERIC(10, 2) NOT NULL,
  currency TEXT NOT NULL,
  status payment_enum NOT NULL DEFAULT 'pending',
  created_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP(3) WITHOUT TIME ZONE DEFAULT NOW()
);

CREATE TYPE priority_enum AS ENUM ('low', 'normal', 'high', 'urgent');
CREATE TYPE status_enum AS ENUM ('read','unread');
CREATE TYPE notification_type_enum AS ENUM ('email','sms','whatsapp');

CREATE TABLE notification (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES customer_user(user_id),
  title VARCHAR(200) NOT NULL,
  description TEXT,
  priority priority_enum NOT NULL DEFAULT 'normal',
  status status_enum DEFAULT 'unread',
  type notification_type_enum DEFAULT 'email',
  created_at TIMESTAMP DEFAULT NOW(),
  send_at TIMESTAMP,
  read_at TIMESTAMP
);

CREATE TABLE entry (
  id SERIAL PRIMARY KEY,
  product_id INT REFERENCES product(product_id),
  quantity INT NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMP DEFAULT NOW(),
  created_by INT REFERENCES customer_user(user_id),
);
