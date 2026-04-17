CREATE DATABASE WarungBerkah;
GO
USE WarungBerkah;
GO

CREATE TABLE Distributor (
    id_distributor   INT           PRIMARY KEY IDENTITY(1,1),
    nama_distributor NVARCHAR(100) NOT NULL,
    kota             NVARCHAR(50),
    provinsi         NVARCHAR(50),
    no_telepon       NVARCHAR(20)
);
GO

CREATE TABLE Faktur (
    id_faktur      INT          PRIMARY KEY IDENTITY(1,1),
    id_distributor INT          NOT NULL REFERENCES Distributor(id_distributor),
    tgl_masuk      DATE         NOT NULL,
    tgl_selesai    DATE,
    status         NVARCHAR(20) DEFAULT 'Proses',
    lama_proses AS (
        CASE
            WHEN tgl_selesai IS NOT NULL
            THEN DATEDIFF(DAY, tgl_masuk, tgl_selesai)
            ELSE NULL
        END
    ) PERSISTED
);
GO

CREATE TABLE Barang (
    id_barang   INT           PRIMARY KEY IDENTITY(1,1),
    nama_barang NVARCHAR(100) NOT NULL,
    satuan      NVARCHAR(20),
    kategori    NVARCHAR(50),
    stok        INT           DEFAULT 0,
    harga_beli  DECIMAL(15,2) NOT NULL,
    harga_jual  DECIMAL(15,2) NOT NULL,
    margin AS (harga_jual - harga_beli) PERSISTED
);
GO

CREATE TABLE Detail_Faktur (
    id_detail   INT PRIMARY KEY IDENTITY(1,1),
    id_faktur   INT NOT NULL REFERENCES Faktur(id_faktur),
    id_barang   INT NOT NULL REFERENCES Barang(id_barang),
    jumlah_beli INT NOT NULL
);
GO

INSERT INTO Distributor (nama_distributor, kota, provinsi, no_telepon)
VALUES
    ('PT. Sumber Jaya',  'Denpasar', 'Bali',       '08123456789'),
    ('CV. Mitra Dagang', 'Surabaya', 'Jawa Timur', '08234567890'),
    ('UD. Berkah Niaga', 'Bandung',  'Jawa Barat', '08345678901');

INSERT INTO Barang (nama_barang, satuan, kategori, stok, harga_beli, harga_jual)
VALUES
    ('Beras Premium',     'kg',  'Sembako',    200, 11000,  13500),
    ('Minyak Goreng 1L',  'pcs', 'Sembako',    150, 14000,  17000),
    ('Gula Pasir',        'kg',  'Sembako',    100, 13000,  15500),
    ('Sabun Cuci Piring', 'pcs', 'Kebersihan',  80,  4500,   6000),
    ('Mie Instan',        'dus', 'Makanan',     60, 95000, 110000);

INSERT INTO Faktur (id_distributor, tgl_masuk, tgl_selesai, status)
VALUES
    (1, '2025-01-05', '2025-01-07', 'Selesai'),
    (2, '2025-01-10', '2025-01-13', 'Selesai'),
    (1, '2025-01-20', NULL,         'Proses');

INSERT INTO Detail_Faktur (id_faktur, id_barang, jumlah_beli)
VALUES
    (1, 1, 50),
    (1, 2, 30),
    (2, 3, 40),
    (2, 5, 10),
    (3, 4, 20);

SELECT
    f.id_faktur,
    d.nama_distributor,
    f.tgl_masuk,
    f.tgl_selesai,
    f.status,
    f.lama_proses AS lama_proses_hari
FROM Faktur f
JOIN Distributor d ON f.id_distributor = d.id_distributor;

SELECT
    nama_barang,
    harga_beli,
    harga_jual,
    margin AS keuntungan_per_satuan
FROM Barang
ORDER BY margin DESC;

SELECT
    df.id_faktur,
    b.nama_barang,
    b.satuan,
    df.jumlah_beli,
    b.harga_beli,
    b.harga_jual,
    b.margin,
    (df.jumlah_beli * b.margin) AS total_profit
FROM Detail_Faktur df
JOIN Barang b ON df.id_barang = b.id_barang
WHERE df.id_faktur = 1;

SELECT
    f.id_faktur,
    d.nama_distributor,
    SUM(df.jumlah_beli * b.margin) AS total_profit_faktur
FROM Faktur f
JOIN Distributor d    ON f.id_distributor = d.id_distributor
JOIN Detail_Faktur df ON f.id_faktur = df.id_faktur
JOIN Barang b         ON df.id_barang = b.id_barang
GROUP BY f.id_faktur, d.nama_distributor
ORDER BY total_profit_faktur DESC;
