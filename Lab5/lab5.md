Лабораторна робота 5: Нормалізація бази даних
Виконав(ла): [Твоє Ім'я]

1. Початковий дизайн таблиць
Для демонстрації процесу нормалізації припустимо, що на початковому етапі дані тату-студії зберігалися в одному ненормалізованому журналі: studio_log_draft.

Таблиця: studio_log_draft
Стовпці:

session_id (PK)

client_full_name

client_phone

medical_notes

artist_name (ПІБ майстра текстом)

specialization

session_date

total_price

inventory_items_used (наприклад: "Голка RL-3: 2шт, Фарба Black: 1шт")

Аналіз проблеми:
Поточна схема не відповідає 1NF, оскільки стовпець inventory_items_used містить множинні значення (перелік матеріалів через кому). Також присутні транзитивні залежності: спеціалізація майстра залежить від імені майстра, а не від ID сеансу.

2. Функціональні залежності (ФЗ)
Якщо розбити складні поля на окремі атрибути, мінімальний набір ФЗ буде таким:

ФЗ 1 (Повна залежність): {session_id, item_id} -> {amount_used} — Кількість використаного матеріалу залежить від конкретного сеансу та конкретного товару.

ФЗ 2 (Часткова залежність): session_id -> {client_id, artist_id, session_date, price} — Основні дані сеансу залежать лише від ID сеансу.

ФЗ 3 (Транзитивна залежність): client_id -> {client_full_name, client_phone} — Дані клієнта залежать від його ідентифікатора.

ФЗ 4 (Транзитивна залежність): artist_id -> {artist_name, specialization} — Дані майстра залежать від його ідентифікатора.

ФЗ 5 (Транзитивна залежність): item_id -> {item_name, category} — Дані складу залежать від ID товару.

3. Нормалізація
Крок 1: Перехід до 1NF (Атомарність)
Рішення: Розбиваємо поле inventory_items_used на окремі рядки. Тепер кожен запис містить лише один матеріал для одного сеансу.

Крок 2: Перехід до 2NF (Усунення часткових залежностей)
Рішення: Оскільки у нас з'явився складений ключ (сеанс + матеріал), ми відокремлюємо дані про самі сеанси від даних про витрати матеріалів.

Результат: Таблиці Sessions_2NF та Material_Usage.

Крок 3: Перехід до 3NF (Усунення транзитивних залежностей)
Рішення: Виносимо дані клієнтів та майстрів у власні таблиці, щоб уникнути дублювання імен. Також виносимо категорії товарів в окремий довідник.

Результат: Таблиці Clients, Artists, Inventory, Categories.

4. Трансформація структури (ALTER TABLE)
Використовуємо команди ALTER TABLE для встановлення зв'язків та обмежень цілісності у твоїй існуючій базі.

SQL
-- Прив'язуємо сеанс до клієнта
ALTER TABLE Sessions 
ADD CONSTRAINT fk_session_client FOREIGN KEY (client_id) REFERENCES Clients(client_id) ON DELETE CASCADE;

-- Додаємо перевірку ціни (щоб не була від'ємною)
ALTER TABLE Sessions 
ADD CONSTRAINT chk_total_price CHECK (total_price >= 0);

-- Усуваємо текстове дублювання категорій у складі
-- (Припускаємо, що ми вже створили таблицю Item_Categories)
ALTER TABLE Inventory 
ADD COLUMN category_id INT,
ADD CONSTRAINT fk_inventory_category FOREIGN KEY (category_id) REFERENCES Item_Categories(category_id);
5. Перероблений дизайн таблиць (SQL 3NF)
SQL
-- 1. Таблиця Клієнтів
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    medical_notes TEXT
);

-- 2. Таблиця Майстрів
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50) NOT NULL
);

-- 3. Таблиця Сеансів (3NF)
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES Clients(client_id),
    artist_id INT NOT NULL REFERENCES Artists(artist_id),
    scheduled_at TIMESTAMP NOT NULL CHECK (scheduled_at > NOW()),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0)
);

-- 4. Таблиця Складу
CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    quantity INT DEFAULT 0
);

-- 5. Таблиця Витрат (Зв'язок Many-to-Many)
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INT NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INT NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INT NOT NULL CHECK (amount_used > 0)
);



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
    client_id INTEGER NOT NULL REFERENCES Clients(client_id),
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id),
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL DEFAULT 0
);

CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    quantity INTEGER DEFAULT 0
);

CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES Sessions(session_id),
    item_id INTEGER REFERENCES Inventory(item_id),
    amount_used INTEGER NOT NULL
);
