
-- ============================================
-- Ejercicio B1 - Crear las tablas del gimnasio
-- ============================================

-- Tabla de planes
CREATE TABLE planes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    precio_mensual NUMERIC(6,2) NOT NULL CHECK (precio_mensual >= 0)
);

-- Tabla de socios
CREATE TABLE socios (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_alta DATE NOT NULL,
    plan_id INTEGER NOT NULL REFERENCES planes(id)
);

-- Tabla de tarjetas
CREATE TABLE tarjetas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    activa BOOLEAN NOT NULL,
    socio_id INTEGER UNIQUE NOT NULL REFERENCES socios(id)
);

-- Tabla de monitores
CREATE TABLE monitores (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL
);

-- Tabla de clases
CREATE TABLE clases (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    actividad VARCHAR(100) NOT NULL,
    sala VARCHAR(50) NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    plazas INTEGER NOT NULL CHECK (plazas > 0),
    monitor_id INTEGER NOT NULL REFERENCES monitores(id)
);

-- Tabla de reservas
CREATE TABLE reservas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id),
    clase_id INTEGER NOT NULL REFERENCES clases(id),
    fecha_reserva DATE NOT NULL,
    UNIQUE (socio_id, clase_id)
);

-- Tabla de especialidades
CREATE TABLE especialidades (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- Tabla intermedia de monitores y especialidades
CREATE TABLE monitor_especialidades (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    monitor_id INTEGER NOT NULL REFERENCES monitores(id),
    especialidad_id INTEGER NOT NULL REFERENCES especialidades(id),
    UNIQUE (monitor_id, especialidad_id)
);


-- ============================================
-- Ejercicio B2 - Insertar datos de prueba
-- ============================================

-- Insertar los planes disponibles
INSERT INTO planes (nombre, precio_mensual)
VALUES
    ('Básico', 29.90),
    ('Completo', 44.90),
    ('Estudiante', 24.90),
    ('Mañanas', 19.90);

-- Insertar los socios
INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES
    ('11111111A', 'Ana Pérez', 'ana@gym.com', '2026-01-10', 2),
    ('22222222B', 'Luis García', 'luis@gym.com', '2026-02-03', 1),
    ('33333333C', 'Marta López', 'marta@gym.com', '2026-03-15', 3),
    ('44444444D', 'Hugo Sanz', 'hugo@gym.com', '2026-03-20', 2),
    ('55555555E', 'Lucía Ruiz', 'lucia@gym.com', '2026-05-02', 3),
    ('66666666F', 'Pablo Martín', 'pablo@gym.com', '2026-06-11', 1),
    ('77777777G', 'Sara Gil', 'sara@gym.com', '2026-09-01', 2),
    ('88888888H', 'Diego Vidal', 'diego@gym.com', '2026-10-01', 1);

-- Insertar las tarjetas
-- Diego todavía no tiene tarjeta
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES
    ('TJ-0001', TRUE, 1),
    ('TJ-0002', TRUE, 2),
    ('TJ-0003', TRUE, 3),
    ('TJ-0004', FALSE, 4),
    ('TJ-0005', TRUE, 5),
    ('TJ-0006', TRUE, 6),
    ('TJ-0007', TRUE, 7);

-- Insertar los monitores
INSERT INTO monitores (dni, nombre, email)
VALUES
    ('90000001J', 'Carla Navarro', 'carla@gym.com'),
    ('90000002K', 'Javier Ortega', 'javier@gym.com'),
    ('90000003L', 'Elena Romero', 'elena@gym.com'),
    ('90000004M', 'Rubén Castro', 'ruben@gym.com');

-- Insertar las clases
-- Rubén todavía no da ninguna clase
INSERT INTO clases (actividad, sala, fecha_hora, plazas, monitor_id)
VALUES
    ('Spinning', 'Sala 1', '2026-11-02 09:00', 12, 1),
    ('Yoga', 'Sala 2', '2026-11-02 18:00', 10, 2),
    ('Pilates', 'Sala 2', '2026-11-03 10:00', 8, 3),
    ('Spinning', 'Sala 1', '2026-11-03 19:00', 12, 1),
    ('Zumba', 'Sala 3', '2026-11-04 18:30', 20, 3),
    ('Yoga', 'Sala 2', '2026-11-05 09:30', 10, 2),
    ('Crossfit', 'Sala 3', '2026-11-05 20:00', 3, 1);

-- Insertar las reservas
-- La clase 6 todavía no tiene reservas
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES
    (1, 1, '2026-10-28'),
    (1, 3, '2026-10-28'),
    (1, 7, '2026-10-29'),
    (2, 1, '2026-10-29'),
    (2, 2, '2026-10-29'),
    (3, 2, '2026-10-30'),
    (3, 5, '2026-10-30'),
    (4, 1, '2026-10-30'),
    (4, 7, '2026-10-31'),
    (5, 3, '2026-10-31'),
    (5, 5, '2026-10-31'),
    (6, 4, '2026-11-01'),
    (7, 5, '2026-11-01'),
    (7, 7, '2026-11-01');

-- Insertar las especialidades
INSERT INTO especialidades (nombre)
VALUES
    ('Ciclo indoor'),
    ('Yoga'),
    ('Pilates'),
    ('Baile'),
    ('Fuerza');

-- Relacionar los monitores con sus especialidades
INSERT INTO monitor_especialidades (monitor_id, especialidad_id)
VALUES
    (1, 1),
    (1, 5),
    (2, 2),
    (2, 3),
    (3, 3),
    (3, 4),
    (4, 5);

-- ============================================
-- Ejercicio B3 - Comprobar restricciones
-- ============================================
-- Ejecutar cada prueba por separado quitando solo sus prefijos --.
-- B3.1 a B3.6 deben fallar; no ejecutar junto con B1 y B2.

-- Ejercicio B3.1
-- Un socio con un plan que no existe
-- INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
-- VALUES ('99999999Z', 'Nora Prueba', 'nora@gym.com', '2026-10-27', 99);

-- Ejercicio B3.2
-- Un socio con el email de Ana
-- INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
-- VALUES ('99999999Z', 'Nora Prueba', 'ana@gym.com', '2026-10-27', 1);

-- Ejercicio B3.3
-- Una segunda tarjeta para Ana
-- INSERT INTO tarjetas (codigo, activa, socio_id)
-- VALUES ('TJ-0099', TRUE, 1);

-- Ejercicio B3.4
-- Ana reserva otra vez el Spinning del lunes
-- INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
-- VALUES (1, 1, '2026-10-30');

-- Ejercicio B3.5
-- Una reserva para una clase que no existe
-- INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
-- VALUES (2, 50, '2026-10-30');

-- Ejercicio B3.6
-- Borrar el plan Básico
-- DELETE FROM planes WHERE nombre = 'Básico';

-- Ejercicio B3.7
-- Borrar Mañanas y volver a insertarlo antes de B4.
-- SELECT * FROM planes WHERE nombre = 'Mañanas';
-- DELETE FROM planes WHERE nombre = 'Mañanas';
-- INSERT INTO planes (nombre, precio_mensual) VALUES ('Mañanas', 19.90);
-- SELECT * FROM planes ORDER BY id;

-- ============================================
-- Ejercicio B4 - Consultar tablas relacionadas
-- ============================================
-- Resultados comprobados con los datos B2, antes de las modificaciones B5.

-- Ejercicio B4.1
-- Socios con su plan y precio
SELECT s.nombre AS socio, p.nombre AS plan, p.precio_mensual
FROM socios s
INNER JOIN planes p ON p.id = s.plan_id
ORDER BY s.nombre;

-- Ejercicio B4.2
-- Clases con su monitor
SELECT c.actividad, c.fecha_hora, c.sala, m.nombre AS monitor
FROM clases c
INNER JOIN monitores m ON m.id = c.monitor_id
ORDER BY c.fecha_hora, c.id;

-- Ejercicio B4.3
-- Todos los socios, tengan o no tarjeta
SELECT s.nombre AS socio, t.codigo AS tarjeta
FROM socios s
LEFT JOIN tarjetas t ON t.socio_id = s.id
ORDER BY s.nombre;

-- Ejercicio B4.4
-- Socios sin tarjeta
SELECT s.nombre AS socio
FROM socios s
LEFT JOIN tarjetas t ON t.socio_id = s.id
WHERE t.id IS NULL
ORDER BY s.nombre;

-- Ejercicio B4.5
-- Número de socios por plan, incluidos los planes vacíos
SELECT p.nombre AS plan, COUNT(s.id) AS socios
FROM planes p
LEFT JOIN socios s ON s.plan_id = p.id
GROUP BY p.id, p.nombre
ORDER BY p.id;

-- Ejercicio B4.6
-- Reservas con socio y clase
SELECT s.nombre AS socio, c.actividad, c.fecha_hora
FROM reservas r
INNER JOIN socios s ON s.id = r.socio_id
INNER JOIN clases c ON c.id = r.clase_id
ORDER BY s.nombre, c.fecha_hora, r.id;

-- Ejercicio B4.7
-- Socios apuntados a la clase 1
SELECT s.nombre AS socio
FROM reservas r
INNER JOIN socios s ON s.id = r.socio_id
WHERE r.clase_id = 1
ORDER BY s.nombre;

-- Ejercicio B4.8
-- Clases con su número de reservas
SELECT c.id, c.actividad, c.fecha_hora, c.plazas, COUNT(r.id) AS reservas
FROM clases c
LEFT JOIN reservas r ON r.clase_id = c.id
GROUP BY c.id, c.actividad, c.fecha_hora, c.plazas
ORDER BY c.fecha_hora, c.id;

-- Ejercicio B4.9
-- Monitores que no dan clases
SELECT m.nombre AS monitor
FROM monitores m
LEFT JOIN clases c ON c.monitor_id = m.id
WHERE c.id IS NULL
ORDER BY m.nombre;

-- Ejercicio B4.10
-- Especialidades de cada monitor
SELECT m.nombre AS monitor, e.nombre AS especialidad
FROM monitor_especialidades me
INNER JOIN monitores m ON m.id = me.monitor_id
INNER JOIN especialidades e ON e.id = me.especialidad_id
ORDER BY m.nombre, e.nombre;

-- ============================================
-- Ejercicio B5 - Modificar y borrar
-- ============================================
-- Ejecutar una sola vez después de B4.

-- Ejercicio B5.1
-- Luis se cambia al plan Completo
SELECT s.* FROM socios s WHERE s.email = 'luis@gym.com';
UPDATE socios
SET plan_id = (SELECT p.id FROM planes p WHERE p.nombre = 'Completo')
WHERE email = 'luis@gym.com';

-- Ejercicio B5.2
-- Activar la tarjeta de Hugo
SELECT t.* FROM tarjetas t WHERE t.codigo = 'TJ-0004';
UPDATE tarjetas SET activa = TRUE WHERE codigo = 'TJ-0004';

-- Ejercicio B5.3
-- Crear la tarjeta de Diego
SELECT s.id, s.nombre FROM socios s WHERE s.email = 'diego@gym.com';
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES ('TJ-0008', TRUE, (SELECT s.id FROM socios s WHERE s.email = 'diego@gym.com'));

-- Ejercicio B5.4
-- Diego reserva el Yoga del jueves
SELECT c.* FROM clases c WHERE c.id = 6;
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES ((SELECT s.id FROM socios s WHERE s.email = 'diego@gym.com'), 6, '2026-11-02');

-- Ejercicio B5.5
-- Cancelar solo la reserva de Luis para la clase 2
SELECT r.* FROM reservas r
WHERE r.socio_id = (SELECT s.id FROM socios s WHERE s.email = 'luis@gym.com')
  AND r.clase_id = 2;
DELETE FROM reservas
WHERE socio_id = (SELECT s.id FROM socios s WHERE s.email = 'luis@gym.com')
  AND clase_id = 2;

-- Ejercicio B5.6
-- La baja directa falla; quitar -- solo para probar el error por separado.
-- SELECT * FROM socios WHERE email = 'pablo@gym.com';
-- DELETE FROM socios WHERE email = 'pablo@gym.com';
-- Borrar primero las filas que dependen de Pablo y después al socio.
BEGIN;
SELECT r.* FROM reservas r
WHERE r.socio_id = (SELECT s.id FROM socios s WHERE s.email = 'pablo@gym.com');
DELETE FROM reservas
WHERE socio_id = (SELECT s.id FROM socios s WHERE s.email = 'pablo@gym.com');
SELECT t.* FROM tarjetas t
WHERE t.socio_id = (SELECT s.id FROM socios s WHERE s.email = 'pablo@gym.com');
DELETE FROM tarjetas
WHERE socio_id = (SELECT s.id FROM socios s WHERE s.email = 'pablo@gym.com');
SELECT * FROM socios WHERE email = 'pablo@gym.com';
DELETE FROM socios WHERE email = 'pablo@gym.com';
COMMIT;
