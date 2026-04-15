/* =========================================================================
   PROJECT         : Sistem Informasi Sarana dan Prasarana (satprasDB)
   VERSION         : 1.0 (Production Ready - Clean Schema)
   ARCHITECTURE    : Master-Transaction Schema Isolation
   ========================================================================= */

-- =========================================================================
-- FASE 1: INISIALISASI DATABASE & SKEMA
-- =========================================================================
USE master;
GO

-- Hapus database lama jika sudah ada agar eksekusi dijamin bersih (Fresh Install)
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'satprasDB')
BEGIN
    ALTER DATABASE satprasDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE satprasDB;
END
GO

CREATE DATABASE satprasDB;
GO

USE satprasDB;
GO

-- Membuat batasan teritori (Schema)
CREATE SCHEMA [master];
GO
CREATE SCHEMA [transaction];
GO


-- =========================================================================
-- FASE 2: MEMBANGUN FONDASI DATA (SCHEMA MASTER)
-- Urutan eksekusi sangat ketat untuk menjaga Integritas Relasional
-- =========================================================================

CREATE TABLE [master].semester(
    idSemester int primary key identity(1,1),
    tahunAjaran varchar(50) not null
);

CREATE TABLE [master].karyawan(
    idKaryawan int primary key,
    namaKaryawan varchar(100) not null -- FIXED: Panjang string sudah didefinisikan
);

CREATE TABLE [master].gedung(
    idGedung int primary key,
    namaGedung VARCHAR(100) NOT NULL
);

CREATE TABLE [master].ruangan(
    idRuangan int primary key,
    idGedung int not null,
    namaRuangan VARCHAR(100) NOT NULL,
    CONSTRAINT FK_ruangan_gedung FOREIGN KEY (idGedung) REFERENCES [master].gedung(idGedung)
);

CREATE TABLE [master].barang(
    idBarang int primary key,
    namaBarang VARCHAR(100) not null,
    stok int DEFAULT 0,
    tipeBarang bit not null -- 0: Non-Rutin (Bahan Habis Pakai), 1: Rutin (Aset)
);


-- =========================================================================
-- FASE 3: MEMBANGUN LAYER OPERASIONAL (SCHEMA TRANSACTION)
-- =========================================================================

CREATE TABLE [transaction].users(
    idUser int identity(1,1) primary key,
    email varchar(50) unique,
    password varchar(255) -- FIXED: Standar keamanan industri untuk Hashing
);

CREATE TABLE [transaction].detailBarang(
    idDetailBarang int primary key,
    idBarang int not null,
    idRuangan int not null,
    CONSTRAINT FK_detailBarang_barang FOREIGN KEY (idBarang) REFERENCES [master].barang(idBarang),
    CONSTRAINT FK_detailBarang_ruangan FOREIGN KEY (idRuangan) REFERENCES [master].ruangan(idRuangan)
);

CREATE TABLE [transaction].permintaanBarang(
    idPermintaanBarang int primary key,
    idBarang int not null,
    idRuangan int not null,
    namaPeminta varchar(50) not null,
    jumlah int not null check (jumlah > 0),
    tglPermintaan date default GETDATE(),
    idSemester int not null,
    CONSTRAINT FK_permintaanBarang_barang FOREIGN KEY (idBarang) REFERENCES [master].barang(idBarang),
    CONSTRAINT FK_permintaanBarang_ruangan FOREIGN KEY (idRuangan) REFERENCES [master].ruangan(idRuangan), -- FIXED: idRuangan mereferensikan idRuangan
    CONSTRAINT FK_permintaanBarang_semester FOREIGN KEY (idSemester) REFERENCES [master].semester(idSemester)
);

CREATE TABLE [transaction].maintenance(
    idMaintenance int primary key,
    idKaryawan int not null,
    idDetailBarang int not null,
    tglCek date default GETDATE(),
    kondisi bit not null, -- 1: Baik, 0: Rusak
    kerusakan VARCHAR(100),
    tindakLanjut VARCHAR(100),
    idSemester int not null,
    CONSTRAINT FK_maintenance_karyawan FOREIGN KEY (idKaryawan) REFERENCES [master].karyawan(idKaryawan),
    CONSTRAINT FK_maintenance_detailBarang FOREIGN KEY (idDetailBarang) REFERENCES [transaction].detailBarang(idDetailBarang),
    CONSTRAINT FK_maintenance_semester FOREIGN KEY (idSemester) REFERENCES [master].semester(idSemester)
);

CREATE TABLE [transaction].report(
    idReport int primary key identity (1,1),
    idMaintenance int not null,
    idPermintaanBarang int not null,
    idSemester int not null,
    tglReport date not null default GETDATE(),
    CONSTRAINT FK_report_maintenance FOREIGN KEY (idMaintenance) REFERENCES [transaction].maintenance(idMaintenance),
    CONSTRAINT FK_report_permintaan FOREIGN KEY (idPermintaanBarang) REFERENCES [transaction].permintaanBarang(idPermintaanBarang),
    CONSTRAINT FK_report_semester FOREIGN KEY (idSemester) REFERENCES [master].semester(idSemester)
);
GO

drop table [transaction].report


-- =========================================================================
-- FASE 4: BUSINESS LOGIC VALIDATION (TRIGGERS)
-- =========================================================================

CREATE TRIGGER [transaction].trg_ValidasiTipeBarangNonCekRutin
ON [transaction].permintaanBarang
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS(
        SELECT 1 FROM inserted i
        JOIN [master].barang b ON i.idBarang = b.idBarang -- FIXED: Schema ditambahkan
        WHERE b.tipeBarang != 0
    )
    BEGIN
        RAISERROR ('TRANSAKSI DITOLAK: Hanya barang tipe NON-PENGECEKKAN RUTIN (0) yang diperbolehkan!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

CREATE TRIGGER [transaction].trg_ValidasiTipeBarangCekRutin
ON [transaction].maintenance
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN [transaction].detailBarang db ON i.idDetailBarang = db.idDetailBarang
        JOIN [master].barang b ON db.idBarang = b.idBarang -- FIXED: Schema ditambahkan
        WHERE b.tipeBarang != 1
    )
    BEGIN
        RAISERROR ('TRANSAKSI DITOLAK: Hanya barang tipe PENGECEKKAN RUTIN (1) yang bisa masuk maintenance!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO


-- =========================================================================
-- FASE 5: DATA INJECTION (DUMMY DATA UNTUK PENGUJIAN)
-- =========================================================================

-- 1. Insert Data Master (Referensi)
INSERT INTO [master].semester (tahunAjaran) VALUES ('2025/2026 Ganjil'), ('2025/2026 Genap');

INSERT INTO [master].karyawan (idKaryawan, namaKaryawan) VALUES (1001, 'Budi Teknisi'), (1002, 'Siti Admin');

INSERT INTO [master].gedung (idGedung, namaGedung) VALUES (1, 'Gedung Rektorat'), (2, 'Gedung Laboratorium Terpadu');

INSERT INTO [master].ruangan (idRuangan, idGedung, namaRuangan) VALUES (101, 1, 'Ruang IT Support'), (201, 2, 'Lab Komputer A');

INSERT INTO [master].barang (idBarang, namaBarang, stok, tipeBarang) VALUES 
(501, 'Spidol Boardmarker', 100, 0), -- Tipe 0: Untuk Permintaan Barang
(502, 'AC Split 1.5 PK', 10, 1),     -- Tipe 1: Untuk Maintenance
(503, 'Kertas A4 80gr', 50, 0),
(504, 'Proyektor Epson', 5, 1);

-- 2. Insert Data Penghubung & User
INSERT INTO [transaction].users (email, password) VALUES 
('admin@satpras.com', 'hashed_password_xyz'),
('teknisi@satpras.com', 'hashed_password_abc');

INSERT INTO [transaction].detailBarang (idDetailBarang, idBarang, idRuangan) VALUES 
(1, 502, 101), -- AC di Ruang IT Support
(2, 504, 201); -- Proyektor di Lab Komputer A

-- 3. Insert Data Transaksi (Pengujian Logika Berhasil)
-- Permintaan Barang (Spidol/Tipe 0) -> Pasti Berhasil
INSERT INTO [transaction].permintaanBarang (idPermintaanBarang, idBarang, idRuangan, namaPeminta, jumlah, idSemester)
VALUES (1, 501, 101, 'Dosen Andi', 5, 1);

-- Maintenance (AC/Tipe 1 yang ada di Detail Barang ID 1) -> Pasti Berhasil
INSERT INTO [transaction].maintenance (idMaintenance, idKaryawan, idDetailBarang, kondisi, kerusakan, tindakLanjut, idSemester)
VALUES (1, 1001, 1, 1, NULL, 'Pembersihan Rutin Filter', 1);

PRINT '========================================================================='
PRINT 'EKSEKUSI DATABASE SATPRASDB BERHASIL 100%. SISTEM SIAP DIGUNAKAN.'
PRINT '========================================================================='
GO