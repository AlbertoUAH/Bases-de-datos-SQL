-- 1. ELIMINAMOS LA BASE DE DATOS, SI EXISTE, Y CREAMOS UNA NUEVA
DROP DATABASE IF EXISTS APPS_MOVILES;
CREATE DATABASE APPS_MOVILES;
USE APPS_MOVILES;

-- 2. BORRAMOS LAS TABLAS, SI EXISTEN
DROP TABLE IF EXISTS TRABAJA;
DROP TABLE IF EXISTS CREA;
DROP TABLE IF EXISTS REALIZA;
DROP TABLE IF EXISTS CONTIENE;
DROP TABLE IF EXISTS DESCARGA;
DROP TABLE IF EXISTS CATEGORIA_APLICACION;
DROP TABLE IF EXISTS EMPRESA;
DROP TABLE IF EXISTS TIENDA;
DROP TABLE IF EXISTS CATEGORIA;
DROP TABLE IF EXISTS USUARIO;
DROP TABLE IF EXISTS APLICACION;
DROP TABLE IF EXISTS EMPLEADO;

-- 3. CREAMOS INICIALMENTE LAS TABLAS
--  EMPRESA
/*
	Se ha elegido como PK el VAT de la empresa
	dado que una empresa, salvo que se registre,
	pueden tener el mismo nombre, mientras que el VAT
	es un identificador unico
*/
CREATE TABLE EMPRESA (
  VAT VARCHAR(12) PRIMARY KEY,
  NOMBRE VARCHAR(50) NOT NULL,
  PAIS_TRIBUTARIO VARCHAR(35) NOT NULL,
  ANNO_CREACION INT UNSIGNED NOT NULL,
  CORREO VARCHAR(50) UNIQUE NOT NULL,
  PAGINA_WEB VARCHAR(80) UNIQUE NOT NULL
  );

-- EMPLEADO
/*
	Nota: el teléfono fijo puede repetirse, dado que varios
	empleados pueden ser de la misma familia y por ello
	compartan el mismo numero
*/
CREATE TABLE EMPLEADO (
  DNI CHAR(9) PRIMARY KEY,
  CORREO VARCHAR(45) UNIQUE NOT NULL,
  TLFNO_FIJO INT UNSIGNED NOT NULL,
  TLFNO_MOVIL INT UNSIGNED UNIQUE NOT NULL,
  CALLE VARCHAR(80) NOT NULL,
  NUMERO VARCHAR(3) DEFAULT 's/n',
  CP CHAR(5) NOT NULL);

-- TRABAJA
/*
	Nota: debe comprobarse (CHECK) que la fecha de inicio
	sea menor a la fecha de fin del trabajo.

	Todos los elementos de la tabla son PK (salvo FECHA_FIN), 
	dado que un empleado no solo se identifica por su
	DNI y VAT de la empresa en la que trabaja, dado que puede
	trabajar en una misma empresa en diferentes periodos de tiempo
	- Si el DNI del empleado desaparece, sus valores en la tabla
	se eliminan en cascada, pues estaria haciendo referencia a un
	empleado que ya no existe (CASCADE).
	Por el contrario, si el codigo de la empresa desaparece, la tabla 
	se mantendria igual (RESTRICT), lo que permitiria conocer la 
	experiencia profesional de cada empleado
	- Si el DNI o VAT se actualiza, la actualización también
	se produce en dicha tabla (CASCADE)
*/
CREATE TABLE TRABAJA (
  DNI CHAR(9) NOT NULL,
  VAT VARCHAR(12) NOT NULL,
  FECHA_INI DATE NOT NULL,
  FECHA_FIN DATE NOT NULL,
  PRIMARY KEY (DNI, VAT, FECHA_INI),
  CHECK (FECHA_INI < FECHA_FIN),
    FOREIGN KEY (DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (VAT)
    REFERENCES EMPRESA (VAT)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- APLICACION
/*
	Nota: debe comprobarse (CHECK) que la fecha de inicio
	sea menor a la fecha de fin del proyecto.
	Ademas, el espacio de memoria de la aplicacion debe
	ser mayor que cero.
	
	La columna ESPACIO esta expresada en MB.
	- Si el DNI del empleado que dirige la aplicacion
	desaparece, la aplicacion no desapareceria
	(dado que continuaria funcionando y estando
	disponible en tienda), marcando unicamente como NULL
	la clave foranea
	- Si el DNI del jefe de proyecto se actualiza, la
	actualizacion tambien se produce en dicha tabla (CASCADE)
*/
CREATE TABLE APLICACION (
  NOMBRE VARCHAR(35) PRIMARY KEY,
  CODIGO INT UNSIGNED UNIQUE NOT NULL,
  FECHA_INI DATE NOT NULL,
  FECHA_FIN DATE NOT NULL,
  ESPACIO DOUBLE UNSIGNED NOT NULL COMMENT 'Espacio (en MB)',
  PRECIO DOUBLE UNSIGNED NOT NULL,
  EMPLEADO_DNI CHAR(9),
  CHECK (FECHA_INI < FECHA_FIN),
  CHECK (ESPACIO > 0),
    FOREIGN KEY (EMPLEADO_DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE SET NULL
    ON UPDATE CASCADE);

-- REALIZA
/*
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que aplicaciones realiza
	cada empleado, y viceversa.
	- Si el DNI del empleado desaparece, sus valores en la tabla
	se eliminan en cascada, pues estaria haciendo referencia a un
	empleado que ya no existe (CASCADE). 
	Por el contrario, si el nombre de la aplicacion desaparece, 
	la tabla se mantendria igual (RESTRICT), lo que permitiria conocer
	la experiencia de cada empleado en el desarrollo de aplicaciones
	- Si el DNI o el nombre se actualiza, la actualizacion tambien
	se produce en dicha tabla (CASCADE)
*/
CREATE TABLE REALIZA (
  DNI CHAR(9) NOT NULL,
  NOMBRE VARCHAR(35) NOT NULL,
  PRIMARY KEY (DNI, NOMBRE),
    FOREIGN KEY (DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (NOMBRE)
    REFERENCES  APLICACION (NOMBRE)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- CREA	
/*
	Las claves foraneas son tambien PKs, con el
	objetivo de identificar que aplicaciones realiza
	cada empresa, y viceversa.
	- Si el nombre de la aplicacion desaparece, sus valores en la tabla
	se eliminan en cascada, pues estaria haciendo referencia a una
	aplicacion que ya no existe (CASCADE).
	Por el contrario, si el codigo de la empresa desaparece, la tabla 
	se mantendria igual (RESTRICT), ya que una aplicacion puede haberse
	desarrollado por mas de una empresa, por lo que si se elimina, el numero
	de empresas que han participado seria inferior al real.
	- Si el VAT o nombre de aplicacion se actualiza, la actualización también
	se produce en dicha tabla (CASCADE)
*/
CREATE TABLE CREA (
  VAT VARCHAR(12) NOT NULL,
  NOMBRE VARCHAR(35) NOT NULL,
  PRIMARY KEY (VAT, NOMBRE),
    FOREIGN KEY (VAT)
    REFERENCES EMPRESA (VAT)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    FOREIGN KEY (NOMBRE)
    REFERENCES  APLICACION (NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- TIENDA
/*
	El campo GESTOR no tiene porque ser unico (mas de una tienda
	podria estar gestionada por una misma empresa)
*/	
CREATE TABLE TIENDA (
  NOMBRE VARCHAR(20) PRIMARY KEY,
  GESTOR VARCHAR(20) NOT NULL,
  DIRECCION_WEB VARCHAR(80) UNIQUE NOT NULL);

-- CONTIENE
/*
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que aplicaciones contiene
	cada tienda, y viceversa.
	- Si el nombre de la tienda o el nombre de la aplicacion
	desaparece, en esta situacion si se eliminarian los campos
	en CONTIENE, dado que desde el punto de vista del usuario,
	si la tienda o la aplicacion desapareciera, no podría descargar
	dicha app (CASCADE)
	- Si el nombre de la tienda o aplicacion se actualiza, la actualización 
	también se produce en dicha tabla (CASCADE)
*/
CREATE TABLE CONTIENE (
  NOMBRE_TIENDA VARCHAR(20) NOT NULL,
  NOMBRE_APLICACION VARCHAR(35) NOT NULL,
  PRIMARY KEY (NOMBRE_TIENDA, NOMBRE_APLICACION),
    FOREIGN KEY (NOMBRE_TIENDA)
    REFERENCES TIENDA (NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (NOMBRE_APLICACION)
    REFERENCES APLICACION (NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- CATEGORIA
-- El campo ID_CATEGORIA se auto-incrementa, lo que permite insertar unicamente el campo NOMBRE
-- para mayor comodidad
CREATE TABLE CATEGORIA (
  ID_CATEGORIA INT AUTO_INCREMENT PRIMARY KEY,
  NOMBRE VARCHAR(20) UNIQUE NOT NULL);

-- CATEGORIA_APLICACION
/*
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que categorias estan
	asociadas a cada aplicacion.
	- Si la categoria o aplicacion desaparecen, en esta situacion 
    se eliminarian los campos en CATEGORIA_APLICACION, dado 
    que dejarian de existir (desde el punto de vista del usuario final) (CASCADE)
	- Si el nombre de la categoria o tienda se actualiza, la actualización 
	también se produce en dicha tabla (CASCADE)
*/
CREATE TABLE CATEGORIA_APLICACION (
  NOMBRE VARCHAR(35) NOT NULL,
  ID_CATEGORIA INT NOT NULL,
  PRIMARY KEY (NOMBRE, ID_CATEGORIA),
    FOREIGN KEY (NOMBRE)
    REFERENCES APLICACION (NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_CATEGORIA)
    REFERENCES CATEGORIA (ID_CATEGORIA)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- USUARIO
-- Nota: si el numero de calle no existe, se incluye 's/n' por defecto
CREATE TABLE USUARIO (
  NUM_CUENTA INT PRIMARY KEY,
  NOMBRE VARCHAR(50) UNIQUE NOT NULL,
  CALLE VARCHAR(80) NOT NULL,
  NUMERO VARCHAR(3) DEFAULT 's/n',
  CP CHAR(5) NOT NULL,
  PAIS VARCHAR(35) NOT NULL);

-- DESCARGA
/*
	Nota: debe comprobarse (CHECK) que la puntuacion
	este comprendida entre 0 y 5.
	
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que usuarios descargan
	aplicaciones, y evitar con ello que un usuario descargue
	dos o mas veces la misma aplicacion.
	- Si el usuario o aplicacion desaparecen, con el fin
	de mantener un historico de descargas, no se eliminan
	las filas (RESTRICT).
	De este modo se permite conocer, por ejemplo,
	el numero de descargas realizadas en una fecha determinada,
	incluso en caso de que el usuario o la aplicacion ya no existan
	- Si el nombre de usuario o aplicacion se modifican, 
	la actualización también se produce en dicha tabla (CASCADE)
*/
CREATE TABLE DESCARGA (
  NUM_CUENTA INT NOT NULL,
  NOMBRE VARCHAR(35) NOT NULL,
  PUNTUACION INT UNSIGNED NULL,
  NUM_MOVIL INT UNSIGNED NOT NULL,
  FEC_DESCARGA DATE NOT NULL,
  COMENTARIO TEXT NULL,
  PRIMARY KEY (NUM_CUENTA, NOMBRE),
  CHECK (PUNTUACION BETWEEN 0 AND 5),
    FOREIGN KEY (NUM_CUENTA)
    REFERENCES USUARIO (NUM_CUENTA)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    FOREIGN KEY (NOMBRE)
    REFERENCES APLICACION (NOMBRE)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- ------------------------------------------------------------------------------------------------------------------------
-- 4. CARGA DATOS
SET GLOBAL local_infile ='ON';

-- Salvo la tabla categoria, el resto de tablas se cargan mediante ficheros .csv
LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/empresas.csv' 
INTO TABLE empresa 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/empleados.csv' 
INTO TABLE empleado 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/trabaja.csv' 
INTO TABLE trabaja 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tienda.csv' 
INTO TABLE tienda 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

INSERT INTO categoria (NOMBRE) VALUES
('Arte'), ('Automocion'), ('Belleza'),
('Casa y hogar'), ('Entretenimiento'),
('Social'), ('Compras'), ('Libros'),
('Educacion'), ('Empresas'),
('Estilo de vida'), ('Finanzas'), ('Fotografia');

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/aplicacion.csv' 
INTO TABLE aplicacion 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/realiza.csv' 
INTO TABLE realiza 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crea.csv' 
INTO TABLE crea
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/contiene.csv' 
INTO TABLE contiene 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categoria_aplicacion.csv' 
INTO TABLE categoria_aplicacion 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/usuario.csv' 
INTO TABLE usuario 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/descarga.csv' 
INTO TABLE descarga 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

-- ------------------------------------------------------------------------------------------------------------------------
-- 5. CREACION PROCEDURES, FUNCIONES Y TRIGGERS
-- Borramos los triggers, procedure y function (si existen)
DROP TRIGGER IF EXISTS comprobar_fecha_fin_trabaja_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_fin_aplicacion_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_descarga_BI;
DROP TRIGGER IF EXISTS comprobar_letra_dni_BI;
DROP TRIGGER IF EXISTS comprobar_trabaja_en_aplicacion_BI;

DROP PROCEDURE IF EXISTS comprobar_fecha;
DROP FUNCTION IF EXISTS comprobar_letra_dni;

-- Esta variable permite definir funciones en MySQL, de lo contrario fallaria por falta de permisos
SET GLOBAL log_bin_trust_function_creators = 1;

/*
	Procedimiento encargado de comprobar si
	una fecha pasada como parametro es mayor
	a la fecha actual, en cuyo caso responde
	con un mensaje de error.
*/
DELIMITER $$
CREATE PROCEDURE comprobar_fecha(fecha DATE)
BEGIN
	IF fecha > CURDATE() THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error. La fecha es superior a la fecha actual';
	END IF;
END$$

/*

	Funcion encargada de comprobar si la letra del DNI
	pasado como parametro es valido o no. Para ello extrae
	los numeros del DNI y, dividiendo entre 23, devuelve la letra
	correspondiente.
	Fuente: https://es.wikibooks.org/wiki/Algoritmia/Algoritmo_para_obtener_la_letra_del_NIF#PL-SQL

*/
CREATE FUNCTION comprobar_letra_dni(dni CHAR(9))
RETURNS CHAR(9)
BEGIN
	SET @dni_sin_letra = cast(substring(dni,1,8) as UNSIGNED);
	SET @letra = substring('TRWAGMYFPDXBNJZSQVHLCKE', @dni_sin_letra % 23 + 1,  1);
    RETURN @letra;
END$$

/*
	El procedimiento comprobar_fecha() se emplea
	para los triggers:
	
		-> comprobar_fecha_fin_trabaja_BI: comprueba que
		   la fecha fin de la tabla trabajo no sea mayor
		   a la fecha actual
		   
		-> comprobar_fecha_fin_aplicacion_BI: comprueba que
		   que la fecha de fin de disenno de la aplicacion no
		   sea mayor a la fecha actual
		   
		-> comprobar_fecha_descarga_BI: comprueba que la fecha
		   de descarga de una aplicacion no sea mayor a la fecha
		   actual
	En los triggers mencionados, la comprobacion se realiza ANTES
	DEL INSERT
*/
CREATE TRIGGER comprobar_fecha_fin_trabaja_BI
BEFORE INSERT
ON trabaja FOR EACH ROW
BEGIN
    CALL comprobar_fecha(NEW.FECHA_FIN);
END$$

CREATE TRIGGER comprobar_fecha_fin_aplicacion_BI
BEFORE INSERT
ON aplicacion FOR EACH ROW
BEGIN
    CALL comprobar_fecha(NEW.FECHA_FIN);
END$$

CREATE TRIGGER comprobar_fecha_descarga_BI
BEFORE INSERT
ON descarga FOR EACH ROW
BEGIN
	IF NEW.FEC_DESCARGA < (SELECT FECHA_FIN FROM APLICACION WHERE NOMBRE = NEW.NOMBRE) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error. La fecha es superior a la fecha de fin de la aplicacion';
	ELSE
		CALL comprobar_fecha(NEW.FEC_DESCARGA);
	END IF;
END$$

/*
	Mediante la funcion comprobar_letra_dni, este
	trigger se encargara de comprobar si
	el DNI es o no valido, en funcion de la letra
	calculada. En caso negativo, devuelve un mensaje
	de error.
	
	La comprobacion se realiza ANTES DEL INSERT
*/
CREATE TRIGGER comprobar_letra_dni_BI
BEFORE INSERT
ON empleado FOR EACH ROW
BEGIN
    SET @letra = comprobar_letra_dni(NEW.DNI);
    IF @letra <> substring(NEW.DNI,9,9) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error. EL DNI NO es valido";
	END IF;
END$$

/*
	Por ultimo, comprobar_trabaja_en_aplicacion_BI se encargara
	de comprobar si el jefe de proyecto esta previamente en la tabla
	realiza. En caso contrario, se mostrara un mensaje de error.
	
	La comprobacion se realiza ANTES DEL INSERT
*/
CREATE TRIGGER comprobar_trabaja_en_aplicacion_BI BEFORE INSERT ON aplicacion
    FOR EACH ROW
    BEGIN
        IF NEW.EMPLEADO_DNI NOT IN (
            SELECT distinct(r.DNI)
            FROM realiza AS r
            WHERE (NEW.EMPLEADO_DNI = r.DNI)
        ) THEN
           SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Error. El jefe de proyecto no esta en la tabla Realiza";
	END IF;
END$$

DELIMITER ;

-- ------------------------------------------------------------------------------------------------------------------------
-- 6. CONSULTAS

-- Consulta 1. Obtener la fecha en la que se realizan mas descargas
SELECT FEC_DESCARGA, count(FEC_DESCARGA) as NUM_DESCARGAS
FROM descarga
GROUP BY FEC_DESCARGA
ORDER BY NUM_DESCARGAS DESC
LIMIT 1;

-- Consulta 2. Obtener las 3 empresas que haya participado mas veces en el desarrollo de aplicaciones
SELECT e.*, count(c.VAT) AS PARTICIPACIONES
FROM empresa AS e INNER JOIN crea AS c USING(VAT)
GROUP BY c.VAT
ORDER BY PARTICIPACIONES DESC
LIMIT 3;

-- Consulta 3. Obtener aquellos empleados que hayan estado en mas de una empresa (o en la misma empresa mas de una vez),
-- que tengan extension de correo @gmail
SELECT emp.*
FROM empleado AS emp INNER JOIN (SELECT DNI FROM trabaja GROUP BY DNI HAVING count(DNI) > 1) AS t
ON emp.DNI = t.DNI
WHERE CORREO LIKE '%@gmail%';

-- Consulta 4. Obtener el DNI del empleado con menos experiencia laboral (en meses)
SELECT e.DNI, sum(timestampdiff(month, t.FECHA_INI, t.FECHA_FIN)) as MESES
FROM empleado AS e INNER JOIN trabaja AS t USING(DNI)
GROUP BY e.DNI
ORDER BY MESES
LIMIT 1;

-- Consulta 5. Obtener el pais de los usuarios que mas aplicaciones se han descargado (y el que menos)
SELECT descargas.PAIS, max(descargas.NUM_DESCARGAS) AS DESCARGAS
FROM
(SELECT PAIS, count(PAIS) as NUM_DESCARGAS
FROM usuario INNER JOIN descarga USING(NUM_CUENTA)
GROUP BY PAIS
ORDER BY NUM_DESCARGAS DESC) as descargas

UNION

SELECT descargas.PAIS, min(descargas.NUM_DESCARGAS) AS DESCARGAS
FROM
(SELECT PAIS, count(PAIS) as NUM_DESCARGAS
FROM usuario INNER JOIN descarga USING(NUM_CUENTA)
GROUP BY PAIS
ORDER BY NUM_DESCARGAS) as descargas;

-- Consulta 6. Obtener DNI, correo y movil de aquellos empleados que NO hayan sido responsables de alguna aplicacion,
-- pertenecientes a la empresa ItalicSystems
SELECT distinct(e.DNI), e.CORREO, e.TLFNO_MOVIL
FROM empresa AS emp INNER JOIN trabaja AS t ON emp.VAT = t.VAT
INNER JOIN empleado AS e ON t.DNI = e.DNI
INNER JOIN realiza AS r ON e.DNI = r.DNI
LEFT JOIN aplicacion AS a ON r.DNI = a.EMPLEADO_DNI
WHERE a.EMPLEADO_DNI IS NULL AND emp.NOMBRE = 'ItalicSystems';

-- Consulta 7. Obtener la aplicacion que menos tiempo haya requerido (en meses) y que haya obtenido un mayor numero de descargas
SELECT a.NOMBRE, timestampdiff(month, a.FECHA_INI, a.FECHA_FIN) as MESES, count(d.NOMBRE) as DESCARGAS
FROM aplicacion AS a INNER JOIN descarga AS d USING(NOMBRE)
GROUP BY a.nombre
ORDER BY MESES ASC, DESCARGAS DESC
LIMIT 1;

-- Consulta 8. Obtener el numero de descargas, agrupadas por tienda (de menos a mas descargas)
SELECT c.NOMBRE_TIENDA, count(d.NOMBRE) as NUM_DESCARGAS
FROM contiene AS c INNER JOIN aplicacion AS a ON c.NOMBRE_APLICACION = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
GROUP BY c.NOMBRE_TIENDA
ORDER BY NUM_DESCARGAS;

-- Consulta 9. Obtener los ingresos totales de las empresas gracias a las aplicaciones (solo de pago) descargadas, cuyo precio este por debajo de la media
SELECT c.VAT, round(a.PRECIO * descargas_por_app.DESCARGAS,2) as INGRESOS
FROM crea AS c INNER JOIN aplicacion AS a ON c.NOMBRE = a.NOMBRE
INNER JOIN 
(SELECT NOMBRE, count(NOMBRE) as DESCARGAS
FROM descarga
GROUP BY NOMBRE) as descargas_por_app ON c.NOMBRE = descargas_por_app.NOMBRE 
WHERE a.PRECIO != 0 AND a.PRECIO < (SELECT avg(PRECIO) FROM aplicacion WHERE PRECIO != 0);

-- Consulta 10. Obtener el precio y espacio de memoria medio de las aplicaciones de pago, que NO sean nativas (NO esten en una unica tienda) 
SELECT round(avg(PRECIO),2) as PRECIO_MEDIO, round(avg(ESPACIO),2) as ESPACIO_MEDIO
FROM aplicacion
WHERE PRECIO != 0 AND NOMBRE NOT IN
(SELECT NOMBRE_APLICACION
FROM contiene
GROUP BY NOMBRE_APLICACION
HAVING count(NOMBRE_TIENDA) = 1);

-- Consulta 11. Obtener el VAT y nombre de las empresas han participado en el desarrollo de aplicaciones nativas (esten en una unica tienda)
SELECT e.VAT, e.NOMBRE
FROM empresa AS e INNER JOIN crea AS c ON e.VAT = c.VAT
INNER JOIN aplicacion AS a ON c.NOMBRE = a.NOMBRE
WHERE a.NOMBRE IN (SELECT NOMBRE_APLICACION FROM contiene GROUP BY NOMBRE_APLICACION HAVING count(NOMBRE_TIENDA) = 1);

-- Consulta 12. Obtener las categorias con una puntuacion acumulada en sus aplicaciones mayor a 100, cuyo pais de descarga sea Espana
SELECT c.NOMBRE, sum(d.PUNTUACION) as PUNTUACION_ACUMULADA
FROM categoria AS c INNER JOIN categoria_aplicacion AS c_a ON c.ID_CATEGORIA = c_a.ID_CATEGORIA
INNER JOIN aplicacion AS a ON c_a.NOMBRE = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
INNER JOIN usuario AS u ON d.NUM_CUENTA = u.NUM_CUENTA
WHERE u.PAIS = 'Espana'
GROUP BY c.NOMBRE
HAVING PUNTUACION_ACUMULADA > 100
ORDER BY PUNTUACION_ACUMULADA DESC;

-- Consulta 13. Obtener DNI y telefono de aquellos empleados que se hayan descargado 7 aplicaciones o menos
SELECT e.TLFNO_MOVIL, e.DNI
FROM empleado AS e
WHERE EXISTS 
(SELECT NUM_CUENTA, count(NOMBRE) as DESCARGAS 
FROM descarga AS d 
WHERE d.NUM_MOVIL = e.TLFNO_MOVIL
GROUP BY NUM_CUENTA
HAVING DESCARGAS <= 7);

-- Si quisiera consultar los usuarios que no han descargado ninguna aplicacion
SELECT u.*
FROM usuario AS u LEFT JOIN descarga AS d
ON u.NUM_CUENTA = d.NUM_CUENTA
WHERE d.NUM_CUENTA IS NULL;

-- Consulta 14. Consultar las aplicaciones con mas de 2 categorias, realizadas entre los annos 2014 y 2020, cuyo espacio en memoria no supere los 60 MB, 
-- y que el porcentaje de descargas (con respecto al numero total de usuarios) sea mayor al 40 %
SELECT distinct(a.NOMBRE)
FROM aplicacion AS a INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
INNER JOIN
(SELECT NOMBRE FROM categoria_aplicacion GROUP BY NOMBRE HAVING count(NOMBRE) > 2) AS t ON d.NOMBRE = t.NOMBRE
WHERE year(a.FECHA_INI) >= 2014 AND year(a.FECHA_FIN) <= 2020
AND a.ESPACIO < 60 AND a.NOMBRE IN
(SELECT NOMBRE
FROM descarga
GROUP BY NOMBRE
HAVING count(*) * 100 / (SELECT count(*) FROM usuario) > 40);

-- Consulta 15. Consultar empleados cuyas aplicaciones en las que hayan participado tengan un numero de descargas superior a 30
-- y una puntuacion media mayor a 3. Ademas, dichos empleados deben tener entre 2 y 5 annos de experiencia.
SELECT e.*
FROM empleado AS e INNER JOIN realiza AS r ON e.DNI = r.DNI
INNER JOIN (SELECT NOMBRE FROM descarga GROUP BY NOMBRE HAVING count(NOMBRE) > 30 AND avg(PUNTUACION) > 3) as descarga ON r.NOMBRE = descarga.NOMBRE
WHERE e.DNI IN 
(SELECT distinct(t.DNI)
FROM empleado AS e INNER JOIN trabaja AS t ON e.DNI = t.DNI
GROUP BY t.DNI
HAVING sum(timestampdiff(year, t.FECHA_INI, t.FECHA_FIN)) BETWEEN 2 AND 5)
GROUP BY e.DNI;

-- Consulta 16. Consultar aquellas empresas que hayan participado en dos o mas aplicaciones de tipo Social o de Entretenimiento, que tengan menos de 4 ceros
-- en las puntuaciones por parte de los usuarios
SELECT c.VAT
FROM crea AS c
WHERE c.NOMBRE IN 
(
SELECT distinct(a.NOMBRE)
FROM aplicacion AS a
INNER JOIN categoria_aplicacion AS c_a ON a.NOMBRE = c_a.NOMBRE
INNER JOIN categoria AS ca ON c_a.ID_CATEGORIA = ca.ID_CATEGORIA
WHERE ca.NOMBRE IN ('Social', 'Entretenimiento') AND a.NOMBRE IN

(SELECT distinct(NOMBRE) FROM descarga WHERE PUNTUACION = 0 GROUP BY NOMBRE HAVING count(PUNTUACION) < 4

UNION

SELECT distinct(d.NOMBRE) FROM descarga AS d WHERE NOT EXISTS (SELECT d_1.NOMBRE FROM descarga AS d_1 WHERE d_1.NOMBRE = d.NOMBRE AND d_1.PUNTUACION = 0))

)
GROUP BY c.VAT
HAVING count(c.VAT) >= 2;