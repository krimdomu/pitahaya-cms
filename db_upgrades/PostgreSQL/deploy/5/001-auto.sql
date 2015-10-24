-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sat Oct 24 11:35:39 2015
-- 
;
--
-- Table: site
--
CREATE TABLE "site" (
  "id" serial NOT NULL,
  "name" character varying(150) NOT NULL,
  "c_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "m_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "skin" character varying(150) NOT NULL,
  "data" jsonb,
  PRIMARY KEY ("id")
);

;
--
-- Table: users
--
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "username" character varying(150) NOT NULL,
  "password" text NOT NULL,
  "email" character varying(250),
  "data" jsonb,
  PRIMARY KEY ("id")
);

;
--
-- Table: language
--
CREATE TABLE "language" (
  "id" serial NOT NULL,
  "master_site_id" integer NOT NULL,
  "lang_site_id" integer NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "language_idx_lang_site_id" on "language" ("lang_site_id");
CREATE INDEX "language_idx_master_site_id" on "language" ("master_site_id");

;
--
-- Table: media_type
--
CREATE TABLE "media_type" (
  "id" serial NOT NULL,
  "site_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "description" character varying(500),
  PRIMARY KEY ("id")
);
CREATE INDEX "media_type_idx_site_id" on "media_type" ("site_id");

;
--
-- Table: page_type
--
CREATE TABLE "page_type" (
  "id" serial NOT NULL,
  "site_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "description" character varying(500),
  PRIMARY KEY ("id")
);
CREATE INDEX "page_type_idx_site_id" on "page_type" ("site_id");

;
--
-- Table: virtual_host
--
CREATE TABLE "virtual_host" (
  "id" serial NOT NULL,
  "site_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "virtual_host_name" UNIQUE ("name")
);
CREATE INDEX "virtual_host_idx_site_id" on "virtual_host" ("site_id");

;
--
-- Table: media
--
CREATE TABLE "media" (
  "id" serial NOT NULL,
  "lft" integer NOT NULL,
  "rgt" integer NOT NULL,
  "level" integer NOT NULL,
  "site_id" integer NOT NULL,
  "active" smallint NOT NULL,
  "hidden" smallint NOT NULL,
  "creator_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "url" character varying(250) NOT NULL,
  "title" character varying(150),
  "description" character varying(500),
  "keywords" character varying(500),
  "type_id" integer NOT NULL,
  "c_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "m_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "rel_date" timestamp,
  "lock_date" timestamp,
  "content" text,
  "data" jsonb,
  PRIMARY KEY ("id", "site_id")
);
CREATE INDEX "media_idx_site_id" on "media" ("site_id");
CREATE INDEX "media_idx_type_id" on "media" ("type_id");

;
--
-- Table: page
--
CREATE TABLE "page" (
  "id" serial NOT NULL,
  "lft" integer NOT NULL,
  "rgt" integer NOT NULL,
  "level" integer NOT NULL,
  "site_id" integer NOT NULL,
  "active" smallint NOT NULL,
  "hidden" smallint NOT NULL,
  "navigation" smallint NOT NULL,
  "creator_id" integer NOT NULL,
  "name" character varying(150) NOT NULL,
  "url" character varying(250) NOT NULL,
  "title" character varying(150),
  "description" character varying(1000),
  "keywords" character varying(1000),
  "type_id" integer NOT NULL,
  "c_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "m_date" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "rel_date" timestamp,
  "lock_date" timestamp,
  "content" text,
  "data" jsonb,
  PRIMARY KEY ("id", "site_id")
);
CREATE INDEX "page_idx_creator_id" on "page" ("creator_id");
CREATE INDEX "page_idx_site_id" on "page" ("site_id");
CREATE INDEX "page_idx_type_id" on "page" ("type_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "language" ADD CONSTRAINT "language_fk_lang_site_id" FOREIGN KEY ("lang_site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE "language" ADD CONSTRAINT "language_fk_master_site_id" FOREIGN KEY ("master_site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "media_type" ADD CONSTRAINT "media_type_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page_type" ADD CONSTRAINT "page_type_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "virtual_host" ADD CONSTRAINT "virtual_host_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "media" ADD CONSTRAINT "media_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "media" ("site_id") ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "media" ADD CONSTRAINT "media_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "media" ADD CONSTRAINT "media_fk_type_id" FOREIGN KEY ("type_id")
  REFERENCES "media_type" ("id") DEFERRABLE;

;
ALTER TABLE "page" ADD CONSTRAINT "page_fk_creator_id" FOREIGN KEY ("creator_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page" ADD CONSTRAINT "page_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "page" ("site_id") ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page" ADD CONSTRAINT "page_fk_site_id" FOREIGN KEY ("site_id")
  REFERENCES "site" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "page" ADD CONSTRAINT "page_fk_type_id" FOREIGN KEY ("type_id")
  REFERENCES "page_type" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
