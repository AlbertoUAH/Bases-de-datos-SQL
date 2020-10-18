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
SELECT @@GLOBAL.secure_file_priv;
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