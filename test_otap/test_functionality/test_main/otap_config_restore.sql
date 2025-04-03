-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- restores from a temporary backup of the otap_config table
-- deletes the temporary backup after restore

SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_has_backup INTEGER;
  l_statement  VARCHAR2(32767);
BEGIN
  SELECT COUNT(*)
    INTO l_has_backup
    FROM user_tables
   WHERE table_name = 'OTAP_CONFIG_BACKUP'
  ;
  IF l_has_backup = 1
  THEN
    DBMS_OUTPUT.PUT_LINE('Temporary backup detected');
    -- create statement for execute immediate to not fail, if table does not exist
    l_statement := q'[MERGE INTO otap_config tgt
USING (SELECT config_name
            , config_value
            , config_max_length
            , config_type
            , translatable
            , config_description
         FROM otap_config_backup
      ) src
   ON (tgt.config_name = src.config_name)
 WHEN MATCHED THEN
   UPDATE SET tgt.config_value = src.config_value WHERE tgt.config_value != src.config_value]';
    EXECUTE IMMEDIATE l_statement;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Temporary backup restored');
    -- if we reach this point, it is safe to drop the backup
    EXECUTE IMMEDIATE 'DROP TABLE otap_config_backup';
    DBMS_OUTPUT.PUT_LINE('Temporary backup dropped');
  ELSE
    DBMS_OUTPUT.PUT_LINE('No temporary backup found, nothing to do');
  END IF;
END;
/
