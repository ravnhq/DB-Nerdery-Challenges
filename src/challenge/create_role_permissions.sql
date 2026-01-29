INSERT INTO roles (name) VALUES 
    ('Client'),
    ('Manager');

-- Insert basic permissions
INSERT INTO permissions (name) VALUES 
    ('create_product'),
    ('update_product'),
    ('delete_product'),
    ('view_orders'),
    ('manage_products'),
    ('view_products'),
    ('purchase_products'),
    ('like_products'),
    ('manage_cart'),
    ('upload_product_images'),
    ('disable_products');

INSERT INTO role_permissions (role_id, permission_id) 
SELECT 2, id FROM permissions;

-- Assign permissions to Client role (basic permissions)
INSERT INTO role_permissions (role_id, permission_id) 
SELECT 1, id FROM permissions 
WHERE name IN ('view_products', 'purchase_products', 'like_products', 'manage_cart');