-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- OTAP_CONFIG trigger
CREATE OR REPLACE TRIGGER otap_config_ins_trg
  BEFORE INSERT ON otap_config
  FOR EACH ROW
BEGIN
  -- only allow defined configuration names
  otap_util.validate_config_name(:NEW.config_name);
  -- validate config_value and raise
  :NEW.config_value := otap_util.validate_config_value( :NEW.config_name
                                                      , :NEW.config_value
                                                      , :NEW.config_type
                                                      , :NEW.translatable
                                                      , :NEW.config_max_length
                                                      )
  ;
  -- check empty strings contained only spaces
  :NEW.created        := SYSDATE;
  :NEW.created_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.created_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
END;
/
CREATE OR REPLACE TRIGGER otap_config_upd_trg
  BEFORE UPDATE ON otap_config
  FOR EACH ROW
BEGIN
  -- deny update of config names
  :NEW.config_name := :OLD.config_name;
  -- translatable is OUT var, prepare var before
  :NEW.translatable := NVL(:NEW.translatable, :OLD.translatable);
  -- validate config_value and raise
  :NEW.config_value := otap_util.validate_config_value( NVL(:NEW.config_name, :OLD.config_name)
                                                      , NVL(:NEW.config_value, :OLD.config_value)
                                                      , NVL(:NEW.config_type, :OLD.config_type)
                                                      , :NEW.translatable
                                                      , NVL(:NEW.config_max_length, :OLD.config_max_length)
                                                      )
  ;
  -- ensure some values are not overwritten
  :NEW.created        := :OLD.created;
  :NEW.created_by     := :OLD.created_by;
  :NEW.created_by_os  := :OLD.created_by_os;
  :NEW.updated        := SYSDATE;
  :NEW.updated_by     := SYS_CONTEXT('USERENV', 'SESSION_USER');
  :NEW.updated_by_os  := SYS_CONTEXT('USERENV', 'OS_USER');
END;
/
CREATE OR REPLACE TRIGGER otap_config_del_trg
  BEFORE DELETE ON otap_config
  FOR EACH ROW
BEGIN
  -- deny delete of defined configuration names
  otap_util.validate_config_name(:OLD.config_name, TRUE);
END;
/
