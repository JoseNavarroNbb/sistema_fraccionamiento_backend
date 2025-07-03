-- =============================================
-- BASE DE DATOS: SISTEMA_FRACCIONAMIENTO
-- Versión: 1.0
-- Autor: JOSE CARLOS NAVARRO B.
-- Fecha: 02 DE JULIO DE 2024
-- 
-- Este script crea la estructura de base de datos para
-- el sistema de administración de fraccionamientos.
-- 
-- Políticas aplicadas:
-- 1. Definicion de entidades y relaciones claras
-- 2. Documentación completa de cada objeto
-- 3. Registros de control (creación/modificación)
-- 4. Normalización adecuada para escalabilidad
-- 5. Índices para mejorar rendimiento
-- =============================================

-- Configuración inicial
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;
SET TIME_ZONE = '-06:00'; -- Zona horaria central México

-- Creación de la base de datos
DROP DATABASE IF EXISTS sistema_fraccionamiento;
CREATE DATABASE sistema_fraccionamiento 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE sistema_fraccionamiento;

-- =============================================
-- TABLA: roles
-- Descripción: Almacena los diferentes roles de usuarios en el sistema
-- =============================================
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL COMMENT 'Nombre del rol (Administrador, Propietario, Arrendatario, etc.)',
    descripcion TEXT COMMENT 'Descripción detallada del rol',
    nivel_permisos INT NOT NULL DEFAULT 1 COMMENT 'Nivel de permisos (1-10)',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si el rol está activo',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_roles_nombre UNIQUE (nombre)
) COMMENT = 'Catálogo de roles de usuarios en el sistema';

-- =============================================
-- TABLA: usuarios
-- Descripción: Almacena la información de todos los usuarios del sistema
-- =============================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL COMMENT 'Rol del usuario en el sistema',
    nombre VARCHAR(100) NOT NULL COMMENT 'Nombre(s) del usuario',
    apellido_paterno VARCHAR(100) NOT NULL COMMENT 'Apellido paterno',
    apellido_materno VARCHAR(100) COMMENT 'Apellido materno',
    email VARCHAR(255) NOT NULL COMMENT 'Correo electrónico (usado para login)',
    telefono VARCHAR(20) COMMENT 'Teléfono de contacto',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Hash de la contraseña',
    salt VARCHAR(100) NOT NULL COMMENT 'Salt para seguridad del hash',
    fecha_ultimo_login DATETIME COMMENT 'Fecha del último inicio de sesión',
    intentos_login INT DEFAULT 0 COMMENT 'Intentos fallidos de login',
    bloqueado BOOLEAN DEFAULT FALSE COMMENT 'Indica si la cuenta está bloqueada',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si el usuario está activo',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_usuarios_email UNIQUE (email),
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (id_rol) REFERENCES roles (id)
) COMMENT = 'Información de todos los usuarios del sistema';

-- =============================================
-- TABLA: lotes
-- Descripción: Registra todos los lotes del fraccionamiento
-- =============================================
CREATE TABLE lotes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(20) NOT NULL COMMENT 'Número o identificador del lote',
    calle VARCHAR(100) NOT NULL COMMENT 'Calle donde se ubica el lote',
    manzana VARCHAR(20) COMMENT 'Manzana del fraccionamiento',
    superficie DECIMAL(10, 2) NOT NULL COMMENT 'Superficie en metros cuadrados',
    estatus ENUM('disponible', 'vendido', 'reservado', 'en_construccion') NOT NULL DEFAULT 'disponible',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_lotes_numero UNIQUE (numero)
) COMMENT = 'Catálogo de todos los lotes del fraccionamiento';

-- =============================================
-- TABLA: propietarios
-- Descripción: Relación entre usuarios y lotes (propiedad)
-- =============================================
CREATE TABLE propietarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL COMMENT 'Usuario propietario',
    id_lote INT NOT NULL COMMENT 'Lote que posee',
    fecha_adquisicion DATE NOT NULL COMMENT 'Fecha en que adquirió el lote',
    porcentaje_propiedad DECIMAL(5, 2) DEFAULT 100.00 COMMENT 'Porcentaje de propiedad si hay copropietarios',
    principal BOOLEAN DEFAULT TRUE COMMENT 'Indica si es el propietario principal',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si la relación está activa',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT fk_propietarios_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id),
    CONSTRAINT fk_propietarios_lote FOREIGN KEY (id_lote) REFERENCES lotes (id),
    CONSTRAINT uk_propietarios_lote_usuario UNIQUE (id_usuario, id_lote)
) COMMENT = 'Relación de propietarios con sus lotes';

-- =============================================
-- TABLA: arrendatarios
-- Descripción: Registra arrendatarios de los lotes
-- =============================================
CREATE TABLE arrendatarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL COMMENT 'Propietario que arrienda',
    id_lote INT NOT NULL COMMENT 'Lote arrendado',
    nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del arrendatario',
    email VARCHAR(255) COMMENT 'Correo electrónico',
    telefono VARCHAR(20) NOT NULL COMMENT 'Teléfono de contacto',
    fecha_inicio DATE NOT NULL COMMENT 'Fecha de inicio del arrendamiento',
    fecha_fin DATE COMMENT 'Fecha de término del arrendamiento (null si indefinido)',
    renta_mensual DECIMAL(12, 2) NOT NULL COMMENT 'Monto de la renta mensual',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si el arrendamiento está activo',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT fk_arrendatarios_propietario FOREIGN KEY (id_propietario) REFERENCES propietarios (id),
    CONSTRAINT fk_arrendatarios_lote FOREIGN KEY (id_lote) REFERENCES lotes (id)
) COMMENT = 'Registro de arrendatarios de los lotes';

-- =============================================
-- TABLA: conceptos_pago
-- Descripción: Catálogo de conceptos por los que se pueden realizar pagos
-- =============================================
CREATE TABLE conceptos_pago (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(20) NOT NULL COMMENT 'Clave corta del concepto',
    nombre VARCHAR(100) NOT NULL COMMENT 'Nombre del concepto',
    descripcion TEXT COMMENT 'Descripción detallada',
    tipo ENUM('ordinario', 'extraordinario', 'multa', 'donacion') NOT NULL DEFAULT 'ordinario',
    aplica_a ENUM('lote', 'usuario', 'general') NOT NULL DEFAULT 'lote',
    monto_base DECIMAL(12, 2) COMMENT 'Monto base para cálculo (puede ser null si es variable)',
    periodicidad ENUM('mensual', 'bimestral', 'trimestral', 'semestral', 'anual', 'unico') NOT NULL DEFAULT 'mensual',
    activo BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'Indica si el concepto está activo',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_conceptos_pago_clave UNIQUE (clave)
) COMMENT = 'Catálogo de conceptos por los que se realizan pagos';

-- =============================================
-- TABLA: recibos
-- Descripción: Cabecera de recibos de pago
-- =============================================
CREATE TABLE recibos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    folio VARCHAR(20) NOT NULL COMMENT 'Folio único del recibo',
    id_lote INT COMMENT 'Lote al que aplica (puede ser null si es general)',
    id_usuario INT NOT NULL COMMENT 'Usuario que realiza el pago',
    fecha_emision DATE NOT NULL COMMENT 'Fecha de emisión del recibo',
    fecha_vencimiento DATE NOT NULL COMMENT 'Fecha de vencimiento',
    subtotal DECIMAL(12, 2) NOT NULL COMMENT 'Subtotal sin IVA',
    iva DECIMAL(12, 2) NOT NULL COMMENT 'Monto de IVA',
    total DECIMAL(12, 2) NOT NULL COMMENT 'Total a pagar',
    estatus ENUM('pendiente', 'pagado', 'cancelado', 'vencido') NOT NULL DEFAULT 'pendiente',
    metodo_pago ENUM('efectivo', 'transferencia', 'tarjeta', 'cheque') COMMENT 'Método de pago (si ya se pagó)',
    referencia_pago VARCHAR(100) COMMENT 'Referencia o número de transacción',
    fecha_pago DATE COMMENT 'Fecha real de pago',
    observaciones TEXT COMMENT 'Observaciones o notas',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_recibos_folio UNIQUE (folio),
    CONSTRAINT fk_recibos_lote FOREIGN KEY (id_lote) REFERENCES lotes (id),
    CONSTRAINT fk_recibos_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
) COMMENT = 'Cabecera de recibos de pago';

-- =============================================
-- TABLA: recibos_detalle
-- Descripción: Detalle de conceptos en cada recibo
-- =============================================
CREATE TABLE recibos_detalle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_recibo INT NOT NULL COMMENT 'Recibo al que pertenece',
    id_concepto INT NOT NULL COMMENT 'Concepto de pago',
    cantidad DECIMAL(10, 2) NOT NULL DEFAULT 1 COMMENT 'Cantidad (metros, meses, etc.)',
    precio_unitario DECIMAL(12, 2) NOT NULL COMMENT 'Precio por unidad',
    importe DECIMAL(12, 2) NOT NULL COMMENT 'Cantidad * Precio unitario',
    descuento DECIMAL(12, 2) DEFAULT 0 COMMENT 'Monto de descuento aplicado',
    iva DECIMAL(5, 2) NOT NULL COMMENT 'Porcentaje de IVA',
    iva_monto DECIMAL(12, 2) NOT NULL COMMENT 'Monto de IVA calculado',
    total DECIMAL(12, 2) NOT NULL COMMENT 'Importe + IVA - Descuento',
    descripcion TEXT COMMENT 'Descripción detallada del concepto',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    CONSTRAINT fk_recibos_detalle_recibo FOREIGN KEY (id_recibo) REFERENCES recibos (id) ON DELETE CASCADE,
    CONSTRAINT fk_recibos_detalle_concepto FOREIGN KEY (id_concepto) REFERENCES conceptos_pago (id)
) COMMENT = 'Detalle de conceptos en cada recibo';

-- =============================================
-- TABLA: gastos
-- Descripción: Registro de gastos del fraccionamiento
-- =============================================
CREATE TABLE gastos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_concepto INT COMMENT 'Concepto relacionado (opcional)',
    id_usuario INT NOT NULL COMMENT 'Usuario que registra el gasto',
    descripcion TEXT NOT NULL COMMENT 'Descripción detallada del gasto',
    monto DECIMAL(12, 2) NOT NULL COMMENT 'Monto total del gasto',
    fecha_gasto DATE NOT NULL COMMENT 'Fecha en que se realizó el gasto',
    comprobante VARCHAR(100) COMMENT 'Referencia o número de comprobante',
    metodo_pago ENUM('efectivo', 'transferencia', 'tarjeta', 'cheque') NOT NULL,
    beneficiario VARCHAR(255) COMMENT 'Persona o empresa que recibe el pago',
    observaciones TEXT COMMENT 'Observaciones adicionales',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT fk_gastos_concepto FOREIGN KEY (id_concepto) REFERENCES conceptos_pago (id),
    CONSTRAINT fk_gastos_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
) COMMENT = 'Registro de gastos del fraccionamiento';

-- =============================================
-- TABLA: documentos
-- Descripción: Registro de documentos digitales del sistema
-- =============================================
CREATE TABLE documentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_lote INT COMMENT 'Lote relacionado (si aplica)',
    id_usuario INT COMMENT 'Usuario relacionado (si aplica)',
    tipo ENUM('contrato', 'identificacion', 'comprobante', 'factura', 'otro') NOT NULL,
    nombre VARCHAR(255) NOT NULL COMMENT 'Nombre del documento',
    ruta_archivo VARCHAR(512) NOT NULL COMMENT 'Ruta donde se almacena el archivo',
    mime_type VARCHAR(100) NOT NULL COMMENT 'Tipo MIME del archivo',
    tamano BIGINT NOT NULL COMMENT 'Tamaño en bytes',
    fecha_documento DATE COMMENT 'Fecha del documento',
    descripcion TEXT COMMENT 'Descripción del documento',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT fk_documentos_lote FOREIGN KEY (id_lote) REFERENCES lotes (id),
    CONSTRAINT fk_documentos_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
) COMMENT = 'Registro de documentos digitales del sistema';

-- =============================================
-- TABLA: notificaciones
-- Descripción: Registro de notificaciones a usuarios
-- =============================================
CREATE TABLE notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL COMMENT 'Usuario destinatario',
    titulo VARCHAR(255) NOT NULL COMMENT 'Título de la notificación',
    mensaje TEXT NOT NULL COMMENT 'Contenido detallado',
    tipo ENUM('info', 'alerta', 'urgente', 'pago') NOT NULL DEFAULT 'info',
    leida BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Indica si fue leída',
    fecha_envio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de envío',
    fecha_lectura DATETIME COMMENT 'Fecha en que se leyó',
    accion VARCHAR(255) COMMENT 'Acción o URL relacionada',
    CONSTRAINT fk_notificaciones_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
) COMMENT = 'Registro de notificaciones a usuarios';

-- =============================================
-- TABLA: configuraciones
-- Descripción: Configuraciones generales del sistema
-- =============================================
CREATE TABLE configuraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) NOT NULL COMMENT 'Clave de la configuración',
    valor TEXT NOT NULL COMMENT 'Valor de la configuración',
    tipo VARCHAR(20) NOT NULL COMMENT 'Tipo de dato (string, number, boolean, json)',
    descripcion TEXT COMMENT 'Descripción de la configuración',
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de creación del registro',
    fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Fecha de última actualización',
    creado_por VARCHAR(50) COMMENT 'Usuario que creó el registro',
    actualizado_por VARCHAR(50) COMMENT 'Usuario que realizó la última actualización',
    CONSTRAINT uk_configuraciones_clave UNIQUE (clave)
) COMMENT = 'Configuraciones generales del sistema';

-- =============================================
-- TABLA: auditoria
-- Descripción: Registro de eventos importantes para auditoría
-- =============================================
CREATE TABLE auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT COMMENT 'Usuario que realizó la acción (si aplica)',
    tabla_afectada VARCHAR(50) NOT NULL COMMENT 'Tabla afectada por la acción',
    tipo_operacion ENUM('insert', 'update', 'delete', 'login', 'logout', 'system') NOT NULL,
    registro_afectado INT COMMENT 'ID del registro afectado',
    valores_anteriores JSON COMMENT 'Valores antes de la operación (para updates/deletes)',
    valores_nuevos JSON COMMENT 'Valores nuevos (para inserts/updates)',
    ip_origen VARCHAR(45) COMMENT 'Dirección IP desde donde se realizó',
    user_agent VARCHAR(255) COMMENT 'Agente de usuario (navegador, dispositivo)',
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha y hora del evento',
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios (id)
) COMMENT = 'Registro de eventos importantes para auditoría';

-- =============================================
-- ÍNDICES ADICIONALES PARA MEJORAR RENDIMIENTO
-- =============================================
CREATE INDEX idx_usuarios_rol ON usuarios(id_rol);
CREATE INDEX idx_propietarios_usuario ON propietarios(id_usuario);
CREATE INDEX idx_propietarios_lote ON propietarios(id_lote);
CREATE INDEX idx_arrendatarios_lote ON arrendatarios(id_lote);
CREATE INDEX idx_recibos_lote ON recibos(id_lote);
CREATE INDEX idx_recibos_usuario ON recibos(id_usuario);
CREATE INDEX idx_recibos_estatus ON recibos(estatus);
CREATE INDEX idx_recibos_fecha ON recibos(fecha_emision);
CREATE INDEX idx_recibos_detalle_recibo ON recibos_detalle(id_recibo);
CREATE INDEX idx_gastos_fecha ON gastos(fecha_gasto);
CREATE INDEX idx_notificaciones_usuario ON notificaciones(id_usuario);
CREATE INDEX idx_notificaciones_leida ON notificaciones(leida);
CREATE INDEX idx_auditoria_fecha ON auditoria(fecha_evento);
CREATE INDEX idx_auditoria_usuario ON auditoria(id_usuario);

-- =============================================
-- VISTAS ÚTILES PARA REPORTES
-- =============================================

-- Vista: Resumen de pagos por lote
CREATE VIEW vista_resumen_pagos AS
SELECT 
    l.id AS id_lote,
    l.numero AS numero_lote,
    l.calle,
    p.id_usuario,
    CONCAT(u.nombre, ' ', u.apellido_paterno) AS propietario,
    COUNT(r.id) AS total_recibos,
    SUM(CASE WHEN r.estatus = 'pagado' THEN r.total ELSE 0 END) AS total_pagado,
    SUM(CASE WHEN r.estatus = 'pendiente' THEN r.total ELSE 0 END) AS total_pendiente,
    MAX(r.fecha_vencimiento) AS ultimo_vencimiento
FROM 
    lotes l
    LEFT JOIN propietarios p ON l.id = p.id_lote AND p.principal = TRUE
    LEFT JOIN usuarios u ON p.id_usuario = u.id
    LEFT JOIN recibos r ON l.id = r.id_lote
GROUP BY 
    l.id, l.numero, l.calle, p.id_usuario, propietario;

-- Vista: Gastos por mes
CREATE VIEW vista_gastos_mensuales AS
SELECT 
    YEAR(fecha_gasto) AS anio,
    MONTH(fecha_gasto) AS mes,
    COUNT(id) AS total_gastos,
    SUM(monto) AS monto_total,
    AVG(monto) AS promedio_por_gasto
FROM 
    gastos
GROUP BY 
    YEAR(fecha_gasto), MONTH(fecha_gasto)
ORDER BY 
    anio DESC, mes DESC;

-- =============================================
-- PROCEDIMIENTOS ALMACENADOS ÚTILES
-- =============================================

-- Procedimiento: Generar recibos mensuales
DELIMITER //
CREATE PROCEDURE generar_recibos_mensuales(IN p_anio INT, IN p_mes INT, IN p_usuario VARCHAR(50))
BEGIN
    DECLARE v_fecha_emision DATE;
    DECLARE v_fecha_vencimiento DATE;
    
    -- Establecer fechas (emisión: primer día del mes, vencimiento: 10 del mes siguiente)
    SET v_fecha_emision = DATE(CONCAT(p_anio, '-', p_mes, '-01'));
    SET v_fecha_vencimiento = DATE_ADD(v_fecha_emision, INTERVAL 40 DAY);
    
    -- Insertar recibos para cada lote con conceptos mensuales
    INSERT INTO recibos (
        folio,
        id_lote,
        id_usuario,
        fecha_emision,
        fecha_vencimiento,
        subtotal,
        iva,
        total,
        estatus,
        creado_por,
        actualizado_por
    )
    SELECT 
        CONCAT('REC-', p_anio, '-', LPAD(p_mes, 2, '0'), '-', LPAD(l.id, 5, '0')) AS folio,
        l.id AS id_lote,
        p.id_usuario,
        v_fecha_emision,
        v_fecha_vencimiento,
        SUM(cp.monto_base) AS subtotal,
        SUM(cp.monto_base * 0.16) AS iva,
        SUM(cp.monto_base * 1.16) AS total,
        'pendiente' AS estatus,
        p_usuario AS creado_por,
        p_usuario AS actualizado_por
    FROM 
        lotes l
        JOIN propietarios p ON l.id = p.id_lote AND p.principal = TRUE
        JOIN conceptos_pago cp ON cp.periodicidad = 'mensual' AND cp.activo = TRUE
    WHERE 
        p.activo = TRUE
    GROUP BY 
        l.id, p.id_usuario;
    
    -- Insertar detalles para cada recibo generado
    INSERT INTO recibos_detalle (
        id_recibo,
        id_concepto,
        cantidad,
        precio_unitario,
        importe,
        iva,
        iva_monto,
        total,
        descripcion
    )
    SELECT 
        r.id AS id_recibo,
        cp.id AS id_concepto,
        1 AS cantidad,
        cp.monto_base AS precio_unitario,
        cp.monto_base AS importe,
        16.00 AS iva,
        cp.monto_base * 0.16 AS iva_monto,
        cp.monto_base * 1.16 AS total,
        CONCAT(cp.nombre, ' - Mes ', p_mes, '/', p_anio) AS descripcion
    FROM 
        recibos r
        JOIN lotes l ON r.id_lote = l.id
        JOIN conceptos_pago cp ON cp.periodicidad = 'mensual' AND cp.activo = TRUE
    WHERE 
        YEAR(r.fecha_emision) = p_anio 
        AND MONTH(r.fecha_emision) = p_mes
        AND r.creado_por = p_usuario;
    
    -- Registrar en auditoría
    INSERT INTO auditoria (
        id_usuario,
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        valores_nuevos,
        ip_origen,
        user_agent
    )
    VALUES (
        (SELECT id FROM usuarios WHERE email = p_usuario LIMIT 1),
        'recibos',
        'system',
        NULL,
        JSON_OBJECT('anio', p_anio, 'mes', p_mes, 'recibos_generados', ROW_COUNT()),
        '127.0.0.1',
        'Procedimiento almacenado'
    );
    
    SELECT ROW_COUNT() AS recibos_generados;
END //
DELIMITER ;

-- =============================================
-- TRIGGERS PARA REGISTRO DE AUDITORÍA
-- =============================================

-- Trigger: Auditoría para tabla usuarios
DELIMITER //
CREATE TRIGGER tr_usuarios_after_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (
        id_usuario,
        tabla_afectada,
        tipo_operacion,
        registro_afectado,
        valores_nuevos,
        ip_origen,
        user_agent
    )
    VALUES (
        NEW.id,
        'usuarios',
        'insert',
        NEW.id,
        JSON_OBJECT(
            'nombre', NEW.nombre,
            'email', NEW.email,
            'id_rol', NEW.id_rol,
            'activo', NEW.activo
        ),
        NULL,
        NULL
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER tr_usuarios_after_update
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.nombre != NEW.nombre OR OLD.email != NEW.email OR OLD.id_rol != NEW.id_rol OR OLD.activo != NEW.activo THEN
        INSERT INTO auditoria (
            id_usuario,
            tabla_afectada,
            tipo_operacion,
            registro_afectado,
            valores_anteriores,
            valores_nuevos,
            ip_origen,
            user_agent
        )
        VALUES (
            NEW.id,
            'usuarios',
            'update',
            NEW.id,
            JSON_OBJECT(
                'nombre', OLD.nombre,
                'email', OLD.email,
                'id_rol', OLD.id_rol,
                'activo', OLD.activo
            ),
            JSON_OBJECT(
                'nombre', NEW.nombre,
                'email', NEW.email,
                'id_rol', NEW.id_rol,
                'activo', NEW.activo
            ),
            NULL,
            NULL
        );
    END IF;
END //
DELIMITER ;

-- =============================================
-- DATOS INICIALES (SEED)
-- =============================================

-- Insertar roles básicos
INSERT INTO roles (nombre, descripcion, nivel_permisos, creado_por, actualizado_por) VALUES 
('Administrador', 'Acceso completo al sistema', 10, 'sistema', 'sistema'),
('Mesa Directiva', 'Miembros de la mesa directiva del fraccionamiento', 8, 'sistema', 'sistema'),
('Propietario', 'Dueño de uno o más lotes', 5, 'sistema', 'sistema'),
('Arrendatario', 'Persona que renta un lote', 3, 'sistema', 'sistema'),
('Guardia', 'Personal de seguridad con acceso limitado', 2, 'sistema', 'sistema');

-- Insertar usuario administrador inicial
INSERT INTO usuarios (
    id_rol,
    nombre,
    apellido_paterno,
    email,
    password_hash,
    salt,
    creado_por,
    actualizado_por
) VALUES (
    1,
    'Admin',
    'Sistema',
    'admin@fraccionamiento.com',
    -- Contraseña: Admin123 (debe ser cambiada después)
    '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918',
    'sistema',
    'sistema',
    'sistema'
);

-- Insertar conceptos de pago comunes
INSERT INTO conceptos_pago (
    clave,
    nombre,
    descripcion,
    tipo,
    aplica_a,
    monto_base,
    periodicidad,
    creado_por,
    actualizado_por
) VALUES 
('MANT', 'Mantenimiento', 'Cuota mensual de mantenimiento del fraccionamiento', 'ordinario', 'lote', 500.00, 'mensual', 'sistema', 'sistema'),
('LUZ', 'Alumbrado', 'Contribución para pago de alumbrado público', 'ordinario', 'lote', 150.00, 'mensual', 'sistema', 'sistema'),
('GUARDIA', 'Servicio de guardia', 'Pago por servicio de vigilancia', 'ordinario', 'lote', 200.00, 'mensual', 'sistema', 'sistema'),
('MULTA', 'Multa', 'Multa por incumplimiento de reglamento', 'multa', 'lote', NULL, 'unico', 'sistema', 'sistema'),
('DONATIVO', 'Donativo', 'Donativo voluntario para mejoras', 'donacion', 'general', NULL, 'unico', 'sistema', 'sistema');

-- Insertar configuraciones básicas
INSERT INTO configuraciones (clave, valor, tipo, descripcion, creado_por, actualizado_por) VALUES 
('IVA_PORCENTAJE', '16', 'number', 'Porcentaje de IVA aplicable', 'sistema', 'sistema'),
('DIAS_VENCIMIENTO', '10', 'number', 'Días de gracia para pagos después de vencimiento', 'sistema', 'sistema'),
('EMAIL_CONTACTO', 'contacto@fraccionamiento.com', 'string', 'Email de contacto para residentes', 'sistema', 'sistema'),
('MANTENIMIENTO_ACTIVO', 'true', 'boolean', 'Indica si se están cobrando cuotas de mantenimiento', 'sistema', 'sistema');

-- Habilitar nuevamente las restricciones de clave foránea
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- FIN DEL SCRIPT
-- =============================================