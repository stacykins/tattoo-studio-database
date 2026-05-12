# Лабораторна робота 5: Нормалізація бази даних 🛠️

## 1. Аналіз початкової схеми
Для демонстрації процесу нормалізації ми проаналізуємо таблицю **Service_Log**, яка в ненормалізованому стані містила надлишкові дані про клієнтів, майстрів та використані матеріали.

### Оригінальна (проблемна) таблиця: `Service_Log`
| Column | Опис | Проблема |
| :--- | :--- | :--- |
| `session_id` | PK | — |
| `client_name` | Ім'я клієнта | Дублюється при кожному візиті |
| `client_phone` | Телефон клієнта | Дублюється |
| `artist_id` | ID майстра | — |
| `artist_name` | Ім'я майстра | Залежить від artist_id, а не від session_id |
| `tattoo_style` | Стиль тату | — |
| `items_used` | Список матеріалів | **Порушує 1NF** (декілька значень в комірці) |

---

## 2. Перелік функціональних залежностей (ФЗ)
Для коректної декомпозиції визначимо зв'язки між атрибутами:

1.  `session_id` → `artist_id`, `tattoo_style`, `date` (Основна залежність)
2.  `client_id` → `client_name`, `client_phone` (Дані клієнта залежать від його ID)
3.  `artist_id` → `artist_name`, `specialization` (Дані майстра залежать від його ID)
4.  `item_id` → `item_name`, `category` (Дані складу)

---

## 3. Процес нормалізації step-by-step

### Крок 1: Перша нормальна форма (1NF)
**Критерій:** Усі атрибути є атомарними, відсутні групи, що повторюються.
* **Проблема:** Поле `items_used` містило список (наприклад: "Голка 3RL, Фарба Black, Спирт").
* **Рішення:** Виносимо матеріали в окрему таблицю зв'язку `Material_Usage`, де кожен рядок — це один використаний предмет для одного сеансу.



### Крок 2: Друга нормальна форма (2NF)
**Критерій:** Таблиця в 1NF + відсутні часткові залежності (кожен неключовий атрибут залежить від **усього** ключа).
* **Проблема:** У таблиці сеансів дані клієнта (`client_name`) залежали лише від частини інформації, що призводило до дублювання, якщо клієнт приходить двічі.
* **Рішення:** Створюємо окрему таблицю `Clients`. Тепер у таблиці `Sessions` зберігається лише `client_id` (FK).

### Крок 3: Третя нормальна форма (3NF)
**Критерій:** Таблиця в 2NF + відсутні транзитивні залежності (неключові атрибути не залежать один від одного).
* **Проблема:** `artist_name` залежить від `artist_id`, а той у свою чергу від `session_id`. Це транзитивна залежність.
* **Рішення:** Виносимо дані майстрів у таблицю `Artists`. У сеансах залишаємо тільки `artist_id`.

---

## 4. Фінальна архітектура (3NF)

Після проведення декомпозиції ми отримали наступну структуру:

1.  **Clients** (`client_id`, full_name, phone) — *Дані клієнта зберігаються 1 раз.*
2.  **Artists** (`artist_id`, full_name, specialization) — *Дані майстра незалежні.*
3.  **Inventory** (`item_id`, item_name, category) — *Довідник матеріалів.*
4.  **Sessions** (`session_id`, client_id, artist_id, scheduled_at, price) — *Центральна таблиця зв'язків.*
5.  **Material_Usage** (`usage_id`, session_id, item_id, amount) — *Деталізація витрат.*

---

## 5. Оновлений SQL DDL (Normalized Schema)

```sql
-- Видалення старих таблиць для чистого перезапуску
DROP TABLE IF EXISTS Material_Usage;
DROP TABLE IF EXISTS Sessions;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Artists;
DROP TABLE IF EXISTS Inventory;

-- 1. Таблиця Клієнтів (3NF)
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL
);

-- 2. Таблиця Майстрів (3NF)
CREATE TABLE Artists (
    artist_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50)
);

-- 3. Таблиця Сеансів (3NF)
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES Clients(client_id) ON DELETE CASCADE,
    artist_id INT REFERENCES Artists(artist_id) ON DELETE SET NULL,
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10, 2) CHECK (total_price >= 0)
);

-- 4. Таблиця Складу (3NF)
CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50)
);

-- 5. Таблиця Витрат матеріалів (Зв'язок Many-to-Many)
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INT REFERENCES Sessions(session_id),
    item_id INT REFERENCES Inventory(item_id),
    amount_used INT NOT NULL
);
