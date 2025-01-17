# Proyecto Base de Datos CampusBike



##### Integrantes

Johan Sebastián Duarte

Joseph Samuel Ospina

![](diagrama.webp)



## Casos de Uso para la Base de Datos



### Caso de uso 1: Gestión de Inventario de Bicicletas



El administrador ingresa los detalles de la bicicleta (modelo, marca, precio, stock).

```sql
DELIMITER //
CREATE TRIGGER insertar_bicicletas
AFTER INSERT ON bicicletas
FOR EACH ROW
BEGIN
	INSERT INTO bicibletas (modelo, marca, precio, stock) VALUES
	(NEW.modelo, NEW.marca, NEW.precio, NEW.stock);
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER verificacion_bicicletas
BEFORE INSERT ON bicicletas
FOR EACH ROW
BEGIN
	IF NEW.modelo IS NULL 
	OR NEW.marca IS NULL 
	OR NEW.precio IS NULL 
	OR NEW.stock IS NULL
	THEN
	SIGNAL SQLSTATE '45000'
	SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
	END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER numnegativos_bicicletas
BEFORE INSERT ON bicicletas
FOR EACH ROW
BEGIN
	IF NEW.precio < 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El precio no puede ser un numero negativo';
	END IF;
END //
DELIMITER ;

INSERT INTO bicicletas (modelo, marca, precio, stock) VALUES
(3, 2, 6000000.50, 5);
```



El administrador actualiza la información (precio, stock).

```sql
UPDATE bicicletas 
SET precio = 8000000.00, stock = 15
WHERE id = 7;
```

El administrador selecciona una bicicleta para eliminar.

```sql
DELETE FROM bicicletas
WHERE id = 7;
```



### Caso de Uso 2: Registro de Ventas



El vendedor selecciona las bicicletas que el cliente desea comprar y especifica la cantidad.

```sql
DELIMITER //
CREATE TRIGGER agregar_ventas
BEFORE INSERT ON ventas 
FOR EACH ROW
BEGIN 
	INSERT INTO ventas (fecha, cliente_id)
	VALUES (NEW.fecha, NEW.cliente_id);
END
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER verificacion_ventas
BEFORE INSERT ON ventas
FOR EACH ROW
BEGIN 
    IF NEW.fecha IS NULL 
    OR NEW.cliente_id IS NULL 
    THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los campos deben llenarse';
    END IF;
END //
DELIMITER ;

INSERT INTO ventas (fecha, cliente_id)values
('2005-08-31', 1);

DELIMITER //
CREATE TRIGGER agregar_detalles_de_ventas
BEFORE INSERT ON detalles_de_ventas 
FOR EACH ROW
BEGIN 
	INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
	VALUES (NEW.venta_id, NEW.bicicleta_id,NEW.cantidad,NEW.precio_unitario);
END
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER verificacion_detalles_de_ventas
BEFORE INSERT ON detalles_de_ventas
FOR EACH ROW
BEGIN 
    IF NEW.venta_id IS NULL 
    OR NEW.bicicleta_id IS NULL 
    OR NEW.cantidad IS NULL 
    OR NEW.precio_unitario IS NULL 
    THEN 
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los campos deben llenarse';
    END IF;
END //
DELIMITER ;

INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad) VALUES
(5, 5, 3, 4000000.50);
```



El sistema calcula el total de la venta.

```sql
SELECT v.id AS id_venta,
SUM(dv.cantidad * dv.precio_unitario) AS total_venta
FROM ventas v
INNER JOIN detalles_de_ventas dv ON v.id = dv.venta_id
GROUP BY v.id;
```



El sistema guarda la venta y actualiza el inventario de bicicletas.

```sql
DELIMITER //
CREATE TRIGGER actualizar_stock_bicicleta
AFTER INSERT ON detalles_de_ventas
FOR EACH ROW
BEGIN
    UPDATE bicicletas
    SET stock = stock - NEW.cantidad
    WHERE id = NEW.bicicleta_id;
END; //

DELIMITER ;
BEGIN;
INSERT INTO ventas (fecha, cliente_id)
VALUES ('2005-08-31', 1);

INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
VALUES (LAST_INSERT_ID(), 5, 3, 4000000.50);
COMMIT;
```



### Caso de Uso 3: Gestión de Proveedores y Repuestos

El administrador ingresa los detalles del proveedor (nombre, contacto, teléfono, correo
electrónico, ciudad).

  ```sql
    DELIMITER //
    CREATE TRIGGER verificacion_proveedores
    BEFORE INSERT ON proveedores
    FOR EACH ROW
    BEGIN
    	IF NEW.nombre IS NULL 
    	OR NEW.contacto IS NULL 
    	OR NEW.email IS NULL 
    	OR NEW.telefono IS NULL
    	OR NEW.ciudad_id IS NULL
    	THEN
    	SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
    	END IF;
    END //
    DELIMITER ;
    
    DELIMITER //
    CREATE TRIGGER numero_proveedores
    BEFORE INSERT ON proveedores
    FOR EACH ROW
    BEGIN
    	IF CHAR_LENGTH(NEW.telefono) != 10
    	THEN
    	SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Debes ingresar un numero de telefono valido; ejemplo (3123345678)';
    	END IF;
    END //
    DELIMITER ;
    
    INSERT INTO proveedores (nombre, contacto, email, telefono, ciudad_id) 
    VALUES ('JH', 3129837777, 'quebendicion@compartan.com',7777 ,7);
  ```



El administrador ingresa los detalles del repuesto (nombre, descripción, precio, stock,
proveedor).

  ```sql
    DELIMITER //
    CREATE TRIGGER verificacion_repuestos
    BEFORE INSERT ON repuestos
    FOR EACH ROW
    BEGIN
    	IF NEW.nombre IS NULL 
    	OR NEW.descripcion IS NULL 
    	OR NEW.precio IS NULL 
    	OR NEW.stock IS NULL
    	OR NEW.modelo IS NULL
    	OR NEW.marca IS NULL
    	THEN
    	SIGNAL SQLSTATE '45000'
    	SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
    	END IF;
    END //
    DELIMITER ;
  
    DELIMITER //
    CREATE TRIGGER numnegativos_repuestos
    BEFORE INSERT ON repuestos
    FOR EACH ROW
    BEGIN
    	IF NEW.precio < 0 THEN
    		SIGNAL SQLSTATE '45000'
    		SET MESSAGE_TEXT = 'El precio no puede ser un numero negativo';
    	END IF;
    END //
    DELIMITER ;
  
    DELIMITER //
    CREATE TRIGGER numnegativos_stock
    BEFORE INSERT ON repuestos
    FOR EACH ROW
    BEGIN
    	IF NEW.stock < 1 THEN
    		SIGNAL SQLSTATE '45000'
    		SET MESSAGE_TEXT = 'El stock no puede ser menor a uno';
    	END IF;
    END //
    DELIMITER ;
    
  INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id, modelo, marca)
  VALUES ('murillo', 'simplemente murrilo detonando a jh', 1000.00, 20, 6, 5, 2 );
  ```



El administrador actualiza la información del proveedor.

```sql
UPDATE proveedores 
SET nombre = 'la liendra'
WHERE id = 6;
```



El administrador selecciona un repuesto existente para actualizar.

```sql
UPDATE repuestos 
SET nombre = 'reykon', descripcion = 'pelea epica por luisa castro'
WHERE id = 6;
```



El administrador selecciona un proveedor para eliminar.

```sql
DELETE FROM proveedores 
WHERE id = 6;
```



El administrador selecciona un repuesto para eliminar.

```sql
DELETE FROM repuestos 
WHERE id = 6;
```



### Caso de Uso 4: Consulta de Historial de Ventas por Cliente

El usuario selecciona la opción para consultar el historial de ventas.

```sql
SELECT id, fecha, cliente_id 
FROM ventas;
```



El usuario selecciona el cliente del cual desea ver el historial.

```sql
SELECT id, fecha, cliente_id 
FROM ventas
WHERE id = 1;
```



El sistema muestra todas las ventas realizadas por el cliente seleccionado.

```sql
+----+------------+------------+
| id | fecha      | cliente_id |
+----+------------+------------+
|  1 | 2023-01-15 |          1 |
+----+------------+------------+
```



El usuario selecciona una venta específica para ver los detalles.

```sql
SELECT v.id AS "Id de la venta", v.fecha AS "Fecha de la compra", d.venta_id, d.cantidad, d.precio_unitario
FROM ventas AS v
JOIN detalles_de_ventas AS d ON v.id = d.venta_id
WHERE v.id = 1;
```



El sistema muestra los detalles de la venta seleccionada (bicicletas compradas, cantidad,
precio).

  ```sql
  SELECT Bicicleta_id, venta_id AS "Id de la compra", cantidad, precio_unitario
  FROM detalles_de_ventas;
  ```

  

### Caso de Uso 5: Gestión de Compras de Repuestos

El administrador selecciona la opción para registrar una nueva compra.

```sql
DELIMITER //
CREATE TRIGGER verificacion_compras
BEFORE INSERT ON compras
FOR EACH ROW
BEGIN
 IF NEW.fecha IS NULL 
 OR NEW.proveedor_id IS NULL 
 OR NEW.total IS NULL 
 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
 END IF;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER numnegativos_compras
BEFORE INSERT ON compras
FOR EACH ROW
BEGIN
	IF NEW.total < 1 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El total no puede ser menor a 1';
	END IF;
END //
DELIMITER ;

INSERT INTO compras (fecha, proveedor_id, total)
VALUES ('2024-07-25', 1, 10000);
```



El administrador selecciona el proveedor al que se realizó la compra.

```sql
SELECT id ,fecha, proveedor_id, total
FROM compras
WHERE id = 6;
```



El administrador ingresa los detalles de la compra (fecha, total).

```sql
DELIMITER //
CREATE TRIGGER verificacion_detallescompra
BEFORE INSERT ON detalles_de_compras
FOR EACH ROW
BEGIN
 IF NEW.compra_id IS NULL 
 OR NEW.cantidad IS NULL 
 OR NEW.precio_unitario IS NULL
 OR NEW.fecha IS NULL
 OR NEW.total IS NULL
 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
 END IF;
END //
DELIMITER ;

  DELIMITER //
  CREATE TRIGGER numnegativos_stock
  BEFORE INSERT ON detalles_de_compras
  FOR EACH ROW
  BEGIN
  	IF NEW.cantidad < 1 THEN
  		SIGNAL SQLSTATE '45000'
  		SET MESSAGE_TEXT = 'La cantidad no puede ser menor a uno';
  	END IF;
  END //
  DELIMITER ;
  
    DELIMITER //
  CREATE TRIGGER numnegativos_precio
  BEFORE INSERT ON detalles_de_compras
  FOR EACH ROW
  BEGIN
  	IF NEW.precio_unitario < 1 THEN
  		SIGNAL SQLSTATE '45000'
  		SET MESSAGE_TEXT = 'El precio unitario no puede ser menor a uno';
  	END IF;
  END //
  DELIMITER ;

INSERT INTO detalles_de_compras (compra_id, cantidad, precio_unitario, fecha, total)
VALUES (1, 10, 210000.75, 2023-10-26, 100000)
```



El administrador selecciona los repuestos comprados y especifica la cantidad y el precio
unitario.

```sql
DELIMITER //
CREATE TRIGGER verificacion_repuestos
BEFORE INSERT ON repuestos
FOR EACH ROW
BEGIN
 IF NEW.nombre IS NULL 
 OR NEW.descripcion IS NULL 
 OR NEW.precio IS NULL
 OR NEW.stock IS NULL
 OR NEW.proveedor_id IS NULL
 OR NEW.modelo IS NULL
 OR NEW.marca IS NULL
 THEN
 SIGNAL SQLSTATE '45000'
 SET MESSAGE_TEXT = 'Todos los campos deben ser ingresados';
 END IF;
END //
DELIMITER ;

  DELIMITER //
  CREATE TRIGGER numnegativos_repuestos
  BEFORE INSERT ON repuestos
  FOR EACH ROW
  BEGIN
  	IF NEW.stock < 0 
  	OR NEW.Precio < 1
  	THEN
  		SIGNAL SQLSTATE '45000'
  		SET MESSAGE_TEXT = 'un valor ingresado no es valido';
  	END IF;
  END //
  DELIMITER ;


INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id, modelo, marca)
VALUES ('Cadena', 'Cadena para bicicleta de montaña', 210000.75, 20, 1, 1, 1)
```



## Casos de Uso con Subconsultas



### Caso de Uso 6: Consulta de Bicicletas Más Vendidas por Marca

El usuario selecciona la opción para consultar las bicicletas más vendidas por marca.

```sql
SELECT m.nombre AS marca, mo.nombre AS bicicleta, SUM(dv.cantidad) AS cantidad_vendida
FROM detalles_de_ventas dv
  INNER JOIN bicicletas b ON dv.bicicleta_id = b.id
  INNER JOIN modelo mo ON b.modelo = mo.id
  INNER JOIN marca m ON b.marca = m.id
GROUP BY m.nombre, mo.nombre
ORDER BY cantidad_vendida DESC;
```



El sistema muestra una lista de marcas y el modelo de bicicleta más vendido para cada marca.

```sql
+-------------+---------------+------------------+
| marca       | bicicleta     | cantidad_vendida |
+-------------+---------------+------------------+
| Mongoose    | BMX Pro       | 5                |
+-------------+---------------+------------------+
| Specialized | Road Elite    | 3                |
+-------------+---------------+------------------+
| Giant       | Mountain 1000 | 2                |
+-------------+---------------+------------------+
| Scott       | Speedster 200 | 1                |
+-------------+---------------+------------------+
| Trek        | Hybrid 300    | 1                |
+-------------+---------------+------------------+
```



### Caso de Uso 7: Clientes con Mayor Gasto en un Año Específico

El administrador selecciona la opción para consultar los clientes con mayor gasto en un año
específico.

  ```sql
  SELECT c.nombre AS cliente, 
  SUM(dv.precio_unitario * dv.cantidad) AS total_gastado
  FROM clientes c
    INNER JOIN ventas v ON c.id = v.cliente_id
    INNER JOIN detalles_de_ventas dv ON v.id = dv.venta_id
  GROUP BY c.nombre
  ORDER BY total_gastado DESC;
  ```

  

El sistema muestra una lista de los clientes que han gastado más en ese año, ordenados por
total gastado.

```sql
+---------------+---------------+
| cliente       | total_gastado |
+---------------+---------------+
| Luis Martínez |   12000000.00 |
| Juan Pérez    |   10000001.00 |
| Carlos Gómez  |    3800001.00 |
| Ana García    |    3500000.75 |
| María López   |    2800000.25 |
+---------------+---------------+
```



### Caso de Uso 8: Proveedores con Más Compras en el Último Mes

El administrador selecciona la opción para consultar los proveedores con más compras en el
último mes.

  ```sql
  SELECT p.nombre, 
    COUNT(c.id) AS cantidad_compras
  FROM proveedores p
    JOIN compras c ON p.id = c.proveedor_id
  WHERE c.fecha >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
  GROUP BY p.nombre
  ORDER BY cantidad_compras DESC;
  ```

  

El sistema muestra una lista de proveedores ordenados por el número de compras recibidas
en el último mes.

  ```sql
  +--------+------------------+
  | nombre | cantidad_compras |
  +--------+------------------+
  | Giant  |                5 |
  +--------+------------------+
  ```

  

### Caso de Uso 9: Repuestos con Menor Rotación en el Inventario

El administrador selecciona la opción para consultar los repuestos con menor rotación.

```sql
SELECT r.nombre, COALESCE(SUM(ddc.cantidad), 0) AS cantidad_vendida
FROM repuestos r
  LEFT JOIN detalles_de_compras ddc ON r.id = ddc.repuesto_id
GROUP BY r.nombre
ORDER BY cantidad_vendida ASC;
```



El sistema muestra una lista de repuestos ordenados por la cantidad vendida, de menor a
mayor.

  ```sql
  +----------+------------------+
  | nombre   | cantidad_vendida |
  +----------+------------------+
  | Cadena   |               10 |
  | Llanta   |               10 |
  | Asiento  |               20 |
  | Pedal    |               20 |
  | Manubrio |               25 |
  +----------+------------------+
  ```

  

### Caso de Uso 10: Ciudades con Más Ventas Realizadas

El administrador selecciona la opción para consultar las ciudades con más ventas realizadas.

```sql
SELECT c.nombre, 
  COUNT(v.id) AS cantidad_ventas
FROM ciudades c
  JOIN clientes cl ON c.id = cl.ciudad_id
  JOIN ventas v ON cl.id = v.cliente_id
GROUP BY c.nombre
ORDER BY cantidad_ventas DESC;
```



El sistema muestra una lista de ciudades ordenadas por la cantidad de ventas realizadas.

```sql
+--------------+-----------------+
| nombre       | cantidad_ventas |
+--------------+-----------------+
| Bogotá       |               1 |
| Medellín     |               1 |
| Cali         |               1 |
| Barranquilla |               1 |
| Cartagena    |               1 |
+--------------+-----------------+
```





## Casos de Uso con Joins



### Caso de Uso 11: Consulta de Ventas por Ciudad

El administrador selecciona la opción para consultar las ventas por ciudad.

```sql
SELECT v.fecha, c.nombre AS 'nombre del cliente', c.email, c.telefono, c.password, ci.nombre AS 'nombre de la ciudad'
FROM ventas AS v
JOIN clientes AS c ON v.cliente_id = c.id
JOIN ciudades AS ci ON c.ciudad_id = ci.id;
```



El sistema muestra una lista de ciudades con el total de ventas realizadas en cada una.

```sql
SELECT ci.nombre, de.cantidad
FROM ciudades AS ci
JOIN clientes AS c ON ci.id = c.ciudad_id
JOIN ventas AS v ON c.id = v.cliente_id
JOIN detalles_de_ventas AS de ON v.id = de.venta_id;
```

```sql
+--------------+----------+
| nombre       | cantidad |
+--------------+----------+
| Bogotá       |        1 |
| Medellín     |        2 |
| Cali         |        3 |
| Barranquilla |        1 |
| Cartagena    |        2 |
+--------------+----------+
```



### Caso de Uso 12: Consulta de Proveedores por País

El administrador selecciona la opción para consultar los proveedores por país.

```sql
SELECT p.nombre AS 'nombre de los paises', pr.nombre AS 'nombre proveedor'
FROM proveedores AS pr
JOIN ciudades AS c ON pr.ciudad_id = c.id
JOIN paises AS p ON c.pais_id = p.id;
```



El sistema muestra una lista de países con los proveedores en cada país.

```sql
+----------------------+------------------+
| nombre de los paises | nombre proveedor |
+----------------------+------------------+
| Estados Unidos       | Giant            |
| México               | Scott            |
| Canadá               | Specialized      |
| España               | Trek             |
| Colombia             | Mongoose         |
+----------------------+------------------+
```



### Caso de Uso 13: Compras de Repuestos por Proveedor

El administrador selecciona la opción para consultar las compras de repuestos por
proveedor.

  ```sql
  SELECT p.nombre AS "nombre del proveedor", d.cantidad AS "cantidad de compras al proveedor"
  FROM proveedores AS p
  JOIN compras AS c ON p.id = c.proveedor_id
  JOIN detalles_de_compras AS d ON c.id = d.compra_id;
  ```

  

El sistema muestra una lista de proveedores con el total de repuestos comprados a cada
uno.

  ```sql
  +----------------------+----------------------------------+
  | nombre del proveedor | cantidad de compras al proveedor |
  +----------------------+----------------------------------+
  | Giant                |                               10 |
  | Scott                |                               10 |
  | Specialized          |                               20 |
  | Trek                 |                               20 |
  | Mongoose             |                               25 |
  +----------------------+----------------------------------+
  ```

  

### Caso de Uso 14: Clientes con Ventas en un Rango de Fechas

El usuario selecciona la opción para consultar los clientes con ventas en un rango de fechas.

```sql
SELECT id, fecha 
FROM ventas 
WHERE fecha BETWEEN 'fecha inicial' AND 'fecha final';
```



El usuario ingresa las fechas de inicio y fin del rango.

```sql
SELECT id, fecha 
FROM ventas 
WHERE fecha BETWEEN '2023-03-05' AND '2023-05-25';
```



El sistema muestra una lista de clientes que han realizado compras dentro del rango de
fechas especificado.

  ```sql
  +----+------------+
  | id | fecha      |
  +----+------------+
  |  3 | 2023-03-05 |
  |  4 | 2023-04-10 |
  |  5 | 2023-05-25 |
  +----+------------+
  ```





## Casos de Uso para Implementar Procedimientos Almacenados



### Caso de Uso 1: Actualización de Inventario de Bicicletas



El sistema llama a un procedimiento almacenado para actualizar el inventario de las
bicicletas vendidas.

  ```sql
  DELIMITER //
  CREATE PROCEDURE actualizar_inventario_bicicletas_vendidas(
  	IN id_bici INT,
      IN n_stock INT
  )
  BEGIN
  	UPDATE bicicletas 
      SET stock = n_stock
      WHERE id = id_bici;
  END //
  DELIMITER ;
  ```

  

El procedimiento almacenado actualiza el stock de cada bicicleta.

```sql
CALL actualizar_inventario_bicicletas_vendidas(1,2);
```



### Caso de Uso 2: Registro de Nueva Venta

El vendedor registra una nueva venta.

```sql
DELIMITER //
CREATE PROCEDURE registrar_venta(
    IN cliente_id INT,
    IN fecha DATE,
    IN bicicleta_id INT,
    IN cantidad INT,
    IN precio_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE venta_id INT;

    INSERT INTO ventas (fecha, cliente_id)
    VALUES (fecha, cliente_id);

    SET venta_id = LAST_INSERT_ID();

    INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (venta_id, bicicleta_id, cantidad, precio_unitario);

    UPDATE bicicletas
    SET stock = stock - cantidad
    WHERE id = bicicleta_id;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para registrar la venta y sus detalles.

```sql
CALL registrar_venta(1, '2023-03-01', 1, 2, 100.00);
```



### Caso de Uso 3: Generación de Reporte de Ventas por Cliente

El administrador selecciona un cliente para generar un reporte de ventas.

```sql
SELECT id, fecha, cliente_id
FROM ventas
WHERE cliente_id = 1;
```



El sistema llama a un procedimiento almacenado para generar el reporte.

```sql
DELIMITER //
CREATE PROCEDURE generarreporte()
BEGIN
    SELECT id, fecha, cliente_id
    FROM ventas
    WHERE cliente_id = 1;
END //

DELIMITER ;

CALL generarreporte();   

+----+------------+------------+
| id | fecha      | cliente_id |
+----+------------+------------+
|  1 | 2023-01-15 |          1 |
+----+------------+------------+
```



El procedimiento almacenado obtiene las ventas y los detalles de las ventas realizadas por el
cliente.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE detallescliente()
  BEGIN 
  	SELECT c.nombre AS "nombre del cliente", v.id AS "id de la venta",  v.fecha AS "fecha de venta", dv.cantidad, dv.precio_unitario
  		FROM clientes AS c
  		JOIN ventas AS v ON c.id = v.cliente_id
  		JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id;
  END //
  
  DELIMITER ;
  
  CALL detallescliente();
  ```

  

### Caso de Uso 4: Registro de Compra de Repuestos

El administrador registra una nueva compra.

```sql
INSERT INTO compras (fecha, proveedor_id, total)
VALUES ('2024-07-26', 1, 20000.00);
```



El sistema llama a un procedimiento almacenado para registrar la compra y sus detalles.

```sql
DELIMITER //
CREATE PROCEDURE aggcompraydetalles(
	IN nfecha DATE,
    IN nproveedor_id INT,
    IN ntotal DECIMAL(10, 2),
    IN ncompra_id INT,
    IN nrepuesto_id INT, 
    IN ncantidad INT,
    IN npreciounitario DECIMAL(10,2)
)
BEGIN 
	INSERT INTO compras (fecha, proveedor_id, total) 
	VALUES (nfecha, nproveedor_id, ntotal);
	
	INSERT INTO  detalles_de_compras (compra_id, repuesto_id, cantidad, precio_unitario)
	VALUES (ncompra_id, nrepuesto_id, ncantidad, npreciounitario);

END //

DELIMITER ;

CALL aggcompraydetalles('2024-07-26', 1, 20000.00, 6, 1,4, 5000.00);
```



El procedimiento almacenado inserta la compra y sus detalles en las tablas correspondientes
y actualiza el stock de repuestos.

  ```sql
  DELIMITER //
  CREATE PROCEDURE aggcompraydetalles(
  	IN nfecha DATE,
      IN nproveedor_id INT,
      IN ntotal DECIMAL(10, 2),
      IN ncompra_id INT,
      IN nrepuesto_id INT, 
      IN ncantidad INT,
      IN npreciounitario DECIMAL(10,2)
  )
  BEGIN 
  	INSERT INTO compras (fecha, proveedor_id, total) 
  	VALUES (nfecha, nproveedor_id, ntotal);
  	
  	INSERT INTO  detalles_de_compras (compra_id, repuesto_id, cantidad, precio_unitario)
  	VALUES (ncompra_id, nrepuesto_id, ncantidad, npreciounitario);
  	
  	UPDATE repuestos
      SET stock = stock - ncantidad
      WHERE id = nrepuesto_id;
  END //
  
  DELIMITER ;
  
  CALL aggcompraydetalles('2024-07-26', 1, 20000.00, 6, 1,4, 5000.00);
  ```

  

### Caso de Uso 5: Generación de Reporte de Inventario

El administrador solicita un reporte de inventario.

```sql
DELIMITER //
CREATE PROCEDURE generar_reporte_inventario()
BEGIN
    SELECT 'Bicicleta' AS tipo, b.id AS id_producto, m.nombre AS modelo, ma.nombre AS marca, b.precio, b.stock
    FROM bicicletas b
    INNER JOIN modelo m ON b.modelo = m.id
    INNER JOIN marca ma ON b.marca = ma.id

    UNION ALL

    SELECT 'Repuesto' AS tipo, r.id AS id_producto, r.nombre AS modelo, r.descripcion AS marca, r.precio, r.stock
    FROM repuestos r;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para generar el reporte.

```sql
CALL generar_reporte_inventario();
```



El procedimiento almacenado obtiene la información del inventario de bicicletas y repuestos.

```sql

```



### Caso de Uso 6: Actualización Masiva de Precios

El sistema llama a un procedimiento almacenado para actualizar los precios.

```sql
DELIMITER //
CREATE PROCEDURE actualizar_precios_marca(IN marca_id INT, IN porcentaje DECIMAL(10,2))
BEGIN
    UPDATE bicicletas
    SET precio = precio * (1 + porcentaje / 100)
    WHERE marca = marca_id;

    UPDATE repuestos
    SET precio = precio * (1 + porcentaje / 100)
    WHERE marca = marca_id;
END //
DELIMITER ;
```



El procedimiento almacenado actualiza los precios de todas las bicicletas de la marca
especificada.

  ```sql
  CALL actualizar_precios_marca(1, 10.00);
  ```

  

### Caso de Uso 7: Generación de Reporte de Clientes por Ciudad

El administrador selecciona la opción para generar un reporte de clientes por ciudad.

```sql
DELIMITER //
CREATE PROCEDURE reporte_clientes_ciudad()
BEGIN
    SELECT c.nombre AS ciudad, COUNT(cl.id) AS cantidad_clientes
    FROM ciudades c
    INNER JOIN clientes cl ON c.id = cl.ciudad_id
    GROUP BY c.nombre
    ORDER BY cantidad_clientes DESC;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para generar el reporte.

```sql
CALL reporte_clientes_ciudad();
```



El procedimiento almacenado obtiene la información de los clientes agrupados por ciudad.

```sql

```



### Caso de Uso 8: Verificación de Stock antes de Venta

El vendedor selecciona una bicicleta para vender.

```sql
DELIMITER //
CREATE PROCEDURE verificar_stock_bicicletas(IN id_bicicleta INT, IN cantidad INT)
BEGIN
    DECLARE stock_actual INT;
    DECLARE mensaje VARCHAR(100);

    SELECT stock INTO stock_actual
    FROM bicicletas
    WHERE id = id_bicicleta;

    IF stock_actual >= cantidad THEN
        SET mensaje = 'Hay suficiente stock para la venta.';
    ELSE
        SET mensaje = 'No hay suficiente stock para la venta.';
    END IF;

    SELECT mensaje AS resultado;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para verificar el stock.

```sql
CALL verificar_stock_bicicletas(1, 2);
```



El procedimiento almacenado devuelve un mensaje indicando si hay suficiente stock para
realizar la venta.

  ```sql
  
  ```

  

### Caso de Uso 9: Registro de Devoluciones

El vendedor registra una devolución de bicicleta.

```sql
DELIMITER //
CREATE PROCEDURE registrar_devolucion_bicicleta(IN id_venta INT, IN id_bicicleta INT, IN cantidad INT)
BEGIN
    DECLARE stock_actual INT;
    DECLARE mensaje VARCHAR(100);

    -- miramos si la venta se hizo antes
    IF NOT EXISTS (SELECT 1 FROM ventas WHERE id = id_venta) THEN
        SET mensaje = 'La venta no existe.';
        SELECT mensaje AS resultado;
        RETURN;
    END IF;

    -- miramos si la bicicleta existe
    IF NOT EXISTS (SELECT 1 FROM bicicletas WHERE id = id_bicicleta) THEN
        SET mensaje = 'La bicicleta no existe.';
        SELECT mensaje AS resultado;
        RETURN;
    END IF;

    -- miramos si lo que se devuelve es mas de lo que se vendio
    IF cantidad > (SELECT cantidad FROM detalles_de_ventas WHERE venta_id = id_venta AND bicicleta_id = id_bicicleta) THEN
        SET mensaje = 'La cantidad a devolver es mayor que la cantidad vendida.';
        SELECT mensaje AS resultado;
        RETURN;
    END IF;

    -- actualizar stock
    SELECT stock INTO stock_actual FROM bicicletas WHERE id = id_bicicleta;
    UPDATE bicicletas SET stock = stock_actual + cantidad WHERE id = id_bicicleta;

    -- registrar devolucion
    INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (id_venta, id_bicicleta, -cantidad, (SELECT precio_unitario FROM detalles_de_ventas WHERE venta_id = id_venta AND bicicleta_id = id_bicicleta));

    SET mensaje = 'La devolución ha sido registrada con éxito.';
    SELECT mensaje AS resultado;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para registrar la devolución.

```sql
CALL registrar_devolucion_bicicleta(1, 1, 1);
```



El procedimiento almacenado inserta la devolución y actualiza el stock de la bicicleta.

```sql

```



### Caso de Uso 10: Generación de Reporte de Compras por Proveedor

El administrador selecciona un proveedor para generar un reporte de compras.

```sql
DELIMITER //

CREATE PROCEDURE reporte_compras_proveedor(IN fecha_inicio DATE, IN fecha_fin DATE)
BEGIN
    SELECT 
        p.nombre AS proveedor,
        SUM(dc.cantidad * dc.precio_unitario) AS total_compras,
        COUNT(c.id) AS cantidad_compras
    FROM compras c
    INNER JOIN detalles_de_compras dc ON c.id = dc.compra_id
    INNER JOIN repuestos r ON dc.repuesto_id = r.id
    INNER JOIN proveedores p ON r.proveedor_id = p.id
    WHERE c.fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY p.nombre
    ORDER BY total_compras DESC;
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para generar el reporte.

```sql
CALL reporte_compras_proveedor('2022-01-01', '2022-12-31');
```



El procedimiento almacenado obtiene las compras y los detalles de las compras realizadas al
proveedor.

  ```sql
  
  ```

  

### Caso de Uso 11: Calculadora de Descuentos en Ventas

El vendedor aplica un descuento a una venta.

```sql
DELIMITER //

CREATE PROCEDURE calcular_descuento(IN cliente_id INT, IN bicicleta_id INT, IN cantidad INT, IN fecha DATE)
BEGIN
    DECLARE precio_unitario DECIMAL(10,2);
    DECLARE total DECIMAL(10,2);
    DECLARE descuento DECIMAL(10,2);
    DECLARE total_con_descuento DECIMAL(10,2);

    SELECT precio INTO precio_unitario FROM bicicletas WHERE id = bicicleta_id;
    SET total = precio_unitario * cantidad;
    SET descuento = total * 0.10; -- calcular el descuento
    SET total_con_descuento = total - descuento; -- total con descuento
    
    INSERT INTO ventas (fecha, cliente_id) VALUES (fecha, cliente_id);
    SET @venta_id = LAST_INSERT_ID(); -- tener el id de la venta creada

    INSERT INTO detalles_de_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (@venta_id, bicicleta_id, cantidad, precio_unitario);

    UPDATE bicicletas SET stock = stock - cantidad WHERE id = bicicleta_id;
    SELECT total_con_descuento AS resultado; -- mostrar el total con el descuento
END //
DELIMITER ;
```



El sistema llama a un procedimiento almacenado para calcular el total con descuento.

```sql
CALL calcular_descuento(1, 1, 2, '2022-01-01');
```



El procedimiento almacenado calcula el total con el descuento aplicado y registra la venta.

```sql

```





## Casos de Uso para Funciones de Resumen



### Caso de Uso 1: Calcular el Total de Ventas Mensuales

El administrador selecciona la opción para calcular el total de ventas mensuales.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario) AS Total_ventas
FROM ventas AS v
JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
WHERE v.fecha BETWEEN 'fecha inicial' AND 'fecha final';
```



El administrador ingresa el mes y el año.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario) AS Total_ventas
FROM ventas AS v
JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
WHERE v.fecha BETWEEN '2023-05-01' AND '2023-05-31';
```



El sistema llama a un procedimiento almacenado para calcular el total de ventas.

```sql
DELIMITER //

CREATE PROCEDURE promediodeventastotal()
BEGIN 
    SELECT SUM(dv.cantidad * dv.precio_unitario) AS Total_ventas
    FROM ventas AS v
    JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id;
END //

DELIMITER ;

CALL promediodeventastotal();
```



El procedimiento almacenado devuelve el total de ventas del mes especificado.

```sql
ventas realizadas en el mes de mayo (05)
DELIMITER //

CREATE PROCEDURE promediodeventasmes(
	IN inicio DATE,
	IN FINAL DATE
)
BEGIN 
	SELECT SUM(dv.cantidad * dv.precio_unitario) AS Total_ventas
    FROM ventas AS v
    JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
    WHERE v.fecha BETWEEN inicio AND FINAL;
END //

DELIMITER ;
CALL promediodeventasmes('2023-05-01', '2023-05-31');
```



### Caso de Uso 2: Calcular el Promedio de Ventas por Cliente

El sistema llama a un procedimiento almacenado para calcular el promedio de ventas.

```sql
DELIMITER //

CREATE PROCEDURE promediodeventas()
BEGIN 
    SELECT AVG(dv.cantidad * dv.precio_unitario) AS 'promedio total de ventas'
    FROM ventas AS v
    JOIN detalles_de_ventas AS dv ON v.id = dv. venta_id;
END //

DELIMITER ;

CALL promediodeventas();
```



El procedimiento almacenado devuelve el promedio de ventas del cliente especificado.

```sql
promedio del cliente 1

DELIMITER //

CREATE PROCEDURE promedioventas(
	IN id_cliente INT
)

BEGIN 
    SELECT AVG(dv.cantidad * dv.precio_unitario) AS 'promedio total de ventas'
    FROM ventas AS v
    JOIN detalles_de_ventas AS dv ON v.id = dv. venta_id
    JOIN clientes AS c ON v.cliente_id = c.id
    WHERE c.id = id_cliente;
END //

DELIMITER ;

CALL promedioventas(1);
```



### Caso de Uso 3: Contar el Número de Ventas Realizadas en un Rango de Fechas

El administrador selecciona la opción para contar el número de ventas en un rango de
fechas.

  ```sql
  SELECT COUNT(dv.cantidad) AS 'cantidad de ventas'
  FROM ventas AS v
  JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
  WHERE v.fecha BETWEEN 'FECHA INICIO' AND 'FECHA FINAL';
  ```

  

El administrador ingresa las fechas de inicio y fin.

```sql
SELECT COUNT(dv.cantidad) AS 'cantidad de ventas'
FROM ventas AS v
JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
WHERE v.fecha BETWEEN '2023-05-01' AND '2023-05-31';
```



El sistema llama a un procedimiento almacenado para contar las ventas.

```sql
DELIMITER //

CREATE PROCEDURE ventastotales()

BEGIN
	SELECT COUNT(dv.cantidad) AS 'cantidad de ventas'
	FROM ventas AS v
	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id;
END //

DELIMITER ;
CALL ventastotales();
```



El procedimiento almacenado devuelve el número de ventas en el rango de fechas
especificado.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE ventasporrango(
  	IN fechainicial DATE,
  	IN fechafinal DATE
  )
  
  BEGIN
  	SELECT COUNT(dv.cantidad) AS 'cantidad de ventas'
  	FROM ventas AS v
  	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
  	WHERE v.fecha BETWEEN fechainicial AND fechafinal;
  END //
  
  DELIMITER ;
  CALL ventasporrango('2023-05-01', '2023-05-31');
  
  
  ```

  

### Caso de Uso 4: Calcular el Total de Repuestos Comprados por Proveedor

El administrador selecciona la opción para calcular el total de repuestos comprados por
proveedor.

  ```sql
  SELECT COUNT(dc.cantidad)
  FROM compras AS c
  JOIN detalles_de_compras AS dc ON c.id = dc.compra_id
  JOIN proveedores AS p ON c.proveedor_id = p.id;
  ```

  

El administrador ingresa el ID del proveedor.

```sql
SELECT COUNT(dc.cantidad)
FROM compras AS c
JOIN detalles_de_compras AS dc ON c.id = dc.compra_id
JOIN proveedores AS p ON c.proveedor_id = p.id
WHERE p.id = 1;
```



El sistema llama a un procedimiento almacenado para calcular el total de repuestos.

```sql
DELIMITER //

CREATE PROCEDURE CalcularTotalRepuestos()
BEGIN
    SELECT 
    	SUM(r.precio * r.stock) AS Total_repuestos
    FROM 
        repuestos r;
END //

DELIMITER ;

CALL CalcularTotalRepuestos();
```



El procedimiento almacenado devuelve el total de repuestos comprados al proveedor
especificado.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE TotalRepuestosPorProveedor(
      IN proveedor_id INT
  )
  BEGIN
      SELECT 
          SUM(dc.precio_unitario * dc.cantidad) AS Total_repuestos
      FROM 
          detalles_de_compras dc
      JOIN 
          repuestos r ON dc.repuesto_id = r.id
      WHERE 
          r.proveedor_id = proveedor_id;
  END //
  
  DELIMITER ;
  
  CALL TotalRepuestosPorProveedor(1);
  ```

  

### Caso de Uso 5: Calcular el Ingreso Total por Año

El administrador selecciona la opción para calcular el ingreso total por año.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario ) AS 'ingresos anuales'
	FROM ventas AS v
	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
	WHERE v.fecha BETWEEN FECHA INICIAL AND FECHA FINAL;
```



El administrador ingresa el año.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario ) AS 'ingresos anuales'
	FROM ventas AS v
	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
	WHERE v.fecha BETWEEN '2023-01-01' AND '2023-12-31';
```



El sistema llama a un procedimiento almacenado para calcular el ingreso total.

```sql
DELIMITER //

CREATE PROCEDURE ingresostotales()

BEGIN 
	SELECT SUM(cantidad * precio_unitario) AS 'ingresos totales'
	FROM detalles_de_ventas;

END // 

DELIMITER ;
CALL ingresostotales();
```



El procedimiento almacenado devuelve el ingreso total del año especificado.

```sql
DELIMITER //
CREATE PROCEDURE ingresostotalesaño(
	IN fechainc DATE,
    IN fechafin DATE
)

BEGIN 
	SELECT SUM(dv.cantidad * dv.precio_unitario ) AS 'ingresos anuales'
	FROM ventas AS v
	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
	WHERE v.fecha BETWEEN fechainc AND fechafin;
END //

DELIMITER ;

CALL ingresostotalesaño('2023-01-01','2023-12-31');
```



### Caso de Uso 6: Calcular el Número de Clientes Activos en un Mes

El administrador selecciona la opción para contar el número de clientes activos en un mes.

```sql
SELECT c.nombre, v.fecha
	FROM clientes AS c
	JOIN ventas AS v ON c.id = v.cliente_id
	WHERE v.fecha BETWEEN FECHA INICIAL AND FECHA FINAL;
```



El administrador ingresa el mes y el año.

```sql
SELECT c.nombre, v.fecha
	FROM clientes AS c
	JOIN ventas AS v ON c.id = v.cliente_id
	WHERE v.fecha BETWEEN '2023-05-01' AND '2023-05-31';
```



El sistema llama a un procedimiento almacenado para contar los clientes activos.

```sql
DELIMITER //

CREATE PROCEDURE clientesactivos()

BEGIN 
	SELECT nombre
	FROM clientes;
END //

DELIMITER ;

CALL clientesactivos();
```



El procedimiento almacenado devuelve el número de clientes que han realizado compras en
el mes especificado.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE clientemasactivo(
  	IN mesinial DATE,
      IN mesfinal DATE
  )
  
  BEGIN 
  	SELECT c.nombre, v.fecha
  	FROM clientes AS c
  	JOIN ventas AS v ON c.id = v.cliente_id
  	WHERE v.fecha BETWEEN mesinial AND mesfinal;
  END //
  
  DELIMITER ;
  
  CALL clientemasactivo('2023-05-01', '2023-05-31' );
  ```

  

### Caso de Uso 7: Calcular el Promedio de Compras por Proveedor

El administrador selecciona la opción para calcular el promedio de compras por proveedor.

```sql
SELECT dc.cantidad, p.nombre
FROM detalles_de_compras AS dc
JOIN compras AS c ON dc.compra_id = c.id
JOIN proveedores AS p ON c.proveedor_id = p.id; 
```



El administrador ingresa el ID del proveedor.

```sql
SELECT dc.cantidad, p.nombre
FROM detalles_de_compras AS dc
JOIN compras AS c ON dc.compra_id = c.id
JOIN proveedores AS p ON c.proveedor_id = p.id
WHERE p.id = 1;
```



El sistema llama a un procedimiento almacenado para calcular el promedio de compras.

```sql
DELIMITER // 

CREATE PROCEDURE promediocompras()

BEGIN 
	SELECT AVG(dc.cantidad)
    FROM detalles_de_compras AS dc
    JOIN compras AS c ON dc.compra_id = c.id
    JOIN proveedores AS p ON c.proveedor_id = p.id; 
END //

DELIMITER ;

CALL promediocompras();
```



El procedimiento almacenado devuelve el promedio de compras del proveedor especificado.

```sql
DELIMITER // 

CREATE PROCEDURE promediocomprasproveedor(
	IN id INT
)

BEGIN 
	SELECT AVG(dc.cantidad) AS 'promedio del proveedor'
    FROM detalles_de_compras AS dc
    JOIN compras AS c ON dc.compra_id = c.id
    JOIN proveedores AS p ON c.proveedor_id = p.id
    WHERE p.id = id;
END //

DELIMITER ;

CALL promediocomprasproveedor(1);
```



### Caso de Uso 8: Calcular el Total de Ventas por Marca

El administrador selecciona la opción para calcular el total de ventas por marca.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario) AS total_ventas,
	m.nombre AS marca
FROM detalles_de_ventas AS dv
JOIN bicicletas AS b ON dv.bicicleta_id = b.id
JOIN marca AS m ON m.id = b.marca
GROUP BY m.nombre;
```



El sistema llama a un procedimiento almacenado para calcular el total de ventas por marca.

```sql
DELIMITER //

CREATE PROCEDURE totalventasmarca()

BEGIN
	SELECT SUM(dv.cantidad * dv.precio_unitario) AS total_ventas,
        m.nombre AS marca
    FROM detalles_de_ventas AS dv
    JOIN bicicletas AS b ON dv.bicicleta_id = b.id
    JOIN marca AS m ON m.id = b.marca
    GROUP BY m.nombre;
END //

DELIMITER ;

CALL totalventasmarca();
```



El procedimiento almacenado devuelve el total de ventas agrupadas por marca.

```sql
DELIMITER //

CREATE PROCEDURE totalventasagrupadasmarca()

BEGIN
	SELECT SUM(dv.cantidad * dv.precio_unitario) AS total_ventas
    FROM detalles_de_ventas AS dv
    JOIN bicicletas AS b ON dv.bicicleta_id = b.id
    JOIN marca AS m ON m.id = b.marca;
END //

DELIMITER ;

CALL totalventasagrupadasmarca();
```



### Caso de Uso 9: Calcular el Promedio de Precios de Bicicletas por Marca

El administrador selecciona la opción para calcular el promedio de precios por marca.

```sql
SELECT AVG(dv.cantidad * dv.precio_unitario) AS total_ventas,
    m.nombre AS marca
FROM detalles_de_ventas AS dv
JOIN bicicletas AS b ON dv.bicicleta_id = b.id
JOIN marca AS m ON m.id = b.marca
GROUP BY m.nombre;
```



El sistema llama a un procedimiento almacenado para calcular el promedio de precios.

```sql
DELIMITER //

CREATE PROCEDURE promedioventasmarca()

BEGIN
	SELECT AVG(dv.cantidad * dv.precio_unitario) AS total_ventas,
        m.nombre AS marca
    FROM detalles_de_ventas AS dv
    JOIN bicicletas AS b ON dv.bicicleta_id = b.id
    JOIN marca AS m ON m.id = b.marca
    GROUP BY m.nombre;
END //

DELIMITER ;

CALL promedioventasmarca();
```



El procedimiento almacenado devuelve el promedio de precios agrupadas por marca.

```sql
DELIMITER //

CREATE PROCEDURE promedioventasagrupadasmarca()

BEGIN
	SELECT SUM(dv.cantidad * dv.precio_unitario) AS total_ventas
    FROM detalles_de_ventas AS dv
    JOIN bicicletas AS b ON dv.bicicleta_id = b.id
    JOIN marca AS m ON m.id = b.marca;
END //

DELIMITER ;

CALL promedioventasagrupadasmarca();
```



### Caso de Uso 10: Contar el Número de Repuestos por Proveedor

El administrador selecciona la opción para contar el número de repuestos por proveedor.

```sql
SELECT dc.cantidad, p.nombre
FROM detalles_de_compras AS dc
JOIN REPUESTOS as r ON dc.repuesto_id = r.id
JOIN proveedores AS p ON r.proveedor_id = p.id;
```



El sistema llama a un procedimiento almacenado para contar los repuestos.

```sql
DELIMITER //

CREATE PROCEDURE contarrepuestos()

BEGIN 
 SELECT SUM(cantidad)
 FROM detalles_de_compras;
END //

DELIMITER ;
CALL contarrepuestos();
```



El procedimiento almacenado devuelve el número de repuestos suministrados por cada
proveedor.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE repuestosdeproveedor()
  
  BEGIN 
   SELECT dc.cantidad, p.nombre
      FROM detalles_de_compras AS dc
      JOIN REPUESTOS as r ON dc.repuesto_id = r.id
      JOIN proveedores AS p ON r.proveedor_id = p.id;
  END //
  
  DELIMITER ;
  CALL repuestosdeproveedor();
  ```

  

### Caso de Uso 11: Calcular el Total de Ingresos por Cliente

El administrador selecciona la opción para calcular el total de ingresos por cliente.

```sql
SELECT SUM(dv.cantidad * dv.precio_unitario) AS 'ingresos por cliente',
	c.nombre AS nombre_cliente
	FROM detalles_de_ventas AS dv
	JOIN ventas AS v ON dv.venta_id = v.id
	JOIN clientes AS c ON c.id = v.cliente_id
	GROUP BY c.nombre;
```



El sistema llama a un procedimiento almacenado para calcular el total de ingresos.

```sql
procedimiento agregado anteriormente
CALL ingresostotales();
```



El procedimiento almacenado devuelve el total de ingresos generados por cada cliente.

```sql
DELIMITER //

CREATE PROCEDURE totalingresoscliente()

BEGIN
    SELECT SUM(dv.cantidad * dv.precio_unitario) AS 'ingresos por cliente',
        c.nombre AS nombre_cliente
        FROM detalles_de_ventas AS dv
        JOIN ventas AS v ON dv.venta_id = v.id
        JOIN clientes AS c ON c.id = v.cliente_id
        GROUP BY c.nombre;
END //

DELIMITER ;

CALL totalingresoscliente();
```



### Caso de Uso 12: Calcular el Promedio de Compras Mensuales

El administrador selecciona la opción para calcular el promedio de compras mensuales.

```sql
SELECT ROUND(AVG(total)), fecha
FROM compras
GROUP BY fecha;
```



El sistema llama a un procedimiento almacenado para calcular el promedio de compras
mensuales.

  ```sql
  DELIMITER //
  
  CREATE PROCEDURE promediocomprasmensual()
  
  BEGIN
      SELECT ROUND(AVG(total)) AS Promedio_compras, fecha
      FROM compras
      GROUP BY fecha;
  END //
  
  DELIMITER ;
  
  CALL promediocomprasmensual();
  ```

  

El procedimiento almacenado devuelve el promedio de compras realizadas mensualmente.

```sql
CALL promediocomprasmensual();

+-------------------+------------+
| Promedio_compras  | fecha      |
+-------------------+------------+
|           2100000 | 2023-01-10 |
|           3150000 | 2023-02-15 |
|           4230000 | 2023-03-20 |
|           1560000 | 2023-04-25 |
|           2330000 | 2023-05-30 |
+-------------------+------------+
```



### Caso de Uso 13: Calcular el Total de Ventas por Día de la Semana

El administrador selecciona la opción para calcular el total de ventas por día de la semana.

```sql
SELECT 
        DATE_FORMAT(v.fecha, '%W') AS dia_semana,
        ROUND(SUM(dv.cantidad * dv.precio_unitario)) AS total_ventas
    FROM 
        ventas AS v
    JOIN 
        detalles_de_ventas AS dv ON v.id = dv.venta_id
    JOIN 
        bicicletas AS b ON dv.bicicleta_id = b.id
    GROUP BY 
        dia_semana
    ORDER BY 
        FIELD(dia_semana, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo');
```



El sistema llama a un procedimiento almacenado para calcular el total de ventas.

```sql
CALL ingresostotales();
```



El procedimiento almacenado devuelve el total de ventas agrupadas por día de la semana.

```sql
DELIMITER //

CREATE PROCEDURE ventassemanales()

BEGIN
    SELECT 
        DATE_FORMAT(v.fecha, '%W') AS dia_semana,
        ROUND(SUM(dv.cantidad * dv.precio_unitario)) AS total_ventas
    FROM 
        ventas AS v
    JOIN 
        detalles_de_ventas AS dv ON v.id = dv.venta_id
    JOIN 
        bicicletas AS b ON dv.bicicleta_id = b.id
    GROUP BY 
        dia_semana
    ORDER BY 
        FIELD(dia_semana, 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo');
END //

DELIMITER ;

CALL ventassemanales();
```



### Caso de Uso 14: Contar el Número de Ventas por Categoría de Bicicleta

El administrador selecciona la opción para contar el número de ventas por categoría de
bicicleta.

  ```sql
  SELECT m.nombre, dv.cantidad
  FROM modelo AS m
  JOIN bicicletas AS b ON m.id = b.modelo
  JOIN detalles_de_ventas AS dv ON b.id = dv.bicicleta_id;
  ```

  

El sistema llama a un procedimiento almacenado para contar las ventas.

```sql
DELIMITER //

CREATE PROCEDURE contarventas()

BEGIN
    SELECT SUM(cantidad) AS 'contar ventas'
	FROM detalles_de_ventas;
END //

DELIMITER ;

CALL contarventas();
```



El procedimiento almacenado devuelve el número de ventas por categoría de bicicleta.

```sql
DELIMITER //

CREATE PROCEDURE ventasmodelo()

BEGIN
    SELECT m.nombre, dv.cantidad
    FROM modelo AS m
    JOIN bicicletas AS b ON m.id = b.modelo
    JOIN detalles_de_ventas AS dv ON b.id = dv.bicicleta_id;
END //

DELIMITER ;

CALL ventasmodelo();
```



### Caso de Uso 15: Calcular el Total de Ventas por Año y Mes

El sistema llama a un procedimiento almacenado para calcular el total de ventas.

```sql
DELIMITER //

CREATE PROCEDURE ventastotalesbicis()

BEGIN 
	SELECT SUM(cantidad * precio_unitario) AS 'ventas totales'
	FROM detalles_de_ventas;

END // 

DELIMITER ;
CALL ventastotalesbicis();
```



El procedimiento almacenado devuelve el total de ventas agrupadas por año y mes.

```sql
DELIMITER //
CREATE PROCEDURE ventastotalesaño(
	IN fechainc DATE,
    IN fechafin DATE
)

BEGIN 
	SELECT SUM(dv.cantidad * dv.precio_unitario ) AS 'ventas anuales'
	FROM ventas AS v
	JOIN detalles_de_ventas AS dv ON v.id = dv.venta_id
	WHERE v.fecha BETWEEN fechainc AND fechafin;
END //

DELIMITER ;

CALL ventastotalesaño('2023-01-01','2023-12-31');
```

