use tienda;

-- 1.- Función que recibe el DNI de un cliente y muestra el total de lo gastado por dicho cliente. En caso de que el cliente no exista o ese cliente no haya realizado ningún pedido, el resultado deberá de ser 0.

SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER &&
DROP FUNCTION IF EXISTS gasto_total_cliente&&
CREATE FUNCTION gasto_total_cliente (DNI_cliente VARCHAR(9))
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(lp.Cantidad*lp.PrecioUnidad) into total
    FROM linea_pedido lp
    INNER JOIN pedidos p ON lp.id_Pedidos = p.id_Pedidos
    INNER JOIN clientes c ON p.Clientes_DNI = c.DNI
    WHERE c.DNI = DNI_cliente;
    IF total IS NULL THEN
        SET total = 0;
    END IF;
    RETURN total;
end&&

DELIMITER ;
SELECT gasto_total_cliente('78948561');
SELECT gasto_total_cliente('10869088');

-- 2.- Función al que se le pasa la id_categoria y liste los productos que corresponden a esa categoría
SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER &&
DROP FUNCTION IF EXISTS productos_por_categoria&&
CREATE FUNCTION productos_por_categoria (
categoria_id INT
)
RETURNS VARCHAR(10000)
BEGIN
    DECLARE productos VARCHAR(255) DEFAULT '';
    SELECT GROUP_CONCAT(p.id_productos SEPARATOR ', ') INTO productos
    FROM productos p
    INNER JOIN categorias c ON p.id_categoria = c.id_categoria
    WHERE c.id_categoria = categoria_id;
    RETURN productos;
end&&

DELIMITER ;
SELECT productos_por_categoria(25);

-- 1.- Muestra la cantidad de pedidos que cada cliente ha realizado en un año concreto, ordenados de mayor a menor.
DELIMITER &&
DROP PROCEDURE IF EXISTS contar_pedidos_por_cliente_en_anio &&
CREATE PROCEDURE contar_pedidos_por_cliente_en_anio(IN anio INT)
BEGIN
    SELECT Clientes_DNI, COUNT(*) AS cantidad_pedidos
    FROM pedidos
    WHERE YEAR(fecha_pedido) = anio
    GROUP BY Clientes_DNI
    ORDER BY cantidad_pedidos DESC;
END &&

-- 2.- Procedimiento que recibe el DNI del cliente y muestre el total consumido y los datos del cliente.
DELIMITER &&
DROP PROCEDURE IF EXISTS detalle_cliente&&
CREATE PROCEDURE detalle_cliente(IN DNI_cliente INT)
BEGIN
    select c.*, gasto_total_cliente(DNI_cliente)
    from clientes c
    where c.DNI = DNI_cliente;
END&&

DELIMITER ;
CALL detalle_cliente('78948561');

-- 3.- Procedimiento que introduciendo un id_producto, nos devuelva la cantidad que se ha pedido en total ese producto
DELIMITER &&
DROP PROCEDURE IF EXISTS numero_veces_pedidos&&
CREATE PROCEDURE numero_veces_pedidos (
IN id_producto INT,
OUT num_pedidos INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE cantidad INT;
    DECLARE cur CURSOR FOR SELECT lp.Cantidad FROM linea_pedido lp WHERE lp.id_productos = id_producto;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    SET num_pedidos = 0;
    OPEN cur;
        read_loop: LOOP
            FETCH cur INTO cantidad;
            IF done THEN
                LEAVE read_loop;
            END IF;
        SET num_pedidos = num_pedidos + cantidad;
        END LOOP;
    CLOSE cur;
end&&

DELIMITER ;
CALL numero_veces_pedidos(4, @num_pedidos);
SELECT @num_pedidos;


-- 1.- Muestra la cantidad de pedidos año 2023, agrupados por el DNI del cliente. Se debe incluir el nombre y apellidos del cliente en la consulta

SELECT p.Clientes_DNI,c.nombre , c.apellidos , COUNT(p.Clientes_DNI) AS cantidad_pedidos
FROM pedidos p
inner join clientes c on c.DNI = p.Clientes_DNI
WHERE YEAR(p.fecha_pedido) = 2023
GROUP BY p.Clientes_DNI
ORDER BY cantidad_pedidos DESC;

-- 2.- Muestre el nombre de los productos los cuales se hayan facturado(pedido en total) más 1000 y menos que 1250 y cuantas veces se han pedido
SELECT p.nombre_productos , sum(lp.Cantidad) as Cantidad
FROM linea_pedido lp
inner join productos p on p.id_productos = lp.id_productos
GROUP BY lp.id_productos
HAVING Cantidad > 1000 and Cantidad < 1250;

--3.- Muestra el total gastado por el cliente con el DNI 78948561. Podemos utilizar la función ya realizada anteriormente “gasto_total_cliente”:
SELECT gasto_total_cliente('78948561');

-- 4.- Listado de clientes que muestra la cantidad de productos comprados y el total que se han gastado (incluir el tipo de moneda, ejemplo: 40€ ), ordenados de mayor a menor según la cantidad.
select c.nombre, sum(lp.Cantidad) as cantidad, concat((sum(lp.Cantidad*lp.PrecioUnidad)), '€') as Total_gastado
from clientes c
inner join pedidos p on c.DNI = p.Clientes_DNI
inner join linea_pedido lp on lp.id_Pedidos = p.id_Pedidos
group by c.nombre
order by cantidad DESC;

-- 5.-Lista la cantidad de pedidos que se han hecho en cada ciudad, ordenando de manera descendente y cual ha sido el pedido más grande registrado en cada ciudad (no hace falta incluir que tipo de producto es el que se ha pedido.
SELECT p.ciudad, count(*) as pedidos, max(lp.Cantidad)
FROM pedidos p
inner join linea_pedido lp on lp.id_Pedidos = p.id_Pedidos
inner join productos p2 on lp.id_productos = p2.id_productos
group by p.ciudad
order by pedidos DESC;

-- 1.- Vista
CREATE VIEW vista_linea_pedido_1000_1250 AS
SELECT p.nombre_productos , sum(lp.Cantidad) as Cantidad
FROM linea_pedido lp
inner join productos p on p.id_productos = lp.id_productos
GROUP BY lp.id_productos
HAVING Cantidad > 1000 and Cantidad < 1250;


SELECT *
FROM vista_linea_pedido_1000_1250 ;

-- 2.- Vista
CREATE VIEW vista_pedidos_por_ciudad AS
SELECT p.ciudad, count(*) as pedidos, max(lp.Cantidad)
FROM pedidos p
inner join linea_pedido lp on lp.id_Pedidos = p.id_Pedidos
inner join productos p2 on lp.id_productos = p2.id_productos
group by p.ciudad
order by pedidos DESC;


SELECT *
FROM vista_pedidos_por_ciudad;

-- Generación tabla trigger
DROP TABLE IF EXISTS log_clientes;
CREATE TABLE log_clientes (
id INT NOT NULL AUTO_INCREMENT,
accion VARCHAR(10) NOT NULL,
DNI VARCHAR(9) NOT NULL,
nombre VARCHAR(45),
apellidos VARCHAR(70),
telefono VARCHAR(20),
direccion VARCHAR(70),
fecha DATETIME NOT NULL,
PRIMARY KEY (id)
);

-- 1.- Trigger
DELIMITER &&
DROP TRIGGER IF EXISTS tr_insert_cliente&&
CREATE TRIGGER tr_insertar_cliente
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO log_clientes (accion, DNI, nombre, apellidos, telefono, direccion, fecha)
    VALUES ('INSERT', NEW.DNI, NEW.nombre, NEW.apellidos, new.teléfono, NEW.dirección, NOW());
END &&

-- 2.- Trigger
DELIMITER &&
DROP TRIGGER IF EXISTS tr_delete_cliente&&
CREATE TRIGGER tr_delete_cliente
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO log_clientes (accion, DNI, nombre, apellidos, telefono, direccion, fecha)
    VALUES ('DELETE', OLD.DNI, OLD.nombre, OLD.apellidos, OLD.teléfono, OLD.dirección, NOW());
END &&
