USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'QLBanHangDienThoai')
BEGIN
    DROP DATABASE QLBanHangDienThoai;
END
GO

CREATE DATABASE QLBanHangDienThoai;

USE QLBanHangDienThoai;
GO

IF OBJECT_ID('dbo.tblNhanVien', 'U') IS NOT NULL DROP TABLE dbo.tblNhanVien;

PRINT N'Đang tạo bảng tblNhanVien...';

CREATE TABLE tblNhanVien (
    MaNV INT PRIMARY KEY IDENTITY(1,1),
    TenNV NVARCHAR(200) NOT NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    NgaySinh DATE,
    SoDT VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(500),
    ChucVu NVARCHAR(100) NOT NULL,
    Luong DECIMAL(18,2) CHECK (Luong >= 0),
    NgayVaoLam DATE NOT NULL,
    TrangThai BIT DEFAULT 1,
    TaiKhoan VARCHAR(50) UNIQUE,
    MatKhau VARCHAR(255),
    GhiChu NVARCHAR(MAX),
);

PRINT N'✓ Tạo bảng tblNhanVien thành công';

GO

PRINT N'Đang tạo bảng tblDienThoai...';
CREATE TABLE tblDienThoai (
    MaDT INT PRIMARY KEY IDENTITY(1,1),
    TenDT NVARCHAR(200) NOT NULL,
    HangSX NVARCHAR(100) NOT NULL,
    GiaBan DECIMAL(18,2) NOT NULL CHECK (GiaBan >= 0),
    ManHinh NVARCHAR(100),
    Camera NVARCHAR(100),
    Pin NVARCHAR(50),
    RAM NVARCHAR(20),
    BoNho NVARCHAR(20),
    MauSac NVARCHAR(50),
    MoTa NVARCHAR(MAX),
    TrangThai BIT DEFAULT 1,
    -- Audit Trail
    NguoiNhap INT NOT NULL,
    NgayNhap DATETIME DEFAULT GETDATE(),
    NguoiSua INT NULL,
    NgaySua DATETIME NULL,
    FOREIGN KEY (NguoiNhap) REFERENCES tblNhanVien(MaNV),
    FOREIGN KEY (NguoiSua) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Tạo bảng tblDienThoai thành công';
GO

PRINT N'Đang tạo bảng tblKhachHang...';
-- Bảng Khách hàng
CREATE TABLE tblKhachHang (
    MaKH INT PRIMARY KEY IDENTITY(1,1),
    TenKH NVARCHAR(200) NOT NULL,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
    NgaySinh DATE,
    SoDT VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    DiaChi NVARCHAR(500),
    TichDiem INT DEFAULT 0 CHECK (TichDiem >= 0),
    GhiChu NVARCHAR(MAX),
    -- Audit Trail
    NguoiNhap INT NOT NULL,
    NgayNhap DATETIME DEFAULT GETDATE(),
    NguoiSua INT NULL,
    NgaySua DATETIME NULL,
    FOREIGN KEY (NguoiNhap) REFERENCES tblNhanVien(MaNV),
    FOREIGN KEY (NguoiSua) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Tạo bảng tblKhachHang thành công';

PRINT N'Đang tạo bảng tblHoaDon...';
-- Bảng Hóa đơn
CREATE TABLE tblHoaDon (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaNV INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) DEFAULT 0 CHECK (TongTien >= 0),
    GhiChu NVARCHAR(MAX),
    FOREIGN KEY (MaKH) REFERENCES tblKhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Tạo bảng tblHoaDon thành công';

GO

PRINT N'Đang tạo bảng tblCTHoaDon...';
-- Bảng Chi tiết hóa đơn
CREATE TABLE tblCTHoaDon (
    MaCT INT PRIMARY KEY IDENTITY(1,1),
    MaHD INT NOT NULL,
    MaDT INT NOT NULL,
    SoLuong INT NOT NULL CHECK (SoLuong > 0),
    DonGia DECIMAL(18,2) NOT NULL CHECK (DonGia >= 0),
    GiamGia DECIMAL(18,2) DEFAULT 0 CHECK (GiamGia >= 0),
    ThanhTien DECIMAL(18,2) NOT NULL CHECK (ThanhTien >= 0),
    FOREIGN KEY (MaHD) REFERENCES tblHoaDon(MaHD) ON DELETE CASCADE,
    FOREIGN KEY (MaDT) REFERENCES tblDienThoai(MaDT)
);

PRINT N'✓ Tạo bảng tblCTHoaDon thành công';

INSERT INTO tblNhanVien (TenNV, GioiTinh, NgaySinh, SoDT, Email, DiaChi, ChucVu, Luong, NgayVaoLam, TaiKhoan, MatKhau, TrangThai)
VALUES
(N'Nguyễn Văn An', N'Nam', '1985-03-15', '0901234567', 'annv@phoneshop.vn',
 N'123 Nguyễn Huệ, Quận 1, TP.HCM', N'Quản lý cửa hàng', 20000000, '2020-01-01', 'admin', '123456', 1),

(N'Trần Thị Bình', N'Nữ', '1992-07-20', '0912345678', 'binhtt@phoneshop.vn',
 N'456 Lê Lợi, Quận 1, TP.HCM', N'Nhân viên bán hàng', 10000000, '2021-03-15', 'binhtt', '123456', 1),

(N'Lê Văn Cường', N'Nam', '1990-11-08', '0923456789', 'cuonglv@phoneshop.vn',
 N'789 Trần Hưng Đạo, Quận 5, TP.HCM', N'Nhân viên bán hàng', 10000000, '2021-06-01', 'cuonglv', '123456', 1),

(N'Phạm Thị Dung', N'Nữ', '1995-05-12', '0934567890', 'dungpt@phoneshop.vn',
 N'321 Hai Bà Trưng, Quận 3, TP.HCM', N'Nhân viên kỹ thuật', 12000000, '2022-01-10', 'dungpt', '123456', 1),

(N'Hoàng Văn Em', N'Nam', '1988-09-25', '0945678901', 'emhv@phoneshop.vn',
 N'654 Võ Văn Tần, Quận 3, TP.HCM', N'Trưởng phòng kinh doanh', 18000000, '2020-06-15', 'emhv', '123456', 1);

PRINT N'✓ Đã chèn 5 bản ghi vào tblNhanVien';
GO

PRINT N'Đang chèn dữ liệu vào tblDienThoai...';
GO

INSERT INTO tblDienThoai (TenDT, HangSX, GiaBan, ManHinh, Camera, Pin, RAM, BoNho, MauSac, MoTa, TrangThai, NguoiNhap, NgayNhap)
VALUES
(N'iPhone 15 Pro Max', N'Apple', 29990000,
 N'6.7" Super Retina XDR', N'48MP Main + 12MP Ultra Wide + 12MP Telephoto',
 N'4422 mAh', N'8GB', N'256GB', N'Titan Tự Nhiên',
 N'iPhone 15 Pro Max với chip A17 Pro, khung Titan cao cấp, camera 48MP cải tiến', 1, 1, '2024-01-15 08:00:00'),

(N'iPhone 14', N'Apple', 19990000,
 N'6.1" Super Retina XDR', N'12MP Main + 12MP Ultra Wide',
 N'3279 mAh', N'6GB', N'128GB', N'Đen',
 N'iPhone 14 với chip A15 Bionic, camera kép 12MP, thiết kế sang trọng', 1, 1, '2024-01-15 08:10:00'),

(N'Samsung Galaxy S24 Ultra', N'Samsung', 28990000,
 N'6.8" Dynamic AMOLED 2X', N'200MP Wide + 50MP Telephoto + 12MP Ultra Wide',
 N'5000 mAh', N'12GB', N'256GB', N'Đen Titan',
 N'Galaxy S24 Ultra với camera 200MP, bút S Pen, hiệu năng đỉnh cao', 1, 1, '2024-01-15 08:20:00'),

(N'Samsung Galaxy A54', N'Samsung', 10990000,
 N'6.4" Super AMOLED', N'50MP OIS + 12MP Ultra Wide + 5MP Macro',
 N'5000 mAh', N'8GB', N'128GB', N'Xanh Mint',
 N'Galaxy A54 tầm trung với camera 50MP OIS, pin 5000mAh, sạc nhanh 25W', 1, 2, '2024-01-20 09:00:00'),

(N'Xiaomi 14', N'Xiaomi', 18990000,
 N'6.36" AMOLED', N'50MP Leica + 50MP Telephoto + 50MP Ultra Wide',
 N'4610 mAh', N'12GB', N'256GB', N'Đen',
 N'Xiaomi 14 với camera Leica, chip Snapdragon 8 Gen 3, sạc nhanh 90W', 1, 2, '2024-02-01 10:00:00'),

(N'OPPO Reno11', N'OPPO', 9990000,
 N'6.7" AMOLED', N'50MP + 32MP Telephoto + 8MP Ultra Wide',
 N'4800 mAh', N'8GB', N'256GB', N'Xanh Lục',
 N'OPPO Reno11 thiết kế mỏng nhẹ, camera chân dung xuất sắc', 1, 2, '2024-02-10 11:00:00'),

(N'Vivo V29', N'Vivo', 11990000,
 N'6.78" AMOLED', N'50MP OIS + 8MP Ultra Wide',
 N'4600 mAh', N'12GB', N'256GB', N'Tím',
 N'Vivo V29 với camera selfie 50MP, thiết kế đổi màu độc đáo', 1, 3, '2024-02-15 14:00:00'),

(N'Realme 11 Pro', N'Realme', 8990000,
 N'6.7" AMOLED', N'100MP + 2MP Depth',
 N'5000 mAh', N'8GB', N'256GB', N'Xanh Oasis',
 N'Realme 11 Pro camera 100MP, sạc nhanh 67W, giá tốt', 1, 3, '2024-03-01 15:00:00');

PRINT N'✓ Đã chèn 8 bản ghi vào tblDienThoai';
GO

PRINT N'Đang chèn dữ liệu vào tblKhachHang...';
GO

INSERT INTO tblKhachHang (TenKH, GioiTinh, NgaySinh, SoDT, Email, DiaChi, TichDiem, NguoiNhap, NgayNhap)
VALUES
(N'Võ Thị Hoa', N'Nữ', '1990-04-12', '0956789012', 'hoavt@gmail.com',
 N'45 Pasteur, Quận 1, TP.HCM', 250, 2, '2024-01-10 10:00:00'),

(N'Đặng Văn Hùng', N'Nam', '1985-08-20', '0967890123', 'hungdv@gmail.com',
 N'78 Điện Biên Phủ, Quận 10, TP.HCM', 850, 2, '2024-01-15 11:00:00'),

(N'Bùi Thị Lan', N'Nữ', '1993-11-05', '0978901234', 'lanbt@gmail.com',
 N'90 Nguyễn Đình Chiểu, Quận 3, TP.HCM', 120, 2, '2024-02-01 09:30:00'),

(N'Phan Văn Minh', N'Nam', '1988-02-18', '0989012345', 'minhpv@gmail.com',
 N'123 Cách Mạng Tháng 8, Quận 3, TP.HCM', 1500, 3, '2024-02-10 14:00:00'),

(N'Ngô Thị Nhung', N'Nữ', '1995-06-30', '0990123456', 'nhungnt@gmail.com',
 N'234 Lê Văn Sỹ, Quận Phú Nhuận, TP.HCM', 60, 3, '2024-02-20 10:30:00'),

(N'Trương Văn Phúc', N'Nam', '1992-12-15', '0991234567', 'phuctv@gmail.com',
 N'567 Hoàng Văn Thụ, Quận Tân Bình, TP.HCM', 420, 3, '2024-03-01 11:00:00'),

(N'Lý Thị Quỳnh', N'Nữ', '1987-09-22', '0992345678', 'quynhlt@gmail.com',
 N'890 Trường Chinh, Quận Tân Phú, TP.HCM', 680, 2, '2024-03-10 15:00:00');

PRINT N'✓ Đã chèn 7 bản ghi vào tblKhachHang';
GO

PRINT N'Đang chèn dữ liệu vào tblHoaDon...';
GO

INSERT INTO tblHoaDon (MaKH, MaNV, NgayLap, TongTien, GhiChu)
VALUES
(1, 2, '2024-11-15 10:30:00', 29990000, N'Khách hàng mua iPhone 15 Pro Max'),
(2, 2, '2024-11-18 14:15:00', 37980000, N'Khách hàng VIP - Giảm giá 1 triệu'),
(3, 3, '2024-11-20 09:45:00', 10990000, N'Khách mua Samsung A54'),
(4, 3, '2024-11-25 16:20:00', 45980000, N'Khách hàng mua combo iPhone + OPPO'),
(5, 2, '2024-12-01 11:00:00', 19490000, N'Khách hàng mua iPhone 14');

PRINT N'✓ Đã chèn 5 bản ghi vào tblHoaDon';
GO

PRINT N'Đang chèn dữ liệu vào tblCTHoaDon...';
GO

-- Hóa đơn 1: Mua 1 iPhone 15 Pro Max
INSERT INTO tblCTHoaDon (MaHD, MaDT, SoLuong, DonGia, GiamGia, ThanhTien)
VALUES (1, 1, 1, 29990000, 0, 29990000);

-- Hóa đơn 2: Mua iPhone 14 + Xiaomi 14
INSERT INTO tblCTHoaDon (MaHD, MaDT, SoLuong, DonGia, GiamGia, ThanhTien)
VALUES
(2, 2, 1, 19990000, 0, 19990000),
(2, 5, 1, 18990000, 1000000, 17990000);

-- Hóa đơn 3: Mua Samsung A54
INSERT INTO tblCTHoaDon (MaHD, MaDT, SoLuong, DonGia, GiamGia, ThanhTien)
VALUES (3, 4, 1, 10990000, 0, 10990000);

-- Hóa đơn 4: Mua iPhone 15 Pro Max + 2 OPPO Reno11
INSERT INTO tblCTHoaDon (MaHD, MaDT, SoLuong, DonGia, GiamGia, ThanhTien)
VALUES
(4, 1, 1, 29990000, 1000000, 28990000),
(4, 6, 2, 9990000, 1000000, 16990000);

-- Hóa đơn 5: Mua iPhone 14 (có giảm giá)
INSERT INTO tblCTHoaDon (MaHD, MaDT, SoLuong, DonGia, GiamGia, ThanhTien)
VALUES (5, 2, 1, 19990000, 500000, 19490000);

PRINT N'✓ Đã chèn 9 bản ghi vào tblCTHoaDon';

GO

PRINT N'Đang tạo các view phục vụ khai thác dữ liệu...';

-- View 1: Danh sách nhân viên đang hoạt động
IF OBJECT_ID('dbo.vwThongTinNhanVienHienHanh', 'V') IS NOT NULL DROP VIEW dbo.vwThongTinNhanVienHienHanh;
GO
CREATE VIEW dbo.vwThongTinNhanVienHienHanh
AS
SELECT
    MaNV,
    TenNV,
    GioiTinh,
    NgaySinh,
    SoDT,
    Email,
    ChucVu,
    Luong,
    NgayVaoLam,
    DATEDIFF(DAY, NgayVaoLam, GETDATE()) AS SoNgayCongTac
FROM dbo.tblNhanVien
WHERE TrangThai = 1;
GO

PRINT N'✓ Tạo view vwThongTinNhanVienHienHanh';
GO

-- View 2: Thông tin điện thoại đang mở bán
IF OBJECT_ID('dbo.vwDanhSachDienThoaiDangBan', 'V') IS NOT NULL DROP VIEW dbo.vwDanhSachDienThoaiDangBan;
GO
CREATE VIEW dbo.vwDanhSachDienThoaiDangBan
AS
SELECT
    MaDT,
    TenDT,
    HangSX,
    GiaBan,
    ManHinh,
    Camera,
    Pin,
    RAM,
    BoNho,
    MauSac,
    TrangThai
FROM dbo.tblDienThoai
WHERE TrangThai = 1;
GO

PRINT N'✓ Tạo view vwDanhSachDienThoaiDangBan';
GO

-- View 3: Khách hàng có tích điểm cao
IF OBJECT_ID('dbo.vwKhachHangTichDiemCao', 'V') IS NOT NULL DROP VIEW dbo.vwKhachHangTichDiemCao;
GO
CREATE VIEW dbo.vwKhachHangTichDiemCao
AS
SELECT
    MaKH,
    TenKH,
    GioiTinh,
    SoDT,
    Email,
    DiaChi,
    TichDiem
FROM dbo.tblKhachHang
WHERE TichDiem >= 500;
GO

PRINT N'✓ Tạo view vwKhachHangTichDiemCao';
GO

-- View 4: Tổng hợp thông tin hóa đơn
IF OBJECT_ID('dbo.vwHoaDonTongHop', 'V') IS NOT NULL DROP VIEW dbo.vwHoaDonTongHop;
GO
CREATE VIEW dbo.vwHoaDonTongHop
AS
SELECT
    hd.MaHD,
    hd.NgayLap,
    hd.TongTien,
    hd.GhiChu,
    kh.MaKH,
    kh.TenKH,
    nv.MaNV,
    nv.TenNV AS TenNhanVien
FROM dbo.tblHoaDon AS hd
INNER JOIN dbo.tblKhachHang AS kh ON kh.MaKH = hd.MaKH
INNER JOIN dbo.tblNhanVien AS nv ON nv.MaNV = hd.MaNV;
GO

PRINT N'✓ Tạo view vwHoaDonTongHop';
GO

-- View 5: Chi tiết sản phẩm trong hóa đơn
IF OBJECT_ID('dbo.vwChiTietHoaDonSanPham', 'V') IS NOT NULL DROP VIEW dbo.vwChiTietHoaDonSanPham;
GO
CREATE VIEW dbo.vwChiTietHoaDonSanPham
AS
SELECT
    cthd.MaCT,
    cthd.MaHD,
    hd.NgayLap,
    cthd.MaDT,
    dt.TenDT,
    cthd.SoLuong,
    cthd.DonGia,
    cthd.GiamGia,
    cthd.ThanhTien
FROM dbo.tblCTHoaDon AS cthd
INNER JOIN dbo.tblHoaDon AS hd ON hd.MaHD = cthd.MaHD
INNER JOIN dbo.tblDienThoai AS dt ON dt.MaDT = cthd.MaDT;
GO

PRINT N'✓ Tạo view vwChiTietHoaDonSanPham';
GO

-- View 6: Doanh thu theo ngày
IF OBJECT_ID('dbo.vwDoanhThuTheoNgay', 'V') IS NOT NULL DROP VIEW dbo.vwDoanhThuTheoNgay;
GO
CREATE VIEW dbo.vwDoanhThuTheoNgay
AS
SELECT
    CAST(NgayLap AS DATE) AS Ngay,
    SUM(TongTien) AS TongDoanhThu,
    COUNT(*) AS SoHoaDon
FROM dbo.tblHoaDon
GROUP BY CAST(NgayLap AS DATE);
GO

PRINT N'✓ Tạo view vwDoanhThuTheoNgay';
GO

-- View 7: Doanh thu theo nhân viên lập hóa đơn
IF OBJECT_ID('dbo.vwDoanhThuTheoNhanVien', 'V') IS NOT NULL DROP VIEW dbo.vwDoanhThuTheoNhanVien;
GO
CREATE VIEW dbo.vwDoanhThuTheoNhanVien
AS
SELECT
    nv.MaNV,
    nv.TenNV,
    nv.ChucVu,
    SUM(hd.TongTien) AS TongDoanhThu,
    COUNT(hd.MaHD) AS SoHoaDon
FROM dbo.tblNhanVien AS nv
INNER JOIN dbo.tblHoaDon AS hd ON hd.MaNV = nv.MaNV
GROUP BY nv.MaNV, nv.TenNV, nv.ChucVu;
GO

PRINT N'✓ Tạo view vwDoanhThuTheoNhanVien';
GO

-- View 8: Sản phẩm bán chạy theo số lượng
IF OBJECT_ID('dbo.vwSanPhamBanChay', 'V') IS NOT NULL DROP VIEW dbo.vwSanPhamBanChay;
GO
CREATE VIEW dbo.vwSanPhamBanChay
AS
SELECT
    dt.MaDT,
    dt.TenDT,
    dt.HangSX,
    SUM(cthd.SoLuong) AS TongSoLuongBan,
    SUM(cthd.ThanhTien) AS TongDoanhThu
FROM dbo.tblDienThoai AS dt
INNER JOIN dbo.tblCTHoaDon AS cthd ON cthd.MaDT = dt.MaDT
GROUP BY dt.MaDT, dt.TenDT, dt.HangSX;
GO

PRINT N'✓ Tạo view vwSanPhamBanChay';
GO

-- View 9: Lịch sử cập nhật điện thoại (ghi nhận người nhập/sửa)
IF OBJECT_ID('dbo.vwLichSuCapNhatDienThoai', 'V') IS NOT NULL DROP VIEW dbo.vwLichSuCapNhatDienThoai;
GO
CREATE VIEW dbo.vwLichSuCapNhatDienThoai
AS
SELECT
    dt.MaDT,
    dt.TenDT,
    dt.NgayNhap,
    nvNhap.TenNV AS NguoiNhap,
    dt.NgaySua,
    nvSua.TenNV AS NguoiSua
FROM dbo.tblDienThoai AS dt
INNER JOIN dbo.tblNhanVien AS nvNhap ON nvNhap.MaNV = dt.NguoiNhap
LEFT JOIN dbo.tblNhanVien AS nvSua ON nvSua.MaNV = dt.NguoiSua;
GO

PRINT N'✓ Tạo view vwLichSuCapNhatDienThoai';
GO

-- View 10: Hóa đơn phát sinh trong 30 ngày gần nhất
IF OBJECT_ID('dbo.vwHoaDonGanDay', 'V') IS NOT NULL DROP VIEW dbo.vwHoaDonGanDay;
GO
CREATE VIEW dbo.vwHoaDonGanDay
AS
SELECT
    hd.MaHD,
    hd.NgayLap,
    hd.TongTien,
    kh.TenKH,
    nv.TenNV AS TenNhanVien
FROM dbo.tblHoaDon AS hd
INNER JOIN dbo.tblKhachHang AS kh ON kh.MaKH = hd.MaKH
INNER JOIN dbo.tblNhanVien AS nv ON nv.MaNV = hd.MaNV
WHERE hd.NgayLap >= DATEADD(DAY, -30, GETDATE());
GO

PRINT N'✓ Tạo view vwHoaDonGanDay';
GO

PRINT N'Đang tạo các thủ tục thao tác dữ liệu...';
GO

-- Proc 1: Thêm khách hàng mới có ghi nhận người nhập
IF OBJECT_ID('dbo.spThemKhachHangMoi', 'P') IS NOT NULL DROP PROCEDURE dbo.spThemKhachHangMoi;
GO
CREATE PROCEDURE dbo.spThemKhachHangMoi
    @TenKH NVARCHAR(200),
    @GioiTinh NVARCHAR(10),
    @NgaySinh DATE = NULL,
    @SoDT VARCHAR(15),
    @Email VARCHAR(100) = NULL,
    @DiaChi NVARCHAR(500) = NULL,
    @NguoiNhap INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.tblKhachHang (TenKH, GioiTinh, NgaySinh, SoDT, Email, DiaChi, TichDiem, NguoiNhap, NgayNhap)
    VALUES (@TenKH, @GioiTinh, @NgaySinh, @SoDT, @Email, @DiaChi, 0, @NguoiNhap, GETDATE());

    SELECT SCOPE_IDENTITY() AS MaKhachHangMoi;
END;
GO

PRINT N'✓ Tạo thủ tục spThemKhachHangMoi';
GO

EXEC dbo.spThemKhachHangMoi
    @TenKH = N'Khách hàng demo',
    @GioiTinh = N'Nam',
    @NgaySinh = '1995-01-01',
    @SoDT = '0911111999',
    @Email = 'demo_customer@gmail.com',
    @DiaChi = N'12 Nguyễn Trãi, TP.HCM',
    @NguoiNhap = 2;
GO

-- Proc 2: Cập nhật giá bán điện thoại và ghi nhận người sửa
IF OBJECT_ID('dbo.spCapNhatGiaBanDienThoai', 'P') IS NOT NULL DROP PROCEDURE dbo.spCapNhatGiaBanDienThoai;
GO
CREATE PROCEDURE dbo.spCapNhatGiaBanDienThoai
    @MaDT INT,
    @GiaBanMoi DECIMAL(18,2),
    @NguoiSua INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.tblDienThoai
    SET GiaBan = @GiaBanMoi,
        NguoiSua = @NguoiSua,
        NgaySua = GETDATE()
    WHERE MaDT = @MaDT;

    SELECT MaDT, TenDT, GiaBan FROM dbo.tblDienThoai WHERE MaDT = @MaDT;
END;
GO

PRINT N'✓ Tạo thủ tục spCapNhatGiaBanDienThoai';
GO

EXEC dbo.spCapNhatGiaBanDienThoai
    @MaDT = 2,
    @GiaBanMoi = 20500000,
    @NguoiSua = 1;
GO

-- Proc 3: Lấy doanh thu theo khoảng thời gian, có thể lọc theo nhân viên
IF OBJECT_ID('dbo.spLayDoanhThuNhanVienTrongKhoang', 'P') IS NOT NULL DROP PROCEDURE dbo.spLayDoanhThuNhanVienTrongKhoang;
GO
CREATE PROCEDURE dbo.spLayDoanhThuNhanVienTrongKhoang
    @TuNgay DATE,
    @DenNgay DATE,
    @MaNV INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        hd.MaNV,
        nv.TenNV,
        SUM(hd.TongTien) AS TongDoanhThu,
        COUNT(hd.MaHD) AS SoHoaDon
    FROM dbo.tblHoaDon AS hd
    INNER JOIN dbo.tblNhanVien AS nv ON nv.MaNV = hd.MaNV
    WHERE hd.NgayLap >= @TuNgay
      AND hd.NgayLap < DATEADD(DAY, 1, @DenNgay)
      AND (@MaNV IS NULL OR hd.MaNV = @MaNV)
    GROUP BY hd.MaNV, nv.TenNV;
END;
GO

PRINT N'✓ Tạo thủ tục spLayDoanhThuNhanVienTrongKhoang';
GO

EXEC dbo.spLayDoanhThuNhanVienTrongKhoang
    @TuNgay = '2024-11-01',
    @DenNgay = '2024-12-31',
    @MaNV = NULL;
GO

-- Proc 4: Thống kê sản phẩm bán chạy theo số lượng tùy theo TOP
IF OBJECT_ID('dbo.spThongKeSanPhamBanChay', 'P') IS NOT NULL DROP PROCEDURE dbo.spThongKeSanPhamBanChay;
GO
CREATE PROCEDURE dbo.spThongKeSanPhamBanChay
    @Top INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
        dt.MaDT,
        dt.TenDT,
        dt.HangSX,
        SUM(cthd.SoLuong) AS TongSoLuong,
        SUM(cthd.ThanhTien) AS TongDoanhThu
    FROM dbo.tblDienThoai AS dt
    INNER JOIN dbo.tblCTHoaDon AS cthd ON cthd.MaDT = dt.MaDT
    GROUP BY dt.MaDT, dt.TenDT, dt.HangSX
    ORDER BY SUM(cthd.SoLuong) DESC;
END;
GO

PRINT N'✓ Tạo thủ tục spThongKeSanPhamBanChay';
GO

EXEC dbo.spThongKeSanPhamBanChay @Top = 3;
GO

-- Proc 5: Tìm kiếm điện thoại theo từ khóa tên hoặc hãng
IF OBJECT_ID('dbo.spTimKiemDienThoaiTheoTuKhoa', 'P') IS NOT NULL DROP PROCEDURE dbo.spTimKiemDienThoaiTheoTuKhoa;
GO
CREATE PROCEDURE dbo.spTimKiemDienThoaiTheoTuKhoa
    @TuKhoa NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MaDT,
        TenDT,
        HangSX,
        GiaBan,
        MauSac
    FROM dbo.tblDienThoai
    WHERE TenDT LIKE N'%' + @TuKhoa + N'%'
       OR HangSX LIKE N'%' + @TuKhoa + N'%';
END;
GO

PRINT N'✓ Tạo thủ tục spTimKiemDienThoaiTheoTuKhoa';
GO

EXEC dbo.spTimKiemDienThoaiTheoTuKhoa @TuKhoa = N'iPhone';
GO

-- ============================================================================
-- REQUIREMENT 6: PHÂN TÁN DỮ LIỆU (DATABASE DISTRIBUTION)
-- Phân tán ngang (Horizontal Partitioning) và Phân tán dọc (Vertical Partitioning)
-- ============================================================================

PRINT N'';
PRINT N'========================================================';
PRINT N'REQUIREMENT 6: PHÂN TÁN DỮ LIỆU (Data Distribution)';
PRINT N'========================================================';
GO

-- ============================================================================
-- PART 1: PHÂN TÁN DỌC (VERTICAL PARTITIONING)
-- Chia tblDienThoai thành 2 bảng: thông tin cơ bản + thông số kỹ thuật
-- ============================================================================

PRINT N'';
PRINT N'[PART 1] PHÂN TÁN DỌC (VERTICAL PARTITIONING)';
PRINT N'Mục đích: Tách bảng tblDienThoai thành 2 bảng riêng';
PRINT N'- tblDienThoai_CoBan: Thông tin cơ bản';
PRINT N'- tblDienThoai_ThongSoKyThuat: Thông số kỹ thuật';
GO

-- Bước 1: Tạo bảng thông tin cơ bản (Vertical Partition 1)
IF OBJECT_ID('dbo.tblDienThoai_CoBan', 'U') IS NOT NULL DROP TABLE dbo.tblDienThoai_CoBan;
GO

PRINT N'Tạo bảng tblDienThoai_CoBan (Thông tin cơ bản)...';
CREATE TABLE dbo.tblDienThoai_CoBan (
    MaDT INT PRIMARY KEY IDENTITY(1,1),
    TenDT NVARCHAR(200) NOT NULL,
    HangSX NVARCHAR(100) NOT NULL,
    GiaBan DECIMAL(18,2) NOT NULL CHECK (GiaBan >= 0),
    MauSac NVARCHAR(50),
    MoTa NVARCHAR(MAX),
    TrangThai BIT DEFAULT 1,
    NguoiNhap INT NOT NULL,
    NgayNhap DATETIME DEFAULT GETDATE(),
    NguoiSua INT NULL,
    NgaySua DATETIME NULL,
    FOREIGN KEY (NguoiNhap) REFERENCES tblNhanVien(MaNV),
    FOREIGN KEY (NguoiSua) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Bảng tblDienThoai_CoBan được tạo';
GO

-- Bước 2: Tạo bảng thông số kỹ thuật (Vertical Partition 2)
IF OBJECT_ID('dbo.tblDienThoai_ThongSoKyThuat', 'U') IS NOT NULL DROP TABLE dbo.tblDienThoai_ThongSoKyThuat;
GO

PRINT N'Tạo bảng tblDienThoai_ThongSoKyThuat (Thông số kỹ thuật)...';
CREATE TABLE dbo.tblDienThoai_ThongSoKyThuat (
    MaDT INT PRIMARY KEY,
    ManHinh NVARCHAR(100),
    Camera NVARCHAR(100),
    Pin NVARCHAR(50),
    RAM NVARCHAR(20),
    BoNho NVARCHAR(20),
    FOREIGN KEY (MaDT) REFERENCES tblDienThoai_CoBan(MaDT) ON DELETE CASCADE
);
PRINT N'✓ Bảng tblDienThoai_ThongSoKyThuat được tạo';
GO

-- Bước 3: Chèn dữ liệu từ bảng gốc vào bảng phân tán dọc
PRINT N'Chèn dữ liệu vào bảng phân tán dọc...';
GO

INSERT INTO dbo.tblDienThoai_CoBan (TenDT, HangSX, GiaBan, MauSac, MoTa, TrangThai, NguoiNhap, NgayNhap)
SELECT TenDT, HangSX, GiaBan, MauSac, MoTa, TrangThai, NguoiNhap, NgayNhap
FROM dbo.tblDienThoai;

INSERT INTO dbo.tblDienThoai_ThongSoKyThuat (MaDT, ManHinh, Camera, Pin, RAM, BoNho)
SELECT MaDT, ManHinh, Camera, Pin, RAM, BoNho
FROM dbo.tblDienThoai;

PRINT N'✓ Dữ liệu đã được chèn vào bảng phân tán dọc';
GO

-- View để hợp nhất dữ liệu từ 2 bảng phân tán dọc
IF OBJECT_ID('dbo.vwDienThoaiDayDu_VerticalPartition', 'V') IS NOT NULL DROP VIEW dbo.vwDienThoaiDayDu_VerticalPartition;
GO

CREATE VIEW dbo.vwDienThoaiDayDu_VerticalPartition
AS
SELECT
    cb.MaDT,
    cb.TenDT,
    cb.HangSX,
    cb.GiaBan,
    ts.ManHinh,
    ts.Camera,
    ts.Pin,
    ts.RAM,
    ts.BoNho,
    cb.MauSac,
    cb.MoTa,
    cb.TrangThai
FROM dbo.tblDienThoai_CoBan cb
INNER JOIN dbo.tblDienThoai_ThongSoKyThuat ts ON cb.MaDT = ts.MaDT;
GO

PRINT N'✓ View vwDienThoaiDayDu_VerticalPartition được tạo';
GO

-- ============================================================================
-- PART 2: PHÂN TÁN NGANG (HORIZONTAL PARTITIONING)
-- Chia tblHoaDon theo khoảng thời gian: Q1, Q2, Q3, Q4
-- ============================================================================

PRINT N'';
PRINT N'[PART 2] PHÂN TÁN NGANG (HORIZONTAL PARTITIONING)';
PRINT N'Mục đích: Chia bảng tblHoaDon theo quý (Q1, Q2, Q3, Q4)';
GO

-- Bước 1: Tạo bảng cho Q1 (Tháng 1-3)
IF OBJECT_ID('dbo.tblHoaDon_Q1', 'U') IS NOT NULL DROP TABLE dbo.tblHoaDon_Q1;
GO

PRINT N'Tạo bảng tblHoaDon_Q1 (Quý 1: Tháng 1-3)...';
CREATE TABLE dbo.tblHoaDon_Q1 (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaNV INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) DEFAULT 0 CHECK (TongTien >= 0),
    GhiChu NVARCHAR(MAX),
    CHECK (MONTH(NgayLap) BETWEEN 1 AND 3),
    FOREIGN KEY (MaKH) REFERENCES tblKhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Bảng tblHoaDon_Q1 được tạo';
GO

-- Bước 2: Tạo bảng cho Q2 (Tháng 4-6)
IF OBJECT_ID('dbo.tblHoaDon_Q2', 'U') IS NOT NULL DROP TABLE dbo.tblHoaDon_Q2;
GO

PRINT N'Tạo bảng tblHoaDon_Q2 (Quý 2: Tháng 4-6)...';
CREATE TABLE dbo.tblHoaDon_Q2 (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaNV INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) DEFAULT 0 CHECK (TongTien >= 0),
    GhiChu NVARCHAR(MAX),
    CHECK (MONTH(NgayLap) BETWEEN 4 AND 6),
    FOREIGN KEY (MaKH) REFERENCES tblKhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Bảng tblHoaDon_Q2 được tạo';
GO

-- Bước 3: Tạo bảng cho Q3 (Tháng 7-9)
IF OBJECT_ID('dbo.tblHoaDon_Q3', 'U') IS NOT NULL DROP TABLE dbo.tblHoaDon_Q3;
GO

PRINT N'Tạo bảng tblHoaDon_Q3 (Quý 3: Tháng 7-9)...';
CREATE TABLE dbo.tblHoaDon_Q3 (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaNV INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) DEFAULT 0 CHECK (TongTien >= 0),
    GhiChu NVARCHAR(MAX),
    CHECK (MONTH(NgayLap) BETWEEN 7 AND 9),
    FOREIGN KEY (MaKH) REFERENCES tblKhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Bảng tblHoaDon_Q3 được tạo';
GO

-- Bước 4: Tạo bảng cho Q4 (Tháng 10-12)
IF OBJECT_ID('dbo.tblHoaDon_Q4', 'U') IS NOT NULL DROP TABLE dbo.tblHoaDon_Q4;
GO

PRINT N'Tạo bảng tblHoaDon_Q4 (Quý 4: Tháng 10-12)...';
CREATE TABLE dbo.tblHoaDon_Q4 (
    MaHD INT PRIMARY KEY IDENTITY(1,1),
    MaKH INT NOT NULL,
    MaNV INT NOT NULL,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTien DECIMAL(18,2) DEFAULT 0 CHECK (TongTien >= 0),
    GhiChu NVARCHAR(MAX),
    CHECK (MONTH(NgayLap) BETWEEN 10 AND 12),
    FOREIGN KEY (MaKH) REFERENCES tblKhachHang(MaKH),
    FOREIGN KEY (MaNV) REFERENCES tblNhanVien(MaNV)
);
PRINT N'✓ Bảng tblHoaDon_Q4 được tạo';
GO

-- Bước 5: Chèn dữ liệu vào bảng phân tán ngang dựa trên tháng
PRINT N'Chèn dữ liệu vào bảng phân tán ngang...';
GO

-- Chèn dữ liệu vào Q1
INSERT INTO dbo.tblHoaDon_Q1 (MaKH, MaNV, NgayLap, TongTien, GhiChu)
SELECT MaKH, MaNV, NgayLap, TongTien, GhiChu
FROM dbo.tblHoaDon
WHERE MONTH(NgayLap) BETWEEN 1 AND 3;

-- Chèn dữ liệu vào Q2
INSERT INTO dbo.tblHoaDon_Q2 (MaKH, MaNV, NgayLap, TongTien, GhiChu)
SELECT MaKH, MaNV, NgayLap, TongTien, GhiChu
FROM dbo.tblHoaDon
WHERE MONTH(NgayLap) BETWEEN 4 AND 6;

-- Chèn dữ liệu vào Q3
INSERT INTO dbo.tblHoaDon_Q3 (MaKH, MaNV, NgayLap, TongTien, GhiChu)
SELECT MaKH, MaNV, NgayLap, TongTien, GhiChu
FROM dbo.tblHoaDon
WHERE MONTH(NgayLap) BETWEEN 7 AND 9;

-- Chèn dữ liệu vào Q4
INSERT INTO dbo.tblHoaDon_Q4 (MaKH, MaNV, NgayLap, TongTien, GhiChu)
SELECT MaKH, MaNV, NgayLap, TongTien, GhiChu
FROM dbo.tblHoaDon
WHERE MONTH(NgayLap) BETWEEN 10 AND 12;

PRINT N'✓ Dữ liệu đã được chèn vào bảng phân tán ngang (Q1-Q4)';
GO

-- ============================================================================
-- PART 3: VIEW HỢP NHẤT DỮ LIỆU PHÂN TÁN NGANG
-- ============================================================================

IF OBJECT_ID('dbo.vwHoaDonDayDu_HorizontalPartition', 'V') IS NOT NULL DROP VIEW dbo.vwHoaDonDayDu_HorizontalPartition;
GO

CREATE VIEW dbo.vwHoaDonDayDu_HorizontalPartition
AS
SELECT MaHD, MaKH, MaNV, NgayLap, TongTien, GhiChu, 'Q1' AS Quy
FROM dbo.tblHoaDon_Q1
UNION ALL
SELECT MaHD, MaKH, MaNV, NgayLap, TongTien, GhiChu, 'Q2' AS Quy
FROM dbo.tblHoaDon_Q2
UNION ALL
SELECT MaHD, MaKH, MaNV, NgayLap, TongTien, GhiChu, 'Q3' AS Quy
FROM dbo.tblHoaDon_Q3
UNION ALL
SELECT MaHD, MaKH, MaNV, NgayLap, TongTien, GhiChu, 'Q4' AS Quy
FROM dbo.tblHoaDon_Q4;
GO

PRINT N'✓ View vwHoaDonDayDu_HorizontalPartition được tạo';
GO

-- ============================================================================
-- PART 4: THỦ TỤC LẤY DỮ LIỆU TỪ BẢNG PHÂN TÁN
-- ============================================================================

PRINT N'';
PRINT N'[PART 4] THỦ TỤC LẤY DỮ LIỆU PHÂN TÁN';
GO

-- Proc 1: Lấy doanh thu từ tất cả quý (hợp nhất từ bảng phân tán ngang)
IF OBJECT_ID('dbo.spLayDoanhThuFromPartitions', 'P') IS NOT NULL DROP PROCEDURE dbo.spLayDoanhThuFromPartitions;
GO

CREATE PROCEDURE dbo.spLayDoanhThuFromPartitions
    @Quy INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Quy IS NULL
    BEGIN
        -- Lấy tất cả dữ liệu từ tất cả quý
        SELECT
            'Q1' AS Quy,
            COUNT(*) AS SoHoaDon,
            SUM(TongTien) AS TongDoanhThu
        FROM dbo.tblHoaDon_Q1
        UNION ALL
        SELECT
            'Q2' AS Quy,
            COUNT(*) AS SoHoaDon,
            SUM(TongTien) AS TongDoanhThu
        FROM dbo.tblHoaDon_Q2
        UNION ALL
        SELECT
            'Q3' AS Quy,
            COUNT(*) AS SoHoaDon,
            SUM(TongTien) AS TongDoanhThu
        FROM dbo.tblHoaDon_Q3
        UNION ALL
        SELECT
            'Q4' AS Quy,
            COUNT(*) AS SoHoaDon,
            SUM(TongTien) AS TongDoanhThu
        FROM dbo.tblHoaDon_Q4;
    END
    ELSE IF @Quy = 1
        SELECT COUNT(*) AS SoHoaDon, SUM(TongTien) AS TongDoanhThu FROM dbo.tblHoaDon_Q1;
    ELSE IF @Quy = 2
        SELECT COUNT(*) AS SoHoaDon, SUM(TongTien) AS TongDoanhThu FROM dbo.tblHoaDon_Q2;
    ELSE IF @Quy = 3
        SELECT COUNT(*) AS SoHoaDon, SUM(TongTien) AS TongDoanhThu FROM dbo.tblHoaDon_Q3;
    ELSE IF @Quy = 4
        SELECT COUNT(*) AS SoHoaDon, SUM(TongTien) AS TongDoanhThu FROM dbo.tblHoaDon_Q4;
END;
GO

PRINT N'✓ Thủ tục spLayDoanhThuFromPartitions được tạo';
GO

-- Proc 2: Lấy thông tin điện thoại từ bảng phân tán dọc
IF OBJECT_ID('dbo.spLayThongTinDienThoaiVertical', 'P') IS NOT NULL DROP PROCEDURE dbo.spLayThongTinDienThoaiVertical;
GO

CREATE PROCEDURE dbo.spLayThongTinDienThoaiVertical
    @HangSX NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        cb.MaDT,
        cb.TenDT,
        cb.HangSX,
        cb.GiaBan,
        ts.ManHinh,
        ts.Camera,
        ts.Pin,
        ts.RAM,
        ts.BoNho,
        cb.MauSac
    FROM dbo.tblDienThoai_CoBan cb
    INNER JOIN dbo.tblDienThoai_ThongSoKyThuat ts ON cb.MaDT = ts.MaDT
    WHERE (@HangSX IS NULL OR cb.HangSX = @HangSX)
      AND cb.TrangThai = 1;
END;
GO

PRINT N'✓ Thủ tục spLayThongTinDienThoaiVertical được tạo';
GO

-- ============================================================================
-- PART 5: TRUY VẤN MINH HỌA DỮ LIỆU PHÂN TÁN
-- ============================================================================

PRINT N'';
PRINT N'[PART 5] TRUY VẤN MINH HỌA DỮ LIỆU PHÂN TÁN';
PRINT N'';
GO

PRINT N'=== Dữ liệu phân tán dọc (Vertical) ===';
SELECT * FROM dbo.vwDienThoaiDayDu_VerticalPartition;
GO

PRINT N'';
PRINT N'=== Dữ liệu phân tán ngang (Horizontal) ===';
SELECT * FROM dbo.vwHoaDonDayDu_HorizontalPartition ORDER BY Quy, NgayLap;
GO

PRINT N'';
PRINT N'=== Doanh thu theo quý (từ bảng phân tán ngang) ===';
EXEC dbo.spLayDoanhThuFromPartitions;
GO

PRINT N'';
PRINT N'=== Thông tin điện thoại từ bảng phân tán dọc ===';
EXEC dbo.spLayThongTinDienThoaiVertical @HangSX = N'Apple';

GO
