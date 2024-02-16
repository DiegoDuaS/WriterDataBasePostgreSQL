import csv
import psycopg2
from psycopg2 import sql

# Conexión a la base de datos 
conn = psycopg2.connect(
    dbname="nombre_basedatos",
    user="usuario",
    password="contraseña",
    host="localhost"
)

cur = conn.cursor()
#archivo_csv = "ruta/al/archivo.csv"
#tabla_db = "nombre_tabla"


# Función para escribir los datos de los archivos a la base de datos 
def writer(tabla_db, archivo_csv):

    sql_insert = sql.SQL("INSERT INTO {} VALUES (%s, %s, %s, ...)").format(sql.Identifier(tabla_db))

    with open(archivo_csv, 'r') as csvfile:
        csvreader = csv.reader(csvfile)
        next(csvreader)
        for row in csvreader:
            # Insertar fila en la base de datos
            cur.execute(sql_insert, row)

    # Confirmar los cambios y cerrar la conexión
    conn.commit()
    cur.close()
    conn.close()
