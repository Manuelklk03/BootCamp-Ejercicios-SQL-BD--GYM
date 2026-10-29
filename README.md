# Entrega: SQL — Diseña la base de datos de un gimnasio

## Objetivo

Hasta ahora has creado tablas, insertado datos y hecho consultas. En esta entrega vas a hacer lo que se hace **antes** de escribir SQL: **pensar cómo se guardan los datos**.

Al terminar deberías poder:

- Explicar qué es una **clave primaria**, una **clave alternativa** (`UNIQUE`) y una **clave ajena**.
- Reconocer relaciones **1:1**, **1:N**, **N:1** y **N:M**.
- Decidir **en qué tabla va la clave ajena**. Es el secreto de todo esto.
- Crear las tablas en PostgreSQL y comprobar que las claves protegen los datos.
- Consultar datos de varias tablas con `INNER JOIN` y `LEFT JOIN`.

**Tiempo orientativo:** 3–4 horas.

**Qué vas a entregar:** un archivo `gimnasio.sql` y un archivo `respuestas.md` (detalles en el apartado [Entrega](#entrega)).

**Cómo trabajarla:**

- Haz la **Parte A** (pensar) antes de tocar PostgreSQL. Es la parte más importante.
- Responde cada pregunta **antes** de seguir leyendo: los apartados siguientes van dando pistas.
- Si te atascas, vuelve a leer el enunciado, consulta la documentación del final o pregunta. Lo que cuenta es que sepas explicar por qué.

---

## 0. El problema

La dueña del gimnasio **FitVal** te cuenta esto:

> «Tenemos **socios**. De cada socio guardamos su DNI, nombre, email y la fecha en la que se dio de alta. No puede haber dos socios con el mismo DNI ni con el mismo email.
>
> Cada socio paga un **plan** (Básico, Completo, Estudiante…). Cada plan tiene un precio al mes. Muchos socios están en el mismo plan, pero un socio solo tiene un plan.
>
> Para entrar, cada socio tiene **una tarjeta de acceso** con un código. Una tarjeta es de un único socio, y un socio solo tiene una tarjeta. Los socios recién llegados pueden estar unos días sin tarjeta.
>
> Tenemos **monitores** (trabajadores): DNI, nombre y email.
>
> Programamos **clases**: «Spinning el lunes a las 9:00 en la Sala 1, 12 plazas». Cada clase la da **un** monitor. Un monitor da muchas clases.
>
> Los socios **reservan** plaza en las clases. Un socio reserva muchas clases y a una clase van muchos socios. Queremos saber qué día hizo cada reserva. Un socio no puede reservar dos veces la misma clase.
>
> Ah, y cada monitor tiene **especialidades** (Yoga, Pilates, Fuerza…). Un monitor puede tener varias y la misma especialidad la tienen varios monitores.»

Todas las tablas de la entrega salen de este texto. Vuelve a leerlo cada vez que tengas una duda sobre el diseño.

---

# PARTE A — Pensar antes de escribir SQL

Escribe tus respuestas de esta parte en `respuestas.md`, con el número de cada ejercicio (A1, A2…).

## 1. Tres tipos de clave

| Clave | Para qué sirve | ¿Se puede repetir? | ¿Puede estar vacía (`NULL`)? | En SQL |
|---|---|---|---|---|
| **Clave primaria (PK)** | Identifica cada fila. Solo hay **una** por tabla. | No | No | `PRIMARY KEY` |
| **Clave alternativa** | Otra columna que **también** identifica a la fila, pero no es la principal. Ej.: DNI, email. | No | Mejor que no (`NOT NULL`) | `UNIQUE` |
| **Clave ajena (FK)** | Guarda el `id` de una fila **de otra tabla**. Es la que **relaciona** tablas. | **Sí, normalmente sí** | Depende de si la relación es obligatoria | `REFERENCES otra_tabla(id)` |

> La clave ajena también se llama **clave foránea** (en inglés, *foreign key*). Es lo mismo.

Ejemplo con la tabla `socios`:

| id (PK) | dni (UNIQUE) | nombre | email (UNIQUE) | plan_id (FK) |
|---:|---|---|---|---:|
| 1 | 11111111A | Ana Pérez | ana@gym.com | 2 |
| 2 | 22222222B | Luis García | luis@gym.com | 1 |
| 4 | 44444444D | Hugo Sanz | hugo@gym.com | 2 |

Fíjate: `plan_id` vale `2` en dos filas. **Una clave ajena se repite**, porque muchos socios pueden tener el mismo plan. Una PK o un `UNIQUE`, nunca.

### Ejercicio A1

Mirando la tabla de arriba:

1. ¿Qué columnas no se pueden repetir nunca?
2. ¿Cuál es la clave primaria? ¿Cuáles son claves alternativas?
3. ¿Qué columna apunta a otra tabla? ¿A cuál?
4. El DNI ya identifica a cada socio. ¿Por qué crees que usamos un `id` numérico como clave primaria en vez del DNI? Da al menos una razón.

---

## 2. Los tipos de relación y las dos preguntas

Para saber cómo se relacionan dos tablas **A** y **B**, hazte siempre **dos preguntas**:

1. **Un A**, ¿con cuántos B se relaciona? → *uno* o *muchos*
2. **Un B**, ¿con cuántos A se relaciona? → *uno* o *muchos*

| Respuestas | Relación | ¿Dónde va la clave ajena? |
|---|---|---|
| uno y uno | **1:1** (uno a uno) | En una de las dos tablas (normalmente en la que «depende» de la otra) **+ `UNIQUE`** |
| uno y muchos | **1:N** (uno a muchos) | En la tabla del lado **muchos** |
| muchos y uno | **N:1** (muchos a uno) | Es la misma relación que 1:N vista desde el otro lado. En el lado **muchos** |
| muchos y muchos | **N:M** (muchos a muchos) | En **ninguna** de las dos: se crea una **tabla intermedia** con dos claves ajenas |

Las dos reglas que hay que recordar:

> **Regla 1.** La clave ajena va en el lado del **muchos**.
>
> **Regla 2.** Si los dos lados son **muchos**, crea una tabla en medio.

¿Por qué? Porque **en una celda solo cabe un valor**. Lo vas a ver en los ejemplos.

### Ejercicio A2

Con el enunciado del apartado 0, haz las dos preguntas para cada pareja y escribe el tipo de relación:

| Pareja | Un A, ¿cuántos B? | Un B, ¿cuántos A? | Relación |
|---|---|---|---|
| planes – socios | | | |
| socios – tarjetas | | | |
| monitores – clases | | | |
| socios – clases | | | |
| monitores – especialidades | | | |

---

## 3. Relación 1:N — ejemplo resuelto: planes y socios

**Las dos preguntas:**

- Un plan, ¿cuántos socios? → **muchos**.
- Un socio, ¿cuántos planes? → **uno**.

Relación **1:N**. Lado *muchos*: **socios**. La clave ajena va en `socios`.

### ¿Y si la pusiéramos al revés?

Intentemos guardar los socios dentro de `planes`:

| id | nombre | precio_mensual | socio_id |
|---:|---|---:|---|
| 2 | Completo | 44.90 | **1, 4, 7** ❌ |

No cabe: en una celda solo va **un** valor. Tendríamos que repetir el plan una vez por socio, con el precio copiado mil veces. Mal.

Ahora en el lado correcto:

| id | nombre | plan_id |
|---:|---|---:|
| 1 | Ana | 2 |
| 4 | Hugo | 2 |
| 7 | Sara | 2 |

Cada socio guarda **un solo** número. El plan se escribe una vez en su tabla. ✅

### Así queda en SQL

```sql
CREATE TABLE planes (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    precio_mensual NUMERIC(6,2) NOT NULL CHECK (precio_mensual >= 0)
);

CREATE TABLE socios (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni VARCHAR(9) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    fecha_alta DATE NOT NULL,
    plan_id INTEGER NOT NULL REFERENCES planes(id)
);
```

Qué significa lo importante:

- `plan_id INTEGER`: es un número porque guarda un `id` de `planes`, que es un número.
- `REFERENCES planes(id)`: PostgreSQL comprobará que ese plan existe.
- `NOT NULL`: todo socio **tiene que** tener un plan («un socio paga un plan»).
- `NUMERIC(6,2)`: número con 2 decimales, el tipo recomendado para dinero.
- **Orden:** `planes` se crea **antes** que `socios`. No puedes apuntar a una tabla que todavía no existe.

### Ejercicio A3 — Ahora tú: monitores y clases

Repite el razonamiento para **monitores** y **clases**:

1. Haz las dos preguntas.
2. ¿En qué tabla va la clave ajena? ¿Cómo la llamarías?
3. Dibuja (en una tabla Markdown) cómo quedaría si la pusieras **en el lado equivocado** y explica en una frase por qué falla.
4. ¿Debe ser `NOT NULL`? ¿Por qué?
5. ¿Qué tabla hay que crear primero?

---

## 4. Relación 1:1 — ejemplo resuelto: socios y tarjetas

**Las dos preguntas:**

- Un socio, ¿cuántas tarjetas? → **una**.
- Una tarjeta, ¿cuántos socios? → **uno**.

Relación **1:1**. Aquí la clave ajena *podría* ir en cualquiera de las dos. ¿Cuál elegimos?

- Un socio puede existir **sin** tarjeta (los recién llegados).
- Una tarjeta **no** existe sin su socio.

La tarjeta **depende** del socio, así que la clave ajena va en `tarjetas`. Si la pusiéramos en `socios` (`tarjeta_id`), los socios sin tarjeta tendrían esa columna vacía.

```sql
CREATE TABLE tarjetas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    activa BOOLEAN NOT NULL,
    socio_id INTEGER UNIQUE NOT NULL REFERENCES socios(id)
);
```

El truco está en **`UNIQUE`** sobre `socio_id`:

- **Sin `UNIQUE`:** el socio 1 podría aparecer en varias tarjetas → sería 1:N.
- **Con `UNIQUE`:** cada socio aparece como mucho en una tarjeta → 1:1. ✅

> **Una relación 1:1 es una relación 1:N con `UNIQUE` en la clave ajena.**

### Ejercicio A4

1. ¿Qué pasaría si quitásemos `UNIQUE` de `socio_id`? Explícalo con un ejemplo de datos.
2. Hay dos columnas `UNIQUE` en `tarjetas`. ¿Qué evita cada una?
3. Inventa otra relación 1:1 de la vida real (fuera del gimnasio) y di en qué tabla pondrías la clave ajena.

---

## 5. Relación N:M — ejemplo resuelto: socios y clases

**Las dos preguntas:**

- Un socio, ¿cuántas clases reserva? → **muchas**.
- Una clase, ¿cuántos socios? → **muchos**.

Relación **N:M**. Prueba a poner la clave ajena en un lado:

`clase_id` en `socios`:

| id | nombre | clase_id |
|---:|---|---|
| 1 | Ana | **1, 3, 7** ❌ |

`socio_id` en `clases`:

| id | actividad | socio_id |
|---:|---|---|
| 1 | Spinning | **1, 2, 4** ❌ |

**No cabe en ningún lado.** Solución: una **tabla intermedia** donde cada fila es **una reserva** (un socio + una clase):

```text
socios  1 ──── N  reservas  N ──── 1  clases
```

Una relación N:M se convierte en **dos relaciones 1:N**. Y ya sabes dónde va la clave ajena en una 1:N: en el lado muchos, o sea, en `reservas`, dos veces.

| id | socio_id | clase_id | fecha_reserva |
|---:|---:|---:|---|
| 1 | 1 | 1 | 2026-10-28 |
| 2 | 1 | 3 | 2026-10-28 |
| 4 | 2 | 1 | 2026-10-29 |

```sql
CREATE TABLE reservas (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    socio_id INTEGER NOT NULL REFERENCES socios(id),
    clase_id INTEGER NOT NULL REFERENCES clases(id),
    fecha_reserva DATE NOT NULL,
    UNIQUE (socio_id, clase_id)
);
```

Qué significa lo importante:

- Dos claves ajenas: una a `socios` y otra a `clases`.
- `fecha_reserva`: la tabla intermedia puede guardar datos **de la relación**. La fecha no es del socio ni de la clase: es de **esa** reserva.
- `UNIQUE (socio_id, clase_id)`: la **pareja** no se repite. Ana puede reservar muchas clases y la clase 1 puede tener muchos socios, pero Ana no puede reservar la clase 1 dos veces.

### Ejercicio A5 — Ahora tú: monitores y especialidades

1. Haz las dos preguntas y escribe el tipo de relación.
2. ¿Qué tablas necesitas? Ponles nombre.
3. Escribe las columnas de cada tabla y marca cuál es PK, cuál `UNIQUE` y cuál FK.
4. ¿Qué evita el `UNIQUE` de la tabla intermedia?
5. ¿Qué tienen en común `reservas` y tu tabla intermedia? ¿En qué se diferencian?

---

## 6. Entrenamiento: ¿dónde va la clave ajena?

### Ejercicio A6

Para cada caso: haz las dos preguntas, escribe la relación y di **en qué tabla va la clave ajena** (o qué tabla intermedia crearías).

1. País – ciudad.
2. Persona – pasaporte.
3. Alumno – asignatura.
4. Cliente – pedido.
5. Película – actor. (Pista: ¿dónde guardarías el nombre del personaje?)
6. Autor – libro. (Cuidado: depende de un dato que no te he dado. ¿Cuál?)
7. **Furniro:** usuario – pedido (*User – Order*).
8. **Furniro:** pedido – producto (*Order – Product*). ¿Qué datos guardarías en la tabla intermedia?

---

## 7. El modelo completo

> Lee este apartado **cuando hayas terminado A1–A6**: aquí está el modelo completo.

**Usa exactamente estos nombres** de tablas y columnas. Los datos de prueba de la Parte B dependen de ellos.

```text
planes (id PK, nombre UNIQUE, precio_mensual)
socios (id PK, dni UNIQUE, nombre, email UNIQUE, fecha_alta, plan_id FK → planes)
tarjetas (id PK, codigo UNIQUE, activa, socio_id FK UNIQUE → socios)
monitores (id PK, dni UNIQUE, nombre, email UNIQUE)
clases (id PK, actividad, sala, fecha_hora, plazas, monitor_id FK → monitores)
reservas (id PK, socio_id FK → socios, clase_id FK → clases, fecha_reserva, UNIQUE(socio_id, clase_id))
especialidades (id PK, nombre UNIQUE)
monitor_especialidades (id PK, monitor_id FK → monitores, especialidad_id FK → especialidades, UNIQUE(monitor_id, especialidad_id))
```

```text
planes 1 ──── N socios 1 ──── 1 tarjetas
                 │
                 1
                 │
                 N
             reservas
                 N
                 │
                 1
monitores 1 ──── N clases

monitores 1 ──── N monitor_especialidades N ──── 1 especialidades
```

Más adelante veremos cómo se dibuja esto de forma estándar con diagramas UML.

---

# PARTE B — Construirlo en PostgreSQL

Escribe **todo el SQL** de esta parte en `gimnasio.sql`, con un comentario antes de cada ejercicio:

```sql
-- Ejercicio B3.1
SELECT ...
```

## 8. Prepara la base de datos

Usa el PostgreSQL de Docker de la clase. Arráncalo si está parado:

```bash
docker start postgres-sql
```

Crea una base de datos nueva llamada `gimnasio`:

- **pgAdmin:** clic derecho en **Databases → Create → Database…**, nombre `gimnasio`, **Save**. Después abre el **Query Tool** sobre `gimnasio`.
- **Terminal:**

```bash
docker exec -it postgres-sql psql -U alumno -d academia
```

```sql
CREATE DATABASE gimnasio;
\c gimnasio
```

Comprueba **siempre** que estás conectado a `gimnasio` antes de ejecutar nada.

**Script de reinicio.** Si te equivocas y quieres empezar de cero, ejecuta esto (borra las tablas en orden inverso: primero las que apuntan a otras):

```sql
DROP TABLE IF EXISTS monitor_especialidades;
DROP TABLE IF EXISTS especialidades;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS clases;
DROP TABLE IF EXISTS monitores;
DROP TABLE IF EXISTS tarjetas;
DROP TABLE IF EXISTS socios;
DROP TABLE IF EXISTS planes;
```

## 9. Crea las tablas

### Ejercicio B1

1. Copia y ejecuta las tablas que ya tienes resueltas: `planes`, `socios` (apartado 3) y `tarjetas` (apartado 4).
2. Escribe **tú** el `CREATE TABLE` de `monitores` y `clases`. Tipos sugeridos: `fecha_hora TIMESTAMP`, `plazas INTEGER` (con `CHECK` para que sea mayor que 0).
3. Copia y ejecuta `reservas` (apartado 5). Ojo con el orden: ¿qué tablas tienen que existir antes?
4. Escribe **tú** el `CREATE TABLE` de `especialidades` y `monitor_especialidades`.
5. Comprueba la estructura: `\dt` y `\d clases` en `psql`, o **Tables → Refresh** en pgAdmin.

- [ ] Tengo las 8 tablas creadas.
- [ ] `\d reservas` muestra las dos claves ajenas y el `UNIQUE`.

## 10. Carga los datos de prueba

### Ejercicio B2

Copia y ejecuta este script **una sola vez**, con las tablas recién creadas (los `id` deben empezar en 1):

```sql
INSERT INTO planes (nombre, precio_mensual)
VALUES
    ('Básico', 29.90),
    ('Completo', 44.90),
    ('Estudiante', 24.90),
    ('Mañanas', 19.90);

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

-- Diego (8) todavía no tiene tarjeta
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES
    ('TJ-0001', TRUE, 1),
    ('TJ-0002', TRUE, 2),
    ('TJ-0003', TRUE, 3),
    ('TJ-0004', FALSE, 4),
    ('TJ-0005', TRUE, 5),
    ('TJ-0006', TRUE, 6),
    ('TJ-0007', TRUE, 7);

INSERT INTO monitores (dni, nombre, email)
VALUES
    ('90000001J', 'Carla Navarro', 'carla@gym.com'),
    ('90000002K', 'Javier Ortega', 'javier@gym.com'),
    ('90000003L', 'Elena Romero', 'elena@gym.com'),
    ('90000004M', 'Rubén Castro', 'ruben@gym.com');

-- Rubén (4) es nuevo y todavía no da ninguna clase
INSERT INTO clases (actividad, sala, fecha_hora, plazas, monitor_id)
VALUES
    ('Spinning', 'Sala 1', '2026-11-02 09:00', 12, 1),
    ('Yoga', 'Sala 2', '2026-11-02 18:00', 10, 2),
    ('Pilates', 'Sala 2', '2026-11-03 10:00', 8, 3),
    ('Spinning', 'Sala 1', '2026-11-03 19:00', 12, 1),
    ('Zumba', 'Sala 3', '2026-11-04 18:30', 20, 3),
    ('Yoga', 'Sala 2', '2026-11-05 09:30', 10, 2),
    ('Crossfit', 'Sala 3', '2026-11-05 20:00', 3, 1);

-- La clase 6 (Yoga del jueves) no tiene reservas
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

INSERT INTO especialidades (nombre)
VALUES
    ('Ciclo indoor'),
    ('Yoga'),
    ('Pilates'),
    ('Baile'),
    ('Fuerza');

INSERT INTO monitor_especialidades (monitor_id, especialidad_id)
VALUES
    (1, 1),
    (1, 5),
    (2, 2),
    (2, 3),
    (3, 3),
    (3, 4),
    (4, 5);
```

Comprueba con `SELECT * FROM` cada tabla.

- [ ] 4 planes, 8 socios, 7 tarjetas, 4 monitores, 7 clases, 14 reservas, 5 especialidades.

> Si un `INSERT` falla a medias, los `id` pueden dejar de empezar en 1. Lo más rápido: script de reinicio, crear tablas y cargar otra vez.

## 11. Rompe la base de datos a propósito

Las claves no son decoración: **protegen los datos**. Vamos a comprobarlo.

### Ejercicio B3

Para cada instrucción:

1. **Antes de ejecutarla**, escribe en `respuestas.md` qué crees que pasará y por qué.
2. Ejecútala.
3. Copia la línea del error (está en inglés: tradúcela) y di **qué clave** lo ha impedido.

```sql
-- B3.1 Un socio con un plan que no existe
INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES ('99999999Z', 'Nora Prueba', 'nora@gym.com', '2026-10-27', 99);

-- B3.2 Un socio con el email de Ana
INSERT INTO socios (dni, nombre, email, fecha_alta, plan_id)
VALUES ('99999999Z', 'Nora Prueba', 'ana@gym.com', '2026-10-27', 1);

-- B3.3 Una segunda tarjeta para Ana
INSERT INTO tarjetas (codigo, activa, socio_id)
VALUES ('TJ-0099', TRUE, 1);

-- B3.4 Ana reserva otra vez el Spinning del lunes
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES (1, 1, '2026-10-30');

-- B3.5 Una reserva para una clase que no existe
INSERT INTO reservas (socio_id, clase_id, fecha_reserva)
VALUES (2, 50, '2026-10-30');

-- B3.6 Borrar el plan Básico
DELETE FROM planes WHERE nombre = 'Básico';

-- B3.7 Borrar el plan Mañanas
DELETE FROM planes WHERE nombre = 'Mañanas';
```

**Pregunta B3.8:** B3.6 falla y B3.7 funciona. Los dos son planes. ¿Por qué?

> Después de B3.7 ya no existe el plan «Mañanas». **Vuelve a insertarlo**, lo necesitarás en B4.5:
>
> ```sql
> INSERT INTO planes (nombre, precio_mensual) VALUES ('Mañanas', 19.90);
> ```

## 12. Consultas

### Ejercicio B4

Escribe una consulta para cada apartado. Usa alias (`s`, `p`, `c`…).

1. Nombre de cada socio, nombre de su plan y precio. Ordenado por nombre del socio.
2. Todas las clases con actividad, fecha y hora, sala y **nombre del monitor**, ordenadas por fecha.
3. Todos los socios con el código de su tarjeta. **Deben salir también los que no tienen tarjeta.**
4. Solo los socios que **no** tienen tarjeta.
5. Cuántos socios hay en cada plan. Deben salir **todos** los planes, aunque tengan 0 socios. (Pista: `LEFT JOIN` y `COUNT(s.id)`, no `COUNT(*)`.)
6. Lista de reservas: nombre del socio, actividad y fecha y hora de la clase. (Pista: empieza en `reservas` y haz dos `JOIN`.)
7. Nombres de los socios apuntados a la clase con `id` 1.
8. Para cada clase: actividad, fecha y hora, plazas y número de reservas. Deben salir también las clases sin reservas.
9. Monitores que no dan ninguna clase.
10. Cada monitor con sus especialidades (una fila por pareja monitor–especialidad).

**Pregunta B4.11:** en la consulta 6, Ana sale tres veces. ¿Es un error? ¿Por qué ocurre?

## 13. Modificar y borrar

Recuerda: antes de un `UPDATE` o un `DELETE`, haz un `SELECT` con el mismo `WHERE`.

### Ejercicio B5

1. Luis se cambia al plan Completo. Actualízalo usando su email.
2. Hugo ha pagado: activa su tarjeta `TJ-0004`.
3. Dale a Diego la tarjeta `TJ-0008` (activa).
4. Diego reserva el Yoga del jueves (clase 6) con fecha `2026-11-02`.
5. Luis cancela su reserva del Yoga del lunes (clase 2). Borra **solo esa** reserva.
6. Pablo se da de baja. Intenta borrarlo con `DELETE FROM socios WHERE email = 'pablo@gym.com';`. ¿Qué pasa? Bórralo correctamente. ¿En qué orden has tenido que borrar y por qué?

## 14. Explícalo con tus palabras

### Ejercicio B6

Responde en `respuestas.md`, con una o dos frases cada una:

1. ¿Qué diferencia hay entre una clave primaria y una clave `UNIQUE`?
2. ¿Por qué una clave ajena sí puede repetirse?
3. En una relación 1:N, ¿en qué lado va la clave ajena? ¿Por qué no en el otro?
4. ¿Qué convierte una relación 1:N en una 1:1?
5. ¿Por qué una relación N:M necesita una tabla intermedia?
6. ¿Por qué `fecha_reserva` está en `reservas` y no en `socios` ni en `clases`?

---

## Entrega

Crea un repositorio en GitHub llamado `sql-gimnasio` con:

- [ ] `gimnasio.sql`: todos los `CREATE TABLE` (B1) y todo el SQL de B3, B4 y B5, cada uno con su comentario `-- Ejercicio ...`.
- [ ] `respuestas.md`: respuestas de A1–A6, B3 (predicción, error y explicación), B4.11 y B6.
- [ ] Una captura del resultado de la consulta B4.6 (reservas con socio y clase).

Entrega en Moodle la **URL del repositorio**. Si no puedes usar GitHub, sube los tres archivos directamente a Moodle.

Se valora como **Apto** si: el modelo de tablas es correcto (claves ajenas en su sitio), el SQL se ejecuta y las respuestas están explicadas con tus palabras. No hace falta que todo salga a la primera: explica qué has probado.

## Si algo falla

- **`relation "socios" does not exist`**: no has creado esa tabla, o estás conectado a otra base de datos. Comprueba que estás en `gimnasio`.
- **`relation "planes" does not exist` al crear `socios`**: orden incorrecto. Crea primero la tabla a la que apuntas.
- **Error de clave ajena al cargar los datos**: los `id` no empiezan en 1. Ejecuta el script de reinicio y vuelve a crear y cargar.
- **`syntax error at or near`**: revisa comas al final de cada columna (la última no lleva), paréntesis y punto y coma.
- **pgAdmin no muestra las tablas**: clic derecho en **Tables → Refresh**.
- **`cannot drop table ... because other objects depend on it`**: borra primero las tablas que apuntan a esa (usa el script de reinicio).

## Reto opcional

1. **Plazas libres:** para cada clase, muestra actividad, fecha y plazas libres (`plazas - reservas`). ¿Qué clase está llena?
2. **Ingresos:** ¿cuánto dinero ingresa el gimnasio al mes sumando el plan de cada socio?
3. **Socios activos:** socios con **2 o más** reservas, con su número de reservas. (Pista: `GROUP BY` + `HAVING`.)
4. **Tres tablas:** nombres de los socios (sin repetir) que han reservado alguna clase de Carla Navarro.
5. **Diseño:** el gimnasio quiere guardar el **historial de pagos** de cada socio (fecha, importe). ¿Qué tabla crearías? ¿Qué relación tiene con `socios` y dónde va la clave ajena? Escribe el `CREATE TABLE`.

## Documentación para consultar

- [PostgreSQL: restricciones (PRIMARY KEY, UNIQUE, FOREIGN KEY)](https://www.postgresql.org/docs/current/ddl-constraints.html)
- [PostgreSQL: JOIN entre tablas](https://www.postgresql.org/docs/current/tutorial-join.html)
- [W3Schools: SQL FOREIGN KEY](https://www.w3schools.com/sql/sql_foreignkey.asp)
- [W3Schools: SQL LEFT JOIN](https://www.w3schools.com/sql/sql_join_left.asp)

Si usas IA para resolver dudas, pídele que te **explique** el error o te dé una **pista**, no la solución. En la corrección tendrás que saber explicar tu modelo.
