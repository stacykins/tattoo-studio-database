/*
============================================================
 Tattoo Studio Management System Database
 Lab Work №2
============================================================

Author: (Ваше ім'я)
Date: 2026
Description:
This file contains:
1. Database schema (DDL)
2. Sample data (DML)
3. Tables, keys and constraints description

============================================================
*/


-- =========================================================
-- 1. DATABASE SCHEMA CREATION (DDL)
-- =========================================================

-- -------------------------
-- Table: Clients
-- -------------------------
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    medical_notes TEXT
);

-- -------------------------
-- Table: Artists
-- -------------------------
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

-- -------------------------
-- Table: Sessions
-- -------------------------
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL
        REFERENCES Clients(client_id)
        ON DELETE CASCADE,
    artist_id INTEGER NOT NULL
        REFERENCES Artists(artist_id)
        ON DELETE RESTRICT,
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL
        CHECK (total_price >= 0)
);

-- -------------------------
-- Table: Tattoos
-- -------------------------
CREATE TABLE Tattoos (
    tattoo_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL
        REFERENCES Sessions(session_id)
        ON DELETE CASCADE,
    body_part VARCHAR(50) NOT NULL,
    description TEXT
);

-- -------------------------
-- Table: Inventory
-- -------------------------
CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0
        CHECK (quantity >= 0)
);

-- -------------------------
-- Table: Material_Usage
-- -------------------------
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL
        REFERENCES Sessions(session_id)
        ON DELETE CASCADE,
    item_id INTEGER NOT NULL
        REFERENCES Inventory(item_id)
        ON DELETE CASCADE,
    amount_used INTEGER NOT NULL
        CHECK (amount_used > 0)
);


-- =========================================================
-- 2. DATA INSERTION (DML - SAMPLE DATA)
-- =========================================================

-- -------------------------
-- Clients
-- -------------------------
INSERT INTO Clients (full_name, phone, medical_notes) VALUES
('Олексій Петренко', '+380501112233', 'Алергія на червоний пігмент'),
('Марія Сидоренко', '+380674445566', NULL),
('Іван Коваленко', '+380937778899', 'Низький больовий поріг');

-- -------------------------
-- Artists
-- -------------------------
INSERT INTO Artists (full_name, specialization) VALUES
('Дмитро Ink', 'Realism'),
('Анна Верес', 'Old School'),
('Віталій Гік', 'Minimalism');

-- -------------------------
-- Inventory
-- -------------------------
INSERT INTO Inventory (item_name, category, quantity) VALUES
('Голки RL-3', 'Needles', 100),
('Фарба Black Dynamic', 'Ink', 20),
('Загоювальна плівка', 'Aftercare', 15);

-- -------------------------
-- Sessions
-- -------------------------
INSERT INTO Sessions (client_id, artist_id, scheduled_at, total_price) VALUES
(1, 1, '2026-04-10 14:00:00', 3500.00),
(2, 2, '2026-04-11 11:00:00', 2000.00),
(3, 3, '2026-04-12 16:30:00', 1500.00);

-- -------------------------
-- Tattoos
-- -------------------------
INSERT INTO Tattoos (session_id, body_part, description) VALUES
(1, 'Передпліччя', 'Портрет лева у реалізмі'),
(2, 'Спина', 'Традиційна роза з мечем'),
(3, 'Зап''ястя', 'Маленький символ нескінченності');

-- -------------------------
-- Material Usage
-- -------------------------
INSERT INTO Material_Usage (session_id, item_id, amount_used) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 1, 1),
(3, 2, 1);


-- =========================================================
-- 3. TABLES AND KEYS DESCRIPTION
-- =========================================================

/*
Table: Clients
- Stores client personal data and medical notes
- PK: client_id

Table: Artists
- Stores tattoo artists and their specialization
- PK: artist_id

Table: Sessions
- Represents appointments between clients and artists
- PK: session_id
- FK: client_id → Clients
- FK: artist_id → Artists

Table: Tattoos
- Describes tattoo work done in each session
- PK: tattoo_id
- FK: session_id → Sessions

Table: Inventory
- Stores consumable materials
- PK: item_id

Table: Material_Usage
- Tracks material usage per session
- PK: usage_id
- FK: session_id → Sessions
- FK: item_id → Inventory
*/


-- =========================================================
-- 4. CONSTRAINTS & ASSUMPTIONS
-- =========================================================

/*
1. Cascading Deletes:
   - Sessions, Tattoos, Material_Usage use ON DELETE CASCADE
   - Deleting a client removes all related sessions and data

2. Referential Integrity:
   - Artists use ON DELETE RESTRICT
   - Prevents deletion of artists assigned to sessions

3. Data Validation:
   - total_price >= 0
   - quantity >= 0
   - amount_used > 0

4. Uniqueness:
   - Client phone numbers are UNIQUE

5. General Notes:
   - Database ensures consistency between sessions, tattoos, and materials
*/


-- =========================================================
-- END OF FILE
-- =========================================================
