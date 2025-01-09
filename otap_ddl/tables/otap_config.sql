-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct schema, using CHAR for different language support
-- table is NOT qualified and created in the schema active at execution, columns ordered by access and then space consumption
CREATE TABLE otap_config
  ( config_name         VARCHAR2(128 CHAR)                                                  NOT NULL
  , config_value        VARCHAR2(4000 CHAR)                                                 NOT NULL
  , config_max_length   NUMBER               DEFAULT -1                                     NOT NULL
  , config_type         VARCHAR2(6 CHAR)     DEFAULT 'CHAR'                                 NOT NULL
  , translatable        NUMBER(1, 0)         DEFAULT 0                                      NOT NULL
  , created             DATE                 DEFAULT SYSDATE                                NOT NULL
  , updated             DATE                 DEFAULT SYSDATE                                NOT NULL
  , created_by          VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
  , created_by_os       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER')      NOT NULL
  , updated_by          VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER') NOT NULL
  , updated_by_os       VARCHAR2(256 CHAR)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER')      NOT NULL
  , config_description  VARCHAR2(4000 CHAR)
  )
;
-- description
COMMENT ON TABLE otap_config IS 'Holds the configuration used by otap. Will use the alias ocfg.';
COMMENT ON COLUMN otap_config.config_name IS 'The unique case sensitive name of the otap configuration object.';
COMMENT ON COLUMN otap_config.config_value IS 'The configuration value always as VARCHAR2. Type handling and conversion must be done by the caller.';
COMMENT ON COLUMN otap_config.config_type IS 'Defines how the config value has to be interpreted. Currently supports CHAR and NUMBER.';
COMMENT ON COLUMN otap_config.config_max_length IS 'Defines a maximum length for config values if set to a number > 0. Default is -1, do not not check length.';
COMMENT ON COLUMN otap_config.translatable IS 'Defines if the config value is translatable. Default is 0 (no). Only CHAR type configuratios can set this to 1 (yes), to be considered by translation.';
COMMENT ON COLUMN otap_config.config_description IS 'Optional description of the otap config object.';
COMMENT ON COLUMN otap_config.created IS 'Date created, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated IS 'Date updated, managed by default and trigger.';
COMMENT ON COLUMN otap_config.created_by IS 'DB user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.created_by_os IS 'OS user who created the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated_by IS 'DB user who updated the record, managed by default and trigger.';
COMMENT ON COLUMN otap_config.updated_by_os IS 'OS user who updated the record, managed by default and trigger.';

-- primary key
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_pk
  PRIMARY KEY (config_name)
  ENABLE
;
-- constraints
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_chk_type
  CHECK (config_type IN ('CHAR', 'NUMBER'))
;
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_chk_max_length
  CHECK (config_max_length = -1 OR config_max_length > 0)
;
ALTER TABLE otap_config
  ADD CONSTRAINT otap_config_chk_translatable
  CHECK (translatable IN (0, 1))
;
