-- 1. Eliminamos la base de datos, si existe, y creamos una nueva
DROP DATABASE IF EXISTS APPS_MOVILES;
CREATE DATABASE APPS_MOVILES;
USE APPS_MOVILES;

-- 2. Borramos las tablas, si existen
DROP TABLE IF EXISTS TRABAJA;
DROP TABLE IF EXISTS REALIZA;
DROP TABLE IF EXISTS CONTIENE;
DROP TABLE IF EXISTS DESCARGA;
DROP TABLE IF EXISTS CATEGORIAS_APLICACION;
DROP TABLE IF EXISTS EMPRESA;
DROP TABLE IF EXISTS TIENDA;
DROP TABLE IF EXISTS CATEGORIAS;
DROP TABLE IF EXISTS USUARIO;
DROP TABLE IF EXISTS APLICACION;
DROP TABLE IF EXISTS EMPLEADO;

-- 3. Creamos inicialmente las tablas
--  EMPRESA
/*
	Nota: el anno de creacion de la empresa debe ser
	menor o igual al anno actual (CHECK).
	
	Se ha elegido como PK el VAT de la empresa
	dado que una empresa, salvo que se patente,
	pueden tener el mismo nombre, mientras que el VAT
	es un identificativo unico
*/
CREATE TABLE EMPRESA (
  VAT VARCHAR(12) PRIMARY KEY,
  NOMBRE VARCHAR(50) UNIQUE NOT NULL,
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
  NUMERO VARCHAR(3) NOT NULL DEFAULT 's/n',
  CP CHAR(5) NOT NULL);

-- TRABAJA
/*
	Nota: debe comprobarse (CHECK) que la fecha de inicio
	sea menor a la fecha de fin del trabajo. Ademas,
	la fecha de inicio debe ser menor a la fecha actual, 
	mientras que la fecha de fin debe ser menor o igual.

	Todos los elementos de la tabla son PK (salvo FECHA_FIN), 
	dado que un empleado no solo se identifica por su
	DNI y VAT de la empresa en la que trabaja, sino
	ademas por el intervalo de fechas en el que trabajo
	en dicha empresa.
	- Si el DNI del empleado o el VAT de la empresa
	desaparece, no se eliminan las filas (manteniendo
	un historico de datos)
	- Si el DNI o VAT se actualiza, la actualización también
	se produce en dicha tabla
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
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    FOREIGN KEY (VAT)
    REFERENCES EMPRESA (VAT)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- APLICACION
/*
	Nota: debe comprobarse (CHECK) que la fecha de inicio
	sea menor a la fecha de fin del proyecto. Ademas,
	la fecha de inicio debe ser menor a la fecha actual, 
	mientras que la fecha de fin debe ser menor o igual.
	Por ultimo, el espacio de memoria de la aplicacion debe
	ser mayor que cero.
	
	La columna espacio esta expresada en MB.
	- Si el DNI del empleado que dirige la aplicacion
	desaparece, la aplicacion no desapareceria
	(dado que continuaria funcionando y estando
	disponible en tienda)
	- Si el DNI del jefe de proyecto se actualiza, la
	actualizacion tambien se produce en dicha tabla
*/
CREATE TABLE APLICACION (
  NOMBRE VARCHAR(35) PRIMARY KEY,
  CODIGO INT UNSIGNED UNIQUE NOT NULL,
  FECHA_INI DATE NOT NULL,
  FECHA_FIN DATE NOT NULL,
  ESPACIO DOUBLE UNSIGNED NOT NULL COMMENT 'Espacio (en MB)',
  PRECIO DOUBLE UNSIGNED NOT NULL,
  EMPLEADO_DNI CHAR(9) NOT NULL,
  CHECK (FECHA_INI < FECHA_FIN),
  CHECK (ESPACIO > 0),
    FOREIGN KEY (EMPLEADO_DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- REALIZA
/*
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que aplicaciones realiza
	cada empleado, y viceversa.
	- Si el DNI del empleado o el nombre de la aplicacion
	desaparece, no se eliminan las filas (manteniendo
	un historico de datos)
	- Si el DNI o el nombre se actualiza, la actualizacion tambien
	se produce en dicha tabla
*/
CREATE TABLE REALIZA (
  DNI CHAR(9) NOT NULL,
  NOMBRE VARCHAR(35) NOT NULL,
  PRIMARY KEY (DNI, NOMBRE),
    FOREIGN KEY (DNI)
    REFERENCES EMPLEADO (DNI)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
    FOREIGN KEY (NOMBRE)
    REFERENCES  APLICACION (NOMBRE)
    ON DELETE RESTRICT
    ON UPDATE CASCADE);

-- TIENDA
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
	dicha app
	- Si el nombre de la tienda o aplicacion se actualiza, la actualización 
	también se produce en dicha tabla
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

-- CATEGORIAS 
CREATE TABLE CATEGORIAS (
  ID_CATEGORIA INT AUTO_INCREMENT PRIMARY KEY,
  NOMBRE VARCHAR(20) UNIQUE NOT NULL);

-- CATEGORIAS_APLICACION
/*
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que categorias estan
	asociadas a cada aplicacion.
	- Si la categoria o aplicacion desaparecen, en esta situacion 
        se eliminarian los campos en CATEGORIAS_APLICACION, dado 
        que dejarian de existir (desde el punto de vista del usuario final)
	- Si el nombre de la categoria o tienda se actualiza, la actualización 
	también se produce en dicha tabla
*/
CREATE TABLE CATEGORIAS_APLICACION (
  NOMBRE VARCHAR(35) NOT NULL,
  ID_CATEGORIA INT NOT NULL,
  PRIMARY KEY (NOMBRE, ID_CATEGORIA),
    FOREIGN KEY (NOMBRE)
    REFERENCES APLICACION (NOMBRE)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_CATEGORIA)
    REFERENCES CATEGORIAS (ID_CATEGORIA)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- USUARIO
CREATE TABLE USUARIO (
  NUM_CUENTA INT PRIMARY KEY,
  NOMBRE VARCHAR(50) UNIQUE NOT NULL,
  CALLE VARCHAR(80) NOT NULL,
  NUMERO VARCHAR(3) NULL DEFAULT 's/n',
  CP CHAR(5) NOT NULL,
  PAIS VARCHAR(35) NOT NULL);

-- DESCARGA
/*
	Nota: debe comprobarse (CHECK) que la puntuacion
	este comprendida entre 0 y 5, ademas de que la fecha
	de descarga sea menor o igual a la fecha actual.
	
	Las claves foráneas son tambien PKs, con el
	objetivo de identificar que usuarios descargan
	aplicaciones, y evitar con ello que un usuario descargue
	dos o mas veces la misma aplicacion.
	- Si el usuario o aplicacion desaparecen, con el fin
	de mantener un historico de descargas, no se eliminan
	las filas	
	- Si el nombre de usuario o aplicacion se modifican, 
	la actualización también se produce en dicha tabla
*/
CREATE TABLE DESCARGA (
  NUM_CUENTA INT NOT NULL,
  NOMBRE VARCHAR(35) NOT NULL,
  PUNTUACION INT UNSIGNED,
  NUM_MOVIL INT UNSIGNED NOT NULL,
  FEC_DESCARGA DATE NOT NULL,
  COMENTARIO TEXT,
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
	
-- 4. Carga datos
-- Salvo la tabla categorias, el resto de tablas se cargan mediante ficheros .csv
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

INSERT INTO categorias (NOMBRE) VALUES
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

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/contiene.csv' 
INTO TABLE contiene 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

LOAD DATA CONCURRENT INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categorias_aplicacion.csv' 
INTO TABLE categorias_aplicacion 
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


-- 5. Creacion procedures, funciones y triggers
DROP TRIGGER IF EXISTS comprobar_fecha_fin_trabaja_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_fin_aplicacion_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_descarga_BI;
DROP TRIGGER IF EXISTS comprobar_letra_dni_BI;
DROP TRIGGER IF EXISTS comprobar_trabaja_en_aplicacion_BI;

DROP PROCEDURE IF EXISTS comprobar_fecha;
DROP FUNCTION IF EXISTS comprobar_letra_dni;

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

*/
CREATE FUNCTION comprobar_letra_dni(dni CHAR(9))
RETURNS CHAR(9)
BEGIN
	SET @dni_sin_letra = cast(substring(dni,1,8) as UNSIGNED);
	SET @letra = substring('TRWAGMYFPDXBNJZSQVHLCKE', @dni_sin_letra % 23 + 1,  1);
    RETURN @letra;
END$$

/*
	El procedimiento comprobar_fecha() se empleado
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
    CALL comprobar_fecha(NEW.FEC_DESCARGA);
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

-- 6. Consultas
USE apps_moviles;

-- Consulta 1. Obtener la fecha en la que se realizan mas descargas
SELECT FEC_DESCARGA, count(FEC_DESCARGA) as NUM_DESCARGAS
FROM descarga
GROUP BY FEC_DESCARGA
ORDER BY NUM_DESCARGAS DESC
LIMIT 1;

-- Consulta 2. Obtener aquellos empleados que hayan estado en mas de una empresa (o en la misma empresa mas de una vez)
SELECT t.DNI, e.NOMBRE, t.FECHA_INI, t.FECHA_FIN
FROM trabaja AS t INNER JOIN (SELECT DNI FROM trabaja GROUP BY DNI HAVING count(DNI) > 1) AS t_2
ON t.DNI = t_2.DNI INNER JOIN empresa AS e ON t.VAT = e.VAT;

-- Consulta 3. Obtener el pais de los usuarios que mas aplicaciones se han descargado (y el que menos)
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

-- Consulta 4. Obtener el DNI del empleado que menos tiempo ha trabajado (en dias)
SELECT e.DNI, sum(timestampdiff(day, t.FECHA_INI, t.FECHA_FIN)) as DIAS
FROM empleado AS e INNER JOIN trabaja AS t USING(DNI)
GROUP BY e.DNI
ORDER BY DIAS
LIMIT 1;

-- Consulta 5. Obtener DNI, correo y movil de aquellos empleados que NO hayan sido responsables de alguna aplicacion
SELECT distinct(e.DNI), CORREO, TLFNO_MOVIL
FROM empleado AS e INNER JOIN realiza AS r ON e.DNI = r.DNI
LEFT JOIN aplicacion AS a ON r.DNI = a.EMPLEADO_DNI
WHERE a.EMPLEADO_DNI IS NULL;

-- Consulta 6. Obtener la aplicacion que menos tiempo haya requerido (en meses) y que haya obtenido un mayor numero de descargas
SELECT distinct(a.NOMBRE), timestampdiff(month, a.FECHA_INI, a.FECHA_FIN) as MESES, count(d.NOMBRE) as DESCARGAS
FROM aplicacion AS a INNER JOIN descarga AS d USING(NOMBRE)
GROUP BY a.nombre
ORDER BY MESES, DESCARGAS DESC
LIMIT 1;

-- Consulta 7. Obtener el numero de descargas, agrupadas por tienda (de menos a mas descargas)
SELECT c.NOMBRE_TIENDA, count(d.NOMBRE) as NUM_DESCARGAS
FROM contiene AS c INNER JOIN aplicacion AS a ON c.NOMBRE_APLICACION = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
GROUP BY c.NOMBRE_TIENDA
ORDER BY NUM_DESCARGAS;

-- Consulta 8. Obtener DNI de aquellos empleados que NO estuvieron durante todo el desarrollo de alguna aplicacion
SELECT distinct(t.DNI)
FROM trabaja AS t INNER JOIN empleado AS e ON t.DNI = e.DNI
INNER JOIN realiza AS r ON e.DNI = r.DNI
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
WHERE t.FECHA_INI > a.FECHA_INI OR t.FECHA_FIN < a.FECHA_FIN;

-- Consulta 9. Ingresos totales de las aplicaciones (solo de pago) descargadas
SELECT NOMBRE, PRECIO * descargas_por_app.DESCARGAS as INGRESOS
FROM aplicacion INNER JOIN 
(SELECT NOMBRE, count(NOMBRE) as DESCARGAS
FROM descarga
GROUP BY NOMBRE) as descargas_por_app USING(NOMBRE)
WHERE PRECIO != 0;

-- Consulta 10. Obtener el precio y espacio de memoria medio de las aplicaciones de pago, que NO sean nativas (NO esten en una unica tienda) 
SELECT NOMBRE, round(avg(PRECIO),2) as PRECIO_MEDIO, round(avg(ESPACIO),2) as ESPACIO_MEDIO
FROM aplicacion
WHERE PRECIO != 0 AND NOMBRE NOT IN
(SELECT NOMBRE_APLICACION
FROM contiene
GROUP BY NOMBRE_APLICACION
HAVING count(NOMBRE_TIENDA) = 1);

-- Consulta 11. Obtener el VAT y nombre del top 3 empresas que mas participaciones (empleados) ha tenido
-- en el desarrollo de aplicaciones nativas (esten en una unica tienda)
SELECT e.VAT, e.NOMBRE, count(r.DNI) as PARTICIPACIONES
FROM empresa AS e INNER JOIN trabaja AS t ON e.VAT = t.VAT
INNER JOIN empleado AS emp ON t.DNI = emp.DNI
INNER JOIN realiza AS r ON emp.DNI = r.DNI
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
WHERE a.NOMBRE IN (SELECT NOMBRE_APLICACION FROM contiene GROUP BY NOMBRE_APLICACION HAVING count(NOMBRE_TIENDA) = 1)
GROUP BY e.VAT, e.NOMBRE
ORDER BY PARTICIPACIONES DESC
LIMIT 3;

-- Consulta 12. Obtener las tres primeras categorias con una puntuacion acumulada en sus aplicaciones mayor a 50
SELECT c.NOMBRE, sum(d.PUNTUACION) as PUNTUACION_ACUMULADA
FROM categorias AS c INNER JOIN categorias_aplicacion AS c_a ON c.ID_CATEGORIA = c_a.ID_CATEGORIA
INNER JOIN aplicacion AS a ON c_a.NOMBRE = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
GROUP BY c.NOMBRE
HAVING PUNTUACION_ACUMULADA > 50
ORDER BY PUNTUACION_ACUMULADA DESC;

-- Consulta 13. Obtener DNI y Telefono de aquellos empleados que se hayan descargado 8 aplicaciones
SELECT distinct(e.TLFNO_MOVIL), e.DNI, count(d.NOMBRE) as NUM_DESCARGAS
FROM empleado AS e RIGHT JOIN descarga AS d
ON d.NUM_MOVIL = e.TLFNO_MOVIL
WHERE e.TLFNO_MOVIL IS NOT NULL
GROUP BY e.TLFNO_MOVIL
HAVING NUM_DESCARGAS = 8
ORDER BY NUM_DESCARGAS DESC;

-- Consulta 14. Consultar empleados con entre 1 y 3 annos de experiencia, cuyas aplicaciones en las que hayan participado tengan una media de puntuacion mayor a 3
SELECT distinct(e.DNI), avg(d.PUNTUACION) as MEDIA
FROM empleado AS e INNER JOIN trabaja AS t ON e.DNI = t.DNI
INNER JOIN realiza AS r ON e.DNI = r.DNI 
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
WHERE timestampdiff(year, t.FECHA_INI, t.FECHA_FIN) BETWEEN 1 AND 3
GROUP BY e.DNI
HAVING MEDIA > 3;

-- Consulta 15. Consultar las aplicaciones realizadas entre los annos 2012 y 2016, cuyo espacio en memoria no supere los 100 MB y el porcentaje de descargas
-- (con respecto al numero total de usuarios) sea mayor al 60 %
SELECT distinct(a.NOMBRE)
FROM aplicacion AS a INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
WHERE year(a.FECHA_INI) BETWEEN 2012 AND 2016 AND year(a.FECHA_FIN) BETWEEN 2012 AND 2016 
AND a.ESPACIO < 100 AND a.NOMBRE IN
(SELECT NOMBRE
FROM descarga
GROUP BY NOMBRE
HAVING count(*) * 100 / (SELECT count(*) FROM usuario) > 60);

-- Consulta 16. Consultar empleados de entre 2 y 4 annos de experiencia en el desarrollo de aplicaciones de "Estilo de vida" gratuitas, junto con
-- empleados que hayan participado en mas de un proyecto de aplicaciones de "Entretenimiento", tambien gratuitas, cuya extension de correo sea gmail.
SELECT *
FROM empleado
WHERE DNI IN
((SELECT distinct(emp.DNI)
FROM trabaja AS t INNER JOIN empresa AS e ON t.VAT = e.VAT
INNER JOIN empleado AS emp ON t.DNI = emp.DNI
INNER JOIN realiza AS r ON emp.DNI = r.DNI
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
INNER JOIN categorias_aplicacion AS c_a ON a.NOMBRE = c_a.NOMBRE
INNER JOIN categorias AS c ON c_a.ID_CATEGORIA = c.ID_CATEGORIA
WHERE timestampdiff(year, t.FECHA_INI, t.FECHA_FIN) BETWEEN 2 AND 4 AND c.NOMBRE = 'Estilo de vida' AND a.PRECIO = 0)

UNION

(SELECT distinct(r.DNI)
FROM realiza AS r INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
INNER JOIN categorias_aplicacion AS c_a ON a.NOMBRE = c_a.NOMBRE
INNER JOIN categorias AS c ON c_a.ID_CATEGORIA = c.ID_CATEGORIA
WHERE c.NOMBRE = 'Entretenimiento'  AND a.PRECIO = 0
GROUP BY r.DNI
HAVING count(r.DNI) > 1)) AND CORREO LIKE '%@gmail%';

-- 7. Una vez definidos los triggers, se muestran algunos ejemplos (error)
-- Prueba comprobar_trabaja_en_aplicacion_BI
INSERT INTO empleado VALUES('54003003S','Salvadoeer23@gmail.com',990252340,650829990,'C. Comercial Espacio Leon','122','09019');
INSERT INTO aplicacion VALUES('Instagram',16568,'2013/07/10','2020/10/20',54,0,'54003003S');

-- Prueba comprobar_letra_dni_BI
INSERT INTO empleado VALUES('54003001S','Salvadoeer23@gmail.com',990252340,650829990,'C. Comercial Espacio Leon','122','09019');

-- Prueba comprobar_fecha_fin_trabaja_BI
INSERT INTO trabaja VALUES('10509293B','ES12345600','2013/07/10','2020/10/21');

-- Prueba comprobar_fecha_fin_aplicacion_BI
INSERT INTO aplicacion VALUES('Instagram',16568,'2013/07/10','2020/10/21',54,0,'10035998X');

-- Prueba comprobar_fecha_descarga_BI
INSERT INTO descarga VALUES('663295','RTNoticias',0,43000744,'2020/10/21','Definitivamente odio RTNoticias!!!!!!');