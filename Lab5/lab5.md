# Лабораторна робота 5: Нормалізація бази даних



## 1. Початковий дизайн таблиць
Для демонстрації процесу нормалізації припустимо, що на початковому етапі проектування всі дані про сеанси, майстрів та використані матеріали зберігалися в одній ненормалізованій таблиці `studio_records_draft`.

**Таблиця:** `studio_records_draft`  
**Стовпці:**
* `session_id` (PK)
* `client_name`
* `client_phone`
* `artist_name`
* `artist_specialization`
* `session_date`
* `total_price`
* `items_used` (наприклад: "Голка RL-3: 2, Фарба Black: 1")

**Аналіз проблеми:** Поточна схема не відповідає **1NF**, оскільки стовпець `items_used` містить множинні значення (назва матеріалу та кількість в одному полі). Також присутні часткові та транзитивні залежності, що призводять до дублювання даних про клієнтів та майстрів.

---

## 2. Функціональні залежності (ФЗ)
Після аналізу атрибутів тату-студії визначимо мінімальний набір функціональних залежностей:

* **ФЗ 1 (Повна залежність):** `{session_id, item_id} -> {amount_used}` — Кількість використаного матеріалу залежить виключно від конкретного сеансу та конкретного товару.
* **ФЗ 2 (Часткова залежність):** `session_id -> {client_id, artist_id, scheduled_at, total_price}` — Основні параметри сеансу залежать лише від ID сеансу.
* **ФЗ 3 (Часткова залежність):** `item_id -> {item_name, category}` — Характеристики товару залежать лише від його ідентифікатора.
* **ФЗ 4 (Транзитивна залежність):** `client_id -> {full_name, phone, medical_notes}` — Особисті дані клієнта залежать від ID клієнта, а не від ID сеансу.
* **ФЗ 5 (Транзитивна залежність):** `artist_id -> {full_name, specialization}` — Дані майстра залежать від його ID.

---

## 3. Процес нормалізації

### 1. Перехід до 1NF. Усунення повторюваних груп
**Проблема:** Поле `items_used` порушує атомарність.  
**Рішення:** Створюємо окремі записи для кожного використаного предмета. Первинний ключ стає складеним: `(session_id, item_id)`.  
**Результат:** `session_1nf(session_id, item_id, client_name, client_phone, artist_name, item_name, amount_used, ...)`



### 2. Перехід до 2NF. Усунення часткових залежностей
**Проблема:** Назва товару (`item_name`) залежить лише від `item_id`, а не від усього складеного ключа. Дані клієнта залежать від `session_id`.  
**Рішення:** Декомпозуємо таблицю на сутності: Сеанси, Склад та Витрати.  
**Результат:** * `inventory_2nf(item_id, item_name, category, quantity)`
* `sessions_2nf(session_id, client_name, client_phone, artist_name, ...)`
* `material_usage(session_id, item_id, amount_used)`

### 3. Перехід до 3NF. Усунення транзитивних залежностей
**Проблема:** У таблиці `sessions_2nf` дані клієнта та майстра залежать від їхніх імен, які в свою чергу залежать від ID. Якщо клієнт прийде вдруге, його телефон доведеться записувати знову.  
**Рішення:** Виокремлюємо клієнтів та майстрів у власні таблиці. У таблиці сеансів залишаємо лише зовнішні ключі (FK).  
**Результат (Фінальні таблиці):** `Clients`, `Artists`, `Sessions`, `Inventory`, `Material_Usage`, `Tattoos`.



---

## 4. Трансформація структури (ALTER TABLE)
Для переходу від початкових начерків до нормалізованої структури ми використовуємо команди `ALTER TABLE`:

```sql
-- Встановлення зв'язку між сеансом та клієнтом
ALTER TABLE Sessions 
ADD CONSTRAINT fk_session_client FOREIGN KEY (client_id) REFERENCES Clients(client_id) ON DELETE CASCADE;

-- Встановлення зв'язку між сеансом та майстром
ALTER TABLE Sessions 
ADD CONSTRAINT fk_session_artist FOREIGN KEY (artist_id) REFERENCES Artists(artist_id) ON DELETE RESTRICT;

-- Додавання перевірки на позитивну ціну
ALTER TABLE Sessions 
ADD CONSTRAINT chk_positive_price CHECK (total_price >= 0);

-- Зв'язок таблиці матеріалів зі складом
ALTER TABLE Material_Usage 
ADD CONSTRAINT fk_usage_item FOREIGN KEY (item_id) REFERENCES Inventory(item_id) ON DELETE CASCADE;

```

```sql
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

```

<img width="1124" height="606" alt="image" src="https://github.com/user-attachments/assets/48be2aaf-3f3c-41b1-b4b1-d89662545c92" />


<img width="1221" height="671" alt="image" src="https://github.com/user-attachments/assets/2d7dc414-0d93-438e-bd74-be100105d6f5" />

