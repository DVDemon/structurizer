-- Active: 1697044197262@@127.0.0.1@3306
CREATE SEQUENCE public.s_fdm_ptr
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  NO CYCLE;



  CREATE TABLE public.fdm_ptr_artifacts (
  id_rec int8 NOT NULL DEFAULT nextval('s_fdm_ptr'::regclass),
  cmdb_mnem varchar(150) NOT NULL,
  "owner" varchar(400) NULL,
  dt_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tc_ts timestamp NULL,
  tc_link varchar(4000) NULL,
  tc_source varchar(50) NULL,
  adr_ts timestamp NULL,
  adr_link varchar(4000) NULL,
  adr_source varchar(50) NULL,
  context_ts timestamp NULL,
  context_link varchar(50) NULL,
  context_source varchar(4000) NULL,
  container_ts timestamp NULL,
  container_link varchar(50) NULL,
  nfr_ts varchar(50) NULL,
  nfr_link varchar(50) NULL,
  ia_ts timestamp NULL,
  ia_link varchar(50) NULL,
  ia_source varchar(4000) NULL,
  ldm_ts timestamp NULL,
  ldm_link varchar(50) NULL,
  techstack_ts timestamp NULL,
  techstack_link varchar(50) NULL,
  deploy_ts timestamp NULL,
  deploy_link varchar(50) NULL,
  deploy_source varchar(4000) NULL,
  api_ts timestamp NULL,
  api_link varchar(50) NULL,
  sequence_ts timestamp NULL,
  sequence_link varchar(50) NULL,
  sequence_source varchar(4000) NULL,
  criticality int2 NULL DEFAULT 2,
  CONSTRAINT "PK_fdm_ptr_artifacts" PRIMARY KEY (id_rec)
);

  