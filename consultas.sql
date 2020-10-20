USE apps_moviles;

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

-- Consulta 3. Obtener el DNI del empleado que menos tiempo ha trabajado (en dias)
SELECT e.DNI, sum(to_days(t.FECHA_FIN) - to_days(t.FECHA_INI)) as DIAS
FROM empleado AS e INNER JOIN trabaja AS t USING(DNI)
GROUP BY e.DNI
ORDER BY DIAS
LIMIT 1;

-- Consulta 4. Obtener DNI y correo de aquellos empleados que NO hayan sido responsables de alguna aplicacion
SELECT distinct(empleado.DNI), empleado.CORREO
FROM empleado INNER JOIN realiza USING(DNI)
WHERE empleado.DNI NOT IN (SELECT EMPLEADO_DNI FROM aplicacion);

-- Consulta 5. Obtener la aplicacion que menos tiempo haya requerido (en meses) y que haya obtenido un mayor numero de descargas
SELECT distinct(a.NOMBRE), timestampdiff(month, FECHA_INI, FECHA_FIN) as MESES, count(d.NOMBRE) as DESCARGAS
FROM aplicacion AS a INNER JOIN descarga AS d USING(NOMBRE)
GROUP BY a.nombre
ORDER BY MESES, DESCARGAS DESC
LIMIT 1;

-- Consulta 6. Obtener el numero de descargas, agrupadas por tienda (de menos a mas descargas)
SELECT c.NOMBRE_TIENDA, count(d.NOMBRE) as NUM_DESCARGAS
FROM contiene AS c INNER JOIN aplicacion AS a ON c.NOMBRE_APLICACION = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
GROUP BY c.NOMBRE_TIENDA
ORDER BY NUM_DESCARGAS;

-- Consulta 7. Obtener DNI de aquellos empleados que NO estuvieron durante todo el desarrollo de alguna aplicacion
SELECT distinct(t.DNI)
FROM trabaja AS t INNER JOIN empleado AS e ON t.DNI = e.DNI
INNER JOIN realiza AS r ON e.DNI = r.DNI
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
WHERE t.FECHA_INI > a.FECHA_INI OR t.FECHA_FIN < a.FECHA_FIN;

-- Consulta 8. Ingresos totales de las aplicaciones (solo de pago) descargadas
SELECT NOMBRE, PRECIO * descargas_por_app.descargas as INGRESOS
FROM aplicacion  INNER JOIN 
(SELECT NOMBRE, count(NOMBRE) as descargas
FROM descarga
GROUP BY NOMBRE) as descargas_por_app USING(NOMBRE)
WHERE PRECIO != 0;

-- Consulta 9. Obtener el precio y espacio de memoria medio de las aplicaciones de pago, que NO sean nativas (NO esten en una unica tienda) 
SELECT NOMBRE, round(avg(PRECIO),2) as PRECIO_MEDIO, round(avg(ESPACIO),2) as ESPACIO_MEDIO
FROM aplicacion
WHERE PRECIO != 0 AND NOMBRE NOT IN
(SELECT NOMBRE_APLICACION
FROM contiene
GROUP BY NOMBRE_APLICACION
HAVING count(NOMBRE_TIENDA) = 1);

-- Consulta 10. Obtener el VAT y nombre de la empresa que mas participaciones (empleados) ha tenido
-- en el desarrollo de aplicaciones nativas (esten en una unica tienda)
SELECT e.VAT, e.NOMBRE, count(r.DNI) as PARTICIPACIONES
FROM empresa AS e INNER JOIN trabaja AS t ON e.VAT = t.VAT
INNER JOIN empleado AS emp ON t.DNI = emp.DNI
INNER JOIN realiza AS r ON emp.DNI = r.DNI
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
WHERE a.NOMBRE IN (SELECT NOMBRE_APLICACION FROM contiene GROUP BY NOMBRE_APLICACION HAVING count(NOMBRE_TIENDA) = 1)
GROUP BY e.VAT, e.NOMBRE
ORDER BY PARTICIPACIONES DESC
LIMIT 1;

-- Consulta 11. Obtener las tres primeras categorias con una puntuacion acumulada mayor a 50
SELECT c.NOMBRE, sum(d.PUNTUACION) as PUNTUACION_ACUMULADA
FROM categorias AS c INNER JOIN categorias_aplicacion AS c_a ON c.ID_CATEGORIA = c_a.ID_CATEGORIA
INNER JOIN aplicacion AS a ON c_a.NOMBRE = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
GROUP BY c.NOMBRE
HAVING PUNTUACION_ACUMULADA > 50
ORDER BY PUNTUACION_ACUMULADA DESC;

-- Consulta 12. Obtener DNI y Telefono de aquellos empleados que se hayan descargado 8 aplicaciones
SELECT distinct(e.TLFNO_MOVIL), e.DNI, count(d.NOMBRE) as NUM_DESCARGAS
FROM empleado AS e RIGHT JOIN descarga AS d
ON d.NUM_MOVIL = e.TLFNO_MOVIL
WHERE e.TLFNO_MOVIL IS NOT NULL
GROUP BY e.TLFNO_MOVIL
HAVING NUM_DESCARGAS = 8
ORDER BY NUM_DESCARGAS DESC;

-- Consulta 13. Consultar empleados con entre 1 y 3 annos de experiencia, cuyas aplicaciones en las que hayan participado tengan una media de puntuacion mayor a 3
SELECT distinct(e.DNI), avg(d.PUNTUACION) as MEDIA
FROM empleado AS e INNER JOIN trabaja AS t ON e.DNI = t.DNI
INNER JOIN realiza AS r ON e.DNI = r.DNI 
INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
WHERE timestampdiff(year, t.FECHA_INI, t.FECHA_FIN) BETWEEN 1 AND 3
GROUP BY e.DNI
HAVING MEDIA > 3;

-- Consulta 14. Consultar las aplicaciones realizadas entre los annos 2013 y 2015, cuyo espacio en memoria no supere los 100 MB y el porcentaje de descargas sea mayor al 10 %
SELECT distinct(a.NOMBRE)
FROM aplicacion AS a INNER JOIN descarga AS d ON a.NOMBRE = d.NOMBRE
WHERE year(a.FECHA_INI) BETWEEN 2012 AND 2016 AND year(a.FECHA_FIN) BETWEEN 2012 AND 2016 
AND a.ESPACIO < 100 AND a.NOMBRE IN
(SELECT NOMBRE
FROM descarga
GROUP BY NOMBRE
HAVING count(*) * 100 / (SELECT count(*) FROM usuario) > 60);

-- Consulta 15. Consultar empleados de entre 2 y 4 annos de experiencia en el desarrollo de aplicaciones de "Belleza" gratuitas, junto con
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
WHERE timestampdiff(year, t.FECHA_INI, t.FECHA_FIN) BETWEEN 2 AND 4 AND c.NOMBRE = 'Belleza' AND a.PRECIO = 0)

UNION

(SELECT distinct(r.DNI)
FROM realiza AS r INNER JOIN aplicacion AS a ON r.NOMBRE = a.NOMBRE
INNER JOIN categorias_aplicacion AS c_a ON a.NOMBRE = c_a.NOMBRE
INNER JOIN categorias AS c ON c_a.ID_CATEGORIA = c.ID_CATEGORIA
WHERE c.NOMBRE = 'Entretenimiento'  AND a.PRECIO = 0
GROUP BY r.DNI
HAVING count(r.DNI) > 1)) AND CORREO LIKE '%@gmail%';