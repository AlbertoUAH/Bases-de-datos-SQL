-- UNA VEZ DEFINIDOS LOS TRIGGERS, SE MUESTRAN ALGUNOS EJEMPLOS (ERROR)

-- Prueba comprobar_letra_dni_BI
-- DNI Valido
INSERT INTO empleado VALUES('10195062J','Alberto23@gmail.com',990252340,650829997,'C. Comercial Espacio Leon','122','09019');
-- DNI No valido
INSERT INTO empleado VALUES('54053101S','Salvadoeer23@gmail.com',990252340,650829990,'C. Comercial Espacio Leon','122','09019');

-- Prueba comprobar_trabaja_en_aplicacion_BI
INSERT INTO aplicacion VALUES('Instagram',16568,'2013/07/10','2020/10/20',54,0,'10195062J');

-- Prueba comprobar_fecha_fin_trabaja_BI
INSERT INTO trabaja VALUES('56813892M','ES12345600','2013/07/10','2021/10/21');

-- Prueba comprobar_fecha_fin_aplicacion_BI
INSERT INTO aplicacion VALUES('Instagram',16568,'2013/07/10','2021/10/21',54,0,'56813892M');

-- Prueba comprobar_fecha_descarga_BI
-- FEC_DESCARGA > FECHA ACTUAL
INSERT INTO descarga VALUES('663295','RTNoticias',0,43000744,'2021/10/21','Definitivamente odio RTNoticias!!!!!!');
-- FEC_DESCARGA < FECHA_FIN (aplicacion)
INSERT INTO descarga VALUES('663295','RTNoticias',0,43000744,'2019/08/01','Definitivamente odio RTNoticias!!!!!!');