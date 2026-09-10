-- Flyway Migration V1: Initial Schema for AgriRent
-- Compatible with Microsoft SQL Server 2017+

-- 1. Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        email NVARCHAR(150) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        full_name NVARCHAR(150) NOT NULL,
        role NVARCHAR(50) NOT NULL, -- ROLE_FARMER, ROLE_OWNER, ROLE_ADMIN
        farm_name NVARCHAR(200) NULL,
        phone NVARCHAR(50) NULL,
        address NVARCHAR(255) NULL,
        city NVARCHAR(100) NULL,
        state NVARCHAR(100) NULL,
        zip_code NVARCHAR(20) NULL,
        is_verified BIT NOT NULL DEFAULT 1,
        avatar_url NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX idx_users_email ON users(email);
    CREATE INDEX idx_users_role ON users(role);
END;

-- 2. Equipment Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'equipment')
BEGIN
    CREATE TABLE equipment (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        owner_id BIGINT NOT NULL,
        title NVARCHAR(255) NOT NULL,
        make NVARCHAR(100) NOT NULL,
        model NVARCHAR(100) NOT NULL,
        year INT NOT NULL,
        category NVARCHAR(100) NOT NULL, -- TRACTORS, HARVESTERS, TILLAGE, SEEDERS, SPRAYERS, HAY_FORAGE
        serial_vin NVARCHAR(100) NULL,
        horsepower INT NULL,
        engine_hours INT NOT NULL DEFAULT 0,
        drive_type NVARCHAR(50) NULL, -- 4WD, MFWD, 2WD, TRACK
        fuel_type NVARCHAR(50) NULL, -- DIESEL, ELECTRIC, HYBRID
        transmission NVARCHAR(100) NULL,
        hydraulic_flow_gpm DECIMAL(10,2) NULL,
        pto_speed NVARCHAR(50) NULL,
        hitch_category NVARCHAR(50) NULL,
        description NVARCHAR(MAX) NULL,
        images NVARCHAR(MAX) NULL, -- JSON array or comma separated image URLs
        daily_rate DECIMAL(18,2) NOT NULL,
        weekly_rate DECIMAL(18,2) NULL,
        monthly_rate DECIMAL(18,2) NULL,
        security_deposit DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        purchase_price DECIMAL(18,2) NULL,
        is_for_rent BIT NOT NULL DEFAULT 1,
        is_for_sale BIT NOT NULL DEFAULT 0,
        status NVARCHAR(50) NOT NULL DEFAULT 'AVAILABLE', -- AVAILABLE, RENTED, MAINTENANCE, IN_TRANSIT, PENDING_APPROVAL, REJECTED
        approval_status NVARCHAR(50) NOT NULL DEFAULT 'APPROVED', -- PENDING, APPROVED, REJECTED
        audit_notes NVARCHAR(MAX) NULL,
        location_address NVARCHAR(255) NULL,
        city NVARCHAR(100) NOT NULL,
        state NVARCHAR(50) NOT NULL,
        zip_code NVARCHAR(20) NOT NULL,
        latitude DECIMAL(10,6) NULL,
        longitude DECIMAL(10,6) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_equipment_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE NO ACTION
    );

    CREATE INDEX idx_equipment_owner ON equipment(owner_id);
    CREATE INDEX idx_equipment_category ON equipment(category);
    CREATE INDEX idx_equipment_status ON equipment(status);
    CREATE INDEX idx_equipment_approval ON equipment(approval_status);
END;

-- 3. Equipment Telemetry Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'equipment_telemetry')
BEGIN
    CREATE TABLE equipment_telemetry (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        equipment_id BIGINT NOT NULL UNIQUE,
        engine_hours INT NOT NULL,
        fuel_level_percent INT NOT NULL DEFAULT 100,
        def_fluid_percent INT NOT NULL DEFAULT 100,
        battery_voltage DECIMAL(5,2) NULL DEFAULT 12.6,
        coolant_temp_f INT NULL DEFAULT 185,
        oil_pressure_psi INT NULL DEFAULT 48,
        gps_latitude DECIMAL(10,6) NULL,
        gps_longitude DECIMAL(10,6) NULL,
        next_service_hours INT NULL,
        last_ping_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_telemetry_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE
    );

    CREATE INDEX idx_telemetry_equipment ON equipment_telemetry(equipment_id);
END;

-- 4. Bookings Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'bookings')
BEGIN
    CREATE TABLE bookings (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        equipment_id BIGINT NOT NULL,
        renter_id BIGINT NOT NULL,
        owner_id BIGINT NOT NULL,
        start_date DATETIME2 NOT NULL,
        end_date DATETIME2 NOT NULL,
        total_days INT NOT NULL,
        delivery_method NVARCHAR(50) NOT NULL DEFAULT 'DELIVERY', -- DELIVERY, PICKUP
        delivery_address NVARCHAR(255) NULL,
        operator_included BIT NOT NULL DEFAULT 0,
        damage_waiver_included BIT NOT NULL DEFAULT 1,
        daily_rate DECIMAL(18,2) NOT NULL,
        equipment_subtotal DECIMAL(18,2) NOT NULL,
        delivery_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        insurance_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        escrow_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        total_amount DECIMAL(18,2) NOT NULL,
        status NVARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, ACCEPTED, ACTIVE, COMPLETED, CANCELLED, REJECTED
        payment_status NVARCHAR(50) NOT NULL DEFAULT 'ESCROW_HOLD', -- PENDING, ESCROW_HOLD, RELEASED, REFUNDED
        special_instructions NVARCHAR(MAX) NULL,
        hours_used INT NOT NULL DEFAULT 0,
        hours_allowed INT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_bookings_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE NO ACTION,
        CONSTRAINT fk_bookings_renter FOREIGN KEY (renter_id) REFERENCES users(id) ON DELETE NO ACTION,
        CONSTRAINT fk_bookings_owner FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE NO ACTION
    );

    CREATE INDEX idx_bookings_renter ON bookings(renter_id);
    CREATE INDEX idx_bookings_owner ON bookings(owner_id);
    CREATE INDEX idx_bookings_equipment ON bookings(equipment_id);
    CREATE INDEX idx_bookings_status ON bookings(status);
END;

-- 5. Reviews Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'reviews')
BEGIN
    CREATE TABLE reviews (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        equipment_id BIGINT NOT NULL,
        booking_id BIGINT NULL,
        reviewer_id BIGINT NOT NULL,
        rating INT NOT NULL, -- 1 to 5
        comment NVARCHAR(MAX) NULL,
        equipment_condition_rating INT NULL,
        communication_rating INT NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_reviews_equipment FOREIGN KEY (equipment_id) REFERENCES equipment(id) ON DELETE CASCADE,
        CONSTRAINT fk_reviews_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE NO ACTION,
        CONSTRAINT fk_reviews_reviewer FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE NO ACTION
    );

    CREATE INDEX idx_reviews_equipment ON reviews(equipment_id);
END;

-- 6. Escrow Transactions Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'escrow_transactions')
BEGIN
    CREATE TABLE escrow_transactions (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        booking_id BIGINT NOT NULL,
        payer_id BIGINT NOT NULL,
        payee_id BIGINT NOT NULL,
        amount DECIMAL(18,2) NOT NULL,
        platform_fee DECIMAL(18,2) NOT NULL DEFAULT 0.0,
        escrow_status NVARCHAR(50) NOT NULL DEFAULT 'HELD', -- HELD, RELEASED_TO_OWNER, REFUNDED_TO_RENTER, DISPUTED
        transaction_ref NVARCHAR(100) NOT NULL UNIQUE,
        dispute_reason NVARCHAR(MAX) NULL,
        dispute_resolution NVARCHAR(MAX) NULL,
        released_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT fk_escrow_booking FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE NO ACTION,
        CONSTRAINT fk_escrow_payer FOREIGN KEY (payer_id) REFERENCES users(id) ON DELETE NO ACTION,
        CONSTRAINT fk_escrow_payee FOREIGN KEY (payee_id) REFERENCES users(id) ON DELETE NO ACTION
    );

    CREATE INDEX idx_escrow_booking ON escrow_transactions(booking_id);
    CREATE INDEX idx_escrow_status ON escrow_transactions(escrow_status);
END;
