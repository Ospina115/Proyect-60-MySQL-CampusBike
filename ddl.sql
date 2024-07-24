DROP DATABASE campusbike;

CREATE DATABASE IF NOT EXISTS campusbike;


USE campusbike;


CREATE TABLE paises (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE ciudades(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    pais_id INT,
    FOREIGN KEY (pais_id) REFERENCES paises(id)
);

CREATE TABLE bicicletas(
    id INT PRIMARY KEY AUTO_INCREMENT,
    modelo VARCHAR(100),
    marca VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT
);

CREATE TABLE clientes(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    email VARCHAR(100),
    telefono INT,
    password VARCHAR(100),
    ciudad_id INT,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id)
);

CREATE TABLE ventas(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    cliente_id INT,
    FOREIGN KEY (cliente)
);

CREATE TABLE detalles_de_ventas(
    id INT PRIMARY KEY AUTO_INCREMENT,
    venta_id INT,
    bicicleta_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (venta_id) REFERENCES ventas(id),
    FOREIGN KEY (bicicleta_id) REFERENCES bicicletas(id)
);

CREATE TABLE proveedores(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    contacto INT,
    email VARCHAR(100),
    telefono INT
    ciudad_id INT,
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id)
);

CREATE TABLE repuestos(
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    descripcion VARCHAR(200),
    precio DECIMAL(10,2),
    stock INT,
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE compras(
    id INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE,
    proveedor_id INT,
    FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
    total DECIMAL
);

CREATE TABLE detalles_de_compras(
    id INT PRIMARY KEY AUTO_INCREMENT,
    compra_id INT,
    repuesto_id INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (compra_id) REFERENCES compras(id),
    FOREIGN KEY (repuesto_id) REFERENCES repuestos(id)
);