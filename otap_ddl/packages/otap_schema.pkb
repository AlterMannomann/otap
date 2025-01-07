-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS

  FUNCTION count_chk( p_count   IN      INTEGER
                    , o_errors  IN OUT  VARCHAR2
                    , p_caller  IN      VARCHAR2
                    )
    RETURN INTEGER
  IS
    l_return INTEGER;
  BEGIN
      l_return := CASE p_count
                    WHEN 0
                    THEN otap_constants.OTAP_NUM_TEST_FAILED
                    WHEN 1
                    THEN otap_constants.OTAP_NUM_TEST_PASSED
                    ELSE otap_constants.OTAP_NUM_TEST_UNDEFINED
                  END
      ;
      IF p_count NOT IN (0, 1)
      THEN
        o_errors := otap_string.reduce('Abnormal count result from ' || p_caller || ' count: ' || p_count, 4000);
        otap_log.log(o_errors, p_caller, 'Abnormal count result. Expected 0 or 1');
      END IF;
      RETURN l_return;
  END count_chk;
  -- for description see header file
  FUNCTION has_table( p_table_name      IN     VARCHAR2
                    , o_errors             OUT VARCHAR2
                    , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024) := 'otap_schema.has_table';
    l_has_table     INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128);
    l_table_name    VARCHAR2(128);
    l_errors        VARCHAR2(32767);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_table_name  := otap_string.reduce(p_table_name, 128);
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
      l_test_passed := count_chk(l_has_table, l_errors, l_script);
    ELSE
      -- invalid table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Missing: p_table_name(NULL)';
      otap_log.log(l_errors, l_script, 'NULL test on table name');
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
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

  FUNCTION has_column( p_table_name      IN     VARCHAR2
                     , p_column_name     IN     VARCHAR2
                     , o_errors             OUT VARCHAR2
                     , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_data_type       IN     VARCHAR2 DEFAULT NULL
                     , p_data_length     IN     NUMBER   DEFAULT NULL
                     , p_data_precision  IN     NUMBER   DEFAULT NULL
                     , p_data_scale      IN     NUMBER   DEFAULT NULL
                     , p_nullable        IN     VARCHAR2 DEFAULT NULL
                     , p_data_default    IN     VARCHAR2 DEFAULT NULL
                     , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024) := 'otap_schema.has_column';
    l_has_column    INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128);
    l_table_name    VARCHAR2(128);
    l_column_name   VARCHAR2(128);
    l_errors        VARCHAR2(32767);
  BEGIN
    l_errors      := NULL;
    l_test_passed := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected    := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
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
      l_test_passed := count_chk(l_has_column, l_errors, l_script);
    ELSE
      -- invalid table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Missing: ' ||
                             CASE
                               WHEN l_table_name IS NULL OR LENGTH(l_table_name) = 0
                               THEN 'p_table_name(NULL) '
                             END ||
                             CASE
                               WHEN l_column_name IS NULL OR LENGTH(l_column_name) = 0
                               THEN 'p_column_name(NULL) '
                             END
      ;
      otap_log.log(l_errors, l_script, 'NULL test on table or column name');
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
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

  FUNCTION has_package( p_package_name    IN     VARCHAR2
                      , o_errors             OUT VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_package_type    IN     VARCHAR2 DEFAULT 'PACKAGE'
                      , p_package_state   IN     VARCHAR2 DEFAULT 'VALID'
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024)    := 'otap_schema.has_package';
    l_ignore        VARCHAR2(6)       := 'IGNORE';
    l_valid         VARCHAR2(5)       := 'VALID';
    l_invalid       VARCHAR2(7)       := 'INVALID';
    l_header        VARCHAR2(7)       := 'PACKAGE';
    l_body          VARCHAR2(12)      := 'PACKAGE BODY';
    l_has_package   INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128);
    l_package_name  VARCHAR2(128);
    l_package_type  VARCHAR2(12);
    l_object_state  VARCHAR2(7);
    l_errors        VARCHAR2(32767);
  BEGIN
    l_errors        := NULL;
    l_test_passed   := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected      := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_package_name  := otap_string.reduce(p_package_name, 128);
    l_object_state  := otap_string.reduce(UPPER(p_package_state), 7);
    l_package_type  := otap_string.reduce(UPPER(p_package_type), 12);
    IF     l_package_name         IS NOT NULL
       AND LENGTH(l_package_name)  > 0
       AND l_object_state         IN (l_ignore, l_valid, l_invalid)
       AND l_package_type         IN (l_header, l_body)
    THEN
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      SELECT COUNT(*)
        INTO l_has_package
        FROM dba_objects
       WHERE owner       = l_schema_to_use
         AND object_name = l_package_name
         AND object_type = l_package_type
         AND status      = CASE WHEN l_object_state = l_ignore THEN status ELSE l_object_state END
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_package, l_errors, l_script);
    ELSE
      -- invalid package name, type or state
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE
                                                  WHEN l_package_name IS NULL OR LENGTH(l_package_name) = 0
                                                  THEN 'p_package_name(NULL) '
                                                END ||
                                                CASE
                                                  WHEN l_object_state NOT IN (l_ignore, l_valid, l_invalid)
                                                  THEN 'p_package_state(' || l_object_state || ') '
                                                END ||
                                                CASE
                                                  WHEN l_package_type NOT IN (l_header, l_body)
                                                  THEN 'p_package_type(' || l_package_type || ') '
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Package name NULL or type and state invalid');
    END IF;
    -- now decide on the expected result the final state and if errors are returned
    IF l_test_passed != l_expected
    THEN
      o_errors := otap_string.reduce(l_errors, 4000);
    ELSE
      -- overwrite states from before, as we fulfill expected
      l_test_passed := otap_constants.OTAP_NUM_TEST_PASSED;
      -- overwrite errors expected
      o_errors := NULL;
    END IF;
    RETURN l_test_passed;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END has_package;

END;
/