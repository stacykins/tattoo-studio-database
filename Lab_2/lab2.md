# 🎨 Tattoo Studio Management System Database – Lab №2

## 1. Implementation (SQL Script)

### 1.1 Database Schema Creation (DDL)
```sql
-- ==========================================
-- 1. DATABASE SCHEMA CREATION (DDL)
-- ==========================================

-- Table: Clients
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    medical_notes TEXT
);

-- Table: Artists
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

-- Table: Sessions
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE RESTRICT,
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

-- Table: Tattoos
CREATE TABLE Tattoos (
    tattoo_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    body_part VARCHAR(50) NOT NULL,
    description TEXT
);

-- Table: Inventory
CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0)
);

-- Table: Material_Usage
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INTEGER NOT NULL CHECK (amount_used > 0)
);

-- ==========================================
-- 2. DATA INSERTION (DML - Sample Data)
-- ==========================================

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
(2, 1, 1),
(3, 2, 1);
## 2. Tables and Keys Mapping

| Table           | Description                              | Primary Key | Foreign Keys              |
|----------------|------------------------------------------|------------|---------------------------|
| Clients        | Stores client info and medical notes     | client_id  | —                         |
| Artists        | Tattoo artists and their specialization  | artist_id  | —                         |
| Sessions       | Appointments between clients and artists | session_id | client_id, artist_id      |
| Tattoos        | Details of tattoos performed             | tattoo_id  | session_id                |
| Inventory      | Materials and consumables                | item_id    | —                         |
| Material_Usage | Tracks material usage per session        | usage_id   | session_id, item_id       |

## 3. Constraints & Assumptions

### Referential Integrity

- **ON DELETE CASCADE**: Sessions, Tattoos, Material_Usage – automatically deletes dependent records  
- **ON DELETE RESTRICT**: Artists – prevents deletion if linked sessions exist  

### Data Validation

- total_price >= 0  
- quantity >= 0  
- amount_used > 0  

### Uniqueness

- Clients.phone is UNIQUE – prevents duplicate client records  

## 4. Results

The database was successfully:

- Created in pgAdmin  
- Populated with sample data  
- Verified for correct relationships, constraint enforcement, and data consistency  

## 5. Summary

This database design:

- Ensures data integrity  
- Supports real-world tattoo studio workflows  
- Demonstrates proper use of Primary & Foreign Keys, Constraints, and Relational structure
