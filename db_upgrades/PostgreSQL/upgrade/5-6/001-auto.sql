-- Convert schema 'db_upgrades/_source/deploy/5/001-auto.yml' to 'db_upgrades/_source/deploy/6/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "content_type" (
  "id" serial NOT NULL,
  "site_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "class" character varying(500),
  PRIMARY KEY ("id", "site_id")
);
CREATE INDEX "content_type_idx_site_id" on "content_type" ("site_id");

;

ALTER TABLE page ADD COLUMN content_type_id integer NOT NULL DEFAULT 0;

;

COMMIT;

