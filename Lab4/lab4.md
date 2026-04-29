-- ==========================================================
-- ЛАБОРАТОРНА РОБОТА 4: АНАЛІТИЧНІ ЗАПИТИ (OLAP)
-- ==========================================================

-- ---------------------------------------------------------
-- ЧАСТИНА 1: Агрегатні функції та групування (Мінімум 4 запити)
-- ---------------------------------------------------------

-- 1. Базова агрегація (COUNT): Загальна кількість зареєстрованих клієнтів
SELECT COUNT(client_id) AS total_clients 
FROM Clients;

-- 2. Базова агрегація (MIN, MAX, AVG): Статистика вартості сеансів у студії
SELECT 
    MIN(total_price) AS min_price, 
    MAX(total_price) AS max_price, 
    ROUND(AVG(total_price), 2) AS avg_price 
FROM Sessions;

-- 3. Групування даних (GROUP BY): Кількість запланованих сеансів у кожного майстра
SELECT artist_id, COUNT(session_id) AS total_sessions 
FROM Sessions 
GROUP BY artist_id;

-- 4. Фільтрування груп (HAVING): Майстри, які принесли студії понад 2000 грн
SELECT artist_id, SUM(total_price) AS total_revenue 
FROM Sessions 
GROUP BY artist_id 
HAVING SUM(total_price) > 2000;


-- ---------------------------------------------------------
-- ЧАСТИНА 2: Об'єднання таблиць JOIN (Мінімум 3 запити)
-- ---------------------------------------------------------

-- 1. INNER JOIN (Багатотаблична агрегація): Детальна інформація про розклад (Клієнт + Майстер + Ціна)
SELECT 
    c.full_name AS client_name, 
    a.full_name AS artist_name, 
    s.scheduled_at, 
    s.total_price 
FROM Sessions s
INNER JOIN Clients c ON s.client_id = c.client_id
INNER JOIN Artists a ON s.artist_id = a.artist_id;

-- 2. LEFT JOIN: Статистика використання матеріалів (показує весь склад, навіть якщо матеріал ще не використовували)
SELECT 
    i.item_name, 
    i.category, 
    SUM(mu.amount_used) AS total_used 
FROM Inventory i
LEFT JOIN Material_Usage mu ON i.item_id = mu.item_id
GROUP BY i.item_name, i.category;

-- 3. RIGHT JOIN: Усі майстри та їхні сеанси (покаже всіх майстрів бази, навіть якщо у них наразі немає записів)
SELECT 
    a.full_name AS artist_name, 
    a.specialization,
    s.scheduled_at
FROM Sessions s
RIGHT JOIN Artists a ON s.artist_id = a.artist_id;


-- ---------------------------------------------------------
-- ЧАСТИНА 3: Підзапити (Мінімум 3 запити)
-- ---------------------------------------------------------

-- 1. Підзапит у WHERE: Знайти "VIP-клієнтів", чиї сеанси коштують дорожче, ніж середня вартість сеансу по студії
SELECT full_name, phone 
FROM Clients 
WHERE client_id IN (
    SELECT client_id 
    FROM Sessions 
    WHERE total_price > (SELECT AVG(total_price) FROM Sessions)
);

-- 2. Підзапит у SELECT: Вивести список усіх клієнтів і окремою колонкою показати, скільки всього татуювань вони робили (або планують)
SELECT 
    full_name, 
    phone,
    (SELECT COUNT(*) FROM Sessions s WHERE s.client_id = c.client_id) AS total_visits
FROM Clients c;

-- 3. Підзапит у HAVING: Знайти майстрів, чий загальний заробіток перевищує середній чек одного сеансу в студії
SELECT 
    artist_id, 
    SUM(total_price) AS total_earned 
FROM Sessions 
GROUP BY artist_id 
HAVING SUM(total_price) > (SELECT AVG(total_price) FROM Sessions);
