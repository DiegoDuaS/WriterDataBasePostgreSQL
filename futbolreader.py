import csv
import psycopg2
from psycopg2 import sql


def testear_conexion():
    try:
        conn = psycopg2.connect(
            dbname="FutbolStats_Proy1",
            user="postgres",
            password="",
            host="127.0.0.1"
        )
        print("Se conecto a la base de datos.")
        conn.close()
    except OperationalError as e:
        print(f"Ocurrió un error al intentar conectarse a la base de datos: {e}")
testear_conexion()


# Conexión a la base de datos 
conn = psycopg2.connect(
    dbname="FutbolStats_Proy1",
    user="postgres",
    password="contraseña",
    host="127.0.0.1"
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

# writer("appearences","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("games","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("leagues","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("players","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("shots","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("teams","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")
# writer("teamstats","C:\Users\diego\OneDrive\Escritorio\2024\SEMESTRE V\BD\appearances.csv")