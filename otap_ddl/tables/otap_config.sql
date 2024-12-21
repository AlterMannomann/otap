-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- requires login with the correct schema
-- table is NOT qualified and created in the schema active at execution, columns ordered by access and then space consumption
CREATE TABLE otap_config
  ( config_name         VARCHAR2(128)                                             NOT NULL
  , config_value        VARCHAR2(4000)                                            NOT NULL
  , config_max_length   NUMBER          DEFAULT -1                                NOT NULL
  , config_type         VARCHAR2(6)     DEFAULT 'CHAR'                            NOT NULL
  , created             DATE            DEFAULT SYSDATE                           NOT NULL
  , updated             DATE            DEFAULT SYSDATE                           NOT NULL
  , created_by          VARCHAR2(256)   DEFAULT USER                              NOT NULL
  , created_by_os       VARCHAR2(256)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , updated_by          VARCHAR2(256)   DEFAULT USER                              NOT NULL
  , updated_by_os       VARCHAR2(256)   DEFAULT SYS_CONTEXT('USERENV', 'OS_USER') NOT NULL
  , config_description  VARCHAR2(4000)
  )
;
-- description
COMMENT ON TABLE otap_config IS 'Holds the configuration used by otap. Will use the alias scfg.';
COMMENT ON COLUMN otap_config.config_name IS 'The unique case sensitive name of the otap configuration object.';
COMMENT ON COLUMN otap_config.config_value IS 'The configuration value always as VARCHAR2. Type handling and conversion must be done by the caller.';
COMMENT ON COLUMN otap_config.config_type IS 'Defines how the config value has to be interpreted. Currently supports CHAR and NUMBER.';
COMMENT ON COLUMN otap_config.config_max_length IS 'Defines a maximum length for CHAR type config values if set to a number > 0. Default is -1, do not not check length.';
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

-- trigger
CREATE OR REPLACE TRIGGER otap_config_ins_trg
  BEFORE INSERT ON otap_config
  FOR EACH ROW
DECLARE
  l_ok                BOOLEAN;
BEGIN
  -- only allow defined configuration names
  IF :NEW.config_name NOT IN ( 'PRESERVE_DAYS'
                             , 'DELETE_DELAY'
                             , 'DELETE_BATCH_SIZE'
                             )
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'The configuration name ' || :NEW.config_name || ' is not supported.');
  END IF;
  -- remove any leading and trailing blanks from config_value
  :NEW.config_value   := TRIM(:NEW.config_value);
  :NEW.created        := SYSDATE;
  :NEW.created_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.created_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
  -- check max length if defined
  IF :NEW.config_type = 'CHAR'
  THEN
    IF :NEW.config_max_length > 0
    THEN
      IF LENGTH(:NEW.config_value) > :NEW.config_max_length
      THEN
        RAISE_APPLICATION_ERROR(-20002, 'The config_value exceeds the defined config_max_length. Current length: ' || LENGTH(:NEW.config_value));
      END IF;
    END IF;
  END IF;
  -- check number type
  IF :NEW.config_type = 'NUMBER'
  THEN
    l_ok := TRUE;
    -- compare TO_NUMBER with implicite conversion, if it fails the config_value cannot be interpreted correctly
    BEGIN
      l_ok := (TO_NUMBER(:NEW.config_value) = :NEW.config_value);
    EXCEPTION
      WHEN OTHERS THEN
        l_ok := FALSE;
    END;
    IF NOT l_ok
    THEN
      RAISE_APPLICATION_ERROR(-20003, 'The given config_value "' || NVL(:NEW.config_value, 'NULL') || '" could not be converted successfully to a number.');
    END IF;
  END IF;
  -- handle NULLs
  IF :NEW.config_name = 'PRESERVE_DAYS'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, '1');
  END IF;
  IF :NEW.config_name = 'DELETE_DELAY'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, '10');
  END IF;
  IF :NEW.config_name = 'DELETE_BATCH_SIZE'
  THEN
    :NEW.config_value := NVL(:NEW.config_value, '1000');
  END IF;
END;
/
CREATE OR REPLACE TRIGGER otap_config_upd_trg
  BEFORE UPDATE ON otap_config
  FOR EACH ROW
DECLARE
  l_ok                BOOLEAN;
BEGIN
  -- only allow defined configuration names
  IF :NEW.config_name NOT IN ( 'PRESERVE_DAYS'
                             , 'DELETE_DELAY'
                             , 'DELETE_BATCH_SIZE'
                             )
  THEN
    RAISE_APPLICATION_ERROR(-20001, 'The configuration name ' || :NEW.config_name || ' is not supported.');
  END IF;
  -- remove any leading and trailing blanks from config_value
  :NEW.config_value := TRIM(:NEW.config_value);
  -- ensure some values are not overwritten
  :NEW.created        := :OLD.created;
  :NEW.created_by     := :OLD.created_by;
  :NEW.created_by_os  := :OLD.created_by_os;
  -- check max length if defined
  IF :NEW.config_type = 'CHAR'
  THEN
    IF :NEW.config_max_length > 0
    THEN
      IF LENGTH(:NEW.config_value) > :NEW.config_max_length
      THEN
        RAISE_APPLICATION_ERROR(-20002, 'The config_value exceeds the defined config_max_length. Current length: ' || LENGTH(:NEW.config_value));
      END IF;
    END IF;
  END IF;
  -- check number type
  IF :NEW.config_type = 'NUMBER'
  THEN
    l_ok := TRUE;
    -- compare TO_NUMBER with implicite conversion, if it fails the config_value cannot be interpreted correctly
    BEGIN
      l_ok := (TO_NUMBER(:NEW.config_value) = :NEW.config_value);
    EXCEPTION
      WHEN OTHERS THEN
        l_ok := FALSE;
    END;
    IF NOT l_ok
    THEN
      RAISE_APPLICATION_ERROR(-20003, 'The given config_value "' || NVL(:NEW.config_value, 'NULL') || '" could not be converted successfully to a number.');
    END IF;
  END IF;
  -- check range
  IF :NEW.config_name = 'PRESERVE_DAYS'
  THEN
    IF    TO_NUMBER(:NEW.config_value) > 7
       OR TO_NUMBER(:NEW.config_value) < 1
    THEN
      :NEW.config_value := '1';
    END IF;
  END IF;
  IF :NEW.config_name = 'DELETE_DELAY'
  THEN
    IF    TO_NUMBER(:NEW.config_value) > 600
       OR TO_NUMBER(:NEW.config_value) < 1
    THEN
      :NEW.config_value := '10';
    END IF;
  END IF;
  IF :NEW.config_name = 'DELETE_BATCH_SIZE'
  THEN
    IF    TO_NUMBER(:NEW.config_value) > 10000
       OR TO_NUMBER(:NEW.config_value) < 100
    THEN
      :NEW.config_value := '1000';
    END IF;
  END IF;
END;
/
CREATE OR REPLACE TRIGGER otap_config_upd_trg
  BEFORE UPDATE ON otap_config
  FOR EACH ROW
BEGIN
  -- deny delete of defined configuration names
  IF :OLD.config_name IN ( 'PRESERVE_DAYS'
                         , 'DELETE_DELAY'
                         , 'DELETE_BATCH_SIZE'
                         )
  THEN
    RAISE_APPLICATION_ERROR(-20004, 'The configuration name ' || :OLD.config_name || ' cannot be deleted.');
  END IF;
END;
/
-- create base entries
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('PRESERVE_DAYS', '1', 'NUMBER', 'The number of days otap will keep test result records. Maximum is 7 days, minimum 1 day. Default is 1.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DELETE_DELAY', '10', 'NUMBER', 'The seconds to wait between batch size delete commits to give other applications and requests room to execute. Maximum is 600, minimum is 1. Default is 10.')
;
INSERT INTO otap_config
  (config_name, config_value, config_type, config_description)
  VALUES
  ('DELETE_BATCH_SIZE', '1000', 'NUMBER', 'The records to delete before commit. Maximum is 10000, minimum is 100. Default is 1000.')
;
COMMIT;