-- ============================================
-- SISTEMA DE GESTIÓN DE RENTA DE CARROS
-- Script de creación de base de datos
-- ============================================

-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS renta_carros 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE renta_carros;

-- ============================================
-- 1. SUCURSALES
-- ============================================
CREATE TABLE sucursales (
    sucursal_id       INT PRIMARY KEY AUTO_INCREMENT,
    nombre            VARCHAR(100) NOT NULL,
    direccion         VARCHAR(255) NOT NULL,
    ciudad            VARCHAR(50) NOT NULL,
    estado            VARCHAR(50) NOT NULL,
    codigo_postal     VARCHAR(10),
    telefono          VARCHAR(15),
    email             VARCHAR(100),
    horario_apertura  TIME,
    horario_cierre    TIME,
    activa            BOOLEAN DEFAULT TRUE,
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. EMPLEADOS
-- ============================================
CREATE TABLE empleados (
    empleado_id       INT PRIMARY KEY AUTO_INCREMENT,
    sucursal_id       INT NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    apellido          VARCHAR(100) NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    telefono          VARCHAR(15),
    cargo             ENUM('administrador', 'gerente', 'agente_renta', 'mecanico') NOT NULL,
    salario           DECIMAL(10,2),
    fecha_contratacion DATE NOT NULL,
    activo            BOOLEAN DEFAULT TRUE,
    password_hash     VARCHAR(255) NOT NULL,
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id)
);

-- ============================================
-- 3. CATEGORIAS_VEHICULO
-- ============================================
CREATE TABLE categorias_vehiculo (
    categoria_id      INT PRIMARY KEY AUTO_INCREMENT,
    nombre            VARCHAR(50) NOT NULL,
    descripcion       TEXT,
    precio_diario_base DECIMAL(10,2) NOT NULL,
    precio_semanal_base DECIMAL(10,2),
    deposito_requerido DECIMAL(10,2) DEFAULT 0.00,
    edad_minima_conductor INT DEFAULT 21
);

-- ============================================
-- 4. VEHICULOS
-- ============================================
CREATE TABLE vehiculos (
    vehiculo_id       INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id      INT NOT NULL,
    sucursal_id       INT NOT NULL,
    matricula         VARCHAR(20) UNIQUE NOT NULL,
    vin               VARCHAR(17) UNIQUE,
    marca             VARCHAR(50) NOT NULL,
    modelo            VARCHAR(50) NOT NULL,
    anio              INT NOT NULL,
    color             VARCHAR(30),
    kilometraje       INT DEFAULT 0,
    tipo_combustible  ENUM('gasolina', 'diesel', 'hibrido', 'electrico'),
    capacidad_pasajeros INT DEFAULT 5,
    capacidad_maletas INT DEFAULT 2,
    transmision       ENUM('manual', 'automatica'),
    features          JSON,
    foto_url          VARCHAR(255),
    estado            ENUM('disponible', 'rentado', 'mantenimiento', 'no_disponible') DEFAULT 'disponible',
    fecha_adquisicion DATE,
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (categoria_id) REFERENCES categorias_vehiculo(categoria_id),
    FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id)
);

-- ============================================
-- 5. CLIENTES
-- ============================================
CREATE TABLE clientes (
    cliente_id        INT PRIMARY KEY AUTO_INCREMENT,
    tipo_documento    ENUM('DNI', 'pasaporte', 'licencia_conducir', 'nit') NOT NULL,
    numero_documento  VARCHAR(50) UNIQUE NOT NULL,
    nombre            VARCHAR(100) NOT NULL,
    apellido          VARCHAR(100) NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    telefono          VARCHAR(15),
    telefono_emergencia VARCHAR(15),
    fecha_nacimiento  DATE,
    direccion         VARCHAR(255),
    ciudad            VARCHAR(50),
    licencia_conducir VARCHAR(50),
    fecha_vencimiento_licencia DATE,
    categoria_licencia VARCHAR(10),
    historial_crediticio ENUM('bueno', 'regular', 'malo') DEFAULT 'bueno',
    verificado        BOOLEAN DEFAULT FALSE,
    fecha_registro    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 6. TARIFAS_TEMPORADA
-- ============================================
CREATE TABLE tarifas_temporada (
    tarifa_id         INT PRIMARY KEY AUTO_INCREMENT,
    categoria_id      INT NOT NULL,
    nombre_temporada  VARCHAR(50) NOT NULL,
    fecha_inicio      DATE NOT NULL,
    fecha_fin         DATE NOT NULL,
    multiplicador_precio DECIMAL(3,2) NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES categorias_vehiculo(categoria_id)
);

-- ============================================
-- 7. RESERVAS
-- ============================================
CREATE TABLE reservas (
    reserva_id        INT PRIMARY KEY AUTO_INCREMENT,
    cliente_id        INT NOT NULL,
    vehiculo_id       INT,
    categoria_solicitada INT NOT NULL,
    sucursal_recogida INT NOT NULL,
    sucursal_devolucion INT NOT NULL,
    fecha_recogida    DATETIME NOT NULL,
    fecha_devolucion  DATETIME NOT NULL,
    estado            ENUM('pendiente', 'confirmada', 'en_curso', 'completada', 'cancelada', 'no_show') DEFAULT 'pendiente',
    precio_estimado   DECIMAL(10,2) NOT NULL,
    deposito_estimado DECIMAL(10,2),
    codigo_confirmacion VARCHAR(20) UNIQUE,
    notas_cliente     TEXT,
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(vehiculo_id),
    FOREIGN KEY (categoria_solicitada) REFERENCES categorias_vehiculo(categoria_id),
    FOREIGN KEY (sucursal_recogida) REFERENCES sucursales(sucursal_id),
    FOREIGN KEY (sucursal_devolucion) REFERENCES sucursales(sucursal_id)
);

-- ============================================
-- 8. CONTRATOS
-- ============================================
CREATE TABLE contratos (
    contrato_id       INT PRIMARY KEY AUTO_INCREMENT,
    reserva_id        INT UNIQUE NOT NULL,
    vehiculo_id       INT NOT NULL,
    cliente_id        INT NOT NULL,
    empleado_creacion INT NOT NULL,
    fecha_inicio      DATETIME NOT NULL,
    fecha_fin_estimada DATETIME NOT NULL,
    fecha_fin_real    DATETIME,
    kilometraje_salida INT NOT NULL,
    kilometraje_llegada INT,
    nivel_combustible_salida ENUM('vacio', '1/4', '1/2', '3/4', 'lleno') NOT NULL,
    nivel_combustible_llegada ENUM('vacio', '1/4', '1/2', '3/4', 'lleno'),
    condiciones_salida TEXT,
    condiciones_llegada TEXT,
    precio_total      DECIMAL(10,2) NOT NULL,
    deposito_retenido DECIMAL(10,2),
    deposito_devuelto DECIMAL(10,2),
    estado            ENUM('activo', 'completado', 'extendido', 'cancelado') DEFAULT 'activo',
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id),
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(vehiculo_id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (empleado_creacion) REFERENCES empleados(empleado_id)
);

-- ============================================
-- 9. TIPOS_SEGURO
-- ============================================
CREATE TABLE tipos_seguro (
    tipo_seguro_id    INT PRIMARY KEY AUTO_INCREMENT,
    nombre            VARCHAR(50) NOT NULL,
    descripcion       TEXT,
    cobertura_danos   DECIMAL(10,2),
    cobertura_robo    DECIMAL(10,2),
    cobertura_terceros DECIMAL(10,2),
    deducible         DECIMAL(10,2),
    precio_diario     DECIMAL(10,2) NOT NULL
);

-- ============================================
-- 10. CONTRATOS_SEGUROS
-- ============================================
CREATE TABLE contratos_seguros (
    contrato_seguro_id INT PRIMARY KEY AUTO_INCREMENT,
    contrato_id       INT NOT NULL,
    tipo_seguro_id    INT NOT NULL,
    numero_poliza     VARCHAR(50),
    fecha_inicio      DATE NOT NULL,
    fecha_fin         DATE NOT NULL,
    precio_total      DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (contrato_id) REFERENCES contratos(contrato_id),
    FOREIGN KEY (tipo_seguro_id) REFERENCES tipos_seguro(tipo_seguro_id)
);

-- ============================================
-- 11. PAGOS
-- ============================================
CREATE TABLE pagos (
    pago_id           INT PRIMARY KEY AUTO_INCREMENT,
    contrato_id       INT,
    reserva_id        INT,
    cliente_id        INT NOT NULL,
    monto             DECIMAL(10,2) NOT NULL,
    tipo_pago         ENUM('reserva', 'deposito', 'renta', 'extension', 'multa', 'devolucion', 'danos') NOT NULL,
    metodo_pago       ENUM('tarjeta_credito', 'tarjeta_debito', 'transferencia', 'efectivo', 'cheque', 'deposito_garantia') NOT NULL,
    estado            ENUM('pendiente', 'completado', 'rechazado', 'reembolsado') DEFAULT 'pendiente',
    referencia_externa VARCHAR(100),
    fecha_pago        TIMESTAMP,
    fecha_creacion    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contrato_id) REFERENCES contratos(contrato_id),
    FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);

-- ============================================
-- 12. MANTENIMIENTO
-- ============================================
CREATE TABLE mantenimiento (
    mantenimiento_id  INT PRIMARY KEY AUTO_INCREMENT,
    vehiculo_id       INT NOT NULL,
    tipo_servicio     ENUM('preventivo', 'correctivo', 'reparacion', 'inspeccion') NOT NULL,
    descripcion       TEXT NOT NULL,
    fecha_programada  DATE,
    fecha_realizacion DATE,
    costo             DECIMAL(10,2),
    taller            VARCHAR(100),
    kilometraje_servicio INT,
    estado            ENUM('programado', 'en_proceso', 'completado', 'cancelado') DEFAULT 'programado',
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(vehiculo_id)
);

-- ============================================
-- 13. INCIDENTES
-- ============================================
CREATE TABLE incidentes (
    incidente_id      INT PRIMARY KEY AUTO_INCREMENT,
    contrato_id       INT NOT NULL,
    tipo_incidente    ENUM('accidente', 'robo', 'danos_menores', 'multa', 'falla_mecanica', 'otro') NOT NULL,
    fecha_incidente   DATETIME NOT NULL,
    descripcion       TEXT NOT NULL,
    costo_reparacion  DECIMAL(10,2),
    costo_multa       DECIMAL(10,2),
    responsabilidad_cliente BOOLEAN DEFAULT FALSE,
    estado_resolucion ENUM('reportado', 'en_revision', 'resuelto', 'cerrado') DEFAULT 'reportado',
    documentos_adjuntos JSON,
    FOREIGN KEY (contrato_id) REFERENCES contratos(contrato_id)
);

-- ============================================
-- 14. AUDITORIA_CAMBIOS
-- ============================================
CREATE TABLE auditoria_cambios (
    auditoria_id      INT PRIMARY KEY AUTO_INCREMENT,
    tabla_afectada    VARCHAR(50) NOT NULL,
    registro_id       INT NOT NULL,
    tipo_operacion    ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    usuario           VARCHAR(100),
    fecha_hora        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos_anteriores  JSON,
    datos_nuevos      JSON
);

-- ============================================
-- ÍNDICES RECOMENDADOS
-- ============================================
CREATE INDEX idx_vehiculos_estado ON vehiculos(estado);
CREATE INDEX idx_vehiculos_matricula ON vehiculos(matricula);
CREATE INDEX idx_reservas_fechas ON reservas(fecha_recogida, fecha_devolucion);
CREATE INDEX idx_reservas_estado ON reservas(estado);
CREATE INDEX idx_clientes_documento ON clientes(numero_documento);
CREATE INDEX idx_clientes_email ON clientes(email);
CREATE INDEX idx_contratos_estado ON contratos(estado);
CREATE INDEX idx_pagos_estado ON pagos(estado);
CREATE INDEX idx_mantenimiento_vehiculo ON mantenimiento(vehiculo_id);
CREATE INDEX idx_incidentes_contrato ON incidentes(contrato_id);

-- ============================================
-- DATOS DE PRUEBA (Opcional)
-- ============================================

-- Sucursales
INSERT INTO sucursales (nombre, direccion, ciudad, estado, telefono, email, horario_apertura, horario_cierre) VALUES
('Sucursal Centro', 'Av. Principal 123', 'Ciudad de México', 'CDMX', '5550100100', 'centro@rentacarros.com', '08:00:00', '20:00:00'),
('Sucursal Aeropuerto', 'Terminal 2, Zona de Rentas', 'Ciudad de México', 'CDMX', '5550200200', 'aeropuerto@rentacarros.com', '05:00:00', '23:59:00'),
('Sucursal Norte', 'Blvd. Norte 456', 'Guadalajara', 'Jalisco', '3330300300', 'norte@rentacarros.com', '09:00:00', '19:00:00');

-- Categorías de vehículo
INSERT INTO categorias_vehiculo (nombre, descripcion, precio_diario_base, precio_semanal_base, deposito_requerido, edad_minima_conductor) VALUES
('Económico', 'Vehículos compactos y eficientes', 450.00, 2800.00, 3000.00, 21),
('Compacto', 'Sedanes medianos', 650.00, 4000.00, 5000.00, 21),
('SUV', 'Vehículos deportivos utilitarios', 950.00, 5800.00, 8000.00, 25),
('Lujo', 'Vehículos premium', 1800.00, 11000.00, 15000.00, 25),
('Van', 'Vehículos para 7+ pasajeros', 1200.00, 7200.00, 8000.00, 25);

-- Tipos de seguro
INSERT INTO tipos_seguro (nombre, descripcion, cobertura_danos, cobertura_robo, cobertura_terceros, deducible, precio_diario) VALUES
('Básico', 'Cobertura mínima obligatoria', 50000.00, 0.00, 100000.00, 5000.00, 80.00),
('Cobertura Total', 'Daños, robo y terceros', 200000.00, 200000.00, 500000.00, 2500.00, 180.00),
('Premium', 'Cobertura completa sin deducible', 500000.00, 500000.00, 1000000.00, 0.00, 350.00);

-- Empleados
INSERT INTO empleados (sucursal_id, nombre, apellido, email, telefono, cargo, salario, fecha_contratacion, password_hash) VALUES
(1, 'Juan', 'Pérez', 'juan.perez@rentacarros.com', '5551111111', 'administrador', 35000.00, '2023-01-15', '$2a$10$hashseguro...'),
(1, 'María', 'García', 'maria.garcia@rentacarros.com', '5552222222', 'agente_renta', 18000.00, '2023-03-01', '$2a$10$hashseguro...'),
(2, 'Carlos', 'López', 'carlos.lopez@rentacarros.com', '5553333333', 'gerente', 28000.00, '2023-02-10', '$2a$10$hashseguro...');

-- Vehículos
INSERT INTO vehiculos (categoria_id, sucursal_id, matricula, vin, marca, modelo, anio, color, kilometraje, tipo_combustible, capacidad_pasajeros, capacidad_maletas, transmision, features, estado, fecha_adquisicion) VALUES
(1, 1, 'ABC1234', '3VWFE21C04M000001', 'Volkswagen', 'Vento', 2022, 'Blanco', 25000, 'gasolina', 5, 2, 'automatica', '{"aire_acondicionado": true, "bluetooth": true, "gps": false}', 'disponible', '2022-01-10'),
(2, 1, 'DEF5678', '1HGCM82633A123456', 'Honda', 'Civic', 2023, 'Gris', 15000, 'gasolina', 5, 2, 'automatica', '{"aire_acondicionado": true, "bluetooth": true, "gps": true, "camara_reversa": true}', 'disponible', '2023-02-15'),
(3, 2, 'GHI9012', '5N1AR2MM7DC678901', 'Nissan', 'X-Trail', 2023, 'Negro', 18000, 'gasolina', 7, 3, 'automatica', '{"aire_acondicionado": true, "bluetooth": true, "gps": true, "camara_reversa": true, "quemacocos": true}', 'disponible', '2023-03-20'),
(4, 1, 'JKL3456', 'WBA5B3C50ED123456', 'BMW', 'Serie 3', 2023, 'Azul', 8000, 'gasolina', 5, 2, 'automatica', '{"aire_acondicionado": true, "bluetooth": true, "gps": true, "camara_reversa": true, "quemacocos": true, "asientos_cuero": true}', 'disponible', '2023-04-01');

-- Clientes
INSERT INTO clientes (tipo_documento, numero_documento, nombre, apellido, email, telefono, fecha_nacimiento, direccion, ciudad, licencia_conducir, fecha_vencimiento_licencia, categoria_licencia, verificado) VALUES
('DNI', '12345678A', 'Pedro', 'Martínez', 'pedro.martinez@email.com', '5554444444', '1985-06-15', 'Calle Falsa 123', 'Ciudad de México', 'A1234567', '2027-06-15', 'B', TRUE),
('DNI', '87654321B', 'Ana', 'Rodríguez', 'ana.rodriguez@email.com', '5555555555', '1990-03-20', 'Av. Reforma 456', 'Ciudad de México', 'B7654321', '2026-03-20', 'B', TRUE),
('pasaporte', 'P98765432', 'Luis', 'Hernández', 'luis.hernandez@email.com', '5556666666', '1978-11-10', 'Blvd. Insurgentes 789', 'Guadalajara', 'C9876543', '2028-11-10', 'A', TRUE);

-- ============================================
-- FIN DEL SCRIPT
-- ============================================