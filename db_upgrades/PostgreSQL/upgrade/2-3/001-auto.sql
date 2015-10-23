-- Convert schema 'db_upgrades/_source/deploy/2/001-auto.yml' to 'db_upgrades/_source/deploy/3/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "virtual_host" (
  "id" serial NOT NULL,
  "site_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "virtual_host_name" UNIQUE ("name")
);
CREATE INDEX "virtual_host_idx_site_id" on "virtual_host" ("site_id");

;
ALTER TABLE "virtual_host" ADD CONSTRAINT "virtual_host_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE site DROP COLUMN virtual_hosts;

;

COMMIT;

