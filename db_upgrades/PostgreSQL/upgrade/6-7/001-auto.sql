-- Convert schema 'db_upgrades/_source/deploy/6/001-auto.yml' to 'db_upgrades/_source/deploy/7/001-auto.yml':;

;
ALTER TABLE page ADD CONSTRAINT page_fk_content_type_id_site_id FOREIGN KEY (content_type_id, site_id)
  REFERENCES content_type (id, site_id) ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;


-- No differences found;

