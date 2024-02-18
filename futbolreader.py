import csv
import psycopg2
from psycopg2 import sql


def testear_conexion():
    try:
        conn = psycopg2.connect(
            dbname="FutbolStats_Proy1",
            user="postgres",
            password="",
            host="127.0.0.1",
            port=5432

        )
        print("Se conecto a la base de datos.")
        conn.close()
    except OperationalError as e:
        print(f"Ocurrió un error al intentar conectarse a la base de datos: {e}")
testear_conexion()


def countColumns(archivo_csv):
    try:
        with open(archivo_csv, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            
            # Obtener la primera fila del archivo CSV que contiene el encabezado
            header = next(csvreader)

            # Contar el número de columnas en el encabezado
            num_columnas = len(header)
            
            return num_columnas

    except Exception as e:
        print(f"Error al contar columnas: {e}")
        return 0 


# Conexión a la base de datos 
conn = psycopg2.connect(
    dbname="FutbolStats_Proy1",
    user="postgres",
    password="",
    host="127.0.0.1",
    port=5432
)

cur = conn.cursor()

# Función para escribir los datos de los archivos a la base de datos 
def writer(tabla_db, archivo_csv):

    try:
        num_columns = countColumns(archivo_csv)
        # Construir la sentencia SQL con marcadores de posición
        sql_insert = sql.SQL('INSERT INTO {} VALUES ({})').format(
            sql.Identifier(tabla_db),
            sql.SQL(',').join(sql.Placeholder() * num_columns)  # Ajustar según la cantidad de columnas en tu tabla
        )

        with open(archivo_csv, 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            next(csvreader)
            for row in csvreader:
                # Convertir valores numéricos de cadena a sus tipos correspondientes
                row = [int(val) if val.isdigit() and val.lower() != 'na' else
                    float(val) if '.' in val and val.lower() != 'na' else
                    None if val.lower() == 'na' else
                    val for val in row]
                
                # Insertar fila en la base de datos
                cur.execute(sql_insert, row)

        # Confirmar los cambios y cerrar la conexión
        conn.commit()
        print(f'Datos insertados en la tabla {tabla_db}.')


    except Exception as e:
        # Manejar cualquier error y cerrar la conexión en caso de problemas
        print(f"Error: {e}")
        conn.rollback()

    finally:
        cur.close()
        conn.close()



#writer("leagues","tu_direccion")
#writer("players","tu_direccion")
#writer("teams","tu_direccion")
#writer("games","tu_direccion")
#writer("appearances","tu_direccion")
#writer("shots","tu_direccion")
#writer("teamstats","tu_direccion")