DROP TABLE IF EXISTS rental_flight, rentals, route, airport, waypoint;
DROP TABLE IF EXISTS pilot;
DROP TABLE IF EXISTS planes, users;

CREATE TABLE IF NOT EXISTS waypoint(
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name varchar(20) NOT NULL UNIQUE,
    x float NOT NULL,
    y float NOT NULL
);

CREATE TABLE IF NOT EXISTS airport(
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name varchar(20) NOT NULL,
    icao varchar(5) NOT NULL UNIQUE,
    id_waypoint int REFERENCES waypoint(id)
);

CREATE TABLE IF NOT EXISTS route(
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_from_waypoint int NOT NULL REFERENCES waypoint(id),
    id_to_waypoint int NOT NULL REFERENCES waypoint(id),
    distance float,
    CONSTRAINT different_waypoints CHECK (id_from_waypoint != id_to_waypoint)
);

CREATE OR REPLACE FUNCTION calculate_route_distance()
RETURNS TRIGGER AS $$
DECLARE
    from_x float;
    from_y float;
    to_x float;
    to_y float;
BEGIN
    -- Получаем координаты начальной точки
    SELECT x, y INTO from_x, from_y 
    FROM waypoint 
    WHERE id = NEW.id_from_waypoint;
    
    -- Получаем координаты конечной точки
    SELECT x, y INTO to_x, to_y 
    FROM waypoint 
    WHERE id = NEW.id_to_waypoint;
    
    -- Вычисляем евклидово расстояние
    NEW.distance := SQRT(POWER(to_x - from_x, 2) + POWER(to_y - from_y, 2));
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE OR REPLACE TRIGGER trigger_calculate_distance
    BEFORE INSERT OR UPDATE OF id_from_waypoint, id_to_waypoint ON route
    FOR EACH ROW
    EXECUTE FUNCTION calculate_route_distance();

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
    id_arrival_airport int REFERENCES airport(id),
    id_departure_airport int REFERENCES airport(id),
    is_maintenance boolean DEFAULT FALSE,
    maintenance_cost int NOT NULL,
    refuel_cost int NOT NULL,
    status varchar(10) DEFAULT 'ACTIVE'
);

CREATE TABLE IF NOT EXISTS rental_flight (
    id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_rental int REFERENCES rentals(id),
    id_route int REFERENCES route(id),
    stage int NOT NULL
);

-- Вставляем waypoints (навигационные точки)
INSERT INTO waypoint (name, x, y) VALUES 
-- Основные точки воздушных коридоров
('VORON', 100.0, 150.0), -- 1
('ROSTA', 180.0, 200.0), -- 2
('BELKA', 250.0, 300.0), -- 3
('STREL', 350.0, 400.0), -- 4
('VETKA', 450.0, 350.0), -- 5
('KEDR', 300.0, 200.0), -- 6
('BUKET', 400.0, 250.0), -- 7
('OMEGA', 500.0, 300.0), -- 8
('ALPHA', 150.0, 400.0), -- 9
('BRAVO', 280.0, 450.0), -- 10
('CHARL', 420.0, 500.0), -- 11
('DELTA', 550.0, 450.0), -- 12
('ECHO', 600.0, 350.0), -- 13
('FOXT', 650.0, 250.0), -- 14
('GOLF', 200.0, 100.0); -- 15

-- Вставляем аэропорты (с привязкой к waypoints)
INSERT INTO airport (name, icao, id_waypoint) VALUES 
-- Международные аэропорты
('Шереметьево', 'UUEE', 1),
('Домодедово', 'UUDD', 3),
('Внуково', 'UUWW', 8),
('Пулково', 'ULLI', 14),
('Кольцово', 'USSS', 10),
-- Региональные аэропорты
('Толмачево', 'UNNT', 11);

-- Вставляем маршруты между точками
INSERT INTO route (id_from_waypoint, id_to_waypoint) VALUES 
-- Прямые маршруты
(1, 2),    -- VORON → ROSTA
(1, 15),   -- VORON → GOLF
(2, 15),   -- ROSTA → GOLF
(2, 3),    -- ROSTA → BELKA
(2, 6),    -- ROSTA → KEDR
(3, 9),    -- BELKA → ALPHA
(3, 4),    -- BELKA → STREL
(9, 10),   -- ALPHA → BRAVO
(4, 10),   -- STREL → BRAVO
(4, 11),   -- STREL → CHARL
(4, 5),    -- STREL → VETKA
(11, 12),  -- CHARL → DELTA
(12, 13),  -- DELTA → ECHO
(13, 5),   -- ECHO → VETKA
(5, 8),    -- VETKA → OMEGA
(5, 7),    -- VETKA → BUKET
(7, 8),    -- BUKET → OMEGA
(7, 6),    -- BUKET → KEDR
(8, 14),   -- OMEGA → FOXT

-- Обратные маршруты
(2, 1),    -- ROSTA → VORON
(15, 1),   -- GOLF → VORON
(15, 2),   -- GOLF → ROSTA
(3, 2),    -- BELKA → ROSTA
(6, 2),    -- KEDR → ROSTA
(9, 3),    -- ALPHA → BELKA
(4, 3),    -- STREL → BELKA
(10, 9),   -- BRAVO → ALPHA
(10, 4),   -- BRAVO → STREL
(11, 4),   -- CHARL → STREL
(5, 4),    -- VETKA → STREL
(12, 11),  -- DELTA → CHARL
(13, 12),  -- ECHO → DELTA
(5, 13),   -- VETKA → ECHO
(8, 5),    -- OMEGA → VETKA
(7, 5),    -- BUKET → VETKA
(8, 7),    -- OMEGA → BUKET
(6, 7),    -- KEDR → BUKET
(14, 8);   -- FOXT → OMEGA

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