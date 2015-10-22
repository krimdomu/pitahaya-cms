-- Convert schema 'db_upgrades/_source/deploy/1/001-auto.yml' to 'db_upgrades/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE media DROP CONSTRAINT media_pkey;

;
ALTER TABLE media ADD PRIMARY KEY (id, site_id);

;
ALTER TABLE page DROP CONSTRAINT page_pkey;

;
ALTER TABLE page ADD PRIMARY KEY (id, site_id);

;

COMMIT;

