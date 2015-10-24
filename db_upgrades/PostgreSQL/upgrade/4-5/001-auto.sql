-- Convert schema 'db_upgrades/_source/deploy/4/001-auto.yml' to 'db_upgrades/_source/deploy/5/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE language DROP CONSTRAINT language_fk_lang_site_id;

;
ALTER TABLE language DROP CONSTRAINT language_fk_master_site_id;

;
ALTER TABLE language ADD CONSTRAINT language_fk_lang_site_id FOREIGN KEY (lang_site_id)
  REFERENCES site (id) ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE language ADD CONSTRAINT language_fk_master_site_id FOREIGN KEY (master_site_id)
  REFERENCES site (id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

COMMIT;

