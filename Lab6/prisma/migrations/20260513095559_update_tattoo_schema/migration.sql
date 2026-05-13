-- CreateTable
CREATE TABLE "artists" (
    "artist_id" SERIAL NOT NULL,
    "full_name" VARCHAR(100) NOT NULL,
    "specialization" VARCHAR(50) NOT NULL,
    "bio" TEXT,

    CONSTRAINT "artists_pkey" PRIMARY KEY ("artist_id")
);

-- CreateTable
CREATE TABLE "clients" (
    "client_id" SERIAL NOT NULL,
    "full_name" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "medical_notes" TEXT,

    CONSTRAINT "clients_pkey" PRIMARY KEY ("client_id")
);

-- CreateTable
CREATE TABLE "inventory" (
    "item_id" SERIAL NOT NULL,
    "item_name" VARCHAR(100) NOT NULL,
    "category" VARCHAR(50),
    "quantity" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "inventory_pkey" PRIMARY KEY ("item_id")
);

-- CreateTable
CREATE TABLE "material_usage" (
    "usage_id" SERIAL NOT NULL,
    "session_id" INTEGER NOT NULL,
    "item_id" INTEGER NOT NULL,
    "amount_used" INTEGER NOT NULL,

    CONSTRAINT "material_usage_pkey" PRIMARY KEY ("usage_id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "session_id" SERIAL NOT NULL,
    "client_id" INTEGER NOT NULL,
    "artist_id" INTEGER NOT NULL,
    "scheduled_at" TIMESTAMP(6) NOT NULL,
    "total_price" DECIMAL(10,2) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("session_id")
);

-- CreateTable
CREATE TABLE "tattoos" (
    "tattoo_id" SERIAL NOT NULL,
    "session_id" INTEGER NOT NULL,
    "body_part" VARCHAR(50) NOT NULL,

    CONSTRAINT "tattoos_pkey" PRIMARY KEY ("tattoo_id")
);

-- CreateTable
CREATE TABLE "Review" (
    "review_id" SERIAL NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "tattoo_id" INTEGER NOT NULL,

    CONSTRAINT "Review_pkey" PRIMARY KEY ("review_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "clients_phone_key" ON "clients"("phone");

-- AddForeignKey
ALTER TABLE "material_usage" ADD CONSTRAINT "material_usage_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "inventory"("item_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "material_usage" ADD CONSTRAINT "material_usage_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("session_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_artist_id_fkey" FOREIGN KEY ("artist_id") REFERENCES "artists"("artist_id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "clients"("client_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tattoos" ADD CONSTRAINT "tattoos_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "sessions"("session_id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "Review" ADD CONSTRAINT "Review_tattoo_id_fkey" FOREIGN KEY ("tattoo_id") REFERENCES "tattoos"("tattoo_id") ON DELETE RESTRICT ON UPDATE CASCADE;
