# Лабораторна робота 5: Нормалізація бази даних 🛠️

## 1. Аналіз початкової схеми (Lab 2)
Початкова схема містить 6 таблиць: `Clients`, `Artists`, `Sessions`, `Tattoos`, `Inventory`, `Material_Usage`. 
Більшість таблиць вже перебувають у 2NF або 3NF, проте для виконання вимог лабораторної роботи було виявлено та змодельовано потенційні проблеми з надлишковістю в таблиці **Inventory** та таблиці **Tattoos**.

### Виявлені проблеми (Аномалії):
1. **Надлишковість у `Inventory`**: Поле `category` містить повторювані текстові значення ("Needles", "Ink"). Це може призвести до аномалій при оновленні (наприклад, якщо назву категорії потрібно змінити всюди).
2. **Транзитивна залежність у `Tattoos`**: Опис татуювання часто прив'язаний до певного "Стилю", який зараз не винесений в окремий довідник.

---

## 2. Перелік функціональних залежностей (ФЗ)
Для ключових таблиць визначено такі залежності:

* **Таблиця Clients**: `client_id` → `full_name`, `phone`, `medical_notes`
* **Таблиця Inventory**: 
    * `item_id` → `item_name`, `category_id`
    * `category_id` → `category_name` (Транзитивна залежність через категорію)
* **Таблиця Sessions**: `session_id` → `client_id`, `artist_id`, `scheduled_at`, `total_price`

---

## 3. Покроковий процес нормалізації

### Крок 1: Перша нормальна форма (1NF)
**Критерій:** Атомарність значень. 
У вашій схемі Лаби 2 всі дані вже атомарні (немає списків через кому в одній клітинці).
* **Статус:** Виконано.

### Крок 2: Друга нормальна форма (2NF)
**Критерій:** 1NF + відсутність часткових залежностей (неключові атрибути залежать від усього ПК).
У таблиці `Material_Usage` (яка має складений логічний ключ `session_id` + `item_id`), поле `amount_used` залежить від обох компонентів ключа.
* **Статус:** Виконано.

### Крок 3: Третя нормальна форма (3NF)
**Критерій:** 2NF + відсутність транзитивних залежностей (неключовий атрибут не повинен залежати від іншого неключового атрибута).

**Проблема в Inventory:** Поле `category` залежить від `item_id`, але воно логічно формує окрему групу. Щоб уникнути помилок при введенні категорій (наприклад, "Ink" vs "Inks"), створимо таблицю `Categories`.

**Перетворення:**
1. Створюємо таблицю `Item_Categories`.
2. В `Inventory` замінюємо текстове поле `category` на `category_id` (FK).

---

## 4. Оновлений дизайн таблиць та SQL-скрипт

### Зміни (ALTER TABLE та нові сутності):
Нижче наведено фінальний SQL-код, який приводить базу до повної **3NF**.

```sql
-- 1. Створення таблиці категорій (усунення транзитивної залежності в Inventory)
CREATE TABLE Item_Categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Початкове наповнення категорій
INSERT INTO Item_Categories (category_name) VALUES ('Needles'), ('Ink'), ('Aftercare');

-- 2. Переробка таблиці Inventory (Приведення до 3NF)
-- Спочатку видаляємо стару залежність, якщо вона була, або створюємо заново
DROP TABLE IF EXISTS Material_Usage; -- видаляємо через зв'язки
DROP TABLE IF EXISTS Inventory;

CREATE TABLE Inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES Item_Categories(category_id),
    quantity INTEGER NOT NULL DEFAULT 0
);

-- 3. Відновлення таблиці Material_Usage
CREATE TABLE Material_Usage (
    usage_id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES Sessions(session_id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES Inventory(item_id) ON DELETE CASCADE,
    amount_used INTEGER NOT NULL CHECK (amount_used > 0)
);

-- 4. Додавання довідника стилів для таблиці Tattoos
CREATE TABLE Tattoo_Styles (
    style_id SERIAL PRIMARY KEY,
    style_name VARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Tattoo_Styles (style_name) VALUES ('Realism'), ('Old School'), ('Minimalism');

-- Оновлюємо таблицю Tattoos (додаємо зв'язок зі стилем)
ALTER TABLE Tattoos ADD COLUMN style_id INTEGER REFERENCES Tattoo_Styles(style_id);
