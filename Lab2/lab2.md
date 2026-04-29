# Лабораторна робота №2
<div align="right">
<strong>Група:</strong> ІО-44

<strong>Виконала:</strong> Чухрай А.А.

<strong>Перевірив:</strong> Русінов В. В.
</div>


## Тема: 
Перетворення ER-діаграми на схему PostgreSQL
## Мета: 
- Написати SQL DDL-інструкції для створення кожної таблиці з вашої ERD в PostgreSQL.
- Вказати відповідні типи даних для кожного стовпця, вибрати первинний ключ для кожної таблиці та визначити будь-які необхідні зовнішні ключі, обмеження UNIQUE, NOT NULL, CHECK або DEFAULT.
- Вставити зразки рядків (принаймні 3–5 рядків на таблицю) за допомогою `INSERT INTO`.
- Протестувати все в pgAdmin (або іншому клієнті PostgreSQL), щоб переконатися, що таблиці та дані завантажуються правильно.
### 1.1 Створення схеми бази даних (DDL)
```sql

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

-- ==========================================
-- Додаємо клієнтів
INSERT INTO Clients (full_name, phone, medical_notes) VALUES
('Олексій Петренко', '+380501112233', 'Алергія на червоний пігмент'),
('Марія Сидоренко', '+380674445566', NULL),
('Іван Коваленко', '+380937778899', 'Низький больовий поріг');

-- Додаємо майстрів
INSERT INTO Artists (full_name, specialization) VALUES
('Дмитро Ink', 'Realism'),
('Анна Верес', 'Old School'),
('Віталій Гік', 'Minimalism');

-- Додаємо склад
INSERT INTO Inventory (item_name, category, quantity) VALUES
('Голки RL-3', 'Needles', 100),
('Фарба Black Dynamic', 'Ink', 20),
('Загоювальна плівка', 'Aftercare', 15);

-- Додаємо сеанси (припустимо, дати в майбутньому 2026 році)
INSERT INTO Sessions (client_id, artist_id, scheduled_at, total_price) VALUES
(1, 1, '2026-04-10 14:00:00', 3500.00),
(2, 2, '2026-04-11 11:00:00', 2000.00),
(3, 3, '2026-04-12 16:30:00', 1500.00);

-- Додаємо деталі тату
INSERT INTO Tattoos (session_id, body_part, description) VALUES
(1, 'Передпліччя', 'Портрет лева у реалізмі'),
(2, 'Спина', 'Традиційна роза з мечем'),
(3, 'Зап''ястя', 'Маленький символ нескінченності');

-- Додаємо витрати матеріалів
INSERT INTO Material_Usage (session_id, item_id, amount_used) VALUES
(1, 1, 2), -- 2 голки на складну роботу
(1, 2, 1), -- 1 юніт фарби
(2, 1, 1),
(3, 2, 1);
```

# 2. Опис таблиць та зв'язків

| Таблиця | Опис | Первинний ключ | Зовнішні ключі |
|---------|------|----------------|----------------|
| Clients | Інформація про клієнтів та медзаписки | client_id | — |
| Artists | Тату-майстри та їх спеціалізація | artist_id | — |
| Sessions | Записи на сеанси між клієнтами та майстрами | session_id | client_id, artist_id |
| Tattoos | Деталі виконаних татуювань | tattoo_id | session_id |
| Inventory | Матеріали та витратні засоби | item_id | — |
| Material_Usage | Облік використання матеріалів за сеансами | usage_id | session_id, item_id |

# 3. Обмеження та припущення

## Цілісність посилань
- **ON DELETE CASCADE**: Сеанси, татуювання, використання матеріалів – автоматичне видалення залежних записів  
- **ON DELETE RESTRICT**: Майстри – запобігає видаленню, якщо існують пов'язані сеанси

## Валідація даних
- Загальна вартість (`total_price`) >= 0  
- Кількість на складі (`quantity`) >= 0  
- Використана кількість (`amount_used`) > 0

## Унікальність
- Номер телефону клієнта (`Clients.phone`) є унікальним – запобігає дублюванню записів клієнтів

# 4. Результати

<img width="840" height="404" alt="photo_1" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_1_2026-03-19_03-12-24.jpg" />

<img width="792" height="410" alt="photo_2" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_2_2026-03-19_03-12-24.jpg" />

<img width="797" height="414" alt="photo_3" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_3_2026-03-19_03-12-24.jpg" />

<img width="805" height="446" alt="photo_4" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_4_2026-03-19_03-12-24.jpg" />

<img width="1202" height="453" alt="photo_5" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_5_2026-03-19_03-12-24.jpg" />

<img width="1136" height="412" alt="photo_6" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_6_2026-03-19_03-12-24.jpg" />

<img width="1136" height="412" alt="photo_7" src="https://raw.githubusercontent.com/stacykins/tattoo-studio-database/main/Lab_2/photo_7_2026-03-19_03-12-24.jpg" />


# 5. Висновки
- Розроблена структура бази даних забезпечує цілісність даних  
- Підтримує реальні робочі процеси тату-студії  
- Демонструє правильне використання первинних та зовнішніх ключів, обмежень та реляційної структури
