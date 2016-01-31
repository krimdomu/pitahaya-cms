;
BEGIN;

;

ALTER TABLE "content_type" ADD CONSTRAINT "content_type_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;

CREATE INDEX page_idx_content_type_id_site_id on page (content_type_id, site_id)

;


COMMIT;
