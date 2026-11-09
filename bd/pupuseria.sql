-- =====================================================================
-- pupuseria.sql  -  Rol Base de datos (Semana 15, Software Libre UGB)
-- Caso 2: Pupusería con pedidos en línea  ·  "Pupusería El Comal"
-- Tablas principales: productos, clientes, pedidos
-- Probado en MariaDB 10.x / MySQL 8 (Debian: sudo apt install mariadb-server)
-- Uso:  sudo mariadb < pupuseria.sql
-- =====================================================================

DROP DATABASE IF EXISTS pupuseria;
CREATE DATABASE pupuseria CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pupuseria;

-- ---------------------------------------------------------------------
-- 1. PRODUCTOS: lo que vende la pupusería (pupusas, bebidas, extras)
-- ---------------------------------------------------------------------
CREATE TABLE productos (
  id_producto   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(80)   NOT NULL,
  categoria     ENUM('pupusa','bebida','extra') NOT NULL,
  tipo_masa     ENUM('maiz','arroz','no_aplica') NOT NULL DEFAULT 'no_aplica',
  precio        DECIMAL(6,2)  NOT NULL,
  disponible    BOOLEAN       NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_productos PRIMARY KEY (id_producto),
  CONSTRAINT uq_producto UNIQUE (nombre, tipo_masa),
  CONSTRAINT ck_precio CHECK (precio > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. CLIENTES: quienes hacen pedidos por internet
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
  id_cliente      INT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre          VARCHAR(80)  NOT NULL,
  telefono        VARCHAR(15)  NOT NULL,
  correo          VARCHAR(100) NULL,
  direccion       VARCHAR(200) NULL,
  fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_clientes PRIMARY KEY (id_cliente),
  CONSTRAINT uq_telefono UNIQUE (telefono)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PEDIDOS: cada fila es un producto pedido por un cliente.
--    Las filas con el mismo codigo_orden forman una misma orden.
-- ---------------------------------------------------------------------
CREATE TABLE pedidos (
  id_pedido          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  codigo_orden       VARCHAR(12)  NOT NULL,
  id_cliente         INT UNSIGNED NOT NULL,
  id_producto        INT UNSIGNED NOT NULL,
  cantidad           SMALLINT UNSIGNED NOT NULL,
  precio_unitario    DECIMAL(6,2) NOT NULL,
  tipo_entrega       ENUM('recoger','domicilio') NOT NULL,
  direccion_entrega  VARCHAR(200) NULL,
  estado             ENUM('recibido','en_preparacion','listo','entregado','cancelado')
                     NOT NULL DEFAULT 'recibido',
  fecha_pedido       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_pedidos PRIMARY KEY (id_pedido),
  CONSTRAINT fk_pedidos_clientes FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_pedidos_productos FOREIGN KEY (id_producto)
    REFERENCES productos (id_producto) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_cantidad CHECK (cantidad > 0),
  INDEX idx_codigo_orden (codigo_orden),
  INDEX idx_estado (estado)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- Datos de ejemplo
-- ---------------------------------------------------------------------
INSERT INTO productos (nombre, categoria, tipo_masa, precio) VALUES
 ('Revuelta',          'pupusa', 'maiz',      0.75),
 ('Revuelta',          'pupusa', 'arroz',     0.75),
 ('Queso con loroco',  'pupusa', 'maiz',      0.80),
 ('Queso con loroco',  'pupusa', 'arroz',     0.80),
 ('Frijol con queso',  'pupusa', 'maiz',      0.65),
 ('Chicharrón',        'pupusa', 'maiz',      0.75),
 ('Ayote con queso',   'pupusa', 'maiz',      0.80),
 ('Horchata',          'bebida', 'no_aplica', 0.75),
 ('Café de palo',      'bebida', 'no_aplica', 0.75),
 ('Porción extra de curtido', 'extra', 'no_aplica', 0.25);

INSERT INTO clientes (nombre, telefono, correo, direccion) VALUES
 ('Cliente de prueba 1', '7000-0001', 'cliente1@ejemplo.com', 'Col. Ciudad Jardín, San Miguel'),
 ('Cliente de prueba 2', '7000-0002', NULL,                   NULL),
 ('Cliente de prueba 3', '7000-0003', 'cliente3@ejemplo.com', 'Barrio El Centro, San Miguel');

INSERT INTO pedidos (codigo_orden, id_cliente, id_producto, cantidad, precio_unitario, tipo_entrega, direccion_entrega, estado) VALUES
 ('ORD-0001', 1, 1, 4, 0.75, 'domicilio', 'Col. Ciudad Jardín, San Miguel', 'entregado'),
 ('ORD-0001', 1, 3, 2, 0.80, 'domicilio', 'Col. Ciudad Jardín, San Miguel', 'entregado'),
 ('ORD-0001', 1, 8, 2, 0.75, 'domicilio', 'Col. Ciudad Jardín, San Miguel', 'entregado'),
 ('ORD-0002', 2, 5, 6, 0.65, 'recoger',   NULL,                             'listo'),
 ('ORD-0003', 3, 2, 3, 0.75, 'domicilio', 'Barrio El Centro, San Miguel',   'en_preparacion'),
 ('ORD-0003', 3, 9, 1, 0.75, 'domicilio', 'Barrio El Centro, San Miguel',   'en_preparacion');

-- ---------------------------------------------------------------------
-- Consultas de comprobación
-- ---------------------------------------------------------------------
-- Total por orden
SELECT p.codigo_orden, c.nombre AS cliente, p.tipo_entrega, p.estado,
       SUM(p.cantidad * p.precio_unitario) AS total_usd
FROM pedidos p JOIN clientes c ON c.id_cliente = p.id_cliente
GROUP BY p.codigo_orden, c.nombre, p.tipo_entrega, p.estado
ORDER BY p.codigo_orden;

-- Pedidos pendientes para la cocina
SELECT p.codigo_orden, pr.nombre, pr.tipo_masa, p.cantidad
FROM pedidos p JOIN productos pr ON pr.id_producto = p.id_producto
WHERE p.estado IN ('recibido','en_preparacion')
ORDER BY p.fecha_pedido;
