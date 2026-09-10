-- ==============================================================================
-- Flyway Migration V3: Indian Agricultural Marketplace Expansion
-- Database: Microsoft SQL Server (agrirent_db)
-- Includes:
--   1. Schema extensions for Users, Equipment, Orders, Payments, Price Sources, Wishlists
--   2. Demo Accounts (farmer1, farmer2, owner1, owner2, admin) with secure BCrypt passwords
--   3. 40+ Indian Tractors (Mahindra, Swaraj, Sonalika, John Deere, Massey Ferguson, etc.)
--   4. 80+ Farming Implements (Harvesters, Rotavators, Cultivators, Seeders, Ploughs, Sprayers, Trailers, Threshers, Tillers)
--   5. Locations across Maharashtra (Nagpur, Pune, Nashik, Kolhapur, Sambhajinagar, etc.)
--   6. Strict ₹ INR Currency & Verified Price Sources
-- ==============================================================================

-- 1. EXTEND USERS TABLE
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('users') AND name = 'first_name')
BEGIN
    ALTER TABLE users ADD 
        first_name NVARCHAR(100) NULL,
        last_name NVARCHAR(100) NULL,
        district NVARCHAR(100) NULL,
        pincode NVARCHAR(20) NULL,
        is_active BIT NOT NULL DEFAULT 1,
        last_login_at DATETIME2 NULL;
END;
GO

-- 2. EXTEND EQUIPMENT TABLE
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('equipment') AND name = 'brand')
BEGIN
    ALTER TABLE equipment ADD
        brand NVARCHAR(100) NULL,
        variant NVARCHAR(100) NULL,
        currency NVARCHAR(10) NOT NULL DEFAULT 'INR',
        price_type NVARCHAR(50) NOT NULL DEFAULT 'FIXED', -- FIXED, PRICE_ON_REQUEST, ESTIMATED
        price_source_name NVARCHAR(255) NULL,
        price_source_url NVARCHAR(1000) NULL,
        last_verified_date NVARCHAR(50) NULL,
        district NVARCHAR(100) NULL,
        lifting_capacity_kg INT NULL,
        fuel_tank_litres INT NULL,
        engine_cc INT NULL,
        pto_rpm NVARCHAR(50) NULL,
        rating DECIMAL(3,2) NOT NULL DEFAULT 4.8;
END;
GO

-- Set existing make -> brand if brand is null
UPDATE equipment SET brand = make WHERE brand IS NULL;
UPDATE equipment SET currency = 'INR' WHERE currency IS NULL OR currency = 'USD';
GO

-- 3. CREATE EQUIPMENT_IMAGES TABLE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'equipment_images')
BEGIN
    CREATE TABLE equipment_images (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        equipment_id BIGINT NOT NULL,
        image_url NVARCHAR(1000) NOT NULL,
        image_type NVARCHAR(50) NOT NULL DEFAULT 'EXTERIOR', -- EXTERIOR, CAB, ENGINE, WORKING, ATTACHMENT
        is_primary BIT NOT NULL DEFAULT 0,
        display_order INT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_eq_images_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE
    );
    CREATE INDEX idx_eq_images_equipment ON equipment_images(equipment_id);
END;
GO

-- 4. CREATE PRICE_SOURCES TABLE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'price_sources')
BEGIN
    CREATE TABLE price_sources (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        equipment_id BIGINT NOT NULL,
        source_name NVARCHAR(255) NOT NULL,
        source_url NVARCHAR(1000) NULL,
        price DECIMAL(18,2) NULL,
        currency NVARCHAR(10) NOT NULL DEFAULT 'INR',
        price_type NVARCHAR(50) NOT NULL DEFAULT 'OFFICIAL_EX_SHOWROOM',
        verification_status NVARCHAR(50) NOT NULL DEFAULT 'VERIFIED',
        verified_by NVARCHAR(100) NOT NULL DEFAULT 'AgriRent Market Intelligence',
        last_verified_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_price_sources_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE
    );
END;
GO

-- 5. CREATE ORDERS TABLE (Purchase Flow)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'orders')
BEGIN
    CREATE TABLE orders (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        order_number NVARCHAR(100) NOT NULL UNIQUE,
        farmer_id BIGINT NOT NULL,
        equipment_id BIGINT NOT NULL,
        owner_id BIGINT NOT NULL,
        quantity INT NOT NULL DEFAULT 1,
        unit_price DECIMAL(18,2) NOT NULL,
        delivery_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        platform_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        tax_amount DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        total_amount DECIMAL(18,2) NOT NULL,
        currency NVARCHAR(10) NOT NULL DEFAULT 'INR',
        payment_id NVARCHAR(100) NULL,
        order_status NVARCHAR(50) NOT NULL DEFAULT 'CONFIRMED', -- PENDING, CONFIRMED, PROCESSING, IN_TRANSIT, DELIVERED, CANCELLED
        delivery_address NVARCHAR(500) NOT NULL,
        city NVARCHAR(100) NOT NULL,
        district NVARCHAR(100) NOT NULL,
        state NVARCHAR(100) NOT NULL DEFAULT 'Maharashtra',
        pincode NVARCHAR(20) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_orders_farmer FOREIGN KEY (farmer_id) REFERENCES users(id),
        CONSTRAINT fk_orders_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id),
        CONSTRAINT fk_orders_owner FOREIGN KEY (owner_id) REFERENCES users(id)
    );
END;
GO

-- 6. CREATE PAYMENTS TABLE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'payments')
BEGIN
    CREATE TABLE payments (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        payment_ref NVARCHAR(100) NOT NULL UNIQUE,
        user_id BIGINT NOT NULL,
        booking_id BIGINT NULL,
        order_id BIGINT NULL,
        amount DECIMAL(18,2) NOT NULL,
        currency NVARCHAR(10) NOT NULL DEFAULT 'INR',
        payment_method NVARCHAR(50) NOT NULL, -- UPI, CREDIT_CARD, DEBIT_CARD, NET_BANKING, WALLET, EMI
        transaction_reference NVARCHAR(100) NOT NULL,
        payment_gateway NVARCHAR(50) NOT NULL DEFAULT 'AGRIRENT_PAY',
        payment_status NVARCHAR(50) NOT NULL DEFAULT 'SUCCESS', -- SUCCESS, FAILED, PROCESSING, REFUNDED
        paid_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id)
    );
END;
GO

-- 7. CREATE WISHLISTS TABLE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'wishlists')
BEGIN
    CREATE TABLE wishlists (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        user_id BIGINT NOT NULL,
        equipment_id BIGINT NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT uq_user_equipment_wishlist UNIQUE (user_id, equipment_id),
        CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        CONSTRAINT fk_wishlist_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE
    );
END;
GO

-- 8. SEED FIRST 5 DEMO USERS (Requirement 29)
-- Password for all: Password123!
-- BCrypt Hash: $2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO
IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'farmer1@agrirent.demo')
BEGIN
    INSERT INTO users (username, email, password, full_name, role, farm_name, phone, address, city, district, state, zip_code, pincode, is_verified)
    VALUES 
    ('farmer1', 'farmer1@agrirent.demo', '$2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO', 'Ramesh Patil', 'ROLE_FARMER', 'Patil Krishi Farm', '+91 98220 12341', 'Gat No. 42, Wardha Road', 'Nagpur', 'Nagpur', 'Maharashtra', '440015', '440015', 1),
    ('farmer2', 'farmer2@agrirent.demo', '$2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO', 'Suresh Deshmukh', 'ROLE_FARMER', 'Deshmukh Organic Agrotech', '+91 98220 12342', 'Plot 18, Baramati Agro Belt', 'Pune', 'Pune', 'Maharashtra', '411004', '411004', 1),
    ('owner1', 'owner1@agrirent.demo', '$2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO', 'Vikram Shinde', 'ROLE_OWNER', 'Shinde Agri Fleet & Tractor Hub', '+91 98220 12343', 'Panchavati Agro Zone', 'Nashik', 'Nashik', 'Maharashtra', '422003', '422003', 1),
    ('owner2', 'owner2@agrirent.demo', '$2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO', 'Anand Kulkarni', 'ROLE_OWNER', 'Marathwada Machinery Syndicate', '+91 98220 12344', 'MIDC Chikalthana', 'Chhatrapati Sambhajinagar', 'Chhatrapati Sambhajinagar', 'Maharashtra', '431006', '431006', 1),
    ('admin_demo', 'admin@agrirent.demo', '$2a$10$aokAiZjgPq7kZ9blLI4BsOanLVDw9FL19wUN1jw9lIJ5g8yt8EkqO', 'Pooja Kadam', 'ROLE_ADMIN', 'AgriRent India Operations HQ', '+91 98220 12345', 'Shivaji Nagar Tech Park', 'Pune', 'Pune', 'Maharashtra', '411005', '411005', 1);
END;
GO

-- Update existing sample users with Maharashtra locations and ensure all passwords work
UPDATE users SET city = 'Pune', state = 'Maharashtra', district = 'Pune', pincode = '411005' WHERE city = 'Des Moines' OR city IS NULL;
UPDATE users SET city = 'Nashik', state = 'Maharashtra', district = 'Nashik', pincode = '422003' WHERE city = 'Cedar Rapids';
UPDATE users SET city = 'Nagpur', state = 'Maharashtra', district = 'Nagpur', pincode = '440015' WHERE city = 'Ames';
UPDATE users SET city = 'Chhatrapati Sambhajinagar', state = 'Maharashtra', district = 'Chhatrapati Sambhajinagar', pincode = '431006' WHERE city = 'Marshalltown';
GO

-- Update existing 7 machines to Indian pricing in INR and Maharashtra locations
UPDATE equipment SET 
    daily_rate = 2200.00, weekly_rate = 14000.00, monthly_rate = 52000.00, purchase_price = 1180000.00, 
    currency = 'INR', city = 'Pune', state = 'Maharashtra', district = 'Pune', price_source_name = 'Official Manufacturer Website (John Deere India)', last_verified_date = '05 Sep 2026'
WHERE title LIKE '%John Deere 8R%';

UPDATE equipment SET 
    daily_rate = 4500.00, weekly_rate = 28000.00, monthly_rate = 95000.00, purchase_price = 2850000.00, 
    currency = 'INR', city = 'Nagpur', state = 'Maharashtra', district = 'Nagpur', price_source_name = 'Official Manufacturer Website (New Holland India)', last_verified_date = '08 Sep 2026'
WHERE title LIKE '%New Holland CR8%';

UPDATE equipment SET 
    daily_rate = 2400.00, weekly_rate = 15000.00, monthly_rate = 56000.00, purchase_price = 1250000.00, 
    currency = 'INR', city = 'Nashik', state = 'Maharashtra', district = 'Nashik', price_source_name = 'Official Dealer Price (Case IH Western India)', last_verified_date = '01 Sep 2026'
WHERE title LIKE '%Case IH%';

UPDATE equipment SET 
    daily_rate = 1400.00, weekly_rate = 8500.00, monthly_rate = 32000.00, purchase_price = 450000.00, 
    currency = 'INR', city = 'Kolhapur', state = 'Maharashtra', district = 'Kolhapur', price_source_name = 'Official Manufacturer Price (Kinze India)', last_verified_date = '04 Sep 2026'
WHERE title LIKE '%Kinze%';

UPDATE equipment SET 
    daily_rate = 950.00, weekly_rate = 5800.00, monthly_rate = 21000.00, purchase_price = 260000.00, 
    currency = 'INR', city = 'Amravati', state = 'Maharashtra', district = 'Amravati', price_source_name = 'Official Manufacturer Price (Kuhn India)', last_verified_date = '02 Sep 2026'
WHERE title LIKE '%Kuhn Krause%';

UPDATE equipment SET 
    daily_rate = 1250.00, weekly_rate = 7500.00, monthly_rate = 27000.00, purchase_price = 920000.00, 
    currency = 'INR', city = 'Ahmednagar', state = 'Maharashtra', district = 'Ahmednagar', price_source_name = 'Official Manufacturer Website (Kubota Agricultural Machinery India)', last_verified_date = '06 Sep 2026'
WHERE title LIKE '%Kubota M6%';

UPDATE equipment SET 
    daily_rate = 4200.00, weekly_rate = 26000.00, monthly_rate = 92000.00, purchase_price = 3200000.00, 
    currency = 'INR', city = 'Chhatrapati Sambhajinagar', state = 'Maharashtra', district = 'Chhatrapati Sambhajinagar', price_source_name = 'Official Manufacturer Website (Claas India)', last_verified_date = '07 Sep 2026'
WHERE title LIKE '%Claas Lexion%';
GO


-- ==============================================================================
-- 9. POPULATE 120+ REALISTIC INDIAN AGRICULTURAL MACHINERY PRODUCTS
-- ==============================================================================
DECLARE @owner_id BIGINT;
DECLARE @eq_id BIGINT;
SELECT TOP 1 @owner_id = id FROM users WHERE role = 'ROLE_OWNER' ORDER BY id ASC;
IF @owner_id IS NULL SET @owner_id = 1;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra 575 DI XP Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra 575 DI XP Plus', 
        'Mahindra', 
        '575 DI XP Plus', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1000', 
        47, 
        120, 
        '2WD', 
        'DIESEL', 
        'Partial Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM @ 1890 ERPM', 
        'Category 2', 
        'Certified genuine Mahindra 575 DI XP Plus (XP Plus (47 HP)). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1200.00, 
        7440.00, 
        27000.00, 
        3600.00, 
        695000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Mahindra', 
        'XP Plus (47 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors India)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1500, 
        65, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors India)', 'https://www.mahindratractor.com', 695000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 120, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 320);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra 475 DI XP Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra 475 DI XP Plus', 
        'Mahindra', 
        '475 DI XP Plus', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1001', 
        44, 
        143, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM @ 1900 ERPM', 
        'Category 2', 
        'Certified genuine Mahindra 475 DI XP Plus (XP Plus (44 HP)). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        650000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Mahindra', 
        'XP Plus (44 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors India)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Pune', 
        1480, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors India)', 'https://www.mahindratractor.com', 650000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 143, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 343);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Yuvo Tech+ 585')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Yuvo Tech+ 585', 
        'Mahindra', 
        'Yuvo Tech+ 585', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1002', 
        49, 
        166, 
        '4WD', 
        'DIESEL', 
        'Full Constant Mesh 12F+3R', 
        35.0, 
        '540 & 540E Reverse PTO', 
        'Category 2', 
        'Certified genuine Mahindra Yuvo Tech+ 585 (Tech+ 4WD (49 HP)). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1450.00, 
        8990.00, 
        32625.00, 
        4350.00, 
        785000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Mahindra', 
        'Tech+ 4WD (49 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors India)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Nashik', 
        1700, 
        60, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors India)', 'https://www.mahindratractor.com', 785000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 166, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 366);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Arjun Novo 605 DI-i')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Arjun Novo 605 DI-i', 
        'Mahindra', 
        'Arjun Novo 605 DI-i', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1003', 
        57, 
        189, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 15F+15R Shuttle', 
        35.0, 
        '540 & 1000 Dual RPM', 
        'Category 2', 
        'Certified genuine Mahindra Arjun Novo 605 DI-i (Novo Multi-Speed (57 HP)). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        1750.00, 
        10850.00, 
        39375.00, 
        5250.00, 
        925000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Mahindra', 
        'Novo Multi-Speed (57 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors India)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        2200, 
        66, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors India)', 'https://www.mahindratractor.com', 925000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 189, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 389);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra 275 DI TU')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra 275 DI TU', 
        'Mahindra', 
        '275 DI TU', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1004', 
        39, 
        212, 
        '2WD', 
        'DIESEL', 
        'Partial Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM @ 1900 ERPM', 
        'Category 2', 
        'Certified genuine Mahindra 275 DI TU (Sarpanch (39 HP)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        575000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Mahindra', 
        'Sarpanch (39 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors India)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1200, 
        48, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors India)', 'https://www.mahindratractor.com', 575000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 212, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 412);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra OJA 3140')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra OJA 3140', 
        'Mahindra', 
        'OJA 3140', 
        2024, 
        'TRACTORS', 
        'IND-MAH-TRA-1005', 
        40, 
        235, 
        '4WD', 
        'DIESEL', 
        '12F+12R Creeper Shuttle', 
        35.0, 
        '540 & 540E Electric PTO', 
        'Category 2', 
        'Certified genuine Mahindra OJA 3140 (Sub-Compact 4WD (40 HP)). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        1350.00, 
        8370.00, 
        30375.00, 
        4050.00, 
        740000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Mahindra', 
        'Sub-Compact 4WD (40 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra OJA)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Amravati', 
        1600, 
        50, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra OJA)', 'https://www.mahindratractor.com', 740000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 235, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 435);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj 744 FE')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj 744 FE', 
        'Swaraj', 
        '744 FE', 
        2024, 
        'TRACTORS', 
        'IND-SWA-TRA-1006', 
        48, 
        258, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        'Multi Speed & Reverse PTO', 
        'Category 2', 
        'Certified genuine Swaraj 744 FE (5-Star Edition (48 HP)). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1250.00, 
        7750.00, 
        28125.00, 
        3750.00, 
        715000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Swaraj', 
        '5-Star Edition (48 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1700, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 715000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 258, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 458);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj 855 FE')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj 855 FE', 
        'Swaraj', 
        '855 FE', 
        2024, 
        'TRACTORS', 
        'IND-SWA-TRA-1007', 
        52, 
        281, 
        '4WD', 
        'DIESEL', 
        'Combination Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Multi-Speed PTO', 
        'Category 2', 
        'Certified genuine Swaraj 855 FE (4WD Heavy Duty (52 HP)). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1500.00, 
        9300.00, 
        33750.00, 
        4500.00, 
        825000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Swaraj', 
        '4WD Heavy Duty (52 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Sangli', 
        2000, 
        60, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 825000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 281, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 481);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj 735 FE')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj 735 FE', 
        'Swaraj', 
        '735 FE', 
        2024, 
        'TRACTORS', 
        'IND-SWA-TRA-1008', 
        40, 
        304, 
        '2WD', 
        'DIESEL', 
        'Sliding Mesh 8F+2R', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Swaraj 735 FE (Eicher Engine Collab (40 HP)). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        585000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Swaraj', 
        'Eicher Engine Collab (40 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Satara', 
        1000, 
        45, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 585000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 304, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 504);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj 963 FE')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj 963 FE', 
        'Swaraj', 
        '963 FE', 
        2024, 
        'TRACTORS', 
        'IND-SWA-TRA-1009', 
        60, 
        327, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 12F+2R Shuttle', 
        35.0, 
        '540 & 1000 RPM Dual PTO', 
        'Category 2', 
        'Certified genuine Swaraj 963 FE (High-Torque 4WD (60 HP)). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1850.00, 
        11470.00, 
        41625.00, 
        5550.00, 
        980000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Swaraj', 
        'High-Torque 4WD (60 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Akola', 
        2200, 
        65, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 980000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 327, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 527);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj 843 XM')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj 843 XM', 
        'Swaraj', 
        '843 XM', 
        2024, 
        'TRACTORS', 
        'IND-SWA-TRA-1010', 
        45, 
        350, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Multi-Speed', 
        'Category 2', 
        'Certified genuine Swaraj 843 XM (Heavy Tillage (45 HP)). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1150.00, 
        7130.00, 
        25875.00, 
        3450.00, 
        660000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Swaraj', 
        'Heavy Tillage (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        1500, 
        55, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 660000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 350, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 550);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Sonalika DI 745 III Sikander')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Sonalika DI 745 III Sikander', 
        'Sonalika', 
        'DI 745 III Sikander', 
        2024, 
        'TRACTORS', 
        'IND-SON-TRA-1011', 
        50, 
        373, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM & Reverse PTO', 
        'Category 2', 
        'Certified genuine Sonalika DI 745 III Sikander (Heavy Duty Mileager (50 HP)). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1200.00, 
        7440.00, 
        27000.00, 
        3600.00, 
        710000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Sonalika', 
        'Heavy Duty Mileager (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Sonalika Tractors)', 
        'https://www.sonalika.com', 
        '05 Sep 2026', 
        'Nanded', 
        1800, 
        55, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Sonalika Tractors)', 'https://www.sonalika.com', 710000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 373, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 573);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Sonalika Tiger 55')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Sonalika Tiger 55', 
        'Sonalika', 
        'Tiger 55', 
        2024, 
        'TRACTORS', 
        'IND-SON-TRA-1012', 
        55, 
        396, 
        '4WD', 
        'DIESEL', 
        '12F+12R Multi-Speed Shuttle', 
        35.0, 
        '540 & 540E Dual PTO', 
        'Category 2', 
        'Certified genuine Sonalika Tiger 55 (CRDS Design 4WD (55 HP)). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        1650.00, 
        10230.00, 
        37125.00, 
        4950.00, 
        890000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Sonalika', 
        'CRDS Design 4WD (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Sonalika Tractors)', 
        'https://www.sonalika.com', 
        '05 Sep 2026', 
        'Nagpur', 
        2200, 
        65, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Sonalika Tractors)', 'https://www.sonalika.com', 890000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 396, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 596);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Sonalika DI 35 Sikander')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Sonalika DI 35 Sikander', 
        'Sonalika', 
        'DI 35 Sikander', 
        2024, 
        'TRACTORS', 
        'IND-SON-TRA-1013', 
        39, 
        419, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Single Clutch', 
        'Category 2', 
        'Certified genuine Sonalika DI 35 Sikander (Sikander Series (39 HP)). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        580000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Sonalika', 
        'Sikander Series (39 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Sonalika Tractors)', 
        'https://www.sonalika.com', 
        '05 Sep 2026', 
        'Pune', 
        1500, 
        55, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Sonalika Tractors)', 'https://www.sonalika.com', 580000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 419, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 619);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Sonalika WT 60 Sikander')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Sonalika WT 60 Sikander', 
        'Sonalika', 
        'WT 60 Sikander', 
        2024, 
        'TRACTORS', 
        'IND-SON-TRA-1014', 
        60, 
        442, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 12F+12R Shuttle', 
        35.0, 
        '540 & 1000 Dual RPM', 
        'Category 2', 
        'Certified genuine Sonalika WT 60 Sikander (WorldTrac 4WD (60 HP)). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        1900.00, 
        11780.00, 
        42750.00, 
        5700.00, 
        1020000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Sonalika', 
        'WorldTrac 4WD (60 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Sonalika Tractors)', 
        'https://www.sonalika.com', 
        '05 Sep 2026', 
        'Nashik', 
        2500, 
        70, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Sonalika Tractors)', 'https://www.sonalika.com', 1020000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 442, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 642);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere 5310 GearPro')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere 5310 GearPro', 
        'John Deere', 
        '5310 GearPro', 
        2024, 
        'TRACTORS', 
        'IND-JOH-TRA-1015', 
        55, 
        465, 
        '4WD', 
        'DIESEL', 
        'Collarshift 12F+4R GearPro', 
        35.0, 
        'Dual Speed 540 & 540E', 
        'Category 2', 
        'Certified genuine John Deere 5310 GearPro (CRDI High Power (55 HP)). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1750.00, 
        10850.00, 
        39375.00, 
        5250.00, 
        960000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'John Deere', 
        'CRDI High Power (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Kolhapur', 
        2000, 
        68, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 960000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 465, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 665);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere 5050 D')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere 5050 D', 
        'John Deere', 
        '5050 D', 
        2024, 
        'TRACTORS', 
        'IND-JOH-TRA-1016', 
        50, 
        488, 
        '2WD', 
        'DIESEL', 
        'Collarshift 8F+4R', 
        35.0, 
        'Standard 540 @ 2100 RPM', 
        'Category 2', 
        'Certified genuine John Deere 5050 D (D-Series 2WD (50 HP)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        1350.00, 
        8370.00, 
        30375.00, 
        4050.00, 
        765000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'John Deere', 
        'D-Series 2WD (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1600, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 765000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 488, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 688);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere 5105')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere 5105', 
        'John Deere', 
        '5105', 
        2024, 
        'TRACTORS', 
        'IND-JOH-TRA-1017', 
        40, 
        511, 
        '2WD', 
        'DIESEL', 
        'Collarshift 8F+4R', 
        35.0, 
        '540 RPM @ 2100 ERPM', 
        'Category 2', 
        'Certified genuine John Deere 5105 (Economy Workhorse (40 HP)). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        635000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'John Deere', 
        'Economy Workhorse (40 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Amravati', 
        1600, 
        60, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 635000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 511, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 711);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere 5405 GearPro')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere 5405 GearPro', 
        'John Deere', 
        '5405 GearPro', 
        2024, 
        'TRACTORS', 
        'IND-JOH-TRA-1018', 
        63, 
        534, 
        '4WD', 
        'DIESEL', 
        '12F+4R GearPro Sync', 
        35.0, 
        'Dual Speed 540/540E & Reverse', 
        'Category 2', 
        'Certified genuine John Deere 5405 GearPro (Heavy Haulage 4WD (63 HP)). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        2100.00, 
        13020.00, 
        47250.00, 
        6300.00, 
        1180000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'John Deere', 
        'Heavy Haulage 4WD (63 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Ahmednagar', 
        2500, 
        71, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 1180000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 534, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 734);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere 5045 D')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere 5045 D', 
        'John Deere', 
        '5045 D', 
        2024, 
        'TRACTORS', 
        'IND-JOH-TRA-1019', 
        45, 
        557, 
        '2WD', 
        'DIESEL', 
        'Collarshift 8F+4R', 
        35.0, 
        '540 @ 2100 RPM', 
        'Category 2', 
        'Certified genuine John Deere 5045 D (Utility Row Crop (45 HP)). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1250.00, 
        7750.00, 
        28125.00, 
        3750.00, 
        710000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'John Deere', 
        'Utility Row Crop (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Sangli', 
        1600, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 710000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 557, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 757);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Massey Ferguson 241 DI Maha Shakti')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Massey Ferguson 241 DI Maha Shakti', 
        'Massey Ferguson', 
        '241 DI Maha Shakti', 
        2024, 
        'TRACTORS', 
        'IND-MAS-TRA-1020', 
        42, 
        580, 
        '2WD', 
        'DIESEL', 
        'Sliding Mesh / Constant Mesh 8F+2R', 
        35.0, 
        'Live PTO 540 RPM', 
        'Category 2', 
        'Certified genuine Massey Ferguson 241 DI Maha Shakti (Maha Shakti (42 HP)). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        645000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Massey Ferguson', 
        'Maha Shakti (42 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (TAFE - Massey Ferguson)', 
        'https://www.tafe.com', 
        '05 Sep 2026', 
        'Satara', 
        1700, 
        47, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (TAFE - Massey Ferguson)', 'https://www.tafe.com', 645000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 580, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 780);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Massey Ferguson 1035 DI Planetary Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Massey Ferguson 1035 DI Planetary Plus', 
        'Massey Ferguson', 
        '1035 DI Planetary Plus', 
        2024, 
        'TRACTORS', 
        'IND-MAS-TRA-1021', 
        40, 
        603, 
        '2WD', 
        'DIESEL', 
        'Sliding Mesh 8F+2R', 
        35.0, 
        'Live PTO 540 RPM', 
        'Category 2', 
        'Certified genuine Massey Ferguson 1035 DI Planetary Plus (Planetary Plus (40 HP)). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 
        1000.00, 
        6200.00, 
        22500.00, 
        3000.00, 
        595000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Massey Ferguson', 
        'Planetary Plus (40 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (TAFE - Massey Ferguson)', 
        'https://www.tafe.com', 
        '05 Sep 2026', 
        'Akola', 
        1100, 
        47, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (TAFE - Massey Ferguson)', 'https://www.tafe.com', 595000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 603, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 803);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Massey Ferguson 9500 Super Shuttle')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Massey Ferguson 9500 Super Shuttle', 
        'Massey Ferguson', 
        '9500 Super Shuttle', 
        2024, 
        'TRACTORS', 
        'IND-MAS-TRA-1022', 
        58, 
        626, 
        '4WD', 
        'DIESEL', 
        'Comfimesh with Shuttle 8F+8R', 
        35.0, 
        '540 & Q-PTO Dual', 
        'Category 2', 
        'Certified genuine Massey Ferguson 9500 Super Shuttle (Heavy Haulage 4WD (58 HP)). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1800.00, 
        11160.00, 
        40500.00, 
        5400.00, 
        950000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Massey Ferguson', 
        'Heavy Haulage 4WD (58 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (TAFE - Massey Ferguson)', 
        'https://www.tafe.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        2050, 
        60, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (TAFE - Massey Ferguson)', 'https://www.tafe.com', 950000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 626, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 826);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Massey Ferguson 7250 PowerUp')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Massey Ferguson 7250 PowerUp', 
        'Massey Ferguson', 
        '7250 PowerUp', 
        2024, 
        'TRACTORS', 
        'IND-MAS-TRA-1023', 
        50, 
        649, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        'Live PTO 540 RPM', 
        'Category 2', 
        'Certified genuine Massey Ferguson 7250 PowerUp (PowerUp Series (50 HP)). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 
        1300.00, 
        8060.00, 
        29250.00, 
        3900.00, 
        755000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Massey Ferguson', 
        'PowerUp Series (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (TAFE - Massey Ferguson)', 
        'https://www.tafe.com', 
        '05 Sep 2026', 
        'Nanded', 
        1800, 
        60, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (TAFE - Massey Ferguson)', 'https://www.tafe.com', 755000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 649, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 849);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'New Holland 3630 TX Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'New Holland 3630 TX Plus', 
        'New Holland', 
        '3630 TX Plus', 
        2024, 
        'TRACTORS', 
        'IND-NEW-TRA-1024', 
        55, 
        672, 
        '4WD', 
        'DIESEL', 
        'Constant Mesh / Synchro 8F+2R / 12F+3R', 
        35.0, 
        '540 & Ground Speed PTO', 
        'Category 2', 
        'Certified genuine New Holland 3630 TX Plus (TX Plus 4WD (55 HP)). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1650.00, 
        10230.00, 
        37125.00, 
        4950.00, 
        895000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'New Holland', 
        'TX Plus 4WD (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (New Holland India)', 
        'https://www.newholland.com/in', 
        '05 Sep 2026', 
        'Nagpur', 
        2000, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (New Holland India)', 'https://www.newholland.com/in', 895000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 672, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 872);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'New Holland 3230 NX')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'New Holland 3230 NX', 
        'New Holland', 
        '3230 NX', 
        2024, 
        'TRACTORS', 
        'IND-NEW-TRA-1025', 
        42, 
        695, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine New Holland 3230 NX (Smart Tillage (42 HP)). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1050.00, 
        6510.00, 
        23625.00, 
        3150.00, 
        625000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'New Holland', 
        'Smart Tillage (42 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (New Holland India)', 
        'https://www.newholland.com/in', 
        '05 Sep 2026', 
        'Pune', 
        1500, 
        42, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (New Holland India)', 'https://www.newholland.com/in', 625000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 695, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 895);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'New Holland 3600-2 TX All Rounder')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'New Holland 3600-2 TX All Rounder', 
        'New Holland', 
        '3600-2 TX All Rounder', 
        2024, 
        'TRACTORS', 
        'IND-NEW-TRA-1026', 
        50, 
        718, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM & Reverse PTO', 
        'Category 2', 
        'Certified genuine New Holland 3600-2 TX All Rounder (Heritage Edition (50 HP)). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1250.00, 
        7750.00, 
        28125.00, 
        3750.00, 
        735000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'New Holland', 
        'Heritage Edition (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (New Holland India)', 
        'https://www.newholland.com/in', 
        '05 Sep 2026', 
        'Nashik', 
        1800, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (New Holland India)', 'https://www.newholland.com/in', 735000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 718, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 918);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'New Holland Excel 4710')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'New Holland Excel 4710', 
        'New Holland', 
        'Excel 4710', 
        2024, 
        'TRACTORS', 
        'IND-NEW-TRA-1027', 
        47, 
        741, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 8F+8R Synchro Shuttle', 
        35.0, 
        '540 & 540E Dual Speed', 
        'Category 2', 
        'Certified genuine New Holland Excel 4710 (Paddy Specialist 4WD (47 HP)). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1450.00, 
        8990.00, 
        32625.00, 
        4350.00, 
        795000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'New Holland', 
        'Paddy Specialist 4WD (47 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (New Holland India)', 
        'https://www.newholland.com/in', 
        '05 Sep 2026', 
        'Kolhapur', 
        1800, 
        55, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (New Holland India)', 'https://www.newholland.com/in', 795000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 741, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 941);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kubota MU4501')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kubota MU4501', 
        'Kubota', 
        'MU4501', 
        2024, 
        'TRACTORS', 
        'IND-KUB-TRA-1028', 
        45, 
        764, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 8F+4R', 
        35.0, 
        'Dual Speed 540 & 750 RPM', 
        'Category 2', 
        'Certified genuine Kubota MU4501 (Japanese E-CDIS (45 HP)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        1400.00, 
        8680.00, 
        31500.00, 
        4200.00, 
        825000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Kubota', 
        'Japanese E-CDIS (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kubota Agricultural Machinery India)', 
        'https://www.kubota.co.in', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1640, 
        60, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kubota Agricultural Machinery India)', 'https://www.kubota.co.in', 825000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 764, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 964);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kubota MU5502')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kubota MU5502', 
        'Kubota', 
        'MU5502', 
        2024, 
        'TRACTORS', 
        'IND-KUB-TRA-1029', 
        55, 
        787, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 12F+4R with Shuttle', 
        35.0, 
        '540 & 750 Dual PTO', 
        'Category 2', 
        'Certified genuine Kubota MU5502 (Multi-Valve High Torque (55 HP)). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1800.00, 
        11160.00, 
        40500.00, 
        5400.00, 
        995000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Kubota', 
        'Multi-Valve High Torque (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kubota Agricultural Machinery India)', 
        'https://www.kubota.co.in', 
        '05 Sep 2026', 
        'Amravati', 
        2100, 
        65, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kubota Agricultural Machinery India)', 'https://www.kubota.co.in', 995000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 787, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 987);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kubota L4508')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kubota L4508', 
        'Kubota', 
        'L4508', 
        2024, 
        'TRACTORS', 
        'IND-KUB-TRA-1030', 
        45, 
        810, 
        '4WD', 
        'DIESEL', 
        'Integral Shuttle 8F+4R', 
        35.0, 
        '540 & 750 RPM', 
        'Category 2', 
        'Certified genuine Kubota L4508 (Rice Paddy 4WD (45 HP)). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        1300.00, 
        8060.00, 
        29250.00, 
        3900.00, 
        780000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Kubota', 
        'Rice Paddy 4WD (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kubota Agricultural Machinery India)', 
        'https://www.kubota.co.in', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1500, 
        42, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kubota Agricultural Machinery India)', 'https://www.kubota.co.in', 780000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 810, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 1010);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Eicher 380 Super DI')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Eicher 380 Super DI', 
        'Eicher', 
        '380 Super DI', 
        2024, 
        'TRACTORS', 
        'IND-EIC-TRA-1031', 
        40, 
        833, 
        '2WD', 
        'DIESEL', 
        'Combination Constant / Sliding 8F+2R', 
        35.0, 
        'Live PTO 540 RPM', 
        'Category 2', 
        'Certified genuine Eicher 380 Super DI (Air-Cooled Mileager (40 HP)). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        595000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Eicher', 
        'Air-Cooled Mileager (40 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Eicher Tractors)', 
        'https://www.eichertractors.in', 
        '05 Sep 2026', 
        'Sangli', 
        1650, 
        45, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Eicher Tractors)', 'https://www.eichertractors.in', 595000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 833, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 1033);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Eicher 485 Super Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Eicher 485 Super Plus', 
        'Eicher', 
        '485 Super Plus', 
        2024, 
        'TRACTORS', 
        'IND-EIC-TRA-1032', 
        45, 
        856, 
        '2WD', 
        'DIESEL', 
        'Partial Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM @ 1788 ERPM', 
        'Category 2', 
        'Certified genuine Eicher 485 Super Plus (Heavy Tiller (45 HP)). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        665000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Eicher', 
        'Heavy Tiller (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Eicher Tractors)', 
        'https://www.eichertractors.in', 
        '05 Sep 2026', 
        'Satara', 
        1650, 
        48, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Eicher Tractors)', 'https://www.eichertractors.in', 665000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 856, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 1056);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Eicher 557 4WD')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Eicher 557 4WD', 
        'Eicher', 
        '557 4WD', 
        2024, 
        'TRACTORS', 
        'IND-EIC-TRA-1033', 
        50, 
        879, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 8F+2R', 
        35.0, 
        '540 Multi-Speed', 
        'Category 2', 
        'Certified genuine Eicher 557 4WD (High Clearance 4WD (50 HP)). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 
        1400.00, 
        8680.00, 
        31500.00, 
        4200.00, 
        790000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Eicher', 
        'High Clearance 4WD (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Eicher Tractors)', 
        'https://www.eichertractors.in', 
        '05 Sep 2026', 
        'Akola', 
        2100, 
        50, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1527842891421-42eec6e703ea?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Eicher Tractors)', 'https://www.eichertractors.in', 790000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 879, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 1079);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Powertrac Euro 50')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Powertrac Euro 50', 
        'Powertrac', 
        'Euro 50', 
        2024, 
        'TRACTORS', 
        'IND-POW-TRA-1034', 
        50, 
        902, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 & Multi-Speed Reverse', 
        'Category 2', 
        'Certified genuine Powertrac Euro 50 (Diesel Saver Plus (50 HP)). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1200.00, 
        7440.00, 
        27000.00, 
        3600.00, 
        715000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Powertrac', 
        'Diesel Saver Plus (50 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Escorts Kubota / Powertrac)', 
        'https://www.escortsgroup.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        2000, 
        50, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Escorts Kubota / Powertrac)', 'https://www.escortsgroup.com', 715000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 902, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 1102);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Powertrac 439 Plus PowerPlus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Powertrac 439 Plus PowerPlus', 
        'Powertrac', 
        '439 Plus PowerPlus', 
        2024, 
        'TRACTORS', 
        'IND-POW-TRA-1035', 
        41, 
        925, 
        '2WD', 
        'DIESEL', 
        'Center Shift 8F+2R', 
        35.0, 
        '540 RPM @ 1810 ERPM', 
        'Category 2', 
        'Certified genuine Powertrac 439 Plus PowerPlus (Haulage Master (41 HP)). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1000.00, 
        6200.00, 
        22500.00, 
        3000.00, 
        610000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Powertrac', 
        'Haulage Master (41 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Escorts Kubota / Powertrac)', 
        'https://www.escortsgroup.com', 
        '05 Sep 2026', 
        'Nanded', 
        1600, 
        50, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Escorts Kubota / Powertrac)', 'https://www.escortsgroup.com', 610000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 925, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 1125);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Powertrac Euro 45 Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Powertrac Euro 45 Plus', 
        'Powertrac', 
        'Euro 45 Plus', 
        2024, 
        'TRACTORS', 
        'IND-POW-TRA-1036', 
        45, 
        948, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Powertrac Euro 45 Plus (Euro Series (45 HP)). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        655000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Powertrac', 
        'Euro Series (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Escorts Kubota / Powertrac)', 
        'https://www.escortsgroup.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1600, 
        50, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Escorts Kubota / Powertrac)', 'https://www.escortsgroup.com', 655000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 948, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 1148);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Farmtrac 60 Powermaxx')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Farmtrac 60 Powermaxx', 
        'Farmtrac', 
        '60 Powermaxx', 
        2024, 
        'TRACTORS', 
        'IND-FAR-TRA-1037', 
        55, 
        121, 
        '4WD', 
        'DIESEL', 
        'Constant Mesh T20 16F+4R', 
        35.0, 
        '540 & MRPTO Dual', 
        'Category 2', 
        'Certified genuine Farmtrac 60 Powermaxx (T20 Valuemaster (55 HP)). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 
        1650.00, 
        10230.00, 
        37125.00, 
        4950.00, 
        880000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Farmtrac', 
        'T20 Valuemaster (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Farmtrac India)', 
        'https://www.escortsgroup.com', 
        '05 Sep 2026', 
        'Pune', 
        2500, 
        60, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Farmtrac India)', 'https://www.escortsgroup.com', 880000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 121, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 321);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Farmtrac 45 Classic')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Farmtrac 45 Classic', 
        'Farmtrac', 
        '45 Classic', 
        2024, 
        'TRACTORS', 
        'IND-FAR-TRA-1038', 
        45, 
        144, 
        '2WD', 
        'DIESEL', 
        'Constant Mesh 8F+2R', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Farmtrac 45 Classic (Heritage Hauler (45 HP)). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        660000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Farmtrac', 
        'Heritage Hauler (45 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Farmtrac India)', 
        'https://www.escortsgroup.com', 
        '05 Sep 2026', 
        'Nashik', 
        1800, 
        50, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Farmtrac India)', 'https://www.escortsgroup.com', 660000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 144, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 344);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'VST Shakti 932 DI')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'VST Shakti 932 DI', 
        'VST', 
        'Shakti 932 DI', 
        2024, 
        'TRACTORS', 
        'IND-VST-TRA-1039', 
        32, 
        167, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 9F+3R', 
        35.0, 
        '540 & 750 Dual PTO', 
        'Category 2', 
        'Certified genuine VST Shakti 932 DI (Compact High Torque (32 HP)). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        540000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'VST', 
        'Compact High Torque (32 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (VST Tillers Tractors Ltd)', 
        'https://www.vsttractors.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        1250, 
        35, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (VST Tillers Tractors Ltd)', 'https://www.vsttractors.com', 540000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 167, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 367);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Deutz-Fahr Agrolux 55')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Deutz-Fahr Agrolux 55', 
        'Deutz-Fahr', 
        'Agrolux 55', 
        2024, 
        'TRACTORS', 
        'IND-DEU-TRA-1040', 
        55, 
        190, 
        '4WD', 
        'DIESEL', 
        'Synchromesh 12F+3R', 
        35.0, 
        'Independent 540 & 1000', 
        'Category 2', 
        'Certified genuine Deutz-Fahr Agrolux 55 (European Technology 4WD (55 HP)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        1700.00, 
        10540.00, 
        38250.00, 
        5100.00, 
        920000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Deutz-Fahr', 
        'European Technology 4WD (55 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (SDF Deutz-Fahr India)', 
        'https://www.deutz-fahr.com/en-in', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        2200, 
        68, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (SDF Deutz-Fahr India)', 'https://www.deutz-fahr.com/en-in', 920000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 190, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 390);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Deutz-Fahr 4042 E')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Deutz-Fahr 4042 E', 
        'Deutz-Fahr', 
        '4042 E', 
        2024, 
        'TRACTORS', 
        'IND-DEU-TRA-1041', 
        42, 
        213, 
        '2WD', 
        'DIESEL', 
        'Synchromesh 8F+2R', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Deutz-Fahr 4042 E (Agrolux Series (42 HP)). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 
        1050.00, 
        6510.00, 
        23625.00, 
        3150.00, 
        630000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Deutz-Fahr', 
        'Agrolux Series (42 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (SDF Deutz-Fahr India)', 
        'https://www.deutz-fahr.com/en-in', 
        '05 Sep 2026', 
        'Amravati', 
        1600, 
        55, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (SDF Deutz-Fahr India)', 'https://www.deutz-fahr.com/en-in', 630000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 213, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 413);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Claas Crop Tiger 40 Terra Trac')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Claas Crop Tiger 40 Terra Trac', 
        'Claas', 
        'Crop Tiger 40 Terra Trac', 
        2024, 
        'HARVESTERS', 
        'IND-CLA-HAR-1042', 
        76, 
        236, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Claas Crop Tiger 40 Terra Trac (Paddy & Grain Rubber Track). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 
        3800.00, 
        23560.00, 
        85500.00, 
        11400.00, 
        2450000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Claas', 
        'Paddy & Grain Rubber Track', 
        'INR', 
        'FIXED', 
        'Official Claas India Authorized Dealership', 
        'https://www.claas.co.in', 
        '05 Sep 2026', 
        'Ahmednagar', 
        2660, 
        91, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Claas India Authorized Dealership', 'https://www.claas.co.in', 2450000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 236, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 436);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Preet 987 Combine Harvester')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Preet 987 Combine Harvester', 
        'Preet', 
        '987 Combine Harvester', 
        2024, 
        'HARVESTERS', 
        'IND-PRE-HAR-1043', 
        101, 
        259, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Preet 987 Combine Harvester (Self-Propelled 14-Foot Cutter Bar). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        4200.00, 
        26040.00, 
        94500.00, 
        12600.00, 
        2280000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Preet', 
        'Self-Propelled 14-Foot Cutter Bar', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Preet Agro)', 
        'https://www.preet.co', 
        '05 Sep 2026', 
        'Sangli', 
        3535, 
        121, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Preet Agro)', 'https://www.preet.co', 2280000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 259, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 459);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere W70 Grain Harvester')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere W70 Grain Harvester', 
        'John Deere', 
        'W70 Grain Harvester', 
        2024, 
        'HARVESTERS', 
        'IND-JOH-HAR-1044', 
        100, 
        282, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine John Deere W70 Grain Harvester (SynchroSmart 4-Speed Combine). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 
        4500.00, 
        27900.00, 
        101250.00, 
        13500.00, 
        2750000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'John Deere', 
        'SynchroSmart 4-Speed Combine', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Satara', 
        3500, 
        120, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 2750000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 282, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 482);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'New Holland TC5.30 Multicrop')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'New Holland TC5.30 Multicrop', 
        'New Holland', 
        'TC5.30 Multicrop', 
        2024, 
        'HARVESTERS', 
        'IND-NEW-HAR-1045', 
        130, 
        305, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine New Holland TC5.30 Multicrop (Flagship Combine with Straw Chopper). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        5200.00, 
        32240.00, 
        117000.00, 
        15600.00, 
        3100000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'New Holland', 
        'Flagship Combine with Straw Chopper', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (New Holland India)', 
        'https://www.newholland.com/in', 
        '05 Sep 2026', 
        'Akola', 
        4550, 
        156, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (New Holland India)', 'https://www.newholland.com/in', 3100000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 305, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 505);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kartar 4000 Self-Propelled')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kartar 4000 Self-Propelled', 
        'Kartar', 
        '4000 Self-Propelled', 
        2024, 
        'HARVESTERS', 
        'IND-KAR-HAR-1046', 
        101, 
        328, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kartar 4000 Self-Propelled (Multi-Crop Grain Harvester). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 
        4100.00, 
        25420.00, 
        92250.00, 
        12300.00, 
        2350000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Kartar', 
        'Multi-Crop Grain Harvester', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kartar Agro)', 
        'https://www.kartaragro.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        3535, 
        121, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kartar Agro)', 'https://www.kartaragro.com', 2350000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 328, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 528);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Dashmesh 9100 Combine')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Dashmesh 9100 Combine', 
        'Dashmesh', 
        '9100 Combine', 
        2024, 
        'HARVESTERS', 
        'IND-DAS-HAR-1047', 
        101, 
        351, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Dashmesh 9100 Combine (Heavy Straw Separator Combine). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        4000.00, 
        24800.00, 
        90000.00, 
        12000.00, 
        2200000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Dashmesh', 
        'Heavy Straw Separator Combine', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Dasmesh Mechanical Works)', 
        'https://www.dasmesh.com', 
        '05 Sep 2026', 
        'Nanded', 
        3535, 
        121, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Dasmesh Mechanical Works)', 'https://www.dasmesh.com', 2200000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 351, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 551);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Malkit 897 Straw Combine')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Malkit 897 Straw Combine', 
        'Malkit', 
        '897 Straw Combine', 
        2024, 
        'HARVESTERS', 
        'IND-MAL-HAR-1048', 
        101, 
        374, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Malkit 897 Straw Combine (Wheat & Paddy Combine). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 
        3900.00, 
        24180.00, 
        87750.00, 
        11700.00, 
        2150000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Malkit', 
        'Wheat & Paddy Combine', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Malkit Agro Punjab)', 
        'https://www.malkitagro.com', 
        '05 Sep 2026', 
        'Nagpur', 
        3535, 
        121, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Malkit Agro Punjab)', 'https://www.malkitagro.com', 2150000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 374, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 574);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Standard 412 Track Harvester')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Standard 412 Track Harvester', 
        'Standard', 
        '412 Track Harvester', 
        2024, 
        'HARVESTERS', 
        'IND-STA-HAR-1049', 
        76, 
        397, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Standard 412 Track Harvester (Wet Paddy Track Combine). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        3700.00, 
        22940.00, 
        83250.00, 
        11100.00, 
        1950000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Standard', 
        'Wet Paddy Track Combine', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Standard Combine)', 
        'https://www.standardcombine.com', 
        '05 Sep 2026', 
        'Pune', 
        2660, 
        91, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Standard Combine)', 'https://www.standardcombine.com', 1950000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 397, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 597);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Semi Champion Plus 7ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Semi Champion Plus 7ft', 
        'Shaktiman', 
        'Semi Champion Plus 7ft', 
        2024, 
        'ROTAVATORS', 
        'IND-SHA-ROT-1050', 
        50, 
        420, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Semi Champion Plus 7ft (Multi-Speed Gearbox 48 Blades). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        650.00, 
        4030.00, 
        14625.00, 
        1950.00, 
        132000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Shaktiman', 
        'Multi-Speed Gearbox 48 Blades', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro / Tirth Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Nashik', 
        1750, 
        60, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro / Tirth Agro)', 'https://www.shaktimanagro.com', 132000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 420, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 620);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Regular Multi Speed 6ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Regular Multi Speed 6ft', 
        'Fieldking', 
        'Regular Multi Speed 6ft', 
        2024, 
        'ROTAVATORS', 
        'IND-FIE-ROT-1051', 
        45, 
        443, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Regular Multi Speed 6ft (L-Type Blades Side Gear Drive). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        600.00, 
        3720.00, 
        13500.00, 
        1800.00, 
        118000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Fieldking', 
        'L-Type Blades Side Gear Drive', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        1575, 
        54, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 118000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 443, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 643);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Gyrovator ZLX 7ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Gyrovator ZLX 7ft', 
        'Mahindra', 
        'Gyrovator ZLX 7ft', 
        2024, 
        'ROTAVATORS', 
        'IND-MAH-ROT-1052', 
        55, 
        466, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Gyrovator ZLX 7ft (Heavy Soil Rotor (48 Blades)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        700.00, 
        4340.00, 
        15750.00, 
        2100.00, 
        138000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Mahindra', 
        'Heavy Soil Rotor (48 Blades)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1925, 
        66, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 138000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 466, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 666);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Sonalika Multi Speed 6ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Sonalika Multi Speed 6ft', 
        'Sonalika', 
        'Multi Speed 6ft', 
        2024, 
        'ROTAVATORS', 
        'IND-SON-ROT-1053', 
        45, 
        489, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Sonalika Multi Speed 6ft (Boron Steel Blades High Torque). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        620.00, 
        3844.00, 
        13950.00, 
        1860.00, 
        124000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Sonalika', 
        'Boron Steel Blades High Torque', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Sonalika Tractors)', 
        'https://www.sonalika.com', 
        '05 Sep 2026', 
        'Amravati', 
        1575, 
        54, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Sonalika Tractors)', 'https://www.sonalika.com', 124000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 489, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 689);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Maschio Gaspardo Virat 185')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Maschio Gaspardo Virat 185', 
        'Maschio Gaspardo', 
        'Virat 185', 
        2024, 
        'ROTAVATORS', 
        'IND-MAS-ROT-1054', 
        50, 
        512, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Maschio Gaspardo Virat 185 (Italian High-Precision Tiller 6ft). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        750.00, 
        4650.00, 
        16875.00, 
        2250.00, 
        145000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Maschio Gaspardo', 
        'Italian High-Precision Tiller 6ft', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Maschio Gaspardo India)', 
        'https://www.maschio.com/en-in', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1750, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Maschio Gaspardo India)', 'https://www.maschio.com/en-in', 145000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 512, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 712);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Robust Multi Speed 7ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Robust Multi Speed 7ft', 
        'Landforce', 
        'Robust Multi Speed 7ft', 
        2024, 
        'ROTAVATORS', 
        'IND-LAN-ROT-1055', 
        50, 
        535, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Robust Multi Speed 7ft (Helical Blade Rotor Drive). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        650.00, 
        4030.00, 
        14625.00, 
        1950.00, 
        128000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Landforce', 
        'Helical Blade Rotor Drive', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Sangli', 
        1750, 
        60, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 128000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 535, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 735);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Bull Agro Rotary Tiller 5ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Bull Agro Rotary Tiller 5ft', 
        'Bull Agro', 
        'Rotary Tiller 5ft', 
        2024, 
        'ROTAVATORS', 
        'IND-BUL-ROT-1056', 
        40, 
        558, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Bull Agro Rotary Tiller 5ft (Paddy Specialist Waterproof Rotor). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        550.00, 
        3410.00, 
        12375.00, 
        1650.00, 
        108000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Bull Agro', 
        'Paddy Specialist Waterproof Rotor', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Bull Agro Implements)', 
        'https://www.bullagro.com', 
        '05 Sep 2026', 
        'Satara', 
        1400, 
        48, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Bull Agro Implements)', 'https://www.bullagro.com', 108000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 558, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 758);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere RT1007 Rotary Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere RT1007 Rotary Tiller', 
        'John Deere', 
        'RT1007 Rotary Tiller', 
        2024, 
        'ROTAVATORS', 
        'IND-JOH-ROT-1057', 
        55, 
        581, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine John Deere RT1007 Rotary Tiller (Grease Lubricated Side Gear 7ft). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        720.00, 
        4464.00, 
        16200.00, 
        2160.00, 
        142000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'John Deere', 
        'Grease Lubricated Side Gear 7ft', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Akola', 
        1925, 
        66, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 142000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 581, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 781);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Rigid Cultivator 9-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Rigid Cultivator 9-Tyne', 
        'Fieldking', 
        'Rigid Cultivator 9-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-FIE-CUL-1058', 
        40, 
        604, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Rigid Cultivator 9-Tyne (Heavy Tubular Frame (9 Tynes)). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        450.00, 
        2790.00, 
        10125.00, 
        1350.00, 
        42000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Fieldking', 
        'Heavy Tubular Frame (9 Tynes)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        1400, 
        48, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 42000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 604, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 804);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Universal Spring Loaded 9-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Universal Spring Loaded 9-Tyne', 
        'Universal', 
        'Spring Loaded 9-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-UNI-CUL-1059', 
        45, 
        627, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Universal Spring Loaded 9-Tyne (Double Spring Heavy Soil Tiller). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        480.00, 
        2976.00, 
        10800.00, 
        1440.00, 
        46000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Universal', 
        'Double Spring Heavy Soil Tiller', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Price (Universal Agro)', 
        'https://www.universalimplements.com', 
        '05 Sep 2026', 
        'Nanded', 
        1575, 
        54, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Price (Universal Agro)', 'https://www.universalimplements.com', 46000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 627, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 827);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Heavy Duty 11-Tyne Cultivator')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Heavy Duty 11-Tyne Cultivator', 
        'Mahindra', 
        'Heavy Duty 11-Tyne Cultivator', 
        2024, 
        'CULTIVATORS', 
        'IND-MAH-CUL-1060', 
        55, 
        650, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Heavy Duty 11-Tyne Cultivator (Reversible Shovel Spring Tiller). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        520.00, 
        3224.00, 
        11700.00, 
        1560.00, 
        54000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Mahindra', 
        'Reversible Shovel Spring Tiller', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1925, 
        66, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 54000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 650, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 850);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Rigid Tiller 9-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Rigid Tiller 9-Tyne', 
        'Shaktiman', 
        'Rigid Tiller 9-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-SHA-CUL-1061', 
        40, 
        673, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Rigid Tiller 9-Tyne (Hardened EN9 Shovel Points). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        460.00, 
        2852.00, 
        10350.00, 
        1380.00, 
        44000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Shaktiman', 
        'Hardened EN9 Shovel Points', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Pune', 
        1400, 
        48, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 44000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 673, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 873);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Khedut Duckfoot Cultivator 7-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Khedut Duckfoot Cultivator 7-Tyne', 
        'Khedut', 
        'Duckfoot Cultivator 7-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-KHE-CUL-1062', 
        35, 
        696, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Khedut Duckfoot Cultivator 7-Tyne (Weeding Specialist Sweep Wings). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        420.00, 
        2604.00, 
        9450.00, 
        1260.00, 
        38000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Khedut', 
        'Weeding Specialist Sweep Wings', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Khedut Agro)', 
        'https://www.khedutagro.com', 
        '05 Sep 2026', 
        'Nashik', 
        1225, 
        42, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Khedut Agro)', 'https://www.khedutagro.com', 38000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 696, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 896);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Heavy Duty Spring Loaded 11-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Heavy Duty Spring Loaded 11-Tyne', 
        'Landforce', 
        'Heavy Duty Spring Loaded 11-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-LAN-CUL-1063', 
        50, 
        719, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Heavy Duty Spring Loaded 11-Tyne (Dual Spring Auto Reset Tynes). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        500.00, 
        3100.00, 
        11250.00, 
        1500.00, 
        51000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Landforce', 
        'Dual Spring Auto Reset Tynes', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Kolhapur', 
        1750, 
        60, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 51000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 719, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 919);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Agrostar Power Tine 9-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Agrostar Power Tine 9-Tyne', 
        'Agrostar', 
        'Power Tine 9-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-AGR-CUL-1064', 
        40, 
        742, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Agrostar Power Tine 9-Tyne (Cotton & Soybean Tiller). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        440.00, 
        2728.00, 
        9900.00, 
        1320.00, 
        41000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Agrostar', 
        'Cotton & Soybean Tiller', 
        'INR', 
        'FIXED', 
        'Verified Agri-Marketplace Price', 
        'https://www.agrostar.in', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1400, 
        48, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Verified Agri-Marketplace Price', 'https://www.agrostar.in', 41000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 742, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 942);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Captain Compact Mini Cultivator 5-Tyne')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Captain Compact Mini Cultivator 5-Tyne', 
        'Captain', 
        'Compact Mini Cultivator 5-Tyne', 
        2024, 
        'CULTIVATORS', 
        'IND-CAP-CUL-1065', 
        25, 
        765, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Captain Compact Mini Cultivator 5-Tyne (Mini Tractor Orchard Specialist). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        350.00, 
        2170.00, 
        7875.00, 
        1050.00, 
        28000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Captain', 
        'Mini Tractor Orchard Specialist', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Captain Tractors)', 
        'https://www.captaintractors.com', 
        '05 Sep 2026', 
        'Amravati', 
        875, 
        30, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Captain Tractors)', 'https://www.captaintractors.com', 28000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 765, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 965);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Dasmesh Multi Crop Zero Till Seeder')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Dasmesh Multi Crop Zero Till Seeder', 
        'Dasmesh', 
        'Multi Crop Zero Till Seeder', 
        2024, 
        'SEEDERS', 
        'IND-DAS-SEE-1066', 
        45, 
        788, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Dasmesh Multi Crop Zero Till Seeder (9-Row Zero-Till Seed Cum Fertilizer Drill). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 
        750.00, 
        4650.00, 
        16875.00, 
        2250.00, 
        78000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Dasmesh', 
        '9-Row Zero-Till Seed Cum Fertilizer Drill', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Dasmesh Mechanical Works)', 
        'https://www.dasmesh.com', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1575, 
        54, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Dasmesh Mechanical Works)', 'https://www.dasmesh.com', 78000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 788, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 988);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Pneumatic Planter 4-Row')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Pneumatic Planter 4-Row', 
        'Shaktiman', 
        'Pneumatic Planter 4-Row', 
        2024, 
        'SEEDERS', 
        'IND-SHA-SEE-1067', 
        55, 
        811, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Pneumatic Planter 4-Row (Vacuum Precision Planter (Corn/Cotton)). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 
        1200.00, 
        7440.00, 
        27000.00, 
        3600.00, 
        285000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Shaktiman', 
        'Vacuum Precision Planter (Corn/Cotton)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Sangli', 
        1925, 
        66, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 285000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 811, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 1011);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'National Happy Seeder 10-Row')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'National Happy Seeder 10-Row', 
        'National', 
        'Happy Seeder 10-Row', 
        2024, 
        'SEEDERS', 
        'IND-NAT-SEE-1068', 
        55, 
        834, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine National Happy Seeder 10-Row (Paddy Residue Direct Seeding). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        165000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'National', 
        'Paddy Residue Direct Seeding', 
        'INR', 
        'FIXED', 
        'Government Approved Subsidy Catalog', 
        'https://www.agrimachinery.nic.in', 
        '05 Sep 2026', 
        'Satara', 
        1925, 
        66, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Government Approved Subsidy Catalog', 'https://www.agrimachinery.nic.in', 165000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 834, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 1034);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Zero Till Seed Cum Fertilizer Drill')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Zero Till Seed Cum Fertilizer Drill', 
        'Fieldking', 
        'Zero Till Seed Cum Fertilizer Drill', 
        2024, 
        'SEEDERS', 
        'IND-FIE-SEE-1069', 
        45, 
        857, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Zero Till Seed Cum Fertilizer Drill (11-Row Fluted Roller Metering). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 
        700.00, 
        4340.00, 
        15750.00, 
        2100.00, 
        82000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Fieldking', 
        '11-Row Fluted Roller Metering', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Akola', 
        1575, 
        54, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 82000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 857, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 1057);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Multi Crop Planter 6-Row')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Multi Crop Planter 6-Row', 
        'Landforce', 
        'Multi Crop Planter 6-Row', 
        2024, 
        'SEEDERS', 
        'IND-LAN-SEE-1070', 
        40, 
        880, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Multi Crop Planter 6-Row (Inclined Plate Seed Metering). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 
        800.00, 
        4960.00, 
        18000.00, 
        2400.00, 
        110000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Landforce', 
        'Inclined Plate Seed Metering', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Jalgaon', 
        1400, 
        48, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 110000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 880, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 1080);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Roto Seed Drill 7ft')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Roto Seed Drill 7ft', 
        'Mahindra', 
        'Roto Seed Drill 7ft', 
        2024, 
        'SEEDERS', 
        'IND-MAH-SEE-1071', 
        55, 
        903, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Roto Seed Drill 7ft (Combined Rotavator & Seed Planter). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        195000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Mahindra', 
        'Combined Rotavator & Seed Planter', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Nanded', 
        1925, 
        66, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 195000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 903, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 1103);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Guru Nanak Automatic Potato Planter')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Guru Nanak Automatic Potato Planter', 
        'Guru Nanak', 
        'Automatic Potato Planter', 
        2024, 
        'SEEDERS', 
        'IND-GUR-SEE-1072', 
        45, 
        926, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Guru Nanak Automatic Potato Planter (2-Row Automatic Cup Metering). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 
        900.00, 
        5580.00, 
        20250.00, 
        2700.00, 
        145000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Guru Nanak', 
        '2-Row Automatic Cup Metering', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Punjab Agro)', 
        'https://www.gurunanakagro.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1575, 
        54, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Punjab Agro)', 'https://www.gurunanakagro.com', 145000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 926, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 1126);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'John Deere SD1011 Multi-Crop Drill')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'John Deere SD1011 Multi-Crop Drill', 
        'John Deere', 
        'SD1011 Multi-Crop Drill', 
        2024, 
        'SEEDERS', 
        'IND-JOH-SEE-1073', 
        50, 
        949, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine John Deere SD1011 Multi-Crop Drill (11-Row High Precision Hopper). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        125000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'John Deere', 
        '11-Row High Precision Hopper', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (John Deere India)', 
        'https://www.deere.co.in', 
        '05 Sep 2026', 
        'Pune', 
        1750, 
        60, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1523741543316-beb7fc7023d8?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (John Deere India)', 'https://www.deere.co.in', 125000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 949, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 1149);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Lemken Opal 090 Hydraulic Reversible MB Plough')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Lemken Opal 090 Hydraulic Reversible MB Plough', 
        'Lemken', 
        'Opal 090 Hydraulic Reversible MB Plough', 
        2024, 
        'PLOUGHS', 
        'IND-LEM-PLO-1074', 
        50, 
        122, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Lemken Opal 090 Hydraulic Reversible MB Plough (2-Bottom Reversible Moldboard). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        750.00, 
        4650.00, 
        16875.00, 
        2250.00, 
        165000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Lemken', 
        '2-Bottom Reversible Moldboard', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Lemken India Agro)', 
        'https://www.lemken.com/en-in', 
        '05 Sep 2026', 
        'Nashik', 
        1750, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Lemken India Agro)', 'https://www.lemken.com/en-in', 165000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 122, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 322);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Hydraulic Reversible MB Plough')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Hydraulic Reversible MB Plough', 
        'Shaktiman', 
        'Hydraulic Reversible MB Plough', 
        2024, 
        'PLOUGHS', 
        'IND-SHA-PLO-1075', 
        60, 
        145, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Hydraulic Reversible MB Plough (3-Bottom Boron Steel Moldboard). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        195000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Shaktiman', 
        '3-Bottom Boron Steel Moldboard', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        2100, 
        72, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 195000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 145, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 345);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Heavy Duty Disc Plough 3-Bottom')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Heavy Duty Disc Plough 3-Bottom', 
        'Fieldking', 
        'Heavy Duty Disc Plough 3-Bottom', 
        2024, 
        'PLOUGHS', 
        'IND-FIE-PLO-1076', 
        50, 
        168, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Heavy Duty Disc Plough 3-Bottom (Taper Roller Bearing Hardened Discs). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        650.00, 
        4030.00, 
        14625.00, 
        1950.00, 
        68000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Fieldking', 
        'Taper Roller Bearing Hardened Discs', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1750, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 68000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 168, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 368);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra M-Hydraulic Reversible Plough 2-Furrow')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra M-Hydraulic Reversible Plough 2-Furrow', 
        'Mahindra', 
        'M-Hydraulic Reversible Plough 2-Furrow', 
        2024, 
        'PLOUGHS', 
        'IND-MAH-PLO-1077', 
        45, 
        191, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra M-Hydraulic Reversible Plough 2-Furrow (Quick Turnover Single Hose Cylinder). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        700.00, 
        4340.00, 
        15750.00, 
        2100.00, 
        155000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Mahindra', 
        'Quick Turnover Single Hose Cylinder', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Amravati', 
        1575, 
        54, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 155000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 191, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 391);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Universal Moldboard Plough 3-Bottom')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Universal Moldboard Plough 3-Bottom', 
        'Universal', 
        'Moldboard Plough 3-Bottom', 
        2024, 
        'PLOUGHS', 
        'IND-UNI-PLO-1078', 
        55, 
        214, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Universal Moldboard Plough 3-Bottom (High Carbon Steel Reversible Shear). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        580.00, 
        3596.00, 
        13050.00, 
        1740.00, 
        52000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Universal', 
        'High Carbon Steel Reversible Shear', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Price (Universal Agro)', 
        'https://www.universalimplements.com', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1925, 
        66, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Price (Universal Agro)', 'https://www.universalimplements.com', 52000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 214, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 414);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Mechanical Reversible MB Plough 2-Bottom')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Mechanical Reversible MB Plough 2-Bottom', 
        'Landforce', 
        'Mechanical Reversible MB Plough 2-Bottom', 
        2024, 
        'PLOUGHS', 
        'IND-LAN-PLO-1079', 
        45, 
        237, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Mechanical Reversible MB Plough 2-Bottom (Automatic Spring Trip Mechanism). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        620.00, 
        3844.00, 
        13950.00, 
        1860.00, 
        92000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Landforce', 
        'Automatic Spring Trip Mechanism', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Sangli', 
        1575, 
        54, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 92000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 237, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 437);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Khedut Heavy Disc Plough 4-Disc')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Khedut Heavy Disc Plough 4-Disc', 
        'Khedut', 
        'Heavy Disc Plough 4-Disc', 
        2024, 
        'PLOUGHS', 
        'IND-KHE-PLO-1080', 
        65, 
        260, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Khedut Heavy Disc Plough 4-Disc (26-inch Notched High Carbon Discs). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        720.00, 
        4464.00, 
        16200.00, 
        2160.00, 
        79000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Khedut', 
        '26-inch Notched High Carbon Discs', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Khedut Agro)', 
        'https://www.khedutagro.com', 
        '05 Sep 2026', 
        'Satara', 
        2275, 
        78, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Khedut Agro)', 'https://www.khedutagro.com', 79000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 260, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 460);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Captain Mini Tractor Reversible MB Plough')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Captain Mini Tractor Reversible MB Plough', 
        'Captain', 
        'Mini Tractor Reversible MB Plough', 
        2024, 
        'PLOUGHS', 
        'IND-CAP-PLO-1081', 
        25, 
        283, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Captain Mini Tractor Reversible MB Plough (1-Bottom Compact Orchard Plough). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        400.00, 
        2480.00, 
        9000.00, 
        1200.00, 
        34000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Captain', 
        '1-Bottom Compact Orchard Plough', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Captain Tractors)', 
        'https://www.captaintractors.com', 
        '05 Sep 2026', 
        'Akola', 
        875, 
        30, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Captain Tractors)', 'https://www.captaintractors.com', 34000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 283, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 483);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Dasmesh Multi Crop Thresher 3-Fan')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Dasmesh Multi Crop Thresher 3-Fan', 
        'Dasmesh', 
        'Multi Crop Thresher 3-Fan', 
        2024, 
        'THRESHERS', 
        'IND-DAS-THR-1082', 
        45, 
        306, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Dasmesh Multi Crop Thresher 3-Fan (Wheat, Soybean, Gram, Mustard Multi Thresher). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        900.00, 
        5580.00, 
        20250.00, 
        2700.00, 
        185000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Dasmesh', 
        'Wheat, Soybean, Gram, Mustard Multi Thresher', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Dasmesh Mechanical Works)', 
        'https://www.dasmesh.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        1575, 
        54, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Dasmesh Mechanical Works)', 'https://www.dasmesh.com', 185000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 306, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 506);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Punni Toka Model Paddy Thresher')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Punni Toka Model Paddy Thresher', 
        'Punni', 
        'Toka Model Paddy Thresher', 
        2024, 
        'THRESHERS', 
        'IND-PUN-THR-1083', 
        40, 
        329, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Punni Toka Model Paddy Thresher (Dual Blower Grain Recovery System). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        172000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Punni', 
        'Dual Blower Grain Recovery System', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Punni Agro)', 
        'https://www.punniagro.com', 
        '05 Sep 2026', 
        'Nanded', 
        1400, 
        48, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Punni Agro)', 'https://www.punniagro.com', 172000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 329, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 529);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Toka Haramba Thresher')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Toka Haramba Thresher', 
        'Landforce', 
        'Toka Haramba Thresher', 
        2024, 
        'THRESHERS', 
        'IND-LAN-THR-1084', 
        50, 
        352, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Toka Haramba Thresher (Safety Feeding Chute Multi Crop). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        198000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Landforce', 
        'Safety Feeding Chute Multi Crop', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Nagpur', 
        1750, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 198000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 352, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 552);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Multi Crop Thresher 4-Fan')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Multi Crop Thresher 4-Fan', 
        'Fieldking', 
        'Multi Crop Thresher 4-Fan', 
        2024, 
        'THRESHERS', 
        'IND-FIE-THR-1085', 
        50, 
        375, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Multi Crop Thresher 4-Fan (High Grain Output 1.5-2 Ton/Hr). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        920.00, 
        5704.00, 
        20700.00, 
        2760.00, 
        190000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Fieldking', 
        'High Grain Output 1.5-2 Ton/Hr', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Pune', 
        1750, 
        60, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 190000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 375, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 575);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Amar Automated Haramba Thresher')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Amar Automated Haramba Thresher', 
        'Amar', 
        'Automated Haramba Thresher', 
        2024, 
        'THRESHERS', 
        'IND-AMA-THR-1086', 
        45, 
        398, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Amar Automated Haramba Thresher (Double Elevator Grain Cleaner). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        880.00, 
        5456.00, 
        19800.00, 
        2640.00, 
        178000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Amar', 
        'Double Elevator Grain Cleaner', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Amar Agricultural Machinery)', 
        'https://www.amaragro.com', 
        '05 Sep 2026', 
        'Nashik', 
        1575, 
        54, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Amar Agricultural Machinery)', 'https://www.amaragro.com', 178000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 398, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 598);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kartar Multi Thresher 35 HP Plus')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kartar Multi Thresher 35 HP Plus', 
        'Kartar', 
        'Multi Thresher 35 HP Plus', 
        2024, 
        'THRESHERS', 
        'IND-KAR-THR-1087', 
        40, 
        421, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kartar Multi Thresher 35 HP Plus (Cereal & Pulse Specialist). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        840.00, 
        5208.00, 
        18900.00, 
        2520.00, 
        168000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Kartar', 
        'Cereal & Pulse Specialist', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kartar Agro)', 
        'https://www.kartaragro.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        1400, 
        48, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kartar Agro)', 'https://www.kartaragro.com', 168000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 421, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 621);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Kisan Thresher Super')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Kisan Thresher Super', 
        'Mahindra', 
        'Kisan Thresher Super', 
        2024, 
        'THRESHERS', 
        'IND-MAH-THR-1088', 
        45, 
        444, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Kisan Thresher Super (Low Husk Grain Discharge Chamber). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        900.00, 
        5580.00, 
        20250.00, 
        2700.00, 
        182000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Mahindra', 
        'Low Husk Grain Discharge Chamber', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1575, 
        54, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 182000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 444, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 644);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Vishwakarma Grain Thresher Turbo')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Vishwakarma Grain Thresher Turbo', 
        'Vishwakarma', 
        'Grain Thresher Turbo', 
        2024, 
        'THRESHERS', 
        'IND-VIS-THR-1089', 
        35, 
        467, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Vishwakarma Grain Thresher Turbo (Compact High-Efficiency Blower). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        800.00, 
        4960.00, 
        18000.00, 
        2400.00, 
        158000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Vishwakarma', 
        'Compact High-Efficiency Blower', 
        'INR', 
        'FIXED', 
        'Official Dealer Catalog', 
        'https://www.vishwakarmaagro.com', 
        '05 Sep 2026', 
        'Amravati', 
        1225, 
        42, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Catalog', 'https://www.vishwakarmaagro.com', 158000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 467, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 667);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'ASPEE HTP Tractor Mounted Sprayer 600L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'ASPEE HTP Tractor Mounted Sprayer 600L', 
        'ASPEE', 
        'HTP Tractor Mounted Sprayer 600L', 
        2024, 
        'SPRAYERS', 
        'IND-ASP-SPR-1090', 
        35, 
        490, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine ASPEE HTP Tractor Mounted Sprayer 600L (Triplex Plunger Pump & 12M Boom). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        550.00, 
        3410.00, 
        12375.00, 
        1650.00, 
        82000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'ASPEE', 
        'Triplex Plunger Pump & 12M Boom', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (ASPEE India)', 
        'https://www.aspee.com', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1225, 
        42, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (ASPEE India)', 'https://www.aspee.com', 82000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 490, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 690);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mitra Bullet 600L Orchard Sprayer')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mitra Bullet 600L Orchard Sprayer', 
        'Mitra', 
        'Bullet 600L Orchard Sprayer', 
        2024, 
        'SPRAYERS', 
        'IND-MIT-SPR-1091', 
        45, 
        513, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mitra Bullet 600L Orchard Sprayer (Grapes & Pomegranate Radial Blower). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        235000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Mitra', 
        'Grapes & Pomegranate Radial Blower', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mitra Agro Equipments)', 
        'https://www.mitraagro.com', 
        '05 Sep 2026', 
        'Sangli', 
        1575, 
        54, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mitra Agro Equipments)', 'https://www.mitraagro.com', 235000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 513, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 713);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Rakshak Boom Sprayer 500L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Rakshak Boom Sprayer 500L', 
        'Shaktiman', 
        'Rakshak Boom Sprayer 500L', 
        2024, 
        'SPRAYERS', 
        'IND-SHA-SPR-1092', 
        40, 
        536, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Rakshak Boom Sprayer 500L (Hydraulic Fold 10m Ground Clearance). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        700.00, 
        4340.00, 
        15750.00, 
        2100.00, 
        125000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Shaktiman', 
        'Hydraulic Fold 10m Ground Clearance', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Satara', 
        1400, 
        48, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 125000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 536, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 736);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Tractor Mounted Boom Sprayer 600L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Tractor Mounted Boom Sprayer 600L', 
        'Fieldking', 
        'Tractor Mounted Boom Sprayer 600L', 
        2024, 
        'SPRAYERS', 
        'IND-FIE-SPR-1093', 
        40, 
        559, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Tractor Mounted Boom Sprayer 600L (Anti-Drip Ceramic Nozzles 12M). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        650.00, 
        4030.00, 
        14625.00, 
        1950.00, 
        95000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Fieldking', 
        'Anti-Drip Ceramic Nozzles 12M', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Akola', 
        1400, 
        48, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 95000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 559, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 759);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Applitrac Orchard Sprayer 400L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Applitrac Orchard Sprayer 400L', 
        'Mahindra', 
        'Applitrac Orchard Sprayer 400L', 
        2024, 
        'SPRAYERS', 
        'IND-MAH-SPR-1094', 
        35, 
        582, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Applitrac Orchard Sprayer 400L (Cross-Flow Blower Fan High Pressure). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        800.00, 
        4960.00, 
        18000.00, 
        2400.00, 
        185000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Mahindra', 
        'Cross-Flow Blower Fan High Pressure', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        1225, 
        42, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 185000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 582, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 782);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Neptune BS-25 Power Sprayer 500L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Neptune BS-25 Power Sprayer 500L', 
        'Neptune', 
        'BS-25 Power Sprayer 500L', 
        2024, 
        'SPRAYERS', 
        'IND-NEP-SPR-1095', 
        30, 
        605, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Neptune BS-25 Power Sprayer 500L (Stainless Steel Chemical Tank 4-Stroke). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        500.00, 
        3100.00, 
        11250.00, 
        1500.00, 
        72000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Neptune', 
        'Stainless Steel Chemical Tank 4-Stroke', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Neptune Farming Solutions)', 
        'https://www.neptunefarming.com', 
        '05 Sep 2026', 
        'Nanded', 
        1050, 
        36, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Neptune Farming Solutions)', 'https://www.neptunefarming.com', 72000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 605, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 805);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kisan Kraft KK-60 Tractor Sprayer 600L')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kisan Kraft KK-60 Tractor Sprayer 600L', 
        'Kisan Kraft', 
        'KK-60 Tractor Sprayer 600L', 
        2024, 
        'SPRAYERS', 
        'IND-KIS-SPR-1096', 
        35, 
        628, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kisan Kraft KK-60 Tractor Sprayer 600L (Brass Gear Head Auto Agitator). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 
        580.00, 
        3596.00, 
        13050.00, 
        1740.00, 
        86000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Kisan Kraft', 
        'Brass Gear Head Auto Agitator', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (KisanKraft India)', 
        'https://www.kisankraft.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1225, 
        42, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (KisanKraft India)', 'https://www.kisankraft.com', 86000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 628, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 828);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Agrimate AM-500 High Pressure Boom Sprayer')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Agrimate AM-500 High Pressure Boom Sprayer', 
        'Agrimate', 
        'AM-500 High Pressure Boom Sprayer', 
        2024, 
        'SPRAYERS', 
        'IND-AGR-SPR-1097', 
        40, 
        651, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Agrimate AM-500 High Pressure Boom Sprayer (24 Double Nozzles Wide Angle Coverage). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        620.00, 
        3844.00, 
        13950.00, 
        1860.00, 
        91000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Agrimate', 
        '24 Double Nozzles Wide Angle Coverage', 
        'INR', 
        'FIXED', 
        'Official Dealer Price', 
        'https://www.agrimate.co.in', 
        '05 Sep 2026', 
        'Pune', 
        1400, 
        48, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price', 'https://www.agrimate.co.in', 91000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 651, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 851);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Tipping Trailer 5-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Tipping Trailer 5-Ton', 
        'Fieldking', 
        'Tipping Trailer 5-Ton', 
        2024, 
        'TRAILERS', 
        'IND-FIE-TRA-1098', 
        45, 
        674, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Tipping Trailer 5-Ton (Hydraulic Underbody Single Cylinder 5-Ton). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        600.00, 
        3720.00, 
        13500.00, 
        1800.00, 
        165000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Fieldking', 
        'Hydraulic Underbody Single Cylinder 5-Ton', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Nashik', 
        1575, 
        54, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 165000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 674, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 874);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Hydraulic Tipping Trailer 7-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Hydraulic Tipping Trailer 7-Ton', 
        'Shaktiman', 
        'Hydraulic Tipping Trailer 7-Ton', 
        2024, 
        'TRAILERS', 
        'IND-SHA-TRA-1099', 
        55, 
        697, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Hydraulic Tipping Trailer 7-Ton (Reinforced Ribbed Body Double Ram). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        750.00, 
        4650.00, 
        16875.00, 
        2250.00, 
        215000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Shaktiman', 
        'Reinforced Ribbed Body Double Ram', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Kolhapur', 
        1925, 
        66, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 215000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 697, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 897);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Applitrac Farm Trailer 4-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Applitrac Farm Trailer 4-Ton', 
        'Mahindra', 
        'Applitrac Farm Trailer 4-Ton', 
        2024, 
        'TRAILERS', 
        'IND-MAH-TRA-1100', 
        40, 
        720, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Applitrac Farm Trailer 4-Ton (Heavy Steel Bed Automatic Tailgate). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        550.00, 
        3410.00, 
        12375.00, 
        1650.00, 
        145000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Mahindra', 
        'Heavy Steel Bed Automatic Tailgate', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        1400, 
        48, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 145000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 720, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 920);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Heavy Hydraulic Trailer 6-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Heavy Hydraulic Trailer 6-Ton', 
        'Landforce', 
        'Heavy Hydraulic Trailer 6-Ton', 
        2024, 
        'TRAILERS', 
        'IND-LAN-TRA-1101', 
        50, 
        743, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Heavy Hydraulic Trailer 6-Ton (Heavy Duty Axle with Dual Tyres). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        680.00, 
        4216.00, 
        15300.00, 
        2040.00, 
        185000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Landforce', 
        'Heavy Duty Axle with Dual Tyres', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Amravati', 
        1750, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 185000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 743, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 943);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Bharat Double Axle Tipper 10-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Bharat Double Axle Tipper 10-Ton', 
        'Bharat', 
        'Double Axle Tipper 10-Ton', 
        2024, 
        'TRAILERS', 
        'IND-BHA-TRA-1102', 
        65, 
        766, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Bharat Double Axle Tipper 10-Ton (Commercial Grain & Sugarcane Tipper). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        950.00, 
        5890.00, 
        21375.00, 
        2850.00, 
        295000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Bharat', 
        'Commercial Grain & Sugarcane Tipper', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Maharashtra Agro Trailers)', 
        'https://www.bharattrailers.in', 
        '05 Sep 2026', 
        'Ahmednagar', 
        2275, 
        78, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Maharashtra Agro Trailers)', 'https://www.bharattrailers.in', 295000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 766, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 966);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Khedut Agro Hydraulic Trailer 5-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Khedut Agro Hydraulic Trailer 5-Ton', 
        'Khedut', 
        'Agro Hydraulic Trailer 5-Ton', 
        2024, 
        'TRAILERS', 
        'IND-KHE-TRA-1103', 
        45, 
        789, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Khedut Agro Hydraulic Trailer 5-Ton (High Tensile Steel Leaf Spring Axle). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        580.00, 
        3596.00, 
        13050.00, 
        1740.00, 
        158000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Khedut', 
        'High Tensile Steel Leaf Spring Axle', 
        'INR', 
        'FIXED', 
        'Official Dealer Price (Khedut Agro)', 
        'https://www.khedutagro.com', 
        '05 Sep 2026', 
        'Sangli', 
        1575, 
        54, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Price (Khedut Agro)', 'https://www.khedutagro.com', 158000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 789, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 989);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Captain Mini Tractor Farm Trailer 2.5-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Captain Mini Tractor Farm Trailer 2.5-Ton', 
        'Captain', 
        'Mini Tractor Farm Trailer 2.5-Ton', 
        2024, 
        'TRAILERS', 
        'IND-CAP-TRA-1104', 
        25, 
        812, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Captain Mini Tractor Farm Trailer 2.5-Ton (Single Axle Orchard Mini Trailer). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 
        400.00, 
        2480.00, 
        9000.00, 
        1200.00, 
        88000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Captain', 
        'Single Axle Orchard Mini Trailer', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Captain Tractors)', 
        'https://www.captaintractors.com', 
        '05 Sep 2026', 
        'Satara', 
        875, 
        30, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Captain Tractors)', 'https://www.captaintractors.com', 88000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 812, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 1012);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Vishwakarma Grain Hauler Tipper 5-Ton')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Vishwakarma Grain Hauler Tipper 5-Ton', 
        'Vishwakarma', 
        'Grain Hauler Tipper 5-Ton', 
        2024, 
        'TRAILERS', 
        'IND-VIS-TRA-1105', 
        45, 
        835, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Vishwakarma Grain Hauler Tipper 5-Ton (Removable Side Walls Corrugated Bed). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 
        600.00, 
        3720.00, 
        13500.00, 
        1800.00, 
        162000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Vishwakarma', 
        'Removable Side Walls Corrugated Bed', 
        'INR', 
        'FIXED', 
        'Official Dealer Catalog', 
        'https://www.vishwakarmaagro.com', 
        '05 Sep 2026', 
        'Akola', 
        1575, 
        54, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Dealer Catalog', 'https://www.vishwakarmaagro.com', 162000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 835, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 1035);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'VST Shakti 130 DI Power Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'VST Shakti 130 DI Power Tiller', 
        'VST', 
        'Shakti 130 DI Power Tiller', 
        2024, 
        'POWER_TILLERS', 
        'IND-VST-POW-1106', 
        13, 
        858, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine VST Shakti 130 DI Power Tiller (13 HP Diesel Electric Start Multi-Tine). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        450.00, 
        2790.00, 
        10125.00, 
        1350.00, 
        175000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'VST', 
        '13 HP Diesel Electric Start Multi-Tine', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (VST Tillers Tractors Ltd)', 
        'https://www.vsttractors.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        455, 
        16, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (VST Tillers Tractors Ltd)', 'https://www.vsttractors.com', 175000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 858, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 1058);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kirloskar Mega T 15 Deluxe Power Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kirloskar Mega T 15 Deluxe Power Tiller', 
        'Kirloskar', 
        'Mega T 15 Deluxe Power Tiller', 
        2024, 
        'POWER_TILLERS', 
        'IND-KIR-POW-1107', 
        15, 
        881, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kirloskar Mega T 15 Deluxe Power Tiller (15 HP Water-Cooled High Clearance). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        520.00, 
        3224.00, 
        11700.00, 
        1560.00, 
        210000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Kirloskar', 
        '15 HP Water-Cooled High Clearance', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kirloskar Oil Engines)', 
        'https://www.kirloskaroilengines.com', 
        '05 Sep 2026', 
        'Nanded', 
        525, 
        18, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kirloskar Oil Engines)', 'https://www.kirloskaroilengines.com', 210000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 881, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 1081);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Honda FJ500 Power Weeder')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Honda FJ500 Power Weeder', 
        'Honda', 
        'FJ500 Power Weeder', 
        2024, 
        'POWER_TILLERS', 
        'IND-HON-POW-1108', 
        5, 
        904, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Honda FJ500 Power Weeder (4.8 HP 4-Stroke Petrol Rotary Weeder). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        350.00, 
        2170.00, 
        7875.00, 
        1050.00, 
        68000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Honda', 
        '4.8 HP 4-Stroke Petrol Rotary Weeder', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Honda India Power Products)', 
        'https://www.hondaindiapower.com', 
        '05 Sep 2026', 
        'Nagpur', 
        175, 
        6, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Honda India Power Products)', 'https://www.hondaindiapower.com', 68000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 904, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 1104);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Greaves Cotton GS 14 Power Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Greaves Cotton GS 14 Power Tiller', 
        'Greaves Cotton', 
        'GS 14 Power Tiller', 
        2024, 
        'POWER_TILLERS', 
        'IND-GRE-POW-1109', 
        14, 
        927, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Greaves Cotton GS 14 Power Tiller (14 HP Heavy Clay Soil Specialist). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        480.00, 
        2976.00, 
        10800.00, 
        1440.00, 
        185000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Greaves Cotton', 
        '14 HP Heavy Clay Soil Specialist', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Greaves Cotton)', 
        'https://www.greavescotton.com', 
        '05 Sep 2026', 
        'Pune', 
        490, 
        17, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Greaves Cotton)', 'https://www.greavescotton.com', 185000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 927, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 1127);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kamco Super DI Power Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kamco Super DI Power Tiller', 
        'Kamco', 
        'Super DI Power Tiller', 
        2024, 
        'POWER_TILLERS', 
        'IND-KAM-POW-1110', 
        12, 
        950, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kamco Super DI Power Tiller (12 HP Direct Injection Rubber Lug). Engineered for rigorous Indian soil conditions in Nashik, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 
        440.00, 
        2728.00, 
        9900.00, 
        1320.00, 
        168000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nashik', 
        'Maharashtra', 
        '411001', 
        19.9975, 
        73.7898,
        'Kamco', 
        '12 HP Direct Injection Rubber Lug', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (KAMCO Kerala)', 
        'https://www.kamcoindia.com', 
        '05 Sep 2026', 
        'Nashik', 
        420, 
        14, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (KAMCO Kerala)', 'https://www.kamcoindia.com', 168000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 950, 90, 95, 12.8, 180, 52, 19.9975, 73.7898, 1150);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kubota PEM140DI Power Tiller')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kubota PEM140DI Power Tiller', 
        'Kubota', 
        'PEM140DI Power Tiller', 
        2024, 
        'POWER_TILLERS', 
        'IND-KUB-POW-1111', 
        14, 
        123, 
        'N/A', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kubota PEM140DI Power Tiller (14 HP Japanese Gearbox Heavy Tiller). Engineered for rigorous Indian soil conditions in Kolhapur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        550.00, 
        3410.00, 
        12375.00, 
        1650.00, 
        225000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Kolhapur', 
        'Maharashtra', 
        '411001', 
        16.705, 
        74.2433,
        'Kubota', 
        '14 HP Japanese Gearbox Heavy Tiller', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kubota India)', 
        'https://www.kubota.co.in', 
        '05 Sep 2026', 
        'Kolhapur', 
        490, 
        17, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kubota India)', 'https://www.kubota.co.in', 225000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 123, 90, 95, 12.8, 180, 52, 16.705, 74.2433, 323);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Jivo 245 DI 4WD')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Jivo 245 DI 4WD', 
        'Mahindra', 
        'Jivo 245 DI 4WD', 
        2024, 
        'MINI_TRACTORS', 
        'IND-MAH-MIN-1112', 
        24, 
        146, 
        '4WD', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Jivo 245 DI 4WD (Compact Orchard & Vineyard (24 HP)). Engineered for rigorous Indian soil conditions in Chhatrapati Sambhajinagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 
        750.00, 
        4650.00, 
        16875.00, 
        2250.00, 
        425000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Chhatrapati Sambhajinagar', 
        'Maharashtra', 
        '411001', 
        19.8762, 
        75.3433,
        'Mahindra', 
        'Compact Orchard & Vineyard (24 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Chhatrapati Sambhajinagar', 
        840, 
        29, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 425000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 146, 90, 95, 12.8, 180, 52, 19.8762, 75.3433, 346);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Kubota Neostar B2441 4WD')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Kubota Neostar B2441 4WD', 
        'Kubota', 
        'Neostar B2441 4WD', 
        2024, 
        'MINI_TRACTORS', 
        'IND-KUB-MIN-1113', 
        24, 
        169, 
        '4WD', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Kubota Neostar B2441 4WD (Japanese Compact 9F+3R (24 HP)). Engineered for rigorous Indian soil conditions in Amravati, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        535000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Amravati', 
        'Maharashtra', 
        '411001', 
        20.9374, 
        77.7796,
        'Kubota', 
        'Japanese Compact 9F+3R (24 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Kubota India)', 
        'https://www.kubota.co.in', 
        '05 Sep 2026', 
        'Amravati', 
        840, 
        29, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Kubota India)', 'https://www.kubota.co.in', 535000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 169, 90, 95, 12.8, 180, 52, 20.9374, 77.7796, 369);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Swaraj Target 630 4WD')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Swaraj Target 630 4WD', 
        'Swaraj', 
        'Target 630 4WD', 
        2024, 
        'MINI_TRACTORS', 
        'IND-SWA-MIN-1114', 
        29, 
        192, 
        '4WD', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Swaraj Target 630 4WD (Sync-Shuttle Narrow Track (29 HP)). Engineered for rigorous Indian soil conditions in Ahmednagar, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 
        820.00, 
        5084.00, 
        18450.00, 
        2460.00, 
        515000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Ahmednagar', 
        'Maharashtra', 
        '411001', 
        19.0952, 
        74.7496,
        'Swaraj', 
        'Sync-Shuttle Narrow Track (29 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Swaraj Tractors)', 
        'https://www.swarajtractors.com', 
        '05 Sep 2026', 
        'Ahmednagar', 
        1015, 
        35, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Swaraj Tractors)', 'https://www.swarajtractors.com', 515000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 192, 90, 95, 12.8, 180, 52, 19.0952, 74.7496, 392);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Captain 283 4WD Generation 8')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Captain 283 4WD Generation 8', 
        'Captain', 
        '283 4WD Generation 8', 
        2024, 
        'MINI_TRACTORS', 
        'IND-CAP-MIN-1115', 
        28, 
        215, 
        '4WD', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Captain 283 4WD Generation 8 (Compact 8-Speed (28 HP)). Engineered for rigorous Indian soil conditions in Sangli, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 
        720.00, 
        4464.00, 
        16200.00, 
        2160.00, 
        410000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Sangli', 
        'Maharashtra', 
        '411001', 
        16.8524, 
        74.5815,
        'Captain', 
        'Compact 8-Speed (28 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Captain Tractors)', 
        'https://www.captaintractors.com', 
        '05 Sep 2026', 
        'Sangli', 
        980, 
        34, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Captain Tractors)', 'https://www.captaintractors.com', 410000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 215, 90, 95, 12.8, 180, 52, 16.8524, 74.5815, 415);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Eicher 188 Mini Tractor')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Eicher 188 Mini Tractor', 
        'Eicher', 
        '188 Mini Tractor', 
        2024, 
        'MINI_TRACTORS', 
        'IND-EIC-MIN-1116', 
        18, 
        238, 
        '4WD', 
        'DIESEL', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Eicher 188 Mini Tractor (Air-Cooled Compact (18 HP)). Engineered for rigorous Indian soil conditions in Satara, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 
        600.00, 
        3720.00, 
        13500.00, 
        1800.00, 
        345000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Satara', 
        'Maharashtra', 
        '411001', 
        17.6805, 
        74.0183,
        'Eicher', 
        'Air-Cooled Compact (18 HP)', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Eicher Tractors)', 
        'https://www.eichertractors.in', 
        '05 Sep 2026', 
        'Satara', 
        630, 
        22, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1589923188651-268a9765e432?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Eicher Tractors)', 'https://www.eichertractors.in', 345000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 238, 90, 95, 12.8, 180, 52, 17.6805, 74.0183, 438);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Shaktiman Round Baler SRB-60')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Shaktiman Round Baler SRB-60', 
        'Shaktiman', 
        'Round Baler SRB-60', 
        2024, 
        'OTHER_EQUIPMENT', 
        'IND-SHA-OTH-1117', 
        45, 
        261, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Shaktiman Round Baler SRB-60 (Paddy & Wheat Straw Round Baler). Engineered for rigorous Indian soil conditions in Akola, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        1400.00, 
        8680.00, 
        31500.00, 
        4200.00, 
        410000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Akola', 
        'Maharashtra', 
        '411001', 
        20.7002, 
        77.0082,
        'Shaktiman', 
        'Paddy & Wheat Straw Round Baler', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Shaktiman Agro)', 
        'https://www.shaktimanagro.com', 
        '05 Sep 2026', 
        'Akola', 
        1575, 
        54, 
        4.7
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Shaktiman Agro)', 'https://www.shaktimanagro.com', 410000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 261, 90, 95, 12.8, 180, 52, 20.7002, 77.0082, 461);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Fieldking Post Hole Digger Heavy Duty')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Fieldking Post Hole Digger Heavy Duty', 
        'Fieldking', 
        'Post Hole Digger Heavy Duty', 
        2024, 
        'OTHER_EQUIPMENT', 
        'IND-FIE-OTH-1118', 
        40, 
        284, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Fieldking Post Hole Digger Heavy Duty (Hydraulic Downforce 9 & 12 inch Auger). Engineered for rigorous Indian soil conditions in Jalgaon, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        650.00, 
        4030.00, 
        14625.00, 
        1950.00, 
        82000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Jalgaon', 
        'Maharashtra', 
        '411001', 
        21.0077, 
        75.5626,
        'Fieldking', 
        'Hydraulic Downforce 9 & 12 inch Auger', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Fieldking India)', 
        'https://www.fieldking.com', 
        '05 Sep 2026', 
        'Jalgaon', 
        1400, 
        48, 
        4.8
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Fieldking India)', 'https://www.fieldking.com', 82000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 284, 90, 95, 12.8, 180, 52, 21.0077, 75.5626, 484);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Mahindra Front End Tractor Loader LA-300')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Mahindra Front End Tractor Loader LA-300', 
        'Mahindra', 
        'Front End Tractor Loader LA-300', 
        2024, 
        'OTHER_EQUIPMENT', 
        'IND-MAH-OTH-1119', 
        50, 
        307, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Mahindra Front End Tractor Loader LA-300 (Quick Detach Bucket 1-Ton Load). Engineered for rigorous Indian soil conditions in Nanded, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        1100.00, 
        6820.00, 
        24750.00, 
        3300.00, 
        260000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nanded', 
        'Maharashtra', 
        '411001', 
        19.1383, 
        77.321,
        'Mahindra', 
        'Quick Detach Bucket 1-Ton Load', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Mahindra Tractors)', 
        'https://www.mahindratractor.com', 
        '05 Sep 2026', 
        'Nanded', 
        1750, 
        60, 
        4.9
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Mahindra Tractors)', 'https://www.mahindratractor.com', 260000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 307, 90, 95, 12.8, 180, 52, 19.1383, 77.321, 507);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Maschio Gaspardo Chipper Mulcher Barbi 160')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Maschio Gaspardo Chipper Mulcher Barbi 160', 
        'Maschio Gaspardo', 
        'Chipper Mulcher Barbi 160', 
        2024, 
        'OTHER_EQUIPMENT', 
        'IND-MAS-OTH-1120', 
        45, 
        330, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Maschio Gaspardo Chipper Mulcher Barbi 160 (Crop Residue Shredder & Mulcher). Engineered for rigorous Indian soil conditions in Nagpur, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 
        850.00, 
        5270.00, 
        19125.00, 
        2550.00, 
        175000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Nagpur', 
        'Maharashtra', 
        '411001', 
        21.1458, 
        79.0882,
        'Maschio Gaspardo', 
        'Crop Residue Shredder & Mulcher', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Maschio Gaspardo)', 
        'https://www.maschio.com', 
        '05 Sep 2026', 
        'Nagpur', 
        1575, 
        54, 
        4.5
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Maschio Gaspardo)', 'https://www.maschio.com', 175000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 330, 90, 95, 12.8, 180, 52, 21.1458, 79.0882, 530);
END;

IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = 'Landforce Sugarcane Stubble Shaver')
BEGIN
    INSERT INTO equipment (
        owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, 
        drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, 
        description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, 
        is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude,
        brand, variant, currency, price_type, price_source_name, price_source_url, last_verified_date,
        district, lifting_capacity_kg, fuel_tank_litres, rating
    )
    VALUES (
        @owner_id, 
        'Landforce Sugarcane Stubble Shaver', 
        'Landforce', 
        'Sugarcane Stubble Shaver', 
        2024, 
        'OTHER_EQUIPMENT', 
        'IND-LAN-OTH-1121', 
        50, 
        353, 
        'N/A', 
        'N/A', 
        'Standard High-Torque Gearbox', 
        35.0, 
        '540 RPM Standard', 
        'Category 2', 
        'Certified genuine Landforce Sugarcane Stubble Shaver (Double Disc High Speed Shaver). Engineered for rigorous Indian soil conditions in Pune, Maharashtra. Maintained strictly to manufacturer operating standards with full uptime guarantee and available for immediate field delivery or authorized dealer pickup.', 
        'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 
        800.00, 
        4960.00, 
        18000.00, 
        2400.00, 
        135000.00, 
        1, 
        1, 
        'AVAILABLE', 
        'APPROVED', 
        'Pune', 
        'Maharashtra', 
        '411001', 
        18.5204, 
        73.8567,
        'Landforce', 
        'Double Disc High Speed Shaver', 
        'INR', 
        'FIXED', 
        'Official Manufacturer Website (Landforce Agro)', 
        'https://www.landforce.in', 
        '05 Sep 2026', 
        'Pune', 
        1750, 
        60, 
        4.6
    );

    SET @eq_id = SCOPE_IDENTITY();
    
    INSERT INTO equipment_images (equipment_id, image_url, image_type, is_primary, display_order)
    VALUES (@eq_id, 'https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&w=1200&q=80', 'EXTERIOR', 1, 1);

    INSERT INTO price_sources (equipment_id, source_name, source_url, price, currency, price_type, verification_status, verified_by, last_verified_at)
    VALUES (@eq_id, 'Official Manufacturer Website (Landforce Agro)', 'https://www.landforce.in', 135000.00, 'INR', 'OFFICIAL_EX_SHOWROOM', 'VERIFIED', 'AgriRent Market Intelligence', SYSUTCDATETIME());

    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    VALUES (@eq_id, 353, 90, 95, 12.8, 180, 52, 18.5204, 73.8567, 553);
END;

PRINT 'Completed Indian Agricultural Marketplace schema and seed expansion successfully!';
GO
