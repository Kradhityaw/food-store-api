-- Tabel Users (Pengguna)
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(200),
    UserRole NVARCHAR(20) NOT NULL, -- Customer, Admin, StoreManager
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1
);

-- Tabel Category (Kategori Makanan)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(200)
);

-- Tabel Products (Produk/Makanan)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    Price DECIMAL(10, 2) NOT NULL,
    CategoryID INT REFERENCES Categories(CategoryID),
    StockQuantity INT NOT NULL DEFAULT 0,
    ImageURL NVARCHAR(200),
    IsAvailable BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    ModifiedAt DATETIME DEFAULT GETDATE()
);

-- Tabel Stores (Toko)
CREATE TABLE Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200) NOT NULL,
    PhoneNumber NVARCHAR(20),
    OperatingHours NVARCHAR(100),
    IsActive BIT DEFAULT 1
);

-- Tabel StoreProducts (Relasi Toko dan Produk)
CREATE TABLE StoreProducts (
    StoreProductID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT REFERENCES Stores(StoreID),
    ProductID INT REFERENCES Products(ProductID),
    Price DECIMAL(10, 2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    IsAvailable BIT DEFAULT 1,
    CONSTRAINT UC_Store_Product UNIQUE(StoreID, ProductID)
);

-- Tabel Orders (Pesanan)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT REFERENCES Users(UserID),
    StoreID INT REFERENCES Stores(StoreID),
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status NVARCHAR(20) NOT NULL, -- Pending, Processing, Completed, Cancelled
    PaymentMethod NVARCHAR(50),
    DeliveryAddress NVARCHAR(200),
    Notes NVARCHAR(500)
);

-- Tabel OrderDetails (Detail Pesanan)
CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT REFERENCES Orders(OrderID),
    ProductID INT REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Subtotal DECIMAL(10, 2) NOT NULL
);

-- Tabel Cart (Keranjang Belanja)
CREATE TABLE Cart (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT REFERENCES Users(UserID),
    ProductID INT REFERENCES Products(ProductID),
    StoreID INT REFERENCES Stores(StoreID),
    Quantity INT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT UC_User_Product_Store UNIQUE(UserID, ProductID, StoreID)
);

-- Tabel Payment (Pembayaran)
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT REFERENCES Orders(OrderID),
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    TransactionID NVARCHAR(100),
    PaymentStatus NVARCHAR(20) NOT NULL, -- Pending, Completed, Failed
    PaymentDate DATETIME DEFAULT GETDATE()
);

-- Indeks untuk Optimasi Query
CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_StoreProducts_StoreID ON StoreProducts(StoreID);
CREATE INDEX IX_StoreProducts_ProductID ON StoreProducts(ProductID);
CREATE INDEX IX_Orders_UserID ON Orders(UserID);
CREATE INDEX IX_Orders_StoreID ON Orders(StoreID);
CREATE INDEX IX_OrderDetails_OrderID ON OrderDetails(OrderID);
CREATE INDEX IX_OrderDetails_ProductID ON OrderDetails(ProductID);
CREATE INDEX IX_Cart_UserID ON Cart(UserID);

-- Data dummy untuk tabel Users
INSERT INTO Users (Username, Password, Email, FullName, PhoneNumber, Address, UserRole)
VALUES 
    ('admin', 'hashed_password_123', 'admin@foodapp.com', 'Admin Sistem', '081234567890', 'Jl. Admin No. 1', 'Admin'),
    ('manager1', 'hashed_password_456', 'manager1@foodapp.com', 'Budi Santoso', '081234567891', 'Jl. Manajer No. 10', 'StoreManager'),
    ('manager2', 'hashed_password_789', 'manager2@foodapp.com', 'Siti Rahayu', '081234567892', 'Jl. Manajer No. 20', 'StoreManager'),
    ('customer1', 'hashed_password_abc', 'customer1@gmail.com', 'Andi Wijaya', '081234567893', 'Jl. Pelanggan No. 100', 'Customer'),
    ('customer2', 'hashed_password_def', 'customer2@gmail.com', 'Diana Putri', '081234567894', 'Jl. Pelanggan No. 200', 'Customer'),
    ('customer3', 'hashed_password_ghi', 'customer3@gmail.com', 'Rudi Hartono', '081234567895', 'Jl. Pelanggan No. 300', 'Customer');

-- Data dummy untuk tabel Categories
INSERT INTO Categories (CategoryName, Description)
VALUES
    ('Makanan Utama', 'Berbagai pilihan makanan utama'),
    ('Minuman', 'Pilihan minuman segar'),
    ('Makanan Penutup', 'Hidangan pencuci mulut'),
    ('Cemilan', 'Makanan ringan untuk camilan'),
    ('Paket Hemat', 'Kombinasi makanan dan minuman dengan harga terjangkau');

-- Data dummy untuk tabel Products
INSERT INTO Products (ProductName, Description, Price, CategoryID, StockQuantity, ImageURL, IsAvailable)
VALUES
    ('Nasi Goreng Spesial', 'Nasi goreng dengan telur, ayam, dan sayuran', 25000.00, 1, 100, 'nasigoreng.jpg', 1),
    ('Mie Ayam', 'Mie dengan potongan ayam dan pangsit', 20000.00, 1, 80, 'mieayam.jpg', 1),
    ('Soto Ayam', 'Sup ayam tradisional dengan bumbu rempah', 22000.00, 1, 75, 'sotoayam.jpg', 1),
    ('Es Teh Manis', 'Teh manis dingin', 5000.00, 2, 200, 'esteh.jpg', 1),
    ('Es Jeruk', 'Jus jeruk segar dengan es', 8000.00, 2, 180, 'esjeruk.jpg', 1),
    ('Puding Coklat', 'Puding coklat dengan saus vanilla', 12000.00, 3, 50, 'pudingcoklat.jpg', 1),
    ('Kue Lapis', 'Kue tradisional berlapis', 15000.00, 3, 40, 'kuelapis.jpg', 1),
    ('Pisang Goreng', 'Pisang digoreng dengan tepung crispy', 10000.00, 4, 60, 'pisanggoreng.jpg', 1),
    ('Tempe Mendoan', 'Tempe iris tipis dibalut tepung', 8000.00, 4, 70, 'tempemendoan.jpg', 1),
    ('Paket Nasi Goreng Komplit', 'Nasi goreng dengan telur, ayam, dan es teh', 32000.00, 5, 40, 'paketnasgor.jpg', 1),
    ('Paket Mie Ayam Komplit', 'Mie ayam dengan pangsit dan es jeruk', 30000.00, 5, 35, 'paketmieayam.jpg', 1),
    ('Air Mineral', 'Air mineral dalam kemasan', 4000.00, 2, 300, 'airmineral.jpg', 1),
    ('Ayam Goreng', 'Ayam goreng renyah dengan bumbu spesial', 18000.00, 1, 90, 'ayamgoreng.jpg', 1),
    ('Es Krim Vanilla', 'Es krim lembut rasa vanilla', 10000.00, 3, 45, 'eskrimvanilla.jpg', 1),
    ('Kentang Goreng', 'Kentang goreng renyah', 12000.00, 4, 85, 'kentanggoreng.jpg', 1);

-- Data dummy untuk tabel Stores
INSERT INTO Stores (StoreName, Address, PhoneNumber, OperatingHours, IsActive)
VALUES
    ('Warung Nikmat', 'Jl. Pahlawan No. 123, Jakarta', '021987654321', '08:00 - 22:00', 1),
    ('Resto Bahagia', 'Jl. Sudirman No. 456, Jakarta', '021876543210', '10:00 - 21:00', 1),
    ('Kedai Sederhana', 'Jl. Gajah Mada No. 789, Jakarta', '021765432109', '07:00 - 20:00', 1);

-- Data dummy untuk tabel StoreProducts
INSERT INTO StoreProducts (StoreID, ProductID, Price, StockQuantity, IsAvailable)
VALUES
    -- Produk di Warung Nikmat
    (1, 1, 25000.00, 50, 1),  -- Nasi Goreng Spesial
    (1, 2, 20000.00, 40, 1),  -- Mie Ayam
    (1, 4, 5000.00, 100, 1),  -- Es Teh Manis
    (1, 5, 8000.00, 90, 1),   -- Es Jeruk
    (1, 8, 10000.00, 30, 1),  -- Pisang Goreng
    (1, 10, 32000.00, 20, 1), -- Paket Nasi Goreng Komplit
    (1, 12, 4000.00, 150, 1), -- Air Mineral
    
    -- Produk di Resto Bahagia
    (2, 1, 28000.00, 45, 1),  -- Nasi Goreng Spesial (harga berbeda)
    (2, 3, 22000.00, 35, 1),  -- Soto Ayam
    (2, 4, 6000.00, 85, 1),   -- Es Teh Manis (harga berbeda)
    (2, 6, 12000.00, 25, 1),  -- Puding Coklat
    (2, 7, 15000.00, 20, 1),  -- Kue Lapis
    (2, 11, 30000.00, 15, 1), -- Paket Mie Ayam Komplit
    (2, 12, 5000.00, 120, 1), -- Air Mineral (harga berbeda)
    (2, 13, 18000.00, 40, 1), -- Ayam Goreng
    
    -- Produk di Kedai Sederhana
    (3, 2, 18000.00, 50, 1),  -- Mie Ayam (harga berbeda)
    (3, 3, 20000.00, 45, 1),  -- Soto Ayam (harga berbeda)
    (3, 4, 4000.00, 120, 1),  -- Es Teh Manis (harga berbeda)
    (3, 9, 8000.00, 40, 1),   -- Tempe Mendoan
    (3, 12, 3000.00, 200, 1), -- Air Mineral (harga berbeda)
    (3, 14, 10000.00, 30, 1), -- Es Krim Vanilla
    (3, 15, 12000.00, 45, 1); -- Kentang Goreng

-- Data dummy untuk tabel Orders
INSERT INTO Orders (UserID, StoreID, OrderDate, TotalAmount, Status, PaymentMethod, DeliveryAddress, Notes)
VALUES
    (4, 1, DATEADD(day, -5, GETDATE()), 60000.00, 'Completed', 'Cash', 'Jl. Pelanggan No. 100', 'Tolong dibungkus rapi'),
    (5, 2, DATEADD(day, -3, GETDATE()), 52000.00, 'Completed', 'Transfer', 'Jl. Pelanggan No. 200', 'Tanpa kecap'),
    (6, 3, DATEADD(day, -2, GETDATE()), 42000.00, 'Completed', 'E-Wallet', 'Jl. Pelanggan No. 300', ''),
    (4, 1, DATEADD(day, -1, GETDATE()), 37000.00, 'Processing', 'Cash', 'Jl. Pelanggan No. 100', ''),
    (5, 3, DATEADD(hour, -5, GETDATE()), 38000.00, 'Pending', 'Transfer', 'Jl. Pelanggan No. 200', 'Extra pedas');

-- Data dummy untuk tabel OrderDetails
INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, Subtotal)
VALUES
    -- Order 1 details (customer1 di Warung Nikmat)
    (1, 1, 1, 25000.00, 25000.00),  -- 1 Nasi Goreng Spesial
    (1, 4, 2, 5000.00, 10000.00),   -- 2 Es Teh Manis
    (1, 8, 1, 10000.00, 10000.00),  -- 1 Pisang Goreng
    (1, 12, 1, 4000.00, 4000.00),   -- 1 Air Mineral
    
    -- Order 2 details (customer2 di Resto Bahagia)
    (2, 3, 1, 22000.00, 22000.00),  -- 1 Soto Ayam
    (2, 6, 2, 12000.00, 24000.00),  -- 2 Puding Coklat
    (2, 12, 1, 5000.00, 5000.00),   -- 1 Air Mineral
    
    -- Order 3 details (customer3 di Kedai Sederhana)
    (3, 2, 1, 18000.00, 18000.00),  -- 1 Mie Ayam
    (3, 9, 2, 8000.00, 16000.00),   -- 2 Tempe Mendoan
    (3, 14, 1, 10000.00, 10000.00), -- 1 Es Krim Vanilla
    
    -- Order 4 details (customer1 di Warung Nikmat)
    (4, 10, 1, 32000.00, 32000.00), -- 1 Paket Nasi Goreng Komplit
    (4, 8, 1, 10000.00, 10000.00),  -- 1 Pisang Goreng
    
    -- Order 5 details (customer2 di Kedai Sederhana)
    (5, 2, 1, 18000.00, 18000.00),  -- 1 Mie Ayam
    (5, 15, 1, 12000.00, 12000.00), -- 1 Kentang Goreng
    (5, 4, 2, 4000.00, 8000.00);    -- 2 Es Teh Manis

-- Data dummy untuk tabel Cart
INSERT INTO Cart (UserID, ProductID, StoreID, Quantity)
VALUES
    (4, 3, 2, 1),  -- customer1 menambahkan Soto Ayam dari Resto Bahagia ke keranjang
    (4, 6, 2, 2),  -- customer1 menambahkan 2 Puding Coklat dari Resto Bahagia ke keranjang
    (5, 1, 1, 1),  -- customer2 menambahkan Nasi Goreng Spesial dari Warung Nikmat ke keranjang
    (5, 4, 1, 2),  -- customer2 menambahkan 2 Es Teh Manis dari Warung Nikmat ke keranjang
    (6, 2, 3, 1),  -- customer3 menambahkan Mie Ayam dari Kedai Sederhana ke keranjang
    (6, 14, 3, 1); -- customer3 menambahkan Es Krim Vanilla dari Kedai Sederhana ke keranjang

-- Data dummy untuk tabel Payments
INSERT INTO Payments (OrderID, Amount, PaymentMethod, TransactionID, PaymentStatus, PaymentDate)
VALUES
    (1, 60000.00, 'Cash', 'CASH-001', 'Completed', DATEADD(day, -5, GETDATE())),
    (2, 52000.00, 'Transfer', 'TRF-001', 'Completed', DATEADD(day, -3, GETDATE())),
    (3, 42000.00, 'E-Wallet', 'EW-001', 'Completed', DATEADD(day, -2, GETDATE())),
    (4, 37000.00, 'Cash', 'CASH-002', 'Pending', DATEADD(day, -1, GETDATE())),
    (5, 38000.00, 'Transfer', 'TRF-002', 'Pending', DATEADD(hour, -5, GETDATE()));