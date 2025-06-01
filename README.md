📘 Proyecto ETL y Análisis OLAP en SQL Server

🔹 Descripción
Este proyecto implementa un proceso ETL en SQL Server, estructurando datos de movilidad en cubos OLAP con SQL Server Analysis Services (SSAS).
La información proviene de un archivo CSV que contiene registros sobre movilidad en distintos departamentos de El Salvador durante la pandemia de COVID-19.
📌 Objetivo: Analizar patrones de movilidad en el tiempo y el espacio usando un modelo dimensional y consultas avanzadas en SQL y MDX.

🔹 Estructura del Proyecto
📂 data/ → Contiene el archivo movilidad.csv con datos de movilidad.
📂 sql_scripts/ → Scripts SQL para el proceso ETL y análisis de datos.
📂 mdx_queries/ → Consultas MDX para el cubo OLAP en SSAS.
📂 visualizations/ → Scripts de Python para visualización con Matplotlib.
📂 docs/ → Documentación técnica detallada del proyecto.
📜 README.md → Este documento con instrucciones para ejecutar el proyecto.

🔹 1. Instalación y Configuración
🛠 1.1 Requisitos Previos
✅ SQL Server Management Studio (SSMS)
✅ SQL Server Analysis Services (SSAS)
✅ Python 3.x con Pandas, Matplotlib y PyODBC (solo para visualización)
✅ Power BI (opcional, para dashboards interactivos)
🛠 1.2 Configurar la Base de Datos en SQL Server
Ejecuta el siguiente script SQL para crear la base de datos:
CREATE DATABASE MovilidadElSalvador;
USE MovilidadElSalvador;



🔹 2. Proceso ETL
📂 2.1 Extracción de Datos
Importamos el archivo CSV a SQL Server usando BULK INSERT:
BULK INSERT MovilidadTemporal
FROM 'C:\ruta_del_archivo\movilidad.csv'
WITH (
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',  
    FIRSTROW = 2  
);



📂 2.2 Transformación de Datos
Antes de procesar los datos, verificamos valores nulos y duplicados:
SELECT * FROM MovilidadTemporal WHERE fecha IS NULL OR departamento IS NULL;

SELECT fecha, departamento, COUNT(*) 
FROM MovilidadTemporal 
GROUP BY fecha, departamento 
HAVING COUNT(*) > 1;

📂 2.3 Carga de Datos en el Modelo Dimensional
Las tablas de dimensiones y hechos organizan la información para su análisis en OLAP:
CREATE TABLE DimTiempo (
    idTiempo INT PRIMARY KEY IDENTITY(1,1),
    fecha DATE NOT NULL,
    anio AS (YEAR(fecha)) PERSISTED,
    mes AS (MONTH(fecha)) PERSISTED,
    dia AS (DAY(fecha)) PERSISTED
);

CREATE TABLE DimUbicacion (
    idUbicacion INT PRIMARY KEY IDENTITY(1,1),
    pais VARCHAR(50) NOT NULL,
    departamento VARCHAR(100) NOT NULL
);

CREATE TABLE HechosMovilidad (
    idHechosMovilidad INT PRIMARY KEY IDENTITY(1,1),
    idTiempo INT FOREIGN KEY REFERENCES DimTiempo(idTiempo),
    idUbicacion INT FOREIGN KEY REFERENCES DimUbicacion(idUbicacion),
    porcentajeCambio FLOAT NOT NULL
);

🔹 3. Creación del Cubo OLAP en SSAS
📂 3.1 Configuración en SQL Server Analysis Services (SSAS)
📌 Pasos para configurar el cubo:
✅ Crear un proyecto en SQL Server Data Tools (SSDT).
✅ Definir el origen de datos (MovilidadElSalvador).
✅ Agregar las tablas DimTiempo, DimUbicacion, HechosMovilidad.
✅ Configurar las medidas (porcentajeCambio).
✅ Procesar el cubo OLAP y ejecutar consultas MDX.

🔹 4. Consultas OLAP en MDX
📌 Ejemplo de consulta para movilidad por departamento:
SELECT 
    [DimUbicacion].[Departamento].Members ON ROWS,
    [Measures].[PorcentajeCambio] ON COLUMNS
FROM [CuboMovilidadElSalvador];


🔹 5. Visualización de Datos
📂 5.1 Visualización con Python (Matplotlib)
Ejemplo en Python para graficar movilidad por departamento:
import pyodbc
import pandas as pd
import matplotlib.pyplot as plt

conn = pyodbc.connect("DRIVER={SQL Server};SERVER=localhost;DATABASE=MovilidadElSalvador;Trusted_Connection=yes;")

query = "SELECT departamento, AVG(porcentajeCambio) as movilidad FROM HechosMovilidad JOIN DimUbicacion ON HechosMovilidad.idUbicacion = DimUbicacion.idUbicacion GROUP BY departamento"

df = pd.read_sql(query, conn)

plt.figure(figsize=(10,5))
plt.bar(df['departamento'], df['movilidad'], color='skyblue')
plt.xlabel("Departamento")
plt.ylabel("Cambio de Movilidad (%)")
plt.title("Promedio de Movilidad por Departamento")
plt.xticks(rotation=45)
plt.show()

🔹 6. Reportes y Dashboards
✅ Power BI → Dashboards con conexión directa a SSAS.
✅ Excel PivotTables → Análisis multidimensional.
✅ SSRS (SQL Server Reporting Services) → Reportes automatizados.

🔹 7. Cómo Contribuir
Si deseas mejorar este proyecto:
1️⃣ Haz un fork del repositorio.
2️⃣ Clona el proyecto:
git clone https://github.com/TuUsuario/ProyectoOLAP.git

3️⃣ Agrega tus cambios y sube el commit:
git add .
git commit -m "Mejora en consulta de movilidad por mes"
git push origin main

🔹 8. Licencia
Este proyecto está bajo la licencia MIT, lo que significa que puedes utilizarlo, modificarlo y compartirlo libremente.

