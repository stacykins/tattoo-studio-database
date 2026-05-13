# Лабораторна робота 5: Нормалізація бази даних

## Мета роботи

Проаналізувати структуру бази даних тату-студії, визначити надлишковість та аномалії даних, виконати нормалізацію таблиць до 3NF та побудувати оновлену структуру бази даних.

---

# 1. Початковий дизайн таблиць

Для демонстрації процесу нормалізації припустимо, що на початковому етапі проектування всі дані про сеанси, клієнтів, майстрів та використані матеріали зберігались в одній таблиці.

## Таблиця `studio_records_draft`

| Поле | Опис |
|---|---|
| session_id | ID сеансу |
| client_name | Ім’я клієнта |
| client_phone | Телефон клієнта |
| artist_name | Ім’я майстра |
| artist_specialization | Спеціалізація |
| session_date | Дата сеансу |
| total_price | Загальна ціна |
| items_used | Список використаних матеріалів |

---

## Приклад значення поля `items_used`

```text
"Голка RL-3: 2, Фарба Black Dynamic: 1"
```

---

# 1.1 Визначення нормальної форми початкової схеми

Початкова таблиця `studio_records_draft` не відповідає навіть першій нормальній формі (1NF), оскільки поле `items_used` містить множинні значення та неатомарні дані.

У одному полі зберігається:
- назва матеріалу,
- кількість,
- список декількох матеріалів.

Це порушує вимогу атомарності атрибутів.

---

## Проблеми початкової схеми

### Порушення 1NF
Поле `items_used` містить множинні значення.

### Порушення 2NF
Деякі атрибути залежать лише від частини складеного ключа:
- `item_name` залежить лише від `item_id`.

### Порушення 3NF
Існують транзитивні залежності:
- `client_id -> client_phone`
- `artist_id -> specialization`

---

## Аномалії початкової схеми

### Аномалія вставки
Неможливо додати новий матеріал без створення сеансу.

### Аномалія оновлення
Якщо телефон клієнта зміниться, його доведеться оновлювати у багатьох рядках.

### Аномалія видалення
При видаленні останнього сеансу клієнта може бути втрачена інформація про самого клієнта.

---

## Висновок

Отже, початкова схема знаходиться у ненормалізованій формі (0NF).

---

# 2. Функціональні залежності (ФЗ)

Для початкової таблиці `studio_records_draft` визначено такі функціональні залежності.

## Основні функціональні залежності

1.

```text
session_id → client_id, artist_id, session_date, total_price
```

2.

```text
client_id → client_name, client_phone, medical_notes
```

3.

```text
artist_id → artist_name, artist_specialization
```

4.

```text
item_id → item_name, category
```

5.

```text
(session_id, item_id) → amount_used
```

---

## Кандидатний ключ

Оскільки один сеанс може містити багато матеріалів, а один матеріал може використовуватись у багатьох сеансах, природним ключем є:

```text
(session_id, item_id)
```

---

## Аналіз залежностей

### Часткові залежності
- `item_name` залежить лише від `item_id`
- `category` залежить лише від `item_id`

### Транзитивні залежності
- `client_phone` залежить від `client_id`
- `artist_specialization` залежить від `artist_id`

---

# 3. Процес нормалізації

# 3.1 Перехід до 1NF

## Проблема

Поле `items_used` містить множинні значення:

```text
"Голка RL-3: 2, Фарба Black Dynamic: 1"
```

Це порушує атомарність атрибутів.

---

## Рішення

Кожен використаний матеріал переноситься в окремий рядок.

---

## Таблиця після 1NF

```text
session_1nf(
    session_id,
    item_id,
    client_name,
    client_phone,
    artist_name,
    artist_specialization,
    session_date,
    total_price,
    item_name,
    category,
    amount_used
)
```

### Первинний ключ

```text
(session_id, item_id)
```

---

## Результат

Усі атрибути стали атомарними, тому таблиця відповідає 1NF.

---

# 3.2 Перехід до 2NF

## Проблема

У таблиці `session_1nf` існують часткові залежності:

- `item_name` залежить лише від `item_id`
- `category` залежить лише від `item_id`
- дані сеансу залежать лише від `session_id`

---

## Рішення

Таблиця декомпозується на:
- таблицю сеансів,
- таблицю матеріалів,
- таблицю використання матеріалів.

---

## Таблиці після 2NF

### Таблиця `sessions_2nf`

```text
sessions_2nf(
    session_id,
    client_id,
    artist_id,
    scheduled_at,
    total_price
)
```

---

### Таблиця `inventory_2nf`

```text
inventory_2nf(
    item_id,
    item_name,
    category,
    quantity
)
```

---

### Таблиця `material_usage`

```text
material_usage(
    session_id,
    item_id,
    amount_used
)
```

---

## Результат

Усі неключові атрибути повністю залежать від первинного ключа.

Таблиці відповідають 2NF.

---

# 3.3 Перехід до 3NF

## Проблема

У таблиці `sessions_2nf` присутні транзитивні залежності:

```text
session_id → client_id → client_name, client_phone
```

```text
session_id → artist_id → artist_specialization
```

---

## Рішення

Інформація про клієнтів та майстрів переноситься в окремі таблиці.

---

## Фінальні таблиці у 3NF

### Clients

```text
Clients(
    client_id,
    full_name,
    phone,
    medical_notes
)
```

---

### Artists

```text
Artists(
    artist_id,
    full_name,
    specialization
)
```

---

### Sessions

```text
Sessions(
    session_id,
    client_id,
    artist_id,
    scheduled_at,
    total_price
)
```

---

### Inventory

```text
Inventory(
    item_id,
    item_name,
    category,
    quantity
)
```

---

### Material_Usage

```text
Material_Usage(
    usage_id,
    session_id,
    item_id,
    amount_used
)
```

---

### Tattoos

```text
Tattoos(
    tattoo_id,
    session_id,
    body_part,
    description
)
```

---

## Результат

- відсутні часткові залежності;
- відсутні транзитивні залежності;
- кожен неключовий атрибут залежить лише від первинного ключа.

Фінальна схема відповідає 3NF.

---

# 4. Трансформація структури таблиць

Після декомпозиції ненормалізованої таблиці були створені окремі сутності та встановлені обмеження цілісності даних.

---

## ALTER TABLE

```sql
-- Встановлення зв'язку між сеансом та клієнтом
ALTER TABLE Sessions
ADD CONSTRAINT fk_session_client
FOREIGN KEY (client_id)
REFERENCES Clients(client_id)
ON DELETE CASCADE;

-- Встановлення зв'язку між сеансом та майстром
ALTER TABLE Sessions
ADD CONSTRAINT fk_session_artist
FOREIGN KEY (artist_id)
REFERENCES Artists(artist_id)
ON DELETE RESTRICT;

-- Перевірка позитивної ціни
ALTER TABLE Sessions
ADD CONSTRAINT chk_positive_price
CHECK (total_price >= 0);

-- Зв'язок таблиці використання матеріалів зі складом
ALTER TABLE Material_Usage
ADD CONSTRAINT fk_usage_item
FOREIGN KEY (item_id)
REFERENCES Inventory(item_id)
ON DELETE CASCADE;
```

---

# 5. SQL DDL Скрипти

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

-- 3. Сеанси
CREATE TABLE Sessions (
    session_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    artist_id INTEGER NOT NULL REFERENCES Artists(artist_id) ON DELETE RESTRICT,
    scheduled_at TIMESTAMP NOT NULL,
    total_price DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (total_price >= 0)
);

-- 4. Татуювання
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

-- 6. Використання матеріалів
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INTEGER NOT NULL CHECK (amount_used > 0)
);
```

---


# 6. # Початкова та фінальна ER-схеми

## Початкова (ненормалізована) схема

Під час аналізу було визначено, що схема з лабораторної роботи №2 вже була близькою до 3NF. Тому для демонстрації процесу нормалізації було реконструйовано початкову ненормалізовану таблицю `studio_records_draft`, яка моделює ранній етап проєктування бази даних.

У цій таблиці всі дані про:
- клієнтів,
- майстрів,
- сеанси,
- використані матеріали

зберігалися в одному місці, що призводило до:
- дублювання інформації,
- аномалій вставки,
- аномалій оновлення,
- аномалій видалення.

### ER-діаграма початкової схеми

<img width="334" height="392" alt="image" src="https://github.com/user-attachments/assets/4971d8b8-268f-4474-8ae9-d81e453d3c64" />


---

## Фінальна (нормалізована) схема

Після виконання нормалізації таблиця була декомпозована на окремі сутності:
- Clients
- Artists
- Sessions
- Tattoos
- Inventory
- Material_Usage

У результаті:
- усунено дублювання даних;
- усунено часткові залежності;
- усунено транзитивні залежності;
- забезпечено цілісність даних за допомогою первинних та зовнішніх ключів.

Фінальна схема відповідає третій нормальній формі (3NF).

### ER-діаграма фінальної схеми

<img width="1045" height="437" alt="image" src="https://github.com/user-attachments/assets/15ff4c6e-0562-43b1-955e-1413bc4d88fe" />


# 7. Висновок

У ході лабораторної роботи було проаналізовано початкову ненормалізовану структуру бази даних тату-студії та визначено основні проблеми:
- надлишковість даних;
- аномалії вставки, оновлення та видалення;
- часткові та транзитивні залежності.

Було виконано покрокову нормалізацію до третьої нормальної форми (3NF):
- усунено повторювані групи;
- ліквідовано часткові залежності;
- усунено транзитивні залежності.

У результаті отримано нормалізовану схему бази даних із правильно визначеними первинними та зовнішніми ключами, що забезпечує цілісність даних та зменшує дублювання інформації.
