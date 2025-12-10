DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS pilot;
DROP TABLE IF EXISTS planes, users;

CREATE TABLE IF NOT EXISTS planes (
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name varchar(50) NOT NULL,
    tank_capacity float NOT NULL,
    fuel float NOT NULL DEFAULT 0,
    is_available boolean DEFAULT TRUE,
    rating float DEFAULT 0.0,
    rental_cost decimal(10,2) NOT NULL,
    fuel_consumption float NOT NULL,
    maintenance_cost decimal(10,2) NOT NULL,
    condition varchar(20) DEFAULT 'excellent',
    mileage float DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS users (
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username varchar(100) NOT NULL,
    login varchar(50) NOT NULL UNIQUE,
    password varchar(200) NOT NULL,
    role varchar(20) DEFAULT 'PILOT'
);

CREATE TABLE IF NOT EXISTS pilot (
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user int REFERENCES users(id),
    license varchar(50) NOT NULL UNIQUE,
    mileage float DEFAULT 0.0,
    balance money DEFAULT 0.0
);

CREATE TABLE IF NOT EXISTS rentals (
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT REFERENCES users(id),
    id_plane INT REFERENCES planes(id),
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    status varchar(10) DEFAULT 'ACTIVE'
);

INSERT 
INTO users (username, login, password, role) 
VALUES ('admin', 'admin', '$2a$10$4Jj2PjsFua9wu12v2zlzRuBUrh5Bkf6oK82aiUyN11289YM0.fK9u', 'ADMINISTRATOR')
RETURNING *;

-- Вставка тестовых данных для истребителей
INSERT INTO planes (name, tank_capacity, fuel, is_available, rating, rental_cost, fuel_consumption, maintenance_cost, condition, mileage) VALUES
-- Российские истребители
('Су-30СМ', 9500, 8500, TRUE, 4.8, 25000.00, 4500, 1500000.00, 'EXCELLENT', 1250),
('Су-35С', 11500, 10500, TRUE, 4.9, 35000.00, 5000, 1800000.00, 'EXCELLENT', 850),
('МиГ-29', 4300, 4000, TRUE, 4.5, 15000.00, 3800, 800000.00, 'GOOD', 2100),
('Су-57', 10500, 9500, FALSE, 4.95, 75000.00, 5200, 3500000.00, 'EXCELLENT', 350),

-- Американские истребители
('F-15 Eagle', 6100, 5500, TRUE, 4.7, 30000.00, 4200, 1200000.00, 'GOOD', 1800),
('F-16 Fighting Falcon', 3900, 3500, TRUE, 4.6, 18000.00, 3200, 900000.00, 'FAIR', 2500),
('F-22 Raptor', 8200, 7800, FALSE, 4.9, 85000.00, 4800, 4000000.00, 'EXCELLENT', 600),
('F-35 Lightning II', 8400, 8000, TRUE, 4.8, 65000.00, 4600, 3200000.00, 'EXCELLENT', 450),

-- Европейские истребители
('Eurofighter Typhoon', 5000, 4500, TRUE, 4.7, 40000.00, 4100, 2000000.00, 'GOOD', 1200),
('Dassault Rafale', 4700, 4200, TRUE, 4.75, 42000.00, 3900, 1900000.00, 'EXCELLENT', 950),

-- Китайские истребители
('Chengdu J-20', 11000, 10000, TRUE, 4.85, 55000.00, 5100, 2800000.00, 'EXCELLENT', 400),
('Shenyang J-11', 9000, 8200, TRUE, 4.6, 22000.00, 4400, 1400000.00, 'GOOD', 1500),

-- Советские истребители (классика)
('Су-27', 9400, 8800, TRUE, 4.7, 20000.00, 4600, 1100000.00, 'FAIR', 3000),
('МиГ-21', 2200, 1800, TRUE, 4.3, 8000.00, 2500, 400000.00, 'POOR', 4200),

-- Многоцелевые истребители
('Су-34', 12100, 11000, TRUE, 4.8, 45000.00, 5500, 2200000.00, 'GOOD', 1100),
('МиГ-31', 17350, 16000, FALSE, 4.6, 38000.00, 6000, 2500000.00, 'EXCELLENT', 2000);