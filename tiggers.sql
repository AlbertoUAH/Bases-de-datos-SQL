DROP TRIGGER IF EXISTS comprobar_fecha_fin_trabaja_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_fin_aplicacion_BI;
DROP TRIGGER IF EXISTS comprobar_fecha_descarga_BI;
DROP TRIGGER IF EXISTS comprobar_letra_dni_BI;
DROP PROCEDURE IF EXISTS comprobar_fecha;
DROP FUNCTION IF EXISTS comprobar_letra_dni;
DELETE FROM empleado WHERE DNI = '54003003S';

USE apps_moviles;
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$
CREATE PROCEDURE comprobar_fecha(fecha DATE)
BEGIN
	IF fecha > CURDATE() THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error. La fecha es superior a la fecha actual';
	END IF;
END$$

CREATE FUNCTION comprobar_letra_dni(dni CHAR(9))
RETURNS CHAR(9)
BEGIN
	SET @dni_sin_letra = cast(substring(dni,1,8) as UNSIGNED);
	SET @letra = substring('TRWAGMYFPDXBNJZSQVHLCKE', @dni_sin_letra % 23,  @dni_sin_letra % 23);
    RETURN @letra;
END$$

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

CREATE TRIGGER comprobar_letra_dni_BI
BEFORE INSERT
ON empleado FOR EACH ROW
BEGIN
    SET @letra = comprobar_letra_dni(NEW.DNI);
    IF @letra = substring(NEW.DNI,8,9) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "valido";
	ELSE
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @letra;
	END IF;
END$$

DELIMITER ;

INSERT INTO empleado VALUES('54003003S','Salvadoeer23@gmail.com',990252340,650829990,'C. Comercial Espacio Leon','122','09019');

-- Prueba comprobar_fecha_fin_trabaja_BI
INSERT INTO trabaja VALUES('10509293B','ES12345600','2013/07/10','2020/10/21');

-- Prueba comprobar_fecha_fin_aplicacion_BI
INSERT INTO aplicacion VALUES('Instagram',16568,'2013/07/10','2020/10/21',54,0,'10035998X');

-- Prueba comprobar_fecha_descarga_BI
INSERT INTO descarga VALUES('663295','RTNoticias',0,43000744,'2020/10/21','Definitivamente odio RTNoticias!!!!!!');

