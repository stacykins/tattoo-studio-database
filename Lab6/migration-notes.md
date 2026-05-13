
# Лабораторна робота №6  
<div align="right">
<strong>Група:</strong> ІО-44

<strong>Виконала:</strong> Чухрай А.А.

<strong>Перевірив:</strong> Русінов В. В.
</div>

## Тема: Міграції схем за допомогою Prisma ORM

## Мета роботи

Використати Prisma ORM для керування схемами бази даних PostgreSQL, дослідити процес міграції структури бази даних та перевірити коректність змін за допомогою Prisma Studio.

---

# 1. Ініціалізація Prisma

Для роботи з Prisma ORM було створено новий Node.js проєкт та встановлено необхідні залежності.

## Використані команди

```bash
npm init -y
npm install prisma --save-dev
npm install @prisma/client
npx prisma init --datasource-provider postgresql
```

Після ініціалізації було створено:
- папку `prisma/`
- файл `schema.prisma`
- файл `.env`

У файлі `.env` було налаштовано підключення до існуючої бази даних PostgreSQL.

---

# 2. Аналіз існуючої схеми

Для імпорту вже існуючої схеми бази даних було використано команду:

```bash
npx prisma db pull
```

Prisma автоматично зчитала структуру бази даних та створила відповідні моделі у файлі `schema.prisma`.

---

# 3. Міграція add-review-table

## Опис змін

Було створено нову таблицю `Review` для зберігання відгуків клієнтів про виконані татуювання.

Налаштовано зв’язок:
- одне татуювання → багато відгуків.

---

## Оновлення schema.prisma

```prisma
// Додано нову модель Review
model Review {
  review_id  Int      @id @default(autoincrement())
  rating     Int
  comment    String?
  tattoo_id  Int

  tattoo     tattoos  @relation(fields: [tattoo_id], references: [tattoo_id])
}

// Оновлено модель tattoos
model tattoos {
  tattoo_id   Int        @id @default(autoincrement())
  session_id  Int
  body_part   String     @db.VarChar(50)

  sessions    sessions   @relation(fields: [session_id], references: [session_id])

  reviews     Review[]
}
```

---

## SQL міграція

```sql
-- CreateTable
CREATE TABLE "Review" (
    "review_id" SERIAL NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "tattoo_id" INTEGER NOT NULL,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("review_id")
);

-- AddForeignKey
ALTER TABLE "Review"
ADD CONSTRAINT "Review_tattoo_id_fkey"
FOREIGN KEY ("tattoo_id")
REFERENCES "tattoos"("tattoo_id")
ON DELETE RESTRICT
ON UPDATE CASCADE;
```

---

## Команда міграції

```bash
npx prisma migrate dev --name add-review-table
```

---

# 4. Міграція add-artist-bio

## Опис змін

До таблиці `artists` було додано нове поле `bio`, яке дозволяє зберігати коротку біографію майстра.

Поле є необов’язковим (`String?`), що дозволяє не порушувати цілісність вже існуючих записів.

---

## Оновлення schema.prisma

```prisma
model artists {
  artist_id Int        @id @default(autoincrement())
  full_name String     @db.VarChar(100)

  spec      String?    @db.VarChar(50)

  bio       String?

  sessions  sessions[]
}
```

---

## SQL міграція

```sql
-- AlterTable
ALTER TABLE "artists"
ADD COLUMN "bio" TEXT;
```

---

## Команда міграції

```bash
npx prisma migrate dev --name add-artist-bio
```

---

# 5. Міграція remove-tattoo-description

## Опис змін

Із таблиці `tattoos` було видалено поле `description`.

Після додавання таблиці `Review` інформація про виконану роботу може зберігатися через:
- відгуки клієнтів;
- дані сеансу.

---

## Оновлення schema.prisma

```prisma
model tattoos {
  tattoo_id   Int        @id @default(autoincrement())
  session_id  Int
  body_part   String     @db.VarChar(50)

  sessions    sessions   @relation(fields: [session_id], references: [session_id])

  reviews     Review[]
}
```

---

## SQL міграція

```sql
-- AlterTable
ALTER TABLE "tattoos"
DROP COLUMN "description";
```

---

## Команда міграції

```bash
npx prisma migrate dev --name remove-tattoo-description
```

---

# 6. Перевірка результатів за допомогою Prisma Studio

Для перевірки правильності застосування міграцій було використано Prisma Studio.

## Запуск Prisma Studio

```bash
npx prisma studio
```

Після запуску відкрився веб-інтерфейс для роботи з таблицями бази даних.
<img width="1378" height="617" alt="image" src="https://github.com/user-attachments/assets/1f88294b-7bd3-4ad8-b486-6961687d48ca" />

<img width="226" height="654" alt="image" src="https://github.com/user-attachments/assets/87ae7c48-df4a-4fa6-9d33-f899c4b1ba61" />

---

## Перевірка таблиці Review

У таблицю `Review` було успішно додано новий запис.

Prisma автоматично перевіряє:
- існування `tattoo_id`;
- коректність зовнішнього ключа;
- цілісність зв’язків між таблицями.

### Скріншот таблиці Review


<img width="1238" height="102" alt="image" src="https://github.com/user-attachments/assets/ed468899-2707-4084-8097-ce16859a8a6e" />




---

## Перевірка таблиці artists

У таблиці `artists` успішно з’явилося нове поле `bio`.

Поле доступне для:
- перегляду;
- редагування;
- додавання нових значень.

---

## Перевірка таблиці tattoos

Поле `description` успішно видалено зі структури таблиці `tattoos`.

### Скріншот таблиці artists і tattoos


<img width="1291" height="103" alt="image" src="https://github.com/user-attachments/assets/b2056d65-f03f-4993-b932-cd95ea3fcc25" />
<img width="1071" height="97" alt="image" src="https://github.com/user-attachments/assets/2333ad06-b809-405d-ae4f-4f9849a7e6b3" />



---




---

# 8. Висновок

У ході лабораторної роботи було:
- налаштовано Prisma ORM для PostgreSQL;
- виконано аналіз існуючої схеми бази даних;
- створено та застосовано кілька міграцій;
- додано нову таблицю `Review`;
- додано нове поле `bio` до таблиці `artists`;
- видалено поле `description` із таблиці `tattoos`;
- перевірено роботу схеми за допомогою Prisma Studio та Prisma Client.


