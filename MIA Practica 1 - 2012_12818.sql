/**** Practica 1 - MIA Vacaciones 1er Semestre 2020 ****/
/**** Luis Enrique López Urbina ****/
/**** Carnet: 2012-12818 ****/

/* Crear Base de datos y usuario administrador */
/* 1. Acceder a la consola de postgresql */
--Comando: sudo -i -u postgres

/* 2.Crear un usuario administrador */
--Comando: createuser --interactive -W

/* 3. Crear base de datos y asignar usuario adminstrador */
--Comando: createdb practica -O adminpractica


/**** 1. Generar el script que crea cada una de las tablas que conforman la base de
datos propuesta por el Comité Olímpico. ****/


/*CREAR TABLAS*/
CREATE TABLE profesion (
    cod_prof INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

ALTER TABLE profesion ADD CONSTRAINT profesion_nombre_uq UNIQUE (nombre);

CREATE TABLE pais (
    cod_pais INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

ALTER TABLE pais ADD CONSTRAINT pais_nombre_uq UNIQUE (nombre);

CREATE TABLE puesto (
    cod_puesto INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

ALTER TABLE puesto ADD CONSTRAINT puesto_nombre_uq UNIQUE (nombre);

CREATE TABLE departamento (
    cod_depto INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

ALTER TABLE departamento ADD CONSTRAINT departamento_nombre_uq UNIQUE (nombre);

CREATE TABLE miembro (
    cod_miembro INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    edad INTEGER NOT NULL,
    telefono INTEGER,
    residencia VARCHAR(100),
    PAIS_cod_pais INTEGER NOT NULL,
    PROFESION_cod_prof INTEGER NOT NULL,
    FOREIGN KEY (PAIS_cod_pais) REFERENCES pais (cod_pais) ON DELETE CASCADE,
    FOREIGN KEY (PROFESION_cod_prof) REFERENCES profesion (cod_prof) ON DELETE CASCADE
);

CREATE TABLE puesto_miembro (
    MIEMBRO_cod_miembro INTEGER NOT NULL,
    PUESTO_cod_puesto INTEGER NOT NULL,
    DEPARTAMENTO_cod_depto INTEGER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    PRIMARY KEY (MIEMBRO_cod_miembro, PUESTO_cod_puesto, DEPARTAMENTO_cod_depto),
    FOREIGN KEY (MIEMBRO_cod_miembro) REFERENCES miembro (cod_miembro) ON DELETE CASCADE,
    FOREIGN KEY (PUESTO_cod_puesto) REFERENCES puesto (cod_puesto) ON DELETE CASCADE,
    FOREIGN KEY (DEPARTAMENTO_cod_depto)REFERENCES departamento(cod_depto) ON DELETE CASCADE
);

CREATE TABLE tipo_medalla (
    cod_tipo INTEGER PRIMARY KEY,
    medalla VARCHAR(20)
);

ALTER TABLE tipo_medalla ADD CONSTRAINT tipo_medalla_medalla_uq UNIQUE (medalla);

CREATE TABLE medallero (
    PAIS_cod_pais INTEGER NOT NULL,
    cantidad_medallas INTEGER NOT NULL,
    TIPO_MEDALLA_cod_tipo INTEGER NOT NULL,
    PRIMARY KEY (PAIS_cod_pais, TIPO_MEDALLA_cod_tipo),
    FOREIGN KEY (TIPO_MEDALLA_cod_tipo) REFERENCES tipo_medalla (cod_tipo) ON DELETE CASCADE,
    FOREIGN KEY (PAIS_cod_pais) REFERENCES pais (cod_pais) ON DELETE CASCADE
);

CREATE TABLE disciplina (
    cod_disciplina INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
);

CREATE TABLE atleta (
    cod_atleta INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    edad INTEGER NOT NULL,
    participaciones VARCHAR(100) NOT NULL,
    DISCIPLINA_cod_disciplina INTEGER NOT NULL,
    PAIS_cod_pais INTEGER NOT NULL,
    FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES disciplina (cod_disciplina) ON DELETE CASCADE,
    FOREIGN KEY (PAIS_cod_pais) REFERENCES pais (cod_pais) ON DELETE CASCADE
);

CREATE TABLE categoria (
    cod_categoria INTEGER PRIMARY KEY,
    categoria VARCHAR(50) NOT NULL
);

CREATE TABLE tipo_participacion (
    cod_participacion INTEGER PRIMARY KEY,
    tipo_participacion VARCHAR(100) NOT NULL
);

CREATE TABLE evento (
    cod_evento INTEGER PRIMARY KEY,
    fecha DATE NOT NULL,
    ubicacion VARCHAR(50) NOT NULL,
    hora DATE NOT NULL,
    DISCIPLINA_cod_disciplina INTEGER NOT NULL,
    TIPO_PARTICIPACION_cod_participacion INTEGER NOT NULL,
    CATEGORIA_cod_categoria INTEGER NOT NULL,
    FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES disciplina (cod_disciplina) ON DELETE CASCADE,
    FOREIGN KEY (TIPO_PARTICIPACION_cod_participacion) REFERENCES tipo_participacion (cod_participacion) ON DELETE CASCADE,
    FOREIGN KEY (CATEGORIA_cod_categoria) REFERENCES categoria (cod_categoria) ON DELETE CASCADE
);

CREATE TABLE evento_atleta (
    ATLETA_cod_atleta INTEGER NOT NULL,
    EVENTO_cod_evento INTEGER NOT NULL,
    PRIMARY KEY (ATLETA_cod_atleta, EVENTO_cod_evento),
    FOREIGN KEY (ATLETA_cod_atleta) REFERENCES atleta (cod_atleta) ON DELETE CASCADE,
    FOREIGN KEY (EVENTO_cod_evento) REFERENCES evento (cod_evento) ON DELETE CASCADE
);

CREATE TABLE televisora (
    cod_televisora INTEGER PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE costo_evento (
    EVENTO_cod_evento INTEGER NOT NULL,
    TELEVISORA_cod_televisora INTEGER NOT NULL,
    tarifa INTEGER NOT NULL,
    PRIMARY KEY (EVENTO_cod_evento, TELEVISORA_cod_televisora),
    FOREIGN KEY (EVENTO_cod_evento) REFERENCES evento (cod_evento) ON DELETE CASCADE,
    FOREIGN KEY (TELEVISORA_cod_televisora) REFERENCES televisora (cod_televisora) ON DELETE CASCADE
);


/**** 2. En la tabla “Evento” se decidió que la fecha y hora se trabajaría en una sola
columna. ****/

/* Eliminar las columnas fecha y hora */
ALTER TABLE evento DROP COLUMN fecha;
ALTER TABLE evento DROP COLUMN hora;

/* Crear una columna llamada fecha_hora con el tipo DBMS*/
ALTER TABLE evento ADD COLUMN fecha_hora TIMESTAMP NOT NULL;


/**** 3. Generar el Script que únicamente permita registrar los eventos entre el 24 de julio
de 2020 a partir de las 9:00 hasta el 09 de agosto de 2020 hasta las 20:00 ****/

ALTER TABLE evento ADD CONSTRAINT rango_fecha_hora_evento_ck
    CHECK (fecha_hora >= '2020-07-24 09:00:00' AND fecha_hora <= '2020-08-09 20:00:00');


/**** 4. Las ubicaciones de los eventos se registrarán en una tabla sede y la tabla
   evento en la columna ubicacion solo tendra la llave foreana del codigo de la tabla sede ****/

/* A. Crear tabla Sede */
CREATE TABLE sede (
    cod_sede INTEGER PRIMARY KEY,
    sede VARCHAR(50) NOT NULL
);

/* B. Cambiar el tipo de dato de la columna Ubicación de la tabla Evento por un tipo entero. */
ALTER TABLE evento ALTER COLUMN ubicacion SET DATA TYPE INTEGER USING ubicacion::INTEGER;

/* C. Crear una llave foránea en la columna Ubicación de la tabla Evento y
referenciarla a la columna código de la tabla Sede */

ALTER TABLE evento ADD CONSTRAINT sede_codigo_fk FOREIGN KEY (ubicacion) REFERENCES sede (cod_sede) ON DELETE CASCADE;


/**** 5. Se revisó la información de los miembros que se tienen actualmente y antes
de que se ingresen a la base de datos el Comité desea que a los miembros
que no tengan número telefónico se le ingrese el número por Default 0 al
momento de ser cargados a la base de datos. ****/

ALTER TABLE miembro ALTER COLUMN telefono SET DEFAULT 0;


/**** 6. Generar el script necesario para hacer la inserción de datos a las tablas
requeridas. ****/

/* País */
INSERT INTO pais (cod_pais, nombre) VALUES (1, 'Guatemala');
INSERT INTO pais (cod_pais, nombre) VALUES (2, 'Francia');
INSERT INTO pais (cod_pais, nombre) VALUES (3, 'Argentina');
INSERT INTO pais (cod_pais, nombre) VALUES (4, 'Alemania');
INSERT INTO pais (cod_pais, nombre) VALUES (5, 'Italia');
INSERT INTO pais (cod_pais, nombre) VALUES (6, 'Brasil');
INSERT INTO pais (cod_pais, nombre) VALUES (7, 'Estados Unidos');

/* Profesión */
INSERT INTO profesion (cod_prof, nombre) VALUES (1, 'Médico');
INSERT INTO profesion (cod_prof, nombre) VALUES (2, 'Arquitecto');
INSERT INTO profesion (cod_prof, nombre) VALUES (3, 'Ingeniero');
INSERT INTO profesion (cod_prof, nombre) VALUES (4, 'Secretaria');
INSERT INTO profesion (cod_prof, nombre) VALUES (5, 'Auditor');

/* Miembro */
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (1, 'Scott', 'Mitchell', 32, 0, '1092 Highland Drive Manitowoc, WI 54220', 7, 3);
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (2, 'Fanette', 'Poulin', 25, 25075853, '49, boulevard Aristide Briand 76120 LE GRAND-QUEVILLY', 2, 4);
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (3, 'Laura', 'Cunha Silva', 55, 0, 'Rua Onze, 86 Uberaba-MG', 6, 5);
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (4, 'Juan José', 'López', 38, 36985247, '26 calle 4-10 zona 11', 1, 2);
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (5, 'Arcangela', 'Punicucci', 39, 391664921, 'Via Santa Teresa, 114 90010-Geraci Siculo PA', 5, 1);
INSERT INTO miembro (cod_miembro, nombre, apellido, edad, telefono, residencia, pais_cod_pais, profesion_cod_prof)
VALUES (6, 'Jeuel', 'Villalpando', 31, 0, 'Acuña de Figeroa 6106 80101 Playa Pascual', 3, 5);

/* Disciplina */
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (1, 'Atletismo', 'Saltos de longitud y triples, de altura y con pértiga o garrocha; las pruebas de lanzamiento de martillo, jabalina y disco.');
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (2, 'Bádminton', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (3, 'Ciclismo', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (4, 'Judo', 'Es un arte marcial que se originó en Japón alrededor de 1880');
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (5, 'Lucha', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (6, 'Tenis de mesa', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (7, 'Boxeo', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (8, 'Natación', 'Está presente como deporte en los Juegos desde la primera edición de la era moderna, en Atenas, Grecia, en 1896, donde se disputo en aguas abiertas.');
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (9, 'Esgrima', null);
INSERT INTO disciplina (cod_disciplina, nombre, descripcion) VALUES (10, 'Vela', null);

/* Tipo Medalla */
INSERT INTO tipo_medalla (cod_tipo, medalla) VALUES (1, 'Oro');
INSERT INTO tipo_medalla (cod_tipo, medalla) VALUES (2, 'Plata');
INSERT INTO tipo_medalla (cod_tipo, medalla) VALUES (3, 'Bronce');
INSERT INTO tipo_medalla (cod_tipo, medalla) VALUES (4, 'Platino');


/* Categoria */
INSERT INTO categoria (cod_categoria, categoria) VALUES (1, 'Clasificatorio');
INSERT INTO categoria (cod_categoria, categoria) VALUES (2, 'Eliminatorio');
INSERT INTO categoria (cod_categoria, categoria) VALUES (3, 'Final');


/* Tipo participacion */
INSERT INTO tipo_participacion (cod_participacion, tipo_participacion) VALUES (1, 'Individual');
INSERT INTO tipo_participacion (cod_participacion, tipo_participacion) VALUES (2, 'Parejas');
INSERT INTO tipo_participacion (cod_participacion, tipo_participacion) VALUES (3, 'Equipos');


/* Medallero */
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (5, 3, 1);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (2, 5, 1);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (6, 4, 3);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (4, 3, 4);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (7, 10, 3);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (3, 8, 2);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (1, 2, 1);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (1, 5, 4);
INSERT INTO medallero (pais_cod_pais, cantidad_medallas, tipo_medalla_cod_tipo) VALUES (5, 7, 2);

/* Sede */
INSERT INTO sede (cod_sede, sede) VALUES (1, 'Gimnasio Metropolitano de Tokio');
INSERT INTO sede (cod_sede, sede) VALUES (2, 'Jardín del Palacio Imperial de Tokio');
INSERT INTO sede (cod_sede, sede) VALUES (3, 'Gimnasio Nacional Yoyogi');
INSERT INTO sede (cod_sede, sede) VALUES (4, 'Nippon Budokan');
INSERT INTO sede (cod_sede, sede) VALUES (5, 'Estadio Olímpico');

/* Evento */
INSERT INTO evento (cod_evento, ubicacion, disciplina_cod_disciplina, tipo_participacion_cod_participacion, categoria_cod_categoria, fecha_hora)
VALUES (1, 3, 2, 2, 1, '2020-07-24 11:00:00');
INSERT INTO evento (cod_evento, ubicacion, disciplina_cod_disciplina, tipo_participacion_cod_participacion, categoria_cod_categoria, fecha_hora)
VALUES (2, 1, 6, 1, 3, '2020-07-26 10:30:00');
INSERT INTO evento (cod_evento, ubicacion, disciplina_cod_disciplina, tipo_participacion_cod_participacion, categoria_cod_categoria, fecha_hora)
VALUES (3, 5, 7, 1, 2, '2020-07-30 18:45:00');
INSERT INTO evento (cod_evento, ubicacion, disciplina_cod_disciplina, tipo_participacion_cod_participacion, categoria_cod_categoria, fecha_hora)
VALUES (4, 2, 1, 1, 1, '2020-08-01 12:15:00');
INSERT INTO evento (cod_evento, ubicacion, disciplina_cod_disciplina, tipo_participacion_cod_participacion, categoria_cod_categoria, fecha_hora)
VALUES (5, 4, 10, 3, 1, '2020-08-08 19:35:00');

/*PAIS*/
SELECT * FROM pais ORDER BY cod_pais;
/*PRODESION*/
SELECT * FROM profesion ORDER BY cod_prof;
/*PAIS*/
SELECT m.*, p.nombre, p2.nombre
FROM miembro m
    JOIN pais p on m.PAIS_cod_pais = p.cod_pais
    JOIN profesion p2 on m.PROFESION_cod_prof = p2.cod_prof
ORDER BY m.cod_miembro;
/*DISCIPLINA*/
SELECT * FROM disciplina ORDER BY cod_disciplina;
/*TIPO MEDATALLA*/
SELECT * FROM tipo_medalla ORDER BY cod_tipo;
/*CATEGORIA*/
SELECT * FROM categoria ORDER BY cod_categoria;
/*TIPO PARTICIPACION*/
SELECT * FROM tipo_participacion ORDER BY cod_participacion;
/*TIPO MEDALLERO*/
SELECT m.PAIS_cod_pais, p.nombre, m.TIPO_MEDALLA_cod_tipo, tm.medalla, m.cantidad_medallas
FROM medallero m
    JOIN pais p on m.PAIS_cod_pais = p.cod_pais
    JOIN tipo_medalla tm on m.TIPO_MEDALLA_cod_tipo = tm.cod_tipo;
/*SEDE*/
SELECT * FROM sede;
/*EVENTO*/
SELECT e.cod_evento, e.fecha_hora, e.ubicacion, s.sede, e.DISCIPLINA_cod_disciplina, d.nombre,
       e.TIPO_PARTICIPACION_cod_participacion, tp.tipo_participacion,
       e.CATEGORIA_cod_categoria, c.categoria
FROM evento e
    JOIN disciplina d ON e.DISCIPLINA_cod_disciplina = d.cod_disciplina
    JOIN tipo_participacion tp ON e.TIPO_PARTICIPACION_cod_participacion = tp.cod_participacion
    JOIN categoria c ON e.CATEGORIA_cod_categoria = c.cod_categoria
    JOIN sede s ON e.ubicacion = s.cod_sede
ORDER BY e.cod_evento;


/**** 7. Elabore el script que elimine las restricciones UNIQUE de las columnas: ****/

--Pais
ALTER TABLE pais DROP CONSTRAINT pais_nombre_uq;

--Tipo medalla
ALTER TABLE tipo_medalla DROP CONSTRAINT tipo_medalla_medalla_uq;

--Departamento
ALTER TABLE departamento DROP CONSTRAINT departamento_nombre_uq;


/**** 8. Atletas pueden participar en varias disciplinas y no solo en una ****/

--a. Script que elimine la llave foránea de “cod_disciplina” que se encuentra en la tabla “Atleta”.
ALTER TABLE atleta DROP CONSTRAINT atleta_disciplina_cod_disciplina_fkey;

--a.1 ELiminar la columna DISCIPLINA_cod_disciplina
ALTER TABLE atleta DROP COLUMN disciplina_cod_disciplina;

--b. Script que cree una tabla con el nombre “Disciplina_Atleta”:
CREATE TABLE disciplina_atleta (
    ATLETA_cod_atleta INTEGER NOT NULL,
    DISCIPLINA_cod_disciplina INTEGER NOT NULL,
    PRIMARY KEY (ATLETA_cod_atleta, DISCIPLINA_cod_disciplina),
    FOREIGN KEY (DISCIPLINA_cod_disciplina) REFERENCES disciplina (cod_disciplina) ON DELETE CASCADE,
    FOREIGN KEY (ATLETA_cod_atleta) REFERENCES atleta (cod_atleta) ON DELETE CASCADE
);


/**** 9. En la tabla “Costo_Evento” se determinó que la columna “tarifa” no debe
ser entero sino un decimal con 2 cifras de precisión.
Generar el script para modificar el tipo de dato que se pide. ****/

ALTER TABLE costo_evento ALTER COLUMN tarifa TYPE NUMERIC(1000,2);


/**** 10. Generar el Script que borre de la tabla “Tipo_Medalla”, el registro siguiente: cod_tipo: 4 ****/
DELETE FROM tipo_medalla WHERE cod_tipo = 4 AND medalla = 'Platino';


/**** 11. Generar un script que elimine la tabla TELEVISORAs y COSTO_EVENTO ****/
DROP TABLE costo_evento;
DROP TABLE televisora;


/**** 12. Generar un script que elimine todos los registros contenidos en la tabla DISCIPLINA ****/
DELETE FROM disciplina;


/**** 13. Actualizar los registros de numeros telefonicos de los miembros que no tenian numero telefonico ****/
UPDATE miembro SET telefono = 55464601 WHERE nombre = 'Laura' AND apellido = 'Cunha Silva';
UPDATE miembro SET telefono = 91514243 WHERE nombre = 'Jeuel' AND apellido = 'Villalpando';
UPDATE miembro SET telefono = 920686670 WHERE nombre = 'Scott' AND apellido = 'Mitchell';


/**** 14. Agregar a la tabla atleta una columna llamada fotografia, la cual no es requerida ****/
ALTER TABLE atleta ADD fotografia TEXT;


/**** 15. Todos los atletas que se registren deben cumplir con ser menores a 25 años.
De lo contrario no se debe poder registrar a un atleta en la base de datos. ****/
ALTER TABLE atleta ADD CONSTRAINT validar_edad_minima_atleta_ck CHECK (edad < 25);

--Prueba inciso 15
INSERT INTO public.atleta (cod_atleta, nombre, apellido, edad, participaciones, pais_cod_pais, fotografia)
VALUES (1, 'Luis', 'López', 24, '1', 1, null);
