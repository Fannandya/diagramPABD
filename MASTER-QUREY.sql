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

-- ==============================================
-- ⚙️ CREATE VIEW: VW_DATA_TRANSAKSI (Final)
-- Purpose: Menyimpan hasil join transaksi permintaan barang.
-- Filter Awal: Hanya menampilkan barang dengan tipe b.tipeBarang = 0.
-- ==============================================

CREATE VIEW [dbo].[vwDataTransaksi] AS
SELECT 
    p.idPermintaanBarang AS [ID],       -- p.idPermintaanBarang AS [ID] (sesuai)
    p.idBarang AS [ID Barang],           -- p.idBarang AS [ID Barang] (sesuai)
    b.namaBarang AS [Barang],            -- b.namaBarang AS [Barang] (sesuai)
    r.namaRuangan AS [Ruangan],          -- r.namaRuangan AS [Ruangan] (sesuai)
    p.namaPeminta AS [Peminta],           -- p.namaPeminta AS [Peminta] (sesuai)
    p.jumlah AS [Qty],                    -- p.jumlah AS [Qty] (sesuai)
    s.tahunAjaran AS [Semester],         -- s.tahunAjaran AS [Semester] (sesuai)
    p.idRuangan,                          -- idRuangan (untuk logika C# menghilang/hide)
    p.idSemester                          -- idSemester (untuk logika C# menghilang/hide)
FROM 
    [transaction].[permintaanBarang] p
INNER JOIN 
    [master].[barang] b ON p.idBarang = b.idBarang
INNER JOIN 
    [master].[ruangan] r ON p.idRuangan = r.idRuangan
INNER JOIN 
    [master].[semester] s ON p.idSemester = s.idSemester
WHERE 
    b.tipeBarang = 0; -- Filter untuk barang bukan asset
GO

-- ==============================================
-- ⚙️ CREATE VIEW: vwMaintenanceHistory
-- Purpose: Menyimpan riwayat pemeriksaan/maintenance aset secara komprehensif.
-- ==============================================

CREATE VIEW [dbo].[vwMaintenanceHistory] AS
SELECT 
    m.idMaintenance AS [ID], 
    b.namaBarang AS [Aset], 
    r.namaRuangan AS [Lokasi], 
    m.tglCek AS [Tgl Cek], 
    CASE WHEN m.kondisi = 1 THEN 'Baik' ELSE 'Rusak' END AS [Status], -- Logika Status
    k.namaKaryawan AS [Petugas],                                    -- Siapa yang cek
    b.idBarang,                                                    -- ID Barang Aset
    r.namaRuangan,                                                -- Lokasi Ruangan (optional)
    m.idSemester,                                                 -- Semester (perhatian di sini!)
    db.idDetailBarang                                         -- Detail Transaksi Item
    -- Hanya tampilkan kolom yang benar-benar dibutuhkan aplikasi
FROM 
    [transaction].[maintenance] m 
INNER JOIN -- Wajib ada hubungan antara maintenance dan detail item
    [transaction].[detailBarang] db ON m.idDetailBarang = db.idDetailBarang 
INNER JOIN -- Ambil nama barang berdasarkan ID yang diperiksa
    [master].[barang] b ON db.idBarang = b.idBarang
INNER JOIN -- Tentukan lokasi ruangan dari detail item
    [master].[ruangan] r ON db.idRuangan = r.idRuangan
INNER JOIN -- Ambil nama petugas berdasarkan ID yang melakukan cek
    [master].[karyawan] k ON m.idKaryawan = k.idKaryawan;
GO

-- ==============================================
-- ⚙️ CREATE VIEW: vwDetailBarangAsset
-- Purpose: Menyimpan detail lengkap item barang yang pernah ditransaksikan, 
--          termasuk nama aset dan lokasi ruangan saat transaksi terjadi.
-- ==============================================

drop view [dbo].[vwMaintenanceHistory];

CREATE VIEW [dbo].[vwDetailBarangAsset] AS
SELECT 
    db.idDetailBarang AS [ID Detail],           -- Kunci utama detail item (Transaksi)
    b.namaBarang AS [Aset],                      -- Nama Aset/Barang yang sebenarnya
    b.idBarang,                                  -- ID Barang (untuk kebutuhan JOIN lain)
    db.spesifikasi AS [Spesifikasi],             -- Spesifikasi dari transaksi detail itu sendiri
    r.namaRuangan AS [Lokasi]                    -- Lokasi ruangan saat item dicatat/ditransaksi
FROM 
    [transaction].[detailBarang] db 
INNER JOIN -- WAJIB ada kaitan antara Detail Barang dan Master Barang
    [master].[barang] b ON db.idBarang = b.idBarang 
INNER JOIN -- WAJIB ada kaitan antara Detail Barang dan Master Ruangan
    [master].[ruangan] r ON db.idRuangan = r.idRuangan;
GO


CREATE PROCEDURE [transaction].[sp_UpdateMaintenance]
    @idM INT,                  -- idMaintenance
    @idK INT,                  -- idKaryawan
    @idD INT,                  -- idDetailBarang
    @tgl DATE,                 -- tglCek
    @kon BIT,                  -- kondisi
    @ker VARCHAR(100),         -- kerusakan
    @tin VARCHAR(100),         -- tindakLanjut
    @smt INT                   -- idSemester
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [transaction].[maintenance] 
    SET 
        idKaryawan = @idK, 
        idDetailBarang = @idD, 
        tglCek = @tgl, 
        kondisi = @kon, 
        kerusakan = @ker, 
        tindakLanjut = @tin, 
        idSemester = @smt 
    WHERE idMaintenance = @idM;
END
GO



CREATE PROCEDURE [dbo].[sp_SaveMaintenance]
    @idM INT = NULL,           -- NULL untuk Insert, Ada Nilai untuk Update
    @idK INT,                  -- ID Karyawan
    @idD INT,                  -- ID Detail Barang
    @idB INT,                  -- ID Barang (untuk update stok)
    @tgl DATE,                 -- Tanggal Cek
    @kon BIT,                  -- Kondisi (1: Baik, 0: Rusak)
    @ker VARCHAR(100),         -- Deskripsi Kerusakan
    @tin VARCHAR(100),         -- Tindak Lanjut
    @smt INT                   -- ID Semester
AS
BEGIN
    SET NOCOUNT ON;

    -- Mulai blok pengamanan data 
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @kondisiLama BIT;

        -- 1. LOGIKA UPDATE
        IF @idM IS NOT NULL AND EXISTS (SELECT 1 FROM [transaction].[maintenance] WHERE idMaintenance = @idM)
        BEGIN
            -- Ambil kondisi lama sebelum diubah
            SELECT @kondisiLama = kondisi FROM [transaction].[maintenance] WHERE idMaintenance = @idM;

            -- Hitung penyesuaian stok jika kondisi berubah
            IF (@kondisiLama = 1 AND @kon = 0) -- Dari Baik ke Rusak
            BEGIN
                UPDATE [master].[barang] SET stok = stok - 1 WHERE idBarang = @idB;
            END
            ELSE IF (@kondisiLama = 0 AND @kon = 1) -- Dari Rusak ke Baik
            BEGIN
                UPDATE [master].[barang] SET stok = stok + 1 WHERE idBarang = @idB;
            END

            -- Eksekusi Update
            UPDATE [transaction].[maintenance] SET 
                idKaryawan = @idK, idDetailBarang = @idD, tglCek = @tgl, 
                kondisi = @kon, kerusakan = @ker, tindakLanjut = @tin, idSemester = @smt 
            WHERE idMaintenance = @idM;
        END
        
        -- 2. LOGIKA INSERT
        ELSE
        BEGIN
            -- Jika barang baru masuk dan kondisinya rusak, kurangi stok master
            IF (@kon = 0)
            BEGIN
                UPDATE [master].[barang] SET stok = stok - 1 WHERE idBarang = @idB;
            END

            -- Eksekusi Insert
            INSERT INTO [transaction].[maintenance] 
            (idKaryawan, idDetailBarang, tglCek, kondisi, kerusakan, tindakLanjut, idSemester) 
            VALUES (@idK, @idD, @tgl, @kon, @ker, @tin, @smt);
        END

        -- Jika semua lancar, simpan permanen 
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Jika ada error, batalin semua perubahan 
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        -- Lempar pesan error ke C# [cite: 297, 330]
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO



CREATE PROCEDURE [dbo].[sp_DeletePermintaanBarang]
    @idPB INT -- Parameter ID Permintaan Barang
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @idB INT;
        DECLARE @qty INT;

        -- 1. Ambil data idBarang dan jumlah sebelum dihapus untuk restorasi stok
        SELECT @idB = idBarang, @qty = jumlah 
        FROM [transaction].[permintaanBarang] 
        WHERE idPermintaanBarang = @idPB;

        -- 2. Jika data ditemukan, lakukan proses pemulihan stok
        IF @idB IS NOT NULL
        BEGIN
            -- Kembalikan stok ke master barang
            UPDATE [master].[barang] 
            SET stok = stok + @qty 
            WHERE idBarang = @idB;

            -- 3. Hapus data transaksi permintaan
            DELETE FROM [transaction].[permintaanBarang] 
            WHERE idPermintaanBarang = @idPB;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Batalkan semua perubahan jika terjadi error
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO



CREATE PROCEDURE [dbo].[sp_DeleteMaintenance]
    @idM INT -- Parameter ID Maintenance yang mau dihapus
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @idB INT;
        DECLARE @kon BIT;

        -- 1. Ambil data ID Barang dan Kondisi sebelum log-nya dihapus
        SELECT @idB = db.idBarang, @kon = m.kondisi
        FROM [transaction].[maintenance] m
        JOIN [transaction].[detailBarang] db ON m.idDetailBarang = db.idDetailBarang
        WHERE m.idMaintenance = @idM;

        -- 2. Jika kondisinya 'Rusak' (0), pulihkan stok di master barang
        IF @kon = 0
        BEGIN
            UPDATE [master].[barang] SET stok = stok + 1 WHERE idBarang = @idB;
        END

        -- 3. Hapus log maintenance-nya
        DELETE FROM [transaction].[maintenance] WHERE idMaintenance = @idM;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_SavePermintaanBarang]
    @idPB INT = NULL,          -- NULL untuk Insert, Ada Nilai untuk Update
    @idB INT,                  -- ID Barang
    @idR INT,                  -- ID Ruangan
    @nama VARCHAR(50),         -- Nama Peminta
    @jml INT,                  -- Jumlah (Qty)
    @smt INT                   -- ID Semester
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stokTersedia INT;
        DECLARE @idBLama INT;
        DECLARE @jmlLama INT;

        -- 1. LOGIKA UPDATE
        IF @idPB IS NOT NULL AND EXISTS (SELECT 1 FROM [transaction].[permintaanBarang] WHERE idPermintaanBarang = @idPB)
        BEGIN
            -- Ambil data lama
            SELECT @idBLama = idBarang, @jmlLama = jumlah FROM [transaction].[permintaanBarang] WHERE idPermintaanBarang = @idPB;

            IF (@idB = @idBLama)
            BEGIN
                -- Jika barang sama, cek selisihnya
                DECLARE @selisih INT = @jml - @jmlLama;
                IF (@selisih > 0)
                BEGIN
                    SELECT @stokTersedia = stok FROM [master].[barang] WHERE idBarang = @idB;
                    IF (@stokTersedia < @selisih) THROW 50001, 'Stok tidak mencukupi untuk penambahan jumlah!', 1;
                END
                UPDATE [master].[barang] SET stok = stok - @selisih WHERE idBarang = @idB;
            END
            ELSE
            BEGIN
                -- Jika barang diganti, pulihkan stok lama dan kurangi stok baru
                SELECT @stokTersedia = stok FROM [master].[barang] WHERE idBarang = @idB;
                IF (@stokTersedia < @jml) THROW 50002, 'Stok barang pengganti tidak mencukupi!', 1;

                UPDATE [master].[barang] SET stok = stok + @jmlLama WHERE idBarang = @idBLama;
                UPDATE [master].[barang] SET stok = stok - @jml WHERE idBarang = @idB;
            END

            UPDATE [transaction].[permintaanBarang] SET 
                idBarang=@idB, idRuangan=@idR, namaPeminta=@nama, jumlah=@jml, idSemester=@smt 
            WHERE idPermintaanBarang = @idPB;
        END
        
        -- 2. LOGIKA INSERT
        ELSE
        BEGIN
            -- Cek stok sebelum insert
            SELECT @stokTersedia = stok FROM [master].[barang] WHERE idBarang = @idB;
            IF (@stokTersedia < @jml) THROW 50003, 'Stok tidak mencukupi untuk permintaan baru!', 1;

            UPDATE [master].[barang] SET stok = stok - @jml WHERE idBarang = @idB;

            INSERT INTO [transaction].[permintaanBarang] (idBarang, idRuangan, namaPeminta, jumlah, tglPermintaan, idSemester)
            VALUES (@idB, @idR, @nama, @jml, GETDATE(), @smt);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE [master].[sp_UpdateStokBarang]
    @id INT,        -- Parameter untuk ID Barang
    @diff INT       -- Parameter untuk selisih stok (bisa positif atau negatif)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Langsung eksekusi update stok
        UPDATE [master].[barang] 
        SET stok = stok + @diff 
        WHERE idBarang = @id;

        -- Jika lo mau kasih validasi stok gak boleh minus, bisa ditambahin IF di sini Tam
    END TRY
    BEGIN CATCH
        THROW; -- Lempar error ke aplikasi C# kalau ada masalah
    END CATCH
END
GO

drop procedure [dbo].[sp_DeletePermintaanBarang];
CREATE PROCEDURE [dbo].[sp_DeletePermintaanBarang]
    @idPB INT -- Parameter ID Permintaan Barang
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @idB INT;
        DECLARE @qty INT;

        -- 1. Ambil data idBarang dan jumlah sebelum dihapus untuk restorasi stok
        SELECT @idB = idBarang, @qty = jumlah 
        FROM [transaction].[permintaanBarang] 
        WHERE idPermintaanBarang = @idPB;

        -- 2. Jika data ditemukan, lakukan proses pemulihan stok
        IF @idB IS NOT NULL
        BEGIN
            -- Kembalikan stok ke master barang
            UPDATE [master].[barang] 
            SET stok = stok + @qty 
            WHERE idBarang = @idB;

            -- 3. Hapus data transaksi permintaan
            DELETE FROM [transaction].[permintaanBarang] 
            WHERE idPermintaanBarang = @idPB;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Batalkan semua perubahan jika terjadi error
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE VIEW [dbo].[vwStokAktual] AS
SELECT 
    idBarang, 
    stok 
FROM [master].[barang];
GO

CREATE VIEW [dbo].[vwKatalogBarang] AS
SELECT 
    idBarang AS [ID], 
    namaBarang AS [Nama], 
    stok AS [Stok] 
FROM [master].[barang] 
WHERE tipeBarang = 0;
GO

CREATE VIEW [dbo].[vwSemesterAktif] AS
SELECT 
    idSemester, 
    tahunAjaran 
FROM [master].[semester] 
WHERE tahunAjaran LIKE '%' + CAST(YEAR(GETDATE()) AS VARCHAR) + '%';
GO

CREATE VIEW [dbo].[vwDaftarRuangan] AS
SELECT 
    idRuangan, 
    namaRuangan 
FROM [master].[ruangan];
GO