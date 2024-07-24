INSERT INTO paises (nombre) VALUES
('Estados Unidos'),
('México'),
('Canadá'),
('España'),
('Colombia');

INSERT INTO ciudades (nombre, pais_id) VALUES
('Nueva York', 1),
('Ciudad de México', 2),
('Toronto', 3),
('Madrid', 4),
('Bogotá', 5),
('Medellín', 5),
('Cali', 5),
('Barranquilla', 5),
('Cartagena', 5);

INSERT INTO bicicletas (modelo, marca, precio, stock) VALUES
('Mountain 1000', 'Giant', 5000000.50, 10),
('Speedster 200', 'Scott', 3500000.75, 5),
('Road Elite', 'Specialized', 4000000.00, 7),
('Hybrid 300', 'Trek', 2800000.25, 12),
('BMX Pro', 'Mongoose', 1900000.50, 8);

INSERT INTO clientes (nombre, email, telefono, password, ciudad_id) VALUES
('Juan Pérez', 'juan.perez@gmail.com', 1234567890, 'password123', 6),
('Ana García', 'ana.garcia@gmail.com', 2345678901, 'password456', 5),
('Luis Martínez', 'luis.martinez@gmail.com', 3456789012, 'password789', 7),
('María López', 'maria.lopez@gmail.com', 4567890123, 'password101', 8),
('Carlos Gómez', 'carlos.gomez@gmail.com', 5678901234, 'password202', 9);

INSERT INTO ventas (fecha, cliente_id) VALUES
('2023-01-15', 1),
('2023-02-20', 2),
('2023-03-05', 3),
('2023-04-10', 4),
('2023-05-25', 5);

INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario) VALUES
(1, 1, 2, 5000000.50),
(2, 2, 1, 3500000.75),
(3, 3, 3, 4000000.00),
(4, 4, 1, 2800000.25),
(5, 5, 2, 1900000.50);

INSERT INTO proveedores (nombre, contacto, email, telefono, ciudad_id) VALUES
('Giant', 1234567890, 'gitt@giantbicycles.com', 9876543210, 1),
('Scott', 2345678901, 'scot@scott-sports.com', 8765432109, 2),
('Specialized', 3456789012, 'spe@specialized.com', 7654321098, 3),
('Trek', 4567890123, 'tre@trekbikes.com', 6543210987, 4),
('Mongoose', 5678901234, 'mongo@mongoose.com', 5432109876, 5);

INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id) VALUES
('Cadena', 'Cadena para bicicleta de montaña', 210000.75, 20, 1),
('Llanta', 'Llanta para bicicleta de carretera', 420000.50, 15, 2),
('Asiento', 'Asiento cómodo para bicicleta', 147000.25, 30, 3),
('Pedal', 'Pedal antideslizante', 84000.10, 50, 4),
('Manubrio', 'Manubrio ergonómico', 189000.00, 25, 5);

INSERT INTO compras (fecha, proveedor_id, total) VALUES
('2023-01-10', 1, 2100000.00),
('2023-02-15', 2, 3150000.00),
('2023-03-20', 3, 4230000.00),
('2023-04-25', 4, 1560000.00),
('2023-05-30', 5, 2330000.00);

INSERT INTO detalles_de_compras (compra_id, repuesto_id, cantidad, precio_unitario) VALUES
(1, 1, 10, 210000.75),
(2, 2, 10, 420000.50),
(3, 3, 20, 147000.25),
(4, 4, 20, 84000.10),
(5, 5, 25, 189000.00);
