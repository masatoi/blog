CREATE TABLE "user" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMPTZ,
    "updated_at" TIMESTAMPTZ
);
