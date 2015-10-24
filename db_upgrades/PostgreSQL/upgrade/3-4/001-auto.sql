-- Convert schema 'db_upgrades/_source/deploy/3/001-auto.yml' to 'db_upgrades/_source/deploy/4/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "language" (
  "id" serial NOT NULL,
  "master_site_id" integer NOT NULL,
  "lang_site_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "language_idx_lang_site_id" on "language" ("lang_site_id");
CREATE INDEX "language_idx_master_site_id" on "language" ("master_site_id");

;
ALTER TABLE "language" ADD CONSTRAINT "language_fk_lang_site_id" FOREIGN KEY ("lang_site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "language" ADD CONSTRAINT "language_fk_master_site_id" FOREIGN KEY ("master_site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE DEFERRABLE;

;

COMMIT;

