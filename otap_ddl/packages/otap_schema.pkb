-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS
  -- for description see header file
  FUNCTION has_table( p_table_name   IN     VARCHAR2
                    , o_errors          OUT VARCHAR2
                    , p_schema       IN     VARCHAR2 DEFAULT NULL
                    )
    RETURN INTEGER
  IS
    l_script            VARCHAR2(1024) := 'otap_schema.has_table';
    l_has_table         INTEGER;
    l_test_passed       INTEGER;
    l_schema_to_use     VARCHAR2(128);
    l_table_name        VARCHAR2(128);
    l_errors            VARCHAR2(32767);
  BEGIN
    l_errors     := NULL;
    l_table_name := otap_string.reduce(p_table_name, 128);
    IF     l_table_name        IS NOT NULL
       AND LENGTH(l_table_name) > 0
    THEN
      -- check description
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      SELECT COUNT(*)
        INTO l_has_table
        FROM dba_tables
       WHERE table_name = l_table_name
         AND owner      = l_schema_to_use
      ;
      -- we should find one or zero entries
      l_test_passed := CASE l_has_table
                         WHEN 0
                         THEN otap_constants.OTAP_NUM_TEST_FAILED
                         WHEN 1
                         THEN otap_constants.OTAP_NUM_TEST_PASSED
                         ELSE otap_constants.OTAP_NUM_TEST_UNDEFINED
                       END
      ;
      -- report abnormal results and store them in errors
      IF l_has_table NOT IN (0, 1)
      THEN
        l_errors := otap_string.reduce('Check table ' || l_table_name || ' with schema ' || l_schema_to_use || ' results in count ' || l_has_table, 4000);
        otap_log.log(l_errors, l_script, 'Table name or search condition not unique');
      END IF;
    ELSE
      -- invalid table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Missing table name';
      otap_log.log(l_errors, l_script, 'NULL test on table name');
    END IF;
    o_errors := otap_string.reduce(l_errors, 4000);
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END has_table;

END;
/