# Tattoo Studio Management System Database Project - Lab №2

## 1. Implementation (SQL Script)
This section includes the DDL (Data Definition Language) to create the schema and DML (Data Manipulation Language) to populate the tables with sample rows to ensure referential integrity.

```sql
-- DATABASE SCHEMA CREATION

CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    medical_notes TEXT
);

CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE RESTRICT,
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

CREATE TABLE Tattoos (
    tattoo_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    body_part VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0)
);

CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INTEGER NOT NULL CHECK (amount_used > 0)
);

-- DATA INSERTION (SAMPLE DATA)

INSERT INTO Clients (full_name, phone, medical_notes) VALUES
('Олексій Петренко', '+380501112233', 'Алергія на червоний пігмент'),
('Марія Сидоренко', '+380674445566', NULL),
('Іван Коваленко', '+380937778899', 'Низький больовий поріг');

INSERT INTO Artists (full_name, specialization) VALUES
('Дмитро Ink', 'Realism'),
('Анна Верес', 'Old School'),
('Віталій Гік', 'Minimalism');

INSERT INTO Inventory (item_name, category, quantity) VALUES
('Голки RL-3', 'Needles', 100),
('Фарба Black Dynamic', 'Ink', 20),
('Загоювальна плівка', 'Aftercare', 15);

INSERT INTO Sessions (client_id, artist_id, scheduled_at, total_price) VALUES
(1, 1, '2026-04-10 14:00:00', 3500.00),
(2, 2, '2026-04-11 11:00:00', 2000.00),
(3, 3, '2026-04-12 16:30:00', 1500.00);

INSERT INTO Tattoos (session_id, body_part, description) VALUES
(1, 'Передпліччя', 'Портрет лева у реалізмі'),
(2, 'Спина', 'Традиційна роза з мечем'),
(3, 'Зап''ястя', 'Маленький символ нескінченності');

INSERT INTO Material_Usage (session_id, item_id, amount_used) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 1, 1);

2. Tables and KeysTableDescriptionPrimary Key (PK)Foreign Keys (FK)ClientsStores personal details and medical notesclient_id—ArtistsTattoo masters and their stylesartist_id—SessionsScheduled appointments between clients and artistssession_idclient_id, artist_idTattoosSpecific details about the tattoo worktattoo_idsession_idInventoryConsumables like ink, needles, etc.item_id—Material_UsageTracks items used during each sessionusage_idsession_id, item_id3. Important Constraints & AssumptionsCascading Deletes: ON DELETE CASCADE is used for Sessions and Tattoos. If a client is removed, their session history is cleaned up automatically.Strict Deletion Policy: For the Artists table, we use ON DELETE RESTRICT. A master cannot be deleted if they still have scheduled sessions.Data Validation:total_price and quantity must be non-negative.amount_used must be greater than zero.Uniqueness: Client phone numbers are UNIQUE to prevent duplicate records.4. Results of data integration into tables in pgAdmin
