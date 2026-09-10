package com.agrirent.app.config;

import com.agrirent.app.entity.Equipment;
import com.agrirent.app.entity.User;
import com.agrirent.app.repository.EquipmentRepository;
import com.agrirent.app.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private EquipmentRepository equipmentRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        if (userRepository.count() > 0 && equipmentRepository.count() > 0) {
            log.info("Database already initialized with {} users and {} equipment items. Skipping seed.",
                    userRepository.count(), equipmentRepository.count());
            return;
        }

        log.info("Initializing database with demo accounts and Indian equipment catalog...");

        // 1. Seed Demo Users
        String encodedPassword = passwordEncoder.encode("Password123!");

        User farmer1 = new User();
        farmer1.setUsername("farmer1");
        farmer1.setEmail("farmer1@agrirent.demo");
        farmer1.setPassword(encodedPassword);
        farmer1.setFirstName("Ramesh");
        farmer1.setLastName("Patil");
        farmer1.setFullName("Ramesh Patil");
        farmer1.setRole("ROLE_FARMER");
        farmer1.setPhone("9822012341");
        farmer1.setDistrict("Nagpur");
        farmer1.setCity("Nagpur");
        farmer1.setState("Maharashtra");
        farmer1.setZipCode("440001");
        farmer1.setFarmName("Patil Cotton & Soybean Agro");
        farmer1.setIsActive(true);
        farmer1.setIsVerified(true);
        if (!userRepository.existsByEmail(farmer1.getEmail())) {
            farmer1 = userRepository.save(farmer1);
        } else {
            farmer1 = userRepository.findByEmail(farmer1.getEmail()).get();
        }

        User farmer2 = new User();
        farmer2.setUsername("farmer2");
        farmer2.setEmail("farmer2@agrirent.demo");
        farmer2.setPassword(encodedPassword);
        farmer2.setFirstName("Suresh");
        farmer2.setLastName("Deshmukh");
        farmer2.setFullName("Suresh Deshmukh");
        farmer2.setRole("ROLE_FARMER");
        farmer2.setPhone("9822012342");
        farmer2.setDistrict("Pune");
        farmer2.setCity("Baramati");
        farmer2.setState("Maharashtra");
        farmer2.setZipCode("413102");
        farmer2.setFarmName("Deshmukh Sugarcane Farm");
        farmer2.setIsActive(true);
        farmer2.setIsVerified(true);
        if (!userRepository.existsByEmail(farmer2.getEmail())) {
            farmer2 = userRepository.save(farmer2);
        } else {
            farmer2 = userRepository.findByEmail(farmer2.getEmail()).get();
        }

        User owner1 = new User();
        owner1.setUsername("owner1");
        owner1.setEmail("owner1@agrirent.demo");
        owner1.setPassword(encodedPassword);
        owner1.setFirstName("Vikram");
        owner1.setLastName("Shinde");
        owner1.setFullName("Vikram Shinde");
        owner1.setRole("ROLE_OWNER");
        owner1.setPhone("9822012343");
        owner1.setDistrict("Nashik");
        owner1.setCity("Niphad");
        owner1.setState("Maharashtra");
        owner1.setZipCode("422303");
        owner1.setFarmName("Shinde Agro Rental Fleet");
        owner1.setIsActive(true);
        owner1.setIsVerified(true);
        if (!userRepository.existsByEmail(owner1.getEmail())) {
            owner1 = userRepository.save(owner1);
        } else {
            owner1 = userRepository.findByEmail(owner1.getEmail()).get();
        }

        User owner2 = new User();
        owner2.setUsername("owner2");
        owner2.setEmail("owner2@agrirent.demo");
        owner2.setPassword(encodedPassword);
        owner2.setFirstName("Anand");
        owner2.setLastName("Kulkarni");
        owner2.setFullName("Anand Kulkarni");
        owner2.setRole("ROLE_OWNER");
        owner2.setPhone("9822012344");
        owner2.setDistrict("Chhatrapati Sambhajinagar");
        owner2.setCity("Paithan");
        owner2.setState("Maharashtra");
        owner2.setZipCode("431107");
        owner2.setFarmName("Kulkarni Heavy Machinery Hub");
        owner2.setIsActive(true);
        owner2.setIsVerified(true);
        if (!userRepository.existsByEmail(owner2.getEmail())) {
            owner2 = userRepository.save(owner2);
        } else {
            owner2 = userRepository.findByEmail(owner2.getEmail()).get();
        }

        User admin = new User();
        admin.setUsername("admin");
        admin.setEmail("admin@agrirent.demo");
        admin.setPassword(encodedPassword);
        admin.setFirstName("Pooja");
        admin.setLastName("Kadam");
        admin.setFullName("Pooja Kadam");
        admin.setRole("ROLE_ADMIN");
        admin.setPhone("9822012345");
        admin.setDistrict("Pune");
        admin.setCity("Pune");
        admin.setState("Maharashtra");
        admin.setZipCode("411005");
        admin.setFarmName("AgriRent Central Operations");
        admin.setIsActive(true);
        admin.setIsVerified(true);
        if (!userRepository.existsByEmail(admin.getEmail())) {
            admin = userRepository.save(admin);
        } else {
            admin = userRepository.findByEmail(admin.getEmail()).get();
        }

        log.info("Demo users successfully initialized.");

        // 2. Seed Equipment Catalog if empty
        if (equipmentRepository.count() == 0) {
            List<Equipment> catalog = new ArrayList<>();

            catalog.add(createEquip(owner1, "Mahindra 575 DI (45 HP)", "Mahindra", "Mahindra", "575 DI", "XP Plus",
                    2023, "TRACTORS", 45, 180, "2WD", "Diesel", "8 Forward + 2 Reverse",
                    "Popular 45 HP workhorse for puddling, haulage, rotavator, and general farm work across Maharashtra.",
                    "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1800"), new BigDecimal("10500"), new BigDecimal("38000"), new BigDecimal("680000"),
                    true, true, "Nashik", "Niphad", 1600, 48, 2730, "540 RPM", new BigDecimal("4.85")));

            catalog.add(createEquip(owner2, "Swaraj 855 FE (52 HP)", "Swaraj", "Swaraj", "855 FE", "4WD",
                    2023, "TRACTORS", 52, 220, "4WD", "Diesel", "Constant Mesh 8F+2R",
                    "Heavy duty 52 HP tractor designed for deep ploughing, laser levelling, and heavy trailer haulage.",
                    "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("2200"), new BigDecimal("13000"), new BigDecimal("46000"), new BigDecimal("810000"),
                    true, true, "Pune", "Baramati", 2000, 60, 3307, "540 & Multi-speed", new BigDecimal("4.90")));

            catalog.add(createEquip(owner1, "John Deere 5050 D (50 HP)", "John Deere", "John Deere", "5050 D", "PowerPro",
                    2024, "TRACTORS", 50, 110, "2WD", "Diesel", "Collarshift 8F+4R",
                    "Fuel efficient turbocharged 50 HP tractor with oil immersed disc brakes and high hydraulic lift.",
                    "https://images.unsplash.com/photo-1594771804886-a933bb2d609b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("2100"), new BigDecimal("12500"), new BigDecimal("44000"), new BigDecimal("790000"),
                    true, true, "Kolhapur", "Karveer", 1600, 60, 2900, "540 RPM @ 2100 ERPM", new BigDecimal("4.88")));

            catalog.add(createEquip(owner2, "Sonalika DI 745 III Sikander (50 HP)", "Sonalika", "Sonalika", "DI 745 III", "Sikander",
                    2023, "TRACTORS", 50, 290, "2WD", "Diesel", "Constant Mesh",
                    "Powerful 3-cylinder HDM engine with high torque backup for rotary tiller and heavy haulage.",
                    "https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1900"), new BigDecimal("11000"), new BigDecimal("39000"), new BigDecimal("690000"),
                    true, true, "Nagpur", "Kalmeshwar", 1800, 55, 3065, "540 RPM", new BigDecimal("4.80")));

            catalog.add(createEquip(owner1, "Massey Ferguson 241 DI Maha Shakti (42 HP)", "Massey Ferguson", "Massey Ferguson", "241 DI", "Maha Shakti",
                    2022, "TRACTORS", 42, 340, "2WD", "Diesel", "Manual Sliding Mesh",
                    "SIMPSONS engine classic tractor known for maximum mileage and unbeatable dependability.",
                    "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1600"), new BigDecimal("9500"), new BigDecimal("34000"), new BigDecimal("640000"),
                    true, true, "Satara", "Phaltan", 1700, 47, 2500, "540 RPM @ 1790 ERPM", new BigDecimal("4.78")));

            catalog.add(createEquip(owner2, "New Holland 3630 TX Special Edition (55 HP)", "New Holland", "New Holland", "3630 TX", "Super",
                    2024, "TRACTORS", 55, 95, "4WD", "Diesel", "Fully Constant Mesh 8F+2R",
                    "Top rated 55 HP tractor for commercial custom hiring centers, harvesting, and 12-ton haulage.",
                    "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("2500"), new BigDecimal("15000"), new BigDecimal("52000"), new BigDecimal("950000"),
                    true, true, "Chhatrapati Sambhajinagar", "Paithan", 2000, 60, 2931, "Dual Speed PTO", new BigDecimal("4.92")));

            catalog.add(createEquip(owner1, "Kubota MU4501 4WD (45 HP)", "Kubota", "Kubota", "MU4501", "4WD",
                    2023, "TRACTORS", 45, 140, "4WD", "Diesel", "Synchromesh 8F+4R",
                    "Japanese precision engineered 4-cylinder E-CDIS engine for ultra smooth wetland puddling.",
                    "https://images.unsplash.com/photo-1594771804886-a933bb2d609b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("2300"), new BigDecimal("13500"), new BigDecimal("48000"), new BigDecimal("860000"),
                    true, true, "Nashik", "Dindori", 1640, 60, 2434, "Dual PTO 540 & 750", new BigDecimal("4.91")));

            catalog.add(createEquip(owner2, "Farmtrac 60 Powermaxx (55 HP)", "Farmtrac", "Farmtrac", "60 Powermaxx", "T20",
                    2023, "TRACTORS", 55, 210, "2WD", "Diesel", "Full Constant Mesh 16F+4R",
                    "Escorts T20 technology providing 16 forward speeds for specific rotary and soil operations.",
                    "https://images.unsplash.com/photo-1563245372-f21724e3856d?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("2200"), new BigDecimal("13000"), new BigDecimal("45000"), new BigDecimal("780000"),
                    true, true, "Ahmednagar", "Rahata", 1800, 60, 3514, "Multi-Speed & Reverse PTO", new BigDecimal("4.82")));

            catalog.add(createEquip(owner1, "Captain 283 4WD Mini Tractor (28 HP)", "Captain", "Captain", "283 4WD", "Compact",
                    2023, "TRACTORS", 28, 90, "4WD", "Diesel", "Synchromesh 9F+3R",
                    "Best in class compact tractor for pomegranate, grape vineyards, and sugarcane inter-row operations.",
                    "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1200"), new BigDecimal("7000"), new BigDecimal("25000"), new BigDecimal("490000"),
                    true, true, "Solapur", "Pandharpur", 1000, 25, 1318, "540 & 1000 RPM", new BigDecimal("4.87")));

            catalog.add(createEquip(owner2, "Eicher 485 Super DI (45 HP)", "Eicher", "Eicher", "485 Super DI", "Standard",
                    2022, "TRACTORS", 45, 310, "2WD", "Diesel", "Central Shift 8F+2R",
                    "Air-cooled 3-cylinder engine tractor, extremely economical on diesel for long field shifts.",
                    "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1700"), new BigDecimal("10000"), new BigDecimal("35000"), new BigDecimal("650000"),
                    true, true, "Amravati", "Morshi", 1650, 48, 2945, "540 RPM", new BigDecimal("4.75")));

            // Implements
            catalog.add(createEquip(owner1, "Preet 987 Self-Propelled Combine Harvester", "Preet", "Preet", "987", "Multicrop",
                    2023, "HARVESTERS", 101, 150, "4WD", "Diesel", "Heavy Duty Gearbox",
                    "Heavy-duty grain combine harvester for wheat, soybean, gram, and paddy with minimum loss ratio.",
                    "https://images.unsplash.com/photo-1595878715977-2e8f8df18ea8?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("5500"), new BigDecimal("35000"), new BigDecimal("130000"), new BigDecimal("2450000"),
                    true, true, "Nagpur", "Nagpur", 2500, 320, 4088, "Belt & Pulley", new BigDecimal("4.93")));

            catalog.add(createEquip(owner2, "Claas Crop Tiger 40 Combine Harvester", "Claas", "Claas", "Crop Tiger 40", "Terra Trac",
                    2022, "HARVESTERS", 76, 280, "Track", "Diesel", "Hydrostatic Transmission",
                    "Rubber track multi-crop harvester designed specifically for muddy paddy fields and wet conditions.",
                    "https://images.unsplash.com/photo-1595878715977-2e8f8df18ea8?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("6000"), new BigDecimal("38000"), new BigDecimal("145000"), new BigDecimal("2700000"),
                    true, true, "Kolhapur", "Shirol", 2800, 300, 3922, "Direct Hydro", new BigDecimal("4.95")));

            catalog.add(createEquip(owner1, "Shaktiman Regular Light Rotavator (7 Feet)", "Shaktiman", "Shaktiman", "SRL 215", "7 Ft",
                    2024, "TILLAGE", 45, 40, "Attachment", "N/A", "Multi-Speed Gearbox",
                    "Boron steel blades rotary tiller for pulverizing soil and preparing perfect seedbeds in 1 pass.",
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("900"), new BigDecimal("5000"), new BigDecimal("18000"), new BigDecimal("125000"),
                    true, true, "Pune", "Junnar", 500, null, null, "540 RPM", new BigDecimal("4.88")));

            catalog.add(createEquip(owner2, "Maschio Gaspardo Virat 185 Rotary Tiller", "Maschio Gaspardo", "Maschio Gaspardo", "Virat 185", "6 Ft",
                    2023, "TILLAGE", 40, 60, "Attachment", "N/A", "Side Gear Drive",
                    "Italian engineered heavy duty rotavator with waterproof rotor bearing seals for wet and dry fields.",
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("850"), new BigDecimal("4800"), new BigDecimal("17000"), new BigDecimal("118000"),
                    true, true, "Nashik", "Sinnar", 480, null, null, "540 RPM", new BigDecimal("4.86")));

            catalog.add(createEquip(owner1, "Fieldking Extra Heavy Duty Spring Loaded Cultivator (9 Tynes)", "Fieldking", "Fieldking", "FKCH-9", "9 Tynes",
                    2023, "TILLAGE", 35, 80, "Attachment", "N/A", "Direct Linkage",
                    "9-tyne cultivator suitable for uprooting stubble, aerating soil, and deep weeding operations.",
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("600"), new BigDecimal("3200"), new BigDecimal("11000"), new BigDecimal("48000"),
                    true, true, "Satara", "Karad", 380, null, null, "Linkage Cat II", new BigDecimal("4.80")));

            catalog.add(createEquip(owner2, "Lemken Opal 090 2-Bottom Hydraulic Reversible MB Plough", "Lemken", "Lemken", "Opal 090", "2 Bottom",
                    2024, "TILLAGE", 50, 30, "Attachment", "N/A", "Hydraulic Turnover Mechanism",
                    "Premium German engineered mouldboard plough for inversion of soil, weed burial, and soil turnover.",
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1100"), new BigDecimal("6500"), new BigDecimal("24000"), new BigDecimal("195000"),
                    true, true, "Ahmednagar", "Shrirampur", 460, null, null, "Double Acting Hydraulic", new BigDecimal("4.92")));

            catalog.add(createEquip(owner1, "Shaktiman Pneumatic Planter (4-Row Precision)", "Shaktiman", "Shaktiman", "SPP 4R", "4 Rows",
                    2023, "SEEDERS", 45, 50, "Attachment", "N/A", "Vacuum Disc Metering",
                    "High precision vacuum seeder for cotton, corn, and groundnut ensuring uniform depth and spacing.",
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1500"), new BigDecimal("8500"), new BigDecimal("30000"), new BigDecimal("360000"),
                    true, true, "Nagpur", "Hingna", 650, null, null, "540 RPM PTO Fan", new BigDecimal("4.89")));

            catalog.add(createEquip(owner2, "Mitra Bullet 600 Tractor Mounted Orchard Sprayer", "Mitra", "Mitra", "Bullet 600", "600 Litres",
                    2023, "SPRAYERS", 35, 75, "Attachment", "N/A", "High Pressure Diaphragm Pump",
                    "Advanced air-assisted orchard sprayer specifically calibrated for grapes, pomegranate, and citrus.",
                    "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1200"), new BigDecimal("6800"), new BigDecimal("24000"), new BigDecimal("185000"),
                    true, true, "Nashik", "Nashik", 420, 600, null, "540 RPM", new BigDecimal("4.91")));

            catalog.add(createEquip(owner1, "Toku Multicrop Automatic Thresher (Tractor Driven)", "Toku", "Toku", "T-750", "Multicrop",
                    2022, "HARVESTERS", 35, 190, "Stationary", "N/A", "Double Blower & Sieve",
                    "High throughput crop thresher for soybean, wheat, pigeon pea (tur), and mustard with high cleanliness.",
                    "https://images.unsplash.com/photo-1595878715977-2e8f8df18ea8?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("1400"), new BigDecimal("8000"), new BigDecimal("28000"), new BigDecimal("210000"),
                    true, true, "Amravati", "Achalpur", 850, null, null, "540 RPM", new BigDecimal("4.81")));

            catalog.add(createEquip(owner2, "Tara 5-Ton Hydraulic Tipping Agricultural Trailer", "Tara", "Tara", "TT-5000", "5 Ton Double Axle",
                    2023, "HAY_FORAGE", 40, 110, "Towable", "N/A", "Single Ram Hydraulic Tipper",
                    "Heavy-gauge steel side sheets with automated drop side doors for sugarcane and grain transport.",
                    "https://images.unsplash.com/photo-1589923188900-85dae523342b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("800"), new BigDecimal("4500"), new BigDecimal("16000"), new BigDecimal("180000"),
                    true, true, "Kolhapur", "Radhanagari", 1400, null, null, "Hydraulic Coupler", new BigDecimal("4.84")));

            catalog.add(createEquip(owner1, "VST Shakti 135 DI Ultra Power Tiller (13 HP)", "VST Shakti", "VST", "135 DI", "Ultra",
                    2023, "TILLAGE", 13, 160, "2WD Walk-Behind", "Diesel", "6 Forward + 2 Reverse",
                    "Direct injection diesel walk-behind power tiller with integrated rotary blades for small vegetable plots.",
                    "https://images.unsplash.com/photo-1594771804886-a933bb2d609b?w=800&auto=format&fit=crop&q=80",
                    new BigDecimal("800"), new BigDecimal("4200"), new BigDecimal("15000"), new BigDecimal("195000"),
                    true, true, "Pune", "Khed", 380, 11, 673, "Internal Rotary", new BigDecimal("4.85")));

            equipmentRepository.saveAll(catalog);
            log.info("Successfully seeded {} Indian machinery items into database.", catalog.size());
        }
    }

    private Equipment createEquip(User owner, String title, String make, String brand, String model, String variant,
                                  int year, String category, Integer hp, int engineHours, String driveType,
                                  String fuelType, String transmission, String description, String image,
                                  BigDecimal dailyRate, BigDecimal weeklyRate, BigDecimal monthlyRate,
                                  BigDecimal purchasePrice, boolean forRent, boolean forSale,
                                  String district, String city, Integer liftKg, Integer fuelL, Integer engineCc,
                                  String ptoRpm, BigDecimal rating) {
        Equipment eq = new Equipment();
        eq.setOwner(owner);
        eq.setTitle(title);
        eq.setMake(make);
        eq.setBrand(brand);
        eq.setModel(model);
        eq.setVariant(variant);
        eq.setYear(year);
        eq.setCategory(category);
        eq.setHorsepower(hp);
        eq.setEngineHours(engineHours);
        eq.setDriveType(driveType);
        eq.setFuelType(fuelType);
        eq.setTransmission(transmission);
        eq.setDescription(description);
        eq.setImages(image);
        eq.setDailyRate(dailyRate);
        eq.setWeeklyRate(weeklyRate);
        eq.setMonthlyRate(monthlyRate);
        eq.setSecurityDeposit(dailyRate.multiply(new BigDecimal("2")));
        eq.setPurchasePrice(purchasePrice);
        eq.setIsForRent(forRent);
        eq.setIsForSale(forSale);
        eq.setStatus("AVAILABLE");
        eq.setApprovalStatus("APPROVED");
        eq.setDistrict(district);
        eq.setLocationAddress(city + ", " + district + ", Maharashtra");
        eq.setCity(city);
        eq.setState("Maharashtra");
        eq.setZipCode("411001");
        eq.setLiftingCapacityKg(liftKg);
        eq.setFuelTankLitres(fuelL);
        eq.setEngineCc(engineCc);
        eq.setPtoRpm(ptoRpm);
        eq.setRating(rating);
        eq.setCurrency("INR");
        eq.setPriceType("FIXED");
        eq.setPriceSourceName("TractorJunction Ex-Showroom Maharashtra");
        eq.setPriceSourceUrl("https://www.tractorjunction.com");
        return eq;
    }
}
