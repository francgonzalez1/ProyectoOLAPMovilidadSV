CREATE DATABASE MovilidadSV;
GO

USE MovilidadSV;
GO

--Crear tabla temporal para organizar los datos en las tablas principales--

CREATE TABLE MovilidadTemporal (
    codigopais VARCHAR(50), 
    fecha DATE,
    pais VARCHAR(50),
    departamento VARCHAR(100),
    ComerciosRecreacion FLOAT,
    SupermercadosFarmacias FLOAT,
    ParquesEspacios FLOAT,
    EstacionesTransporte FLOAT,
    LugaresTrabajo FLOAT,
    Residencias FLOAT
);

--Creacion de Tablas DimTiempo, DimUbicacion, DimMovilidad y HechosMovilidad--

CREATE TABLE DimTiempo (
	idTiempo INT PRIMARY KEY IDENTITY(1,1),
    fecha DATE NOT NULL,
    anio AS (YEAR(fecha)) PERSISTED,
    mes AS (MONTH(fecha)) PERSISTED,
    dia AS (DAY(fecha)) PERSISTED
);

CREATE TABLE DimUbicacion (
    idUbicacion INT PRIMARY KEY IDENTITY(1,1),
	codigopais VARCHAR(50) NOT NULL, 
    pais VARCHAR(50) NOT NULL,
    departamento VARCHAR(50) NOT NULL
);

CREATE TABLE DimMovilidad (
    idCategoria INT PRIMARY KEY IDENTITY(1,1),
    tipoMovilidad VARCHAR(50) NOT NULL
);

--Tabla con los Hechos ocurridos--

CREATE TABLE HechosMovilidad (
    idHechosMovilidad INT PRIMARY KEY IDENTITY(1,1),
    idTiempo INT FOREIGN KEY REFERENCES DimTiempo(idTiempo),
    idUbicacion INT FOREIGN KEY REFERENCES DimUbicacion(idUbicacion),
    idCategoria INT FOREIGN KEY REFERENCES DimMovilidad(idCategoria),
    porcentajeCambio FLOAT NOT NULL
);

--Insertar datos en las tablas principales--

INSERT INTO DimTiempo (fecha)
SELECT DISTINCT fecha FROM MovilidadTemporal;

INSERT INTO DimUbicacion (codigopais, pais, departamento)
SELECT DISTINCT codigopais, pais, departamento FROM MovilidadTemporal;

INSERT INTO DimMovilidad (tipoMovilidad) VALUES
('Parques y Espacios Publicos'), ('Supermercados y Farmacias'), ('Estaciones de Transporte'), ('Lugares de Trabajo'), ('Residencias'), ('Comercios y Recreacion') ;

--Insertar datos en la tabla HechosMovilidad--

INSERT INTO HechosMovilidad (idTiempo, idUbicacion, idCategoria, porcentajeCambio)
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.ParquesEspacios
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Parques y Espacios Publicos'
UNION ALL
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.SupermercadosFarmacias
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Supermercados y Farmacia';

INSERT INTO HechosMovilidad (idTiempo, idUbicacion, idCategoria, porcentajeCambio)
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.EstacionesTransporte
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Estaciones de Transporte'
UNION ALL
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.LugaresTrabajo
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Luagares de Trabajo';

INSERT INTO HechosMovilidad (idTiempo, idUbicacion, idCategoria, porcentajeCambio)
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.ComerciosRecreacion
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Comercios y Recreacion'
UNION ALL
SELECT 
    dt.idTiempo, du.idUbicacion, dm.idCategoria,
    mt.Residencias
FROM MovilidadTemporal mt
JOIN DimTiempo dt ON mt.fecha = dt.fecha
JOIN DimUbicacion du ON mt.pais = du.pais AND mt.departamento = du.departamento
JOIN DimMovilidad dm ON dm.tipoMovilidad = 'Residencias';
