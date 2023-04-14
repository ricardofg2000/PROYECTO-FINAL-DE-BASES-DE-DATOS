-- tienda.categorias definition

CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(45) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `descripción` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `imagen` varbinary(100) DEFAULT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;


-- tienda.clientes definition

CREATE TABLE `clientes` (
  `DNI` varchar(9) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `apellidos` varchar(70) DEFAULT NULL,
  `teléfono` varchar(20) DEFAULT NULL,
  `dirección` varchar(70) DEFAULT NULL,
  PRIMARY KEY (`DNI`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- tienda.log_clientes definition

CREATE TABLE `log_clientes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `accion` varchar(10) NOT NULL,
  `DNI` varchar(9) NOT NULL,
  `nombre` varchar(45) DEFAULT NULL,
  `apellidos` varchar(70) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(70) DEFAULT NULL,
  `fecha` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- tienda.`método de pago` definition

CREATE TABLE `método de pago` (
  `id_pago` int NOT NULL AUTO_INCREMENT,
  `cantidad` int DEFAULT NULL,
  PRIMARY KEY (`id_pago`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;


-- tienda.tienda definition

CREATE TABLE `tienda` (
  `id_tienda` int NOT NULL AUTO_INCREMENT,
  `dirección` varchar(70) DEFAULT NULL,
  `ciudad` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id_tienda`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;


-- tienda.efectivo definition

CREATE TABLE `efectivo` (
  `Método de pago_id_pago` int NOT NULL,
  PRIMARY KEY (`Método de pago_id_pago`),
  CONSTRAINT `efectivo_FK` FOREIGN KEY (`Método de pago_id_pago`) REFERENCES `método de pago` (`id_pago`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- tienda.empleados definition

CREATE TABLE `empleados` (
  `código_empleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  `apellidos` varchar(70) DEFAULT NULL,
  `DNI` varchar(9) NOT NULL,
  `teléfono` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `dirección` varchar(60) DEFAULT NULL,
  `email` varchar(45) DEFAULT NULL,
  `id_encargado` int DEFAULT NULL,
  `Tienda_id_tienda` int NOT NULL,
  PRIMARY KEY (`código_empleado`),
  KEY `fk_Empleados_Empleados1_idx` (`id_encargado`),
  KEY `fk_Empleados_Tienda1_idx` (`Tienda_id_tienda`),
  CONSTRAINT `empleados_FK` FOREIGN KEY (`id_encargado`) REFERENCES `empleados` (`código_empleado`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `empleados_FK_1` FOREIGN KEY (`Tienda_id_tienda`) REFERENCES `tienda` (`id_tienda`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;


-- tienda.pedidos definition

CREATE TABLE `pedidos` (
  `id_Pedidos` int NOT NULL AUTO_INCREMENT,
  `fecha_pedido` date NOT NULL,
  `fecha_prevista_entrega` date NOT NULL,
  `fecha_entrega` date DEFAULT NULL,
  `comentarios` varchar(150) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `Clientes_DNI` varchar(9) NOT NULL,
  `Método de pago_id_pago` int NOT NULL,
  `direccion` varchar(100) DEFAULT NULL,
  `ciudad` varchar(50) DEFAULT NULL,
  `id_empleado` int DEFAULT NULL,
  PRIMARY KEY (`id_Pedidos`),
  KEY `fk_Pedidos_Clientes1_idx` (`Clientes_DNI`),
  KEY `fk_Pedidos_Método de pago1_idx` (`Método de pago_id_pago`),
  KEY `pedidos_FK_2` (`id_empleado`),
  CONSTRAINT `pedidos_FK` FOREIGN KEY (`Clientes_DNI`) REFERENCES `clientes` (`DNI`),
  CONSTRAINT `pedidos_FK_1` FOREIGN KEY (`Método de pago_id_pago`) REFERENCES `método de pago` (`id_pago`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `pedidos_FK_2` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`código_empleado`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99984603 DEFAULT CHARSET=utf8mb3;


-- tienda.productos definition

CREATE TABLE `productos` (
  `id_productos` int NOT NULL AUTO_INCREMENT,
  `nombre_productos` varchar(45) NOT NULL,
  `id_categoria` int NOT NULL,
  PRIMARY KEY (`id_productos`),
  KEY `fk_Productos_Categorias1_idx` (`id_categoria`),
  CONSTRAINT `productos_FK` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb3;


-- tienda.productos_en_tienda definition

CREATE TABLE `productos_en_tienda` (
  `id_productos` int NOT NULL,
  `id_tienda` int NOT NULL,
  `Stock` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_productos`,`id_tienda`),
  KEY `fk_Productos_has_Tienda_Tienda1_idx` (`id_tienda`),
  KEY `fk_Productos_has_Tienda_Productos_idx` (`id_productos`),
  CONSTRAINT `productos_en_tienda_FK` FOREIGN KEY (`id_tienda`) REFERENCES `tienda` (`id_tienda`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `productos_en_tienda_FK_1` FOREIGN KEY (`id_productos`) REFERENCES `productos` (`id_productos`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- tienda.tarjeta definition

CREATE TABLE `tarjeta` (
  `num_tarjeta` int DEFAULT NULL,
  `fecha_caducidad` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `CVV` int DEFAULT NULL,
  `Método de pago_id_pago` int NOT NULL,
  PRIMARY KEY (`Método de pago_id_pago`),
  CONSTRAINT `tarjeta_FK` FOREIGN KEY (`Método de pago_id_pago`) REFERENCES `método de pago` (`id_pago`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- tienda.linea_pedido definition

CREATE TABLE `linea_pedido` (
  `id_productos` int NOT NULL,
  `id_Pedidos` int NOT NULL,
  `Cantidad` int NOT NULL,
  `PrecioUnidad` int NOT NULL,
  PRIMARY KEY (`id_productos`,`id_Pedidos`),
  KEY `fk_Productos_has_Pedidos_Pedidos1_idx` (`id_Pedidos`),
  KEY `fk_Productos_has_Pedidos_Productos1_idx` (`id_productos`),
  CONSTRAINT `linea_pedido_FK` FOREIGN KEY (`id_productos`) REFERENCES `productos` (`id_productos`),
  CONSTRAINT `linea_pedido_FK_1` FOREIGN KEY (`id_Pedidos`) REFERENCES `pedidos` (`id_Pedidos`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;