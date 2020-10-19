-- Consulta 1. Obtener la fecha en la que se realizan mas descargas
SELECT FEC_DESCARGA, count(FEC_DESCARGA) as NUM_DESCARGAS
FROM descarga
GROUP BY FEC_DESCARGA
ORDER BY NUM_DESCARGAS DESC
LIMIT 1;

-- Consulta 2. Obtener el pais de los usuarios que mas aplicaciones se han descargado
SELECT PAIS, count(PAIS) as NUM_DESCARGAS
FROM usuario INNER JOIN descarga USING(NUM_CUENTA)
GROUP BY PAIS
ORDER BY NUM_DESCARGAS DESC
LIMIT 1;

-- Consulta 3. Obtener el vat y nombre de la empresa que mas participaciones (empleados) ha tenido
-- en el desarrollo de aplicaciones
SELECT empresa.VAT, empresa.NOMBRE, count(realiza.DNI) as PARTICIPACIONES
FROM empresa INNER JOIN trabaja USING(VAT)
INNER JOIN empleado USING (DNI) INNER JOIN realiza USING(DNI)
GROUP BY empresa.VAT, empresa.NOMBRE
ORDER BY PARTICIPACIONES DESC
LIMIT 1;

-- Consulta 4. Ingresos totales de las aplicaciones (solo de pago) descargadas
SELECT NOMBRE, PRECIO * descargas_por_app.descargas as INGRESOS
FROM aplicacion INNER JOIN 
(SELECT NOMBRE, count(NOMBRE) as descargas
FROM descarga
GROUP BY NOMBRE) as descargas_por_app USING(NOMBRE)
WHERE PRECIO != 0;
