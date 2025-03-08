-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct schema, using CHAR for different language support
-- basic translation table, any inserted translation is immediately active if the language
-- matches the current default language
CREATE TABLE otap_translate
  ( otap_identifier  VARCHAR2(256 CHAR)                                                  NOT NULL
  , label_text       VARCHAR2(256 CHAR)                                                  NOT NULL
  , language_id      VARCHAR2(3 CHAR)     DEFAULT 'N/A'                                  NOT NULL
  , created          DATE                 DEFAULT SYSDATE                                NOT NULL
  , updated          DATE                 DEFAULT SYSDATE                                NOT NULL
  , created_by       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
  , created_by_os    VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER')      NOT NULL
  , updated_by       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
  , updated_by_os    VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER')      NOT NULL
  )
;

COMMENT ON TABLE otap_translate IS 'Provides the possibility for translation of otap templates, formattings and labels.';
COMMENT ON COLUMN otap_translate.otap_identifier IS 'Must match either the config_name in OTAP_CONFIG or the otap_identifier in OTAP_LABELS_MV to be considered. Primary key.';
COMMENT ON COLUMN otap_translate.label_text IS 'Contains the translation for the template, formatting or label';
COMMENT ON COLUMN otap_translate.language_id IS 'The 3 char language code the translation belongs to. Never use T$O, this is the internal intrusive test language id. Default language is defined in OTAP_CONFIG and must match.';
COMMENT ON COLUMN otap_translate.created IS 'Date created, managed by default and trigger.';
COMMENT ON COLUMN otap_translate.updated IS 'Date updated, managed by default and trigger.';
COMMENT ON COLUMN otap_translate.created_by IS 'DB user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_translate.created_by_os IS 'OS user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_translate.updated_by IS 'DB user who updated the record, managed by default and trigger.';
COMMENT ON COLUMN otap_translate.updated_by_os IS 'OS user who updated the record, managed by default and trigger.';

-- primary key
-- no index apart from primary key, just overhead not needed
ALTER TABLE otap_translate
  ADD CONSTRAINT otap_translate_pk
  PRIMARY KEY (otap_identifier, language_id)
  ENABLE
;
