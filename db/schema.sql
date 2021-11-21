CREATE TABLE "user" (
    "id" BIGSERIAL NOT NULL PRIMARY KEY,
    "name" VARCHAR(256) NOT NULL,
    "created_at" TIMESTAMPTZ,
    "updated_at" TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS "schema_migrations" (
    "version" VARCHAR(255) PRIMARY KEY,
    "applied_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
