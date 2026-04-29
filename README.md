# 🖋️ Tattoo Studio Management System (PostgreSQL)

Реляційна база даних для автоматизації бізнес-процесів сучасної тату-студії. Проект охоплює повний цикл розробки: від концептуального моделювання до складної аналітики (OLAP) та оптимізації.

[![Database](https://img.shields.io/badge/Database-PostgreSQL-blue.svg)](https://www.postgresql.org/)
[![Status](https://img.shields.io/badge/Status-In_Progress-orange.svg)]()

## 📌 Огляд проекту
Ця система розроблена для вирішення трьох основних задач:
1. **CRM & Scheduling:** Управління записами клієнтів та графіком майстрів.
2. **Inventory Control:** Моніторинг розхідних матеріалів у реальному часі.
3. **Business Intelligence:** Генерація звітів про дохідність та популярність послуг.

---

## 🛠 Технологічний стек
* **DBMS:** PostgreSQL 16
* **Modeling:** Crow's Foot Notation (ERD)
* **Tools:** pgAdmin 4, DBeaver
* **Environment:** Git / GitHub

---

## 🚀 Прогрес виконання (Roadmap)

- [x] **Lab 1: Conceptual & Logical Design**
  - Проектування ER-діаграми, визначення сутностей (Artists, Clients, Sessions, Inventory) та зв'язків між ними.
- [x] **Lab 2: Schema Implementation (DDL)**
  - Розгортання фізичної схеми, налаштування первинних/зовнішніх ключів та обмежень (Constraints: CHECK, UNIQUE, NOT NULL).
- [x] **Lab 3: Data Seeding & OLTP Operations**
  - Наповнення бази тестовими даними (DML) та реалізація стандартних транзакційних запитів.
- [x] **Lab 4: Advanced Analytics & Reporting (OLAP)**
  - Написання складних агрегаційних запитів, використання JOIN, віконних функцій та підзапитів для бізнес-аналізу.
- [ ] **Lab 5: Database Normalization & Optimization**
  - Приведення до 3NF/BCNF, декомпозиція таблиць та створення індексів для прискорення пошуку.
- [ ] **Lab 6: Migration & Schema Evolution**
  - Використання міграцій (наприклад, через Prisma ORM або Liquibase) для контролю версій схеми.

---

