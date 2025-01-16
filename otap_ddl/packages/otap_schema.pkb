-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS

  FUNCTION count_chk( p_count   IN            INTEGER
                    , o_errors  IN OUT NOCOPY VARCHAR2
                    , p_caller  IN            VARCHAR2
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
  FUNCTION has_table( p_table_name      IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_schema.has_table';
    l_has_table     INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128 CHAR);
    l_table_name    VARCHAR2(128 CHAR);
    l_errors        VARCHAR2(32767 CHAR);
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

  FUNCTION has_column( p_table_name      IN            VARCHAR2
                     , p_column_name     IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_data_type       IN            VARCHAR2 DEFAULT NULL
                     , p_data_length     IN            NUMBER   DEFAULT NULL
                     , p_data_precision  IN            NUMBER   DEFAULT NULL
                     , p_data_scale      IN            NUMBER   DEFAULT NULL
                     , p_nullable        IN            VARCHAR2 DEFAULT NULL
                     , p_data_default    IN            VARCHAR2 DEFAULT NULL
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR) := 'otap_schema.has_column';
    l_has_column    INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128 CHAR);
    l_table_name    VARCHAR2(128 CHAR);
    l_column_name   VARCHAR2(128 CHAR);
    l_errors        VARCHAR2(32767 CHAR);
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

  FUNCTION has_package( p_package_name    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_package_type    IN            VARCHAR2 DEFAULT 'PACKAGE'
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  IS
    l_script        VARCHAR2(1024 CHAR)    := 'otap_schema.has_package';
    l_ignore        VARCHAR2(6 CHAR)       := 'IGNORE';
    l_header        VARCHAR2(7 CHAR)       := 'PACKAGE';
    l_body          VARCHAR2(12 CHAR)      := 'PACKAGE BODY';
    l_has_package   INTEGER;
    l_test_passed   INTEGER;
    l_expected      INTEGER;
    l_schema_to_use VARCHAR2(128 CHAR);
    l_package_name  VARCHAR2(128 CHAR);
    l_package_type  VARCHAR2(12 CHAR);
    l_errors        VARCHAR2(32767 CHAR);
  BEGIN
    l_errors        := NULL;
    l_test_passed   := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected      := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_package_name  := otap_string.reduce(p_package_name, 128);
    l_package_type  := otap_string.reduce(UPPER(p_package_type), 12);
    IF     l_package_name         IS NOT NULL
       AND LENGTH(l_package_name)  > 0
       AND l_package_type         IN (l_header, l_body)
    THEN
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      SELECT COUNT(*)
        INTO l_has_package
        FROM dba_objects
       WHERE owner       = l_schema_to_use
         AND object_name = l_package_name
         AND object_type = l_package_type
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_package, l_errors, l_script);
    ELSE
      -- invalid package name or type
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE
                                                  WHEN l_package_name IS NULL OR LENGTH(l_package_name) = 0
                                                  THEN 'p_package_name(NULL) '
                                                END ||
                                                CASE
                                                  WHEN l_package_type NOT IN (l_header, l_body)
                                                  THEN 'p_package_type(' || l_package_type || ') '
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Package name NULL or type invalid');
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

  FUNCTION has_procedure( p_procedure_name  IN            VARCHAR2
                        , o_errors             OUT NOCOPY VARCHAR2
                        , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_procedure_type  IN            VARCHAR2 DEFAULT 'FUNCTION'
                        , p_package_name    IN            VARCHAR2 DEFAULT NULL
                        , p_return_type     IN            VARCHAR2 DEFAULT NULL
                        , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN INTEGER
  IS
    l_script         VARCHAR2(1024 CHAR)    := 'otap_schema.has_procedure';
    l_procedure      VARCHAR2(9 CHAR)       := 'PROCEDURE';
    l_function       VARCHAR2(8 CHAR)       := 'FUNCTION';
    l_test_passed    INTEGER;
    l_expected       INTEGER;
    l_has_procedure  INTEGER;
    l_procedure_name VARCHAR2(128 CHAR);
    l_package_name   VARCHAR2(128 CHAR);
    l_procedure_type VARCHAR2(9 CHAR);
    l_return_type    VARCHAR2(128 CHAR);
    l_schema_to_use  VARCHAR2(128 CHAR);
    l_errors         VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_procedure_name  := otap_string.reduce(p_procedure_name, 128);
    l_package_name    := otap_string.reduce(p_package_name, 128);
    l_procedure_type  := otap_string.reduce(UPPER(p_procedure_type), 9);
    l_return_type     := otap_string.reduce(UPPER(p_return_type), 128);
    IF     l_procedure_name        IS NOT NULL
       AND LENGTH(l_procedure_name) > 0
       AND l_procedure_type        IN (l_procedure, l_function)
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
        WITH prc AS
             (SELECT dbo.owner
                   , dbp.procedure_name
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN 'FUNCTION'
                       ELSE 'PROCEDURE'
                     END AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , dbo.object_name AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner          = dbr.owner
                 AND dbp.object_name    = dbr.package_name
                 AND dbp.procedure_name = dbr.object_name
                 AND dbp.object_id      = dbr.object_id
                 AND dbp.subprogram_id  = dbr.subprogram_id
                 AND dbr.sequence       = 1
               WHERE dbo.owner        = l_schema_to_use
                 AND dbo.object_type  = 'PACKAGE'
                     -- exclude package itself
                 AND dbp.procedure_name IS NOT NULL
               UNION ALL
              SELECT dbo.owner
                   , dbo.object_name AS procedure_name
                   , dbo.object_type AS procedure_type
                   , CASE
                       WHEN dbr.position       = 0
                        AND dbr.argument_name IS NULL
                       THEN dbr.data_type
                       ELSE NULL
                     END AS return_type
                   , dbo.status
                   , NULL AS package_name
                FROM dba_objects dbo
                LEFT OUTER JOIN dba_procedures dbp
                  ON dbo.owner       = dbp.owner
                 AND dbo.object_name = dbp.object_name
                 AND dbo.object_type = dbp.object_type
                LEFT OUTER JOIN dba_arguments dbr
                  ON dbp.owner         = dbr.owner
                 AND dbp.object_name   = dbr.object_name
                 AND dbp.object_id     = dbr.object_id
                 AND dbp.subprogram_id = dbr.subprogram_id
                 AND dbr.sequence      = 1
               WHERE dbo.owner        = l_schema_to_use
                 AND dbo.object_type IN ('FUNCTION', 'PROCEDURE')
             )
      SELECT COUNT(*)
        INTO l_has_procedure
        FROM prc
       WHERE procedure_name           = l_procedure_name
         AND procedure_type           = l_procedure_type
         AND NVL(return_type, 'n/a')  = NVL(l_return_type, NVL(return_type, 'n/a'))
         AND NVL(package_name, 'n/a') = NVL(l_package_name, NVL(package_name, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_procedure, l_errors, l_script);
    ELSE
      -- invalid package name, type or state
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE
                                                  WHEN l_procedure_name IS NULL OR LENGTH(l_procedure_name) = 0
                                                  THEN 'p_procedure_name(NULL) '
                                                END ||
                                                CASE
                                                  WHEN l_procedure_type NOT IN (l_procedure, l_function)
                                                  THEN 'p_procedure_type(' || l_procedure_type || ') '
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Package name NULL or type invalid');
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
  END has_procedure;

  FUNCTION has_trigger( p_trigger_name    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_trigger_type    IN            VARCHAR2 DEFAULT NULL
                      , p_trigger_event   IN            VARCHAR2 DEFAULT NULL
                      , p_table_owner     IN            VARCHAR2 DEFAULT NULL
                      , p_table_name      IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  IS
    l_script         VARCHAR2(1024 CHAR)    := 'otap_schema.has_trigger';
    l_test_passed    INTEGER;
    l_expected       INTEGER;
    l_has_trigger    INTEGER;
    l_trigger_name   VARCHAR2(128 CHAR);
    l_trigger_type   VARCHAR2(16 CHAR);
    l_trigger_event  VARCHAR2(246 CHAR);
    l_table_owner    VARCHAR2(128 CHAR);
    l_table_name     VARCHAR2(128 CHAR);
    l_schema_to_use  VARCHAR2(128 CHAR);
    l_errors         VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_trigger_name    := otap_string.reduce(p_trigger_name, 128);
    l_trigger_type    := otap_string.reduce(UPPER(p_trigger_type), 16);
    l_trigger_event   := otap_string.reduce(UPPER(p_trigger_event), 246);
    l_table_owner     := otap_string.reduce(p_table_owner, 128);
    l_table_name      := otap_string.reduce(p_table_name, 128);
    IF     l_trigger_name        IS NOT NULL
       AND LENGTH(l_trigger_name) > 0
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_trigger
        FROM dba_triggers
       WHERE owner                  = l_schema_to_use
         AND trigger_name           = l_trigger_name
         AND trigger_type           = NVL(l_trigger_type, trigger_type)
         AND triggering_event       = NVL(l_trigger_event, triggering_event)
         AND table_owner            = NVL(l_table_owner, table_owner)
         AND NVL(table_name, 'n/a') = NVL(l_table_name, NVL(table_name, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_trigger, l_errors, l_script);
    ELSE
      -- invalid package name, type or state
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_trigger_name(NULL)';
      otap_log.log(l_errors, l_script, 'Trigger name NULL');
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
  END has_trigger;

  FUNCTION has_object( p_object_name     IN            VARCHAR2
                     , p_object_type     IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  IS
    l_script         VARCHAR2(1024 CHAR)    := 'otap_schema.has_object';
    l_test_passed    INTEGER;
    l_expected       INTEGER;
    l_has_object     INTEGER;
    l_object_name    VARCHAR2(128 CHAR);
    l_object_type    VARCHAR2(23 CHAR);
    l_schema_to_use  VARCHAR2(128 CHAR);
    l_errors         VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_object_name     := otap_string.reduce(p_object_name, 128);
    l_object_type     := otap_string.reduce(UPPER(p_object_type), 23);
    IF     l_object_name        IS NOT NULL
       AND LENGTH(l_object_name) > 0
       AND l_object_type        IS NOT NULL
       AND LENGTH(l_object_type) > 0
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_object
        FROM dba_objects
       WHERE owner       = l_schema_to_use
         AND object_name = l_object_name
         AND object_type = l_object_type
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_object, l_errors, l_script);
    ELSE
      -- invalid package name, type or state
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE
                                                  WHEN l_object_name IS NULL OR LENGTH(l_object_name) = 0
                                                  THEN 'p_object_name(NULL) '
                                                END ||
                                                CASE
                                                  WHEN l_object_type IS NULL OR LENGTH(l_object_type) = 0
                                                  THEN 'p_object_type(NULL)'
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Object name NULL or type NULL');
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
  END has_object;

END;
/