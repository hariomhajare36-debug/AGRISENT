-- Flyway Migration V2: Seed Data for AgriRent
-- Compatible with Microsoft SQL Server 2017+

-- Insert Users (Password: Password123!)
-- Bcrypt hash: $2a$10$7EqJtq98hPqEX7fNZaFWoO.PvyxH2dF3xR.E0K49EomkL9k6C/3z.
IF NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@agrirent.com')
BEGIN
    INSERT INTO users (username, email, password, full_name, role, farm_name, phone, address, city, state, zip_code, is_verified)
    VALUES 
    ('admin', 'admin@agrirent.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.PvyxH2dF3xR.E0K49EomkL9k6C/3z.', 'Sarah Jenkins', 'ROLE_ADMIN', 'AgriRent Operations HQ', '(515) 555-0199', '100 Gateway Blvd', 'Des Moines', 'IA', '50309', 1),
    ('marcus_vance', 'marcus@cedarvalley.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.PvyxH2dF3xR.E0K49EomkL9k6C/3z.', 'Marcus Vance', 'ROLE_OWNER', 'Cedar Valley Farms & Agri-Fleet', '(319) 555-0142', '4580 Prairie View Rd', 'Cedar Rapids', 'IA', '52404', 1),
    ('david_miller', 'david.miller@farmmail.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.PvyxH2dF3xR.E0K49EomkL9k6C/3z.', 'David Miller', 'ROLE_FARMER', 'Miller Family Grain & Row-Crop', '(515) 555-0177', '1240 Harvest Way', 'Ames', 'IA', '50010', 1),
    ('elena_rostova', 'elena@midwestag.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.PvyxH2dF3xR.E0K49EomkL9k6C/3z.', 'Elena Rostova', 'ROLE_OWNER', 'Heartland Fleet Solutions', '(641) 555-0188', '890 Cornhusker Trail', 'Marshalltown', 'IA', '50158', 1);
END;

-- Equipment Seeds
IF NOT EXISTS (SELECT 1 FROM equipment WHERE title = '2023 John Deere 8R 410')
BEGIN
    DECLARE @owner_marcus BIGINT = (SELECT TOP 1 id FROM users WHERE email = 'marcus@cedarvalley.com');
    DECLARE @owner_elena BIGINT = (SELECT TOP 1 id FROM users WHERE email = 'elena@midwestag.com');

    -- Machine 1
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_marcus, '2023 John Deere 8R 410', 'John Deere', '8R 410', 2023, 'TRACTORS', '1RW8410RLPC041289', 410, 420, '4WD', 'DIESEL', 'e23 PowerShift with Efficiency Manager', 85.0, '1000 RPM (1-3/4 in)', 'Category 4N/3', 'Premium tier high-horsepower row crop tractor with CommandView 4 cab, ActiveCommand Steering 2, and dual Michelin VF 480/80R50 rear tires. Includes Gen 4 4600 CommandCenter display with AutoTrac and Section Control automation.', 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?auto=format&fit=crop&w=1200&q=80', 1450.00, 8200.00, 29500.00, 5000.00, 410000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Ames', 'IA', '50010', 42.0347, -93.6200);

    -- Machine 2
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_elena, '2022 New Holland CR8.90', 'New Holland', 'CR8.90', 2022, 'HARVESTERS', 'NHCR890COMB202291', 517, 310, 'TRACK', 'DIESEL', 'Hydrostatic 2-Speed', 70.0, '1000 RPM', 'N/A', 'Twin Rotor flagship combine with SmartTrax hydraulic suspension tracks, IntelliSense automation, Dynamic Feed Roll, and 410-bushel grain tank with 4.0 bu/sec unloading speed. Includes 40ft draper header.', 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 2600.00, 14500.00, 49000.00, 8000.00, 485000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Des Moines', 'IA', '50309', 41.5868, -93.6250);

    -- Machine 3
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_marcus, '2021 Case IH Magnum 340', 'Case IH', 'Magnum 340', 2021, 'TRACTORS', 'ZLRMAG340CK202140', 340, 890, 'MFWD', 'DIESEL', 'CVXDrive Continuously Variable Transmission', 75.0, '540/1000 Dual Speed', 'Category 3', 'High-versatility tractor with AFS Connect telematics, luxury leather cab, front suspension, class 5 suspended front axle, and 5 rear electro-hydraulic remotes.', 'https://images.unsplash.com/photo-1530267981375-f0de937f5f13?auto=format&fit=crop&w=1200&q=80', 1250.00, 7100.00, 24500.00, 4000.00, 285000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Cedar Rapids', 'IA', '52404', 41.9779, -91.6656);

    -- Machine 4
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_elena, '2020 Kinze 3600 16-Row', 'Kinze', '3600 16-Row', 2020, 'SEEDERS', 'KIN3600PLANT19842', 0, 560, 'N/A', 'N/A', 'Ground Drive with Hydraulic Lift', 35.0, 'N/A', 'Category 3 Pull-Type', '16-row 30-inch bulk fill center pivot planter. Equipped with hydraulic weight transfer, Blue Vantage display, and True Depth downforce control for precise seed placement across varied soil conditions.', 'https://images.unsplash.com/photo-1595246140625-573b715d11dc?auto=format&fit=crop&w=1200&q=80', 950.00, 5400.00, 18500.00, 3000.00, 168000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Fort Dodge', 'IA', '50501', 42.4975, -94.1680);

    -- Machine 5
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_marcus, '2022 Kuhn Krause 8000-25', 'Kuhn Krause', 'Excelerator 8000-25', 2022, 'TILLAGE', 'KK8000TIL2022718', 0, 320, 'N/A', 'N/A', 'Hydraulic Wing Fold', 28.0, 'N/A', 'Category 3/4 Pintle Hitch', '25-foot high-speed vertical tillage system. Excalibur CT blades with Star Wheel finishing reels and 24/7 flat bar rolling baskets. Ideal for high-residue sizing and seedbed preparation at 8-10 mph.', 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?auto=format&fit=crop&w=1200&q=80', 720.00, 4100.00, 14000.00, 2500.00, 94000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Marshalltown', 'IA', '50158', 42.0494, -92.9080);

    -- Machine 6
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_marcus, '2023 Kubota M6-141 Loader', 'Kubota', 'M6-141', 2023, 'TRACTORS', 'KUBM6141LDR202311', 141, 185, '4WD', 'DIESEL', 'Intelli-Shift 24x24 Powershift', 32.0, '540/1000 Independent PTO', 'Category 2', 'Utility powerhouse with LA2255 quick-attach self-leveling loader and 84-inch heavy material bucket. Air-ride cab, dual auxiliary rear remotes, and tight bi-speed turning circle.', 'https://images.unsplash.com/photo-1589923188900-85dae523342b?auto=format&fit=crop&w=1200&q=80', 650.00, 3700.00, 12500.00, 2000.00, 115000.00, 1, 1, 'AVAILABLE', 'APPROVED', 'Iowa City', 'IA', '52240', 41.6611, -91.5302);

    -- Machine 7 (Pending Approval for Admin Demo)
    INSERT INTO equipment (owner_id, title, make, model, year, category, serial_vin, horsepower, engine_hours, drive_type, fuel_type, transmission, hydraulic_flow_gpm, pto_speed, hitch_category, description, images, daily_rate, weekly_rate, monthly_rate, security_deposit, purchase_price, is_for_rent, is_for_sale, status, approval_status, city, state, zip_code, latitude, longitude)
    VALUES (@owner_elena, '2024 Claas Lexion 8800 Terra Trac', 'Claas', 'Lexion 8800', 2024, 'HARVESTERS', 'CLS8800TT202401', 653, 95, 'TRACK', 'DIESEL', 'C-Motion Dual Drive', 80.0, '1000 RPM', 'N/A', 'Top-spec combine with APS Synflow Hybrid threshing system, 510-bushel grain tank, 4.2 bu/sec discharge, and dynamic cooling. Freshly submitted listing awaiting platform safety audit.', 'https://images.unsplash.com/photo-1594771804886-a933bb2d609b?auto=format&fit=crop&w=1200&q=80', 3100.00, 17500.00, 58000.00, 10000.00, 620000.00, 1, 1, 'PENDING_APPROVAL', 'PENDING', 'Cedar Falls', 'IA', '50613', 42.5348, -92.4453);
END;

-- Telemetry Seeds
IF NOT EXISTS (SELECT 1 FROM equipment_telemetry)
BEGIN
    INSERT INTO equipment_telemetry (equipment_id, engine_hours, fuel_level_percent, def_fluid_percent, battery_voltage, coolant_temp_f, oil_pressure_psi, gps_latitude, gps_longitude, next_service_hours)
    SELECT id, engine_hours, 88, 92, 12.8, 182, 51, latitude, longitude, engine_hours + 150
    FROM equipment;
END;

-- Booking Seeds
IF NOT EXISTS (SELECT 1 FROM bookings)
BEGIN
    DECLARE @farmer BIGINT = (SELECT TOP 1 id FROM users WHERE email = 'david.miller@farmmail.com');
    DECLARE @eq1 BIGINT = (SELECT TOP 1 id FROM equipment WHERE title = '2023 John Deere 8R 410');
    DECLARE @eq2 BIGINT = (SELECT TOP 1 id FROM equipment WHERE title = '2022 Kuhn Krause 8000-25');
    DECLARE @eq_owner BIGINT = (SELECT TOP 1 owner_id FROM equipment WHERE id = @eq1);

    -- Active Rental
    INSERT INTO bookings (equipment_id, renter_id, owner_id, start_date, end_date, total_days, delivery_method, delivery_address, operator_included, damage_waiver_included, daily_rate, equipment_subtotal, delivery_fee, insurance_fee, escrow_fee, total_amount, status, payment_status, hours_used, hours_allowed, special_instructions)
    VALUES (@eq1, @farmer, @eq_owner, DATEADD(day, -3, SYSUTCDATETIME()), DATEADD(day, 4, SYSUTCDATETIME()), 7, 'DELIVERY', '1240 Harvest Way, Ames, IA 50010', 0, 1, 1450.00, 10150.00, 450.00, 420.00, 250.00, 11270.00, 'ACTIVE', 'ESCROW_HOLD', 24, 70, 'Deliver to field gate 4 on north perimeter. Gate code: 4421.');

    -- Pending Booking Request (In owner urgent queue)
    INSERT INTO bookings (equipment_id, renter_id, owner_id, start_date, end_date, total_days, delivery_method, delivery_address, operator_included, damage_waiver_included, daily_rate, equipment_subtotal, delivery_fee, insurance_fee, escrow_fee, total_amount, status, payment_status, hours_used, hours_allowed, special_instructions)
    VALUES (@eq2, @farmer, @eq_owner, DATEADD(day, 2, SYSUTCDATETIME()), DATEADD(day, 6, SYSUTCDATETIME()), 4, 'PICKUP', 'Cedar Valley Yard, Cedar Rapids, IA', 0, 1, 720.00, 2880.00, 0.00, 140.00, 80.00, 3100.00, 'PENDING', 'ESCROW_HOLD', 0, 40, 'Will arrive with flatbed trailer at 7:30 AM.');
END;

-- Escrow Transactions Seeds
IF NOT EXISTS (SELECT 1 FROM escrow_transactions)
BEGIN
    DECLARE @b1 BIGINT = (SELECT TOP 1 id FROM bookings WHERE status = 'ACTIVE');
    DECLARE @b1_payer BIGINT = (SELECT renter_id FROM bookings WHERE id = @b1);
    DECLARE @b1_payee BIGINT = (SELECT owner_id FROM bookings WHERE id = @b1);
    DECLARE @b1_amount DECIMAL(18,2) = (SELECT total_amount FROM bookings WHERE id = @b1);

    INSERT INTO escrow_transactions (booking_id, payer_id, payee_id, amount, platform_fee, escrow_status, transaction_ref)
    VALUES (@b1, @b1_payer, @b1_payee, @b1_amount, 250.00, 'HELD', 'ESC-202609-00984');
END;

-- Reviews Seeds
IF NOT EXISTS (SELECT 1 FROM reviews)
BEGIN
    DECLARE @r_farmer BIGINT = (SELECT TOP 1 id FROM users WHERE email = 'david.miller@farmmail.com');
    DECLARE @r_eq BIGINT = (SELECT TOP 1 id FROM equipment WHERE title = '2023 John Deere 8R 410');

    INSERT INTO reviews (equipment_id, reviewer_id, rating, comment, equipment_condition_rating, communication_rating)
    VALUES 
    (@r_eq, @r_farmer, 5, 'Exceptional machine. Arrived in spotless mechanical shape with full tanks and pre-calibrated RTK guidance. Marcus was responsive and courteous.', 5, 5);
END;
