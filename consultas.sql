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

-- Consulta 5. Obtener el precio y espacio de memoria medio de las aplicaciones de pago
SELECT avg(PRECIO) as PRECIO_MEDIO, avg(ESPACIO) as ESPACIO_MEDIO
FROM aplicacion
WHERE PRECIO != 0;

-- Consulta 6. Obtener el DNI del empleado que menos tiempo ha trabajado (en dias)
SELECT DNI, sum(to_days(FECHA_FIN) - to_days(FECHA_INI)) as DIAS
FROM empleado INNER JOIN trabaja USING(DNI)
GROUP BY DNI
ORDER BY DIAS
LIMIT 1;

-- Consulta 7. Obtener el numero de descargas, agrupadas por tienda (de menos a mas descargas)
SELECT NOMBRE_TIENDA, count(descarga.NOMBRE) as NUM_DESCARGAS
FROM contiene INNER JOIN aplicacion ON contiene.NOMBRE_APLICACION = aplicacion.NOMBRE
INNER JOIN descarga ON aplicacion.NOMBRE = descarga.NOMBRE
GROUP BY NOMBRE_TIENDA
ORDER BY NUM_DESCARGAS;

-- Consulta 8. Obtener DNI de aquellos empleados que estuvieron durante todo el desarrollo de alguna aplicacion
SELECT distinct(trabaja.DNI)
FROM trabaja INNER JOIN empleado USING(DNI)
INNER JOIN realiza USING(DNI) INNER JOIN aplicacion USING(NOMBRE)
WHERE trabaja.FECHA_INI = aplicacion.FECHA_INI AND trabaja.FECHA_FIN = aplicacion.FECHA_FIN;

-- Consulta 9. Obtener DNI y correo de aquellos empleados que NO hayan sido responsables de alguna aplicacion
SELECT distinct(empleado.DNI), empleado.CORREO
FROM empleado INNER JOIN realiza USING(DNI)
WHERE empleado.DNI NOT IN (SELECT EMPLEADO_DNI FROM aplicacion);

-- Consulta 10. Obtener las tres primeras categorias con una puntuacion acumulada mayor a 50
SELECT categorias.NOMBRE, sum(descarga.PUNTUACION) as PUNTUACION_ACUMULADA
FROM categorias INNER JOIN categorias_aplicacion ON categorias.ID_CATEGORIA = categorias_aplicacion.ID_CATEGORIA
INNER JOIN aplicacion ON categorias_aplicacion.NOMBRE = aplicacion.NOMBRE
INNER JOIN descarga ON aplicacion.NOMBRE = descarga.NOMBRE
GROUP BY categorias.NOMBRE
HAVING PUNTUACION_ACUMULADA > 50
ORDER BY PUNTUACION_ACUMULADA DESC;

-- Consulta 11. Obtener DNI y Telefono de aquellos empleados que se hayan descargado al menos siete aplicaciones
SELECT distinct(empleado.TLFNO_MOVIL), empleado.DNI, count(descarga.NOMBRE) as NUM_DESCARGAS
FROM empleado RIGHT JOIN descarga
ON descarga.NUM_MOVIL = empleado.TLFNO_MOVIL
WHERE empleado.TLFNO_MOVIL IS NOT NULL
GROUP BY empleado.TLFNO_MOVIL
HAVING NUM_DESCARGAS >= 7
ORDER BY NUM_DESCARGAS DESC;

-- Consulta 12. Obtener la aplicacion que menos tiempo haya requerido (en meses) y que haya obtenido un mayor numero de descargas
SELECT distinct(aplicacion.NOMBRE), timestampdiff(month, FECHA_INI, FECHA_FIN) as MESES, count(descarga.NOMBRE) as DESCARGAS
FROM aplicacion INNER JOIN descarga USING(NOMBRE)
GROUP BY aplicacion.nombre
ORDER BY MESES, DESCARGAS DESC
LIMIT 1;

-- Consulta 13. 