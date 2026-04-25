# Проєкт бази даних тату-студії — Лабораторна робота №3

## 1. Огляд

Лабораторна робота 3 демонструє виконання OLTP (Online Transaction Processing) операцій у базі даних системи управління тату-студією.  
Звіт містить транзакційні сценарії, які імітують реальні бізнес-процеси тату-салону.

Було реалізовано наступні сценарії транзакцій:
- **Транзакція 1:** Скасування сеансу, видалення записів про матеріали та оновлення нотаток клієнта.
- **Транзакція 2:** Завершення сеансу та оновлення складу.

---

## 2. Транзакція 1 — Скасування сеансу та очищення даних

### Сценарій

Клієнт скасовує запис на сеанс.  
Система:
- обнуляє вартість
- видаляє матеріали
- додає примітку клієнту

### SQL-запит

```sql
BEGIN;

UPDATE Sessions 
SET total_price = 0 
WHERE session_id = 2;

DELETE FROM Material_Usage 
WHERE session_id = 2;

UPDATE Clients 
SET medical_notes = 'Скасовано клієнтом' 
WHERE client_id = 2;

COMMIT;
```

## Перевірка результату
```sql
SELECT 
    c.full_name, 
    c.medical_notes, 
    s.session_id, 
    s.total_price
FROM Clients c
LEFT JOIN Sessions s ON s.client_id = c.client_id
WHERE c.client_id = 2;
```
<img width="657" height="87" alt="image" src="https://github.com/user-attachments/assets/a788a8d7-23b4-4197-bd2f-994a7ab64ade" />


Тут вставити результат виконання запиту (таблицю або скріншот)

## 3. Транзакція 2 — Завершення сеансу та оновлення складу
Сценарій

Після завершення сеансу:

додається 500 грн до вартості
списуються матеріали зі складу
### SQL-запит
```sql
BEGIN;

UPDATE Sessions 
SET total_price = total_price + 500 
WHERE session_id = 1;

UPDATE Inventory 
SET quantity = quantity - 2 
WHERE item_id = 1;

UPDATE Inventory 
SET quantity = quantity - 1 
WHERE item_id = 2;

COMMIT;
```
## Перевірка результату
```sql
SELECT 
    s.session_id, 
    s.total_price, 
    i.item_name, 
    i.quantity AS stock_left
FROM Sessions s
JOIN Material_Usage mu ON mu.session_id = s.session_id
JOIN Inventory i ON i.item_id = mu.item_id
WHERE s.session_id = 1;
```
Результат

Тут вставити результат виконання запиту

## 4. Операції маніпулювання даними

### SELECT
```sql
SELECT full_name, specialization 
FROM Artists 
WHERE specialization = 'Realism';
```
```sql
SELECT session_id, scheduled_at, total_price 
FROM Sessions 
WHERE total_price > 2000 
ORDER BY total_price DESC;
```
```sql
SELECT c.full_name, s.scheduled_at, s.total_price 
FROM Clients c 
JOIN Sessions s ON c.client_id = s.client_id;
```
### INSERT
```sql
INSERT INTO Clients (full_name, phone, medical_notes) 
VALUES ('Катерина Мельник', '+380509998877', 'Немає');
```
```sql
INSERT INTO Inventory (item_name, category, quantity) 
VALUES ('Трансферний папір', 'Paper', 50);
```
### UPDATE

```sql
UPDATE Clients 
SET medical_notes = 'Низький больовий поріг, алергія на латекс' 
WHERE phone = '+380937778899';
```
```sql
UPDATE Sessions 
SET total_price = 2200.00 
WHERE session_id = 3;
```
```sql
UPDATE Inventory 
SET quantity = quantity + 50 
WHERE item_name = 'Голки RL-3';
```
### DELETE
```sql
DELETE FROM Clients 
WHERE phone = '+380509998877';
```
```sql
DELETE FROM Inventory 
WHERE item_name = 'Трансферний папір';
```
