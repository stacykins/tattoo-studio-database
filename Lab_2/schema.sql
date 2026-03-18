-- 1. Клієнти
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    medical_notes TEXT
);

-- 2. Майстри
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

-- 3. Сеанси (залежить від Клієнтів та Майстрів)
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE RESTRICT,
    scheduled_at TIMESTAMP NOT NULL CHECK (scheduled_at > NOW()),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

-- 4. Деталі роботи (татуювання)
CREATE TABLE Tattoos (
    tattoo_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    body_part VARCHAR(50) NOT NULL,
    description TEXT
);

-- 5. Склад матеріалів
CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0)
);

-- 6. Витрати матеріалів (таблиця зв'язку багато-до-багатьох)
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INTEGER NOT NULL CHECK (amount_used > 0)
);
