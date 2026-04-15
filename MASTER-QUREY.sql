USE satprasDB;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'master')
BEGIN
    EXEC('CREATE SCHEMA [master]');
END
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'transaction')
BEGIN
    EXEC('CREATE SCHEMA [transaction]');
END
GO

IF OBJECT_ID('[transaction].[report]', 'U') IS NOT NULL DROP TABLE [transaction].[report];
IF OBJECT_ID('[transaction].[permintaanBarang]', 'U') IS NOT NULL DROP TABLE [transaction].[permintaanBarang];
IF OBJECT_ID('[transaction].[maintenance]', 'U') IS NOT NULL DROP TABLE [transaction].[maintenance];
IF OBJECT_ID('[transaction].[detailBarang]', 'U') IS NOT NULL DROP TABLE [transaction].[detailBarang];
IF OBJECT_ID('[transaction].[users]', 'U') IS NOT NULL DROP TABLE [transaction].[users];
IF OBJECT_ID('[master].[barang]', 'U') IS NOT NULL DROP TABLE [master].[barang];
IF OBJECT_ID('[master].[merk]', 'U') IS NOT NULL DROP TABLE [master].[merk];
IF OBJECT_ID('[master].[ruangan]', 'U') IS NOT NULL DROP TABLE [master].[ruangan];
IF OBJECT_ID('[master].[gedung]', 'U') IS NOT NULL DROP TABLE [master].[gedung];
IF OBJECT_ID('[master].[karyawan]', 'U') IS NOT NULL DROP TABLE [master].[karyawan];
IF OBJECT_ID('[master].[semester]', 'U') IS NOT NULL DROP TABLE [master].[semester];
GO

CREATE TABLE [master].[semester] (
    idSemester INT IDENTITY(1,1) PRIMARY KEY,
    tahunAjaran VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE [master].[gedung] (
    idGedung INT IDENTITY(1,1) PRIMARY KEY,
    namaGedung VARCHAR(50) NOT NULL
);

CREATE TABLE [master].[ruangan] (
    idRuangan INT IDENTITY(1,1) PRIMARY KEY,
    idGedung INT NOT NULL FOREIGN KEY REFERENCES [master].[gedung](idGedung),
    namaRuangan VARCHAR(50) NOT NULL
);

CREATE TABLE [master].[karyawan] (
    idKaryawan INT IDENTITY(1,1) PRIMARY KEY,
    namaKaryawan VARCHAR(100) NOT NULL
);

CREATE TABLE [master].[merk] (
    idMerk INT IDENTITY(1,1) PRIMARY KEY,
    namaMerk VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE [master].[barang] (
    idBarang INT PRIMARY KEY,
    namaBarang VARCHAR(100) NOT NULL,
    stok INT DEFAULT 0,
    tipeBarang BIT NOT NULL,
    idMerk INT NULL FOREIGN KEY REFERENCES [master].[merk](idMerk)
);

CREATE TABLE [transaction].[detailBarang] (
    idDetailBarang INT PRIMARY KEY,
    idBarang INT NOT NULL FOREIGN KEY REFERENCES [master].[barang](idBarang),
    idRuangan INT NOT NULL FOREIGN KEY REFERENCES [master].[ruangan](idRuangan),
    spesifikasi VARCHAR(500) NULL
);

CREATE TABLE [transaction].[maintenance] (
    idMaintenance INT IDENTITY(1,1) PRIMARY KEY,
    idKaryawan INT NOT NULL FOREIGN KEY REFERENCES [master].[karyawan](idKaryawan),
    idDetailBarang INT NOT NULL FOREIGN KEY REFERENCES [transaction].[detailBarang](idDetailBarang),
    tglCek DATE NULL,
    kondisi BIT NOT NULL,
    kerusakan VARCHAR(100) NULL,
    tindakLanjut VARCHAR(100) NULL,
    idSemester INT NOT NULL FOREIGN KEY REFERENCES [master].[semester](idSemester)
);

CREATE TABLE [transaction].[permintaanBarang] (
    idPermintaanBarang INT IDENTITY(1,1) PRIMARY KEY,
    idBarang INT NOT NULL FOREIGN KEY REFERENCES [master].[barang](idBarang),
    idRuangan INT NOT NULL FOREIGN KEY REFERENCES [master].[ruangan](idRuangan),
    namaPeminta VARCHAR(50) NOT NULL,
    jumlah INT NOT NULL,
    tglPermintaan DATE NULL,
    idSemester INT NOT NULL FOREIGN KEY REFERENCES [master].[semester](idSemester)
);

CREATE TABLE [transaction].[report] (
    idReport INT IDENTITY(1,1) PRIMARY KEY,
    idMaintenance INT NULL FOREIGN KEY REFERENCES [transaction].[maintenance](idMaintenance),
    idPermintaanBarang INT NULL FOREIGN KEY REFERENCES [transaction].[permintaanBarang](idPermintaanBarang),
    idSemester INT NOT NULL FOREIGN KEY REFERENCES [master].[semester](idSemester),
    tglReport DATE NOT NULL
);

CREATE TABLE [transaction].[users] (
    idUser INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(50) NULL,
    password VARCHAR(255) NULL
);
GO

INSERT INTO [master].[semester] (tahunAjaran) VALUES 
('2025/2026 Ganjil'), 
('2025/2026 Genap');

INSERT INTO [master].[gedung] (namaGedung) VALUES 
('Gedung A'), 
('Gedung B');

INSERT INTO [master].[ruangan] (idGedung, namaRuangan) VALUES 
(1, 'Lab Komputer 1'), 
(1, 'Lab Jaringan'), 
(2, 'Ruang Server');

INSERT INTO [master].[karyawan] (namaKaryawan) VALUES 
('Budi Santoso'), 
('Agus Setiawan'), 
('Rina Kartika');

INSERT INTO [master].[merk] (namaMerk) VALUES 
('Epson'), 
('Asus'), 
('Cisco'), 
('Logitech');

INSERT INTO [master].[barang] (idBarang, namaBarang, stok, tipeBarang, idMerk) VALUES 
(101, 'Proyektor', 2, 1, 1),
(102, 'Router WiFi', 1, 1, 3),
(201, 'Kertas HVS A4', 50, 0, NULL),
(103, 'Mouse Wireless', 3, 1, 4);

INSERT INTO [transaction].[detailBarang] (idDetailBarang, idBarang, idRuangan, spesifikasi) VALUES 
(10101, 101, 1, 'Resolusi 1080p, Lampu 3000 Lumens'),
(10102, 101, 2, 'Resolusi 720p, Lampu 2500 Lumens'),
(10201, 102, 3, 'Dual Band 5GHz, 1200 Mbps'),
(10301, 103, 1, 'Optical Sensor 1000 DPI'),
(10302, 103, 1, 'Optical Sensor 1000 DPI'),
(10303, 103, 2, 'Optical Sensor 1000 DPI');

INSERT INTO [transaction].[maintenance] (idKaryawan, idDetailBarang, tglCek, kondisi, kerusakan, tindakLanjut, idSemester) VALUES 
(1, 10101, GETDATE(), 1, NULL, NULL, 1),
(2, 10201, GETDATE(), 0, 'Sinyal Putus-Putus', 'Restart dan Update Firmware', 1);

INSERT INTO [transaction].[permintaanBarang] (idBarang, idRuangan, namaPeminta, jumlah, tglPermintaan, idSemester) VALUES 
(201, 1, 'Dosen Informatika', 5, GETDATE(), 1);

INSERT INTO [transaction].[report] (idMaintenance, idPermintaanBarang, idSemester, tglReport) VALUES 
(1, NULL, 1, GETDATE()),
(2, NULL, 1, GETDATE()),
(NULL, 1, 1, GETDATE());

INSERT INTO [transaction].[users] (email, password) VALUES 
('admin@sarpras.com', 'admin123');
GO