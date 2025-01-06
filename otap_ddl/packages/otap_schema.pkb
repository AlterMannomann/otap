-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS
  -- for description see header file
  FUNCTION has_table( p_table_name   IN     VARCHAR2
                    , o_errors          OUT VARCHAR2
                    , p_schema       IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024) := 'otap_schema.has_table';
    l_has_table     INTEGER;
    l_test_passed   INTEGER;
    l_schema_to_use VARCHAR2(128);
    l_table_name    VARCHAR2(128);
    l_errors        VARCHAR2(32767);
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

  FUNCTION has_column( p_table_name     IN     VARCHAR2
                     , p_column_name    IN     VARCHAR2
                     , o_errors            OUT VARCHAR2
                     , p_schema         IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_data_type      IN     VARCHAR2 DEFAULT NULL
                     , p_data_length    IN     NUMBER   DEFAULT NULL
                     , p_data_precision IN     NUMBER   DEFAULT NULL
                     , p_data_scale     IN     NUMBER   DEFAULT NULL
                     , p_nullable       IN     VARCHAR2 DEFAULT NULL
                     , p_data_default   IN     VARCHAR2 DEFAULT NULL -- maps to DATA_DEFAULT_VC limited to 4000, LONG is a pain in the ass
                     )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024) := 'otap_schema.has_column';
    l_has_column    INTEGER;
    l_test_passed   INTEGER;
    l_schema_to_use VARCHAR2(128);
    l_table_name    VARCHAR2(128);
    l_column_name   VARCHAR2(128);
    l_errors        VARCHAR2(32767);
  BEGIN
    l_errors      := NULL;
    l_table_name  := otap_string.reduce(p_table_name, 128);
    l_column_name := otap_string.reduce(p_column_name, 128);
    IF     l_table_name         IS NOT NULL
       AND LENGTH(l_table_name)  > 0
       AND l_column_name        IS NOT NULL
       AND LENGTH(l_column_name) > 0
    THEN
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- test column exists
      SELECT COUNT(*)
        INTO l_has_column
        FROM dba_tab_columns
       WHERE owner                              = l_schema_to_use
         AND table_name                         = l_table_name
         AND column_name                        = l_column_name
         AND data_type                          = UPPER(NVL(p_data_type, data_type))
         AND data_length                        = NVL(p_data_length, data_length)
         AND nullable                           = UPPER(NVL(p_nullable, nullable))
         AND NVL(data_precision, -1)            = NVL(p_data_precision, NVL(data_precision, -1))
         AND NVL(data_scale, -1)                = NVL(p_data_scale, NVL(data_scale, -1))
         AND TRIM(NVL(data_default_vc, 'n/a'))  = TRIM(NVL(p_data_default, NVL(data_default_vc, 'n/a')))
      ;
      -- we should find one or zero entries
      l_test_passed := CASE l_has_column
                         WHEN 0
                         THEN otap_constants.OTAP_NUM_TEST_FAILED
                         WHEN 1
                         THEN otap_constants.OTAP_NUM_TEST_PASSED
                         ELSE otap_constants.OTAP_NUM_TEST_UNDEFINED
                       END
      ;
      -- report abnormal results and store them in errors
      IF l_has_column NOT IN (0, 1)
      THEN
        l_errors := otap_string.reduce('Check table ' || l_table_name || ' with schema ' || l_schema_to_use || ' results in count ' || l_has_column, 4000);
        otap_log.log(l_errors, l_script, 'Column name or search condition not unique');
      END IF;
    ELSE
      -- invalid table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Missing: ' ||
                             CASE
                               WHEN l_table_name IS NULL OR LENGTH(l_table_name) = 0
                               THEN 'table name '
                             END ||
                             CASE
                               WHEN l_column_name IS NULL OR LENGTH(l_column_name) = 0
                               THEN 'column name '
                             END
      ;
      otap_log.log(l_errors, l_script, 'NULL test on table or column name');
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
  END has_column;

END;
/