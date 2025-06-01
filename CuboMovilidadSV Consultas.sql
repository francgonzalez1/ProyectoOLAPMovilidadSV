--Validacion de datos insertados--

--Verificar si hay valores NULL en las columnas principales--
SELECT * FROM MovilidadTemporal
WHERE fecha IS NULL OR departamento IS NULL OR parks IS NULL;

--Identificar datos duplicados en la tabla de hechos--
SELECT fecha, departamento, COUNT(*)
FROM MovilidadTemporal
GROUP BY fecha, departamento
HAVING COUNT(*) > 1;

-- Revisar rangos de movilidad para detectar errores--

SELECT MIN(parks) AS Min_Movilidad, MAX(parks) AS Max_Movilidad FROM MovilidadTemporal;

--Consultas de Procesamiento ETL--

--Insertar fechas únicas en DimTiempo--

INSERT INTO DimTiempo (fecha)
SELECT DISTINCT fecha FROM MovilidadTemporal;

-- Insertar ubicaciones únicas en DimUbicacion--

INSERT INTO DimUbicacion (pais, departamento)
SELECT DISTINCT pais, departamento FROM MovilidadTemporal;

-- Insertar tipos de movilidad--

INSERT INTO DimMovilidad (tipoMovilidad) VALUES
('Parques'), ('Supermercados'), ('Transporte'), ('Trabajo'), ('Residencial');

-- Insertar datos de movilidad en la tabla de hechos--

INSERT INTO HechosMovilidad (idTiempo, idUbicacion, idCategoria, porcentajeCambio)
SELECT dt.idTiempo, du.idUbicacion, dm.idCategoria, mt.parks
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Parques';

--Consultas de Analisis de Datos--

--Promedio de movilidad por departamento--

SELECT du.departamento, AVG(hm.porcentajeCambio) AS PromedioMovilidad
FROM HechosMovilidad hm
JOIN DimUbicacion du ON hm.idUbicacion = du.idUbicacion
GROUP BY du.departamento;

-- Variación de movilidad por mes--

SELECT dt.anio, dt.mes, AVG(hm.porcentajeCambio) AS MovilidadPromedio
FROM HechosMovilidad hm
JOIN DimTiempo dt ON hm.idTiempo = dt.idTiempo
GROUP BY dt.anio, dt.mes;

-- Comparación de movilidad entre categorías--

SELECT dm.tipoMovilidad, AVG(hm.porcentajeCambio) AS PromedioMovilidad
FROM HechosMovilidad hm
JOIN DimMovilidad dm ON hm.idCategoria = dm.idCategoria
GROUP BY dm.tipoMovilidad;

--Consulta del CUBO OLAP creado CuboMovilidadSV--

-- Ver movilidad por departamento--

SELECT 
    [DimUbicacion].[Departamento].Members ON ROWS,
    [Measures].[PorcentajeCambio] ON COLUMNS
FROM [CuboMovilidadElSalvador];

-- Analizar movilidad por mes--

SELECT 
    [DimTiempo].[Mes].Members ON ROWS,
    [Measures].[PorcentajeCambio] ON COLUMNS
FROM [CuboMovilidadElSalvador]
WHERE ([DimMovilidad].[TipoMovilidad].[Parques]);