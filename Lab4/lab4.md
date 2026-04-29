# Лабораторна робота №4
<div align="right">
<strong>Група:</strong> ІО-44

<strong>Виконала:</strong> Чухрай А.А.

<strong>Перевірив:</strong> Русінов В. В.
</div>

## 1. Огляд
У цій лабораторній роботі реалізовано аналітичні (OLAP) запити для бази даних тату-студії. Запити дозволяють отримувати зведену статистику, аналізувати фінансові показники студії, завантаженість майстрів та залишки на складі.

---

# 2. Агрегатні функції та групування

## Запит 1: Базова агрегація (COUNT)

```sql
-- Підрахунок загальної кількості зареєстрованих клієнтів у базі студії.
SELECT COUNT(client_id) AS total_clients 
FROM Clients;
```
## Запит 2: Базова агрегація (MIN, MAX, AVG)
```sql
-- Аналіз цінової політики студії: пошук мінімального, максимального та середнього чеку за сеанс.
SELECT 
    MIN(total_price) AS min_price, 
    MAX(total_price) AS max_price, 
    ROUND(AVG(total_price), 2) AS avg_price 
FROM Sessions;
```
## Запит 3: Групування (GROUP BY)
```sql
-- Аналіз завантаженості: підрахунок кількості запланованих сеансів для кожного окремого майстра.
SELECT artist_id, COUNT(session_id) AS total_sessions 
FROM Sessions 
GROUP BY artist_id;
```
## Запит 4: Фільтрування груп (HAVING)
```sql
-- Пошук найбільш прибуткових майстрів (ті, чиї сумарні замовлення перевищують 2000 грн).
SELECT artist_id, SUM(total_price) AS total_revenue 
FROM Sessions 
GROUP BY artist_id 
HAVING SUM(total_price) > 2000;
```
# 3. Об'єднання таблиць (JOIN)
## Запит 5: INNER JOIN (Багатотаблична вибірка)
```sql
-- Зведення даних з трьох таблиць для створення зрозумілого розкладу (Ім'я клієнта, Ім'я майстра, Час сеансу, Ціна).
SELECT 
    c.full_name AS client_name, 
    a.full_name AS artist_name, 
    s.scheduled_at, 
    s.total_price 
FROM Sessions s
INNER JOIN Clients c ON s.client_id = c.client_id
INNER JOIN Artists a ON s.artist_id = a.artist_id;
```
## Запит 6: LEFT JOIN
```sql
-- Аналіз витрат зі складу. LEFT JOIN гарантує, що у звіті будуть показані всі матеріали складу, навіть ті, які ще жодного разу не використовувались на сеансах.
SELECT 
    i.item_name, 
    i.category, 
    SUM(mu.amount_used) AS total_used 
FROM Inventory i
LEFT JOIN Material_Usage mu ON i.item_id = mu.item_id
GROUP BY i.item_name, i.category;
```
## Запит 7: RIGHT JOIN
```sql
-- Виведення списку майстрів. RIGHT JOIN забезпечує відображення абсолютно всіх майстрів студії, включно з тими, до кого наразі немає записів.
SELECT 
    a.full_name AS artist_name, 
    a.specialization,
    s.scheduled_at
FROM Sessions s
RIGHT JOIN Artists a ON s.artist_id = a.artist_id;
```
# 5. Використання підзапитів
## Запит 8: Підзапит у WHERE
```sql
-- Знайти клієнтів, які замовили дорогі татуювання (вартість їхнього сеансу вища за середній чек по всій студії).
SELECT full_name, phone 
FROM Clients 
WHERE client_id IN (
    SELECT client_id 
    FROM Sessions 
    WHERE total_price > (SELECT AVG(total_price) FROM Sessions)
);
```
## Запит 9: Підзапит у SELECT
```sql
-- Отримання списку всіх клієнтів із додаванням динамічної колонки, яка показує загальну кількість їхніх візитів до студії.
SELECT 
    full_name, 
    phone,
    (SELECT COUNT(*) FROM Sessions s WHERE s.client_id = c.client_id) AS total_visits
FROM Clients c;
```
## Запит 10: Підзапит у HAVING
```sql
-- Аналітика доходу майстрів: показати ID майстрів, чий сумарний дохід більший, ніж середня вартість одного сеансу у всій базі.
SELECT 
    artist_id, 
    SUM(total_price) AS total_earned 
FROM Sessions 
GROUP BY artist_id 
HAVING SUM(total_price) > (SELECT AVG(total_price) FROM Sessions);
```
