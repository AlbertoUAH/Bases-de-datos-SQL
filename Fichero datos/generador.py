import random
import string
import csv

vat = [DE1232645120,
DE1239645124,
ES12345600,
ES12345679,
FN1232167,
GB985777049,
GB985777241,
GR1232167,
HU12345678,
IR1232007,
IR1232647,
IT1230117,
IT1232167,
U12345678,
U12345679]

# Empleado
dni = ['' +str(random.randint(10000000,99999999)) + random.choice(string.ascii_letters.upper()) + '' for i in range(1,51)]
nombres = ['Antonio', 'Alberto', 'Marta', 'Sara', 'Maite', 'Alfonso', 'Rodolfo', 'Valentina', 'Guillermo', 'Jose Manuel', 'Remedios', 'Jorge', 'Maria', 'Salvador', 'Mari Paz', 'Carmen', 'Cristina', 'Juan']
tlfno_fijo = [random.randint(90000000,99999999) for i in range(1,51)]
tlfno_movil = [random.randint(60000000,79999999) for i in range(1,51)]
calles = ['Travesía Lorem',
'Acceso glorieta Santander',
'C. Comercial Espacio Leon',
'Ronda General Alfonso XII',
'Avenida Lorem',
'Alameda Osuna',
'Callejon Cuesta',
'Carrera Lorem ipsum',
'Cuesta de los Remedios',
'Paseo de la Castellana',
'Alameda Oscura',
'Glorieta Lorem ipsum',
'Plaza de la Habana',
'Alameda del Cipres',
'Avenida Cantabria']

numero = ['3','121', '23', '1', '12', 's/n', '122', '32', '4', '6', '13', '9', '120', '96', '54', '56', '99']
cod_postales = ['10921', '25475', '06019', '44110', '02034'
'32082',
'38447',
'01419',
'36259',
'44910',
'50322',
'07170',
'30666',
'01111',
'28696',
'00001']

dni = ['38559626F', '10035998X', '33252494C', '14476425Y', '66040882B', '90575819Y', '65213585X', '66911602E', '68050131W', '88641739B', '86710615N', '10006638G', '56724464I', '56399251B', '10506273B', '15185896S', '43281464V', '70183647W', '36085616Y', '51996757K', '41816979N', '66221734P', '85090556E', '26712512V', '56682626E', '11465119E', '66259959S', '83637825P', '21565559G', '82525254F', '75929279G', '29324891U', '67598056X', '81564178A', '51089844F', '28676893H', '97765659F', '86011665D', '88806494K', '17200364N', '16745886M', '49623866N', '42572414J', '97443376H', '53775960P', '52101919Q', '94506225E', '65755599J', '53007965P', '56995529G']
for i in range(1,50):
	
	empleado = []
	empleado.append(random.choice(dni))
	empleado.append(random.choice(vat))
	with open('trabaja.csv', 'a', newline='') as myfile:
		wr = csv.writer(myfile)
		wr.writerow(empleado)

