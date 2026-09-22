USE railway;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS product_ratings;
DROP TABLE IF EXISTS payment_methods;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

SHOW TABLES;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    rol ENUM('admin','cliente','vendedor') DEFAULT 'cliente'
);

CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO categories(nombre)
VALUES
('Celulares'),
('Audio'),
('Computadoras'),
('Laptops'),
('Accesorios'),
('Gaming'),
('Smart Home');

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    imagen VARCHAR(255),
    category_id INT NOT NULL,
    stock INT DEFAULT 0,

    FOREIGN KEY(category_id)
    REFERENCES categories(id)
);


INSERT INTO products
(nombre, descripcion, precio, imagen, category_id, stock)
VALUES

('iPhone 15 Pro',
'Titanio, Chip A17 Pro.',
23999.00,
'/img/products/producto-1/iPhone.png',
1,
10),

('Samsung Galaxy S24 Ultra',
'Cámara 200MP, IA.',
26500.00,
'/img/products/producto-2/samsung.jpg',
1,
10),

('Google Pixel 8 Pro',
'Cámara con IA.',
19500.00,
'/img/products/producto-3/pixel.jpg',
1,
10),

('Xiaomi 13T Pro',
'Cámaras Leica.',
12500.00,
'/img/products/producto-4/xiaomi.jpg',
1,
10),

('MacBook Air M3',
'Chip M3.',
22499.00,
'/img/products/producto-5/macbook.jpg',
3,
10),

('ASUS ROG Zephyrus G14',
'Laptop gamer.',
32000.00,
'/img/products/producto-6/asus.jpg',
4,
10),

('Dell XPS 13 Plus',
'Pantalla OLED.',
29000.00,
'/img/products/producto-7/dell.jpg',
4,
10),

('Sony WH-1000XM5',
'Cancelación de ruido.',
6500.00,
'/img/products/producto-8/sony.jpg',
2,
10),

('AirPods Pro 2',
'Audio espacial.',
4999.00,
'/img/products/producto-9/airpods.jpg',
2,
10),

('Bose SoundLink Flex',
'Bluetooth resistente.',
3200.00,
'/img/products/producto-10/bose.jpg',
2,
10),

('PlayStation 5 Slim',
'Gráficos 4K.',
10999.00,
'/img/products/producto-11/play.jpg',
6,
10),

('Xbox Series X',
'Consola potente.',
11500.00,
'/img/products/producto-12/xbox.jpg',
6,
10),

('Nintendo Switch OLED',
'Modo portátil.',
6999.00,
'/img/products/producto-13/switch.jpg',
6,
10),

('Mouse Logitech MX Master 3S',
'Ergonómico.',
1800.00,
'/img/products/producto-14/logitech.jpg',
5,
10),

('Teclado Mecánico Keychron K2',
'RGB mecánico.',
2100.00,
'/img/products/producto-15/keychron.jpg',
5,
10),

('Hub USB-C 8 en 1',
'HDMI, USB, SD.',
800.00,
'/img/products/producto-16/hub.jpg',
5,
10),

('Echo Dot 5ta Gen',
'Alexa integrada.',
1200.00,
'/img/products/producto-17/echo.jpg',
7,
10),

('Google Nest Hub 2',
'Pantalla inteligente.',
1900.00,
'/img/products/producto-18/nest.jpg',
7,
10),

('Foco Inteligente Wiz',
'Colores WiFi.',
250.00,
'/img/products/producto-19/foco.jpg',
7,
10);

CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    imagen_url VARCHAR(255),

    FOREIGN KEY(product_id)
    REFERENCES products(id)
    ON DELETE CASCADE
);

CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),

    estado ENUM(
        'pendiente',
        'pagado',
        'cancelado'
    ) DEFAULT 'pendiente',

    FOREIGN KEY(user_id)
    REFERENCES users(id)
);

CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    cantidad INT NOT NULL,

    FOREIGN KEY(order_id)
    REFERENCES orders(id),

    FOREIGN KEY(product_id)
    REFERENCES products(id)
);

CREATE TABLE payment_methods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    tipo VARCHAR(50),
    nombre_titular VARCHAR(100),
    ultimos_digitos VARCHAR(4),

    FOREIGN KEY(user_id)
    REFERENCES users(id)
);

CREATE TABLE product_ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL,
    comentario TEXT,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(product_id)
    REFERENCES products(id),

    FOREIGN KEY(user_id)
    REFERENCES users(id)
);

INSERT INTO users
(nombre,email,password,rol)
VALUES
(
'Administrador',
'admin@novastore.com',
'$2b$10$rNy8RBRLchW6K5F/0hNDveZAUioAkoIJAo9HWObM6rtG7Plp/2sva',
'admin'
);

SHOW TABLES;

SELECT COUNT(*) FROM products;

ALTER TABLE payment_methods
ADD COLUMN fecha_expiracion VARCHAR(7),
ADD COLUMN es_principal BOOLEAN DEFAULT FALSE;

DESCRIBE payment_methods;

ALTER TABLE orders
ADD COLUMN payment_method_id INT AFTER total;

ALTER TABLE orders
ADD CONSTRAINT fk_orders_payment
FOREIGN KEY(payment_method_id)
REFERENCES payment_methods(id);

DESCRIBE orders;

SELECT * FROM orders;

SELECT * FROM order_items;

DESCRIBE product_ratings;
SELECT * FROM product_ratings;

ALTER TABLE product_ratings
ADD COLUMN order_id INT NOT NULL AFTER user_id;

ALTER TABLE product_ratings
ADD CONSTRAINT fk_rating_order
FOREIGN KEY (order_id)
REFERENCES orders(id)
ON DELETE CASCADE;

DESCRIBE product_ratings;

ALTER TABLE product_ratings
ADD CONSTRAINT unique_product_order_rating
UNIQUE(product_id, user_id, order_id);