-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS
  -- internal functions
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
      IF l_test_passed = otap_constants.OTAP_NUM_TEST_FAILED
      THEN
        l_errors := 'Table does not exist: ' || l_schema_to_use || '.' || l_table_name;
      END IF;
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
      -- overwrite errors found
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
         AND NVL(data_type, 'n/a')              = NVL(UPPER(p_data_type), NVL(data_type, 'n/a'))
         AND data_length                        = NVL(p_data_length, data_length)
         AND NVL(nullable, 'n/a')               = NVL(UPPER(p_nullable), NVL(nullable, 'n/a'))
         AND NVL(data_precision, -1)            = NVL(p_data_precision, NVL(data_precision, -1))
         AND NVL(data_scale, -1)                = NVL(p_data_scale, NVL(data_scale, -1))
         AND TRIM(NVL(data_default_vc, 'n/a'))  = NVL(TRIM(p_data_default), TRIM(NVL(data_default_vc, 'n/a')))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_column, l_errors, l_script);
      IF l_test_passed = otap_constants.OTAP_NUM_TEST_FAILED
      THEN
        l_errors := 'Column does not exist: ' || l_schema_to_use || '.' || l_table_name || '.' || l_column_name;
      END IF;
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
             -- surprisingly nullable columns
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
       WHERE procedure_name             = l_procedure_name
         AND procedure_type             = l_procedure_type
         AND NVL(return_type, 'n/a')    = NVL(l_return_type, NVL(return_type, 'n/a'))
         AND NVL(package_name, 'n/a')   = NVL(l_package_name, NVL(package_name, 'n/a'))
      ;
      -- we may find more than 1 entry, if function or procedure has same name but different signature
      l_test_passed := CASE WHEN l_has_procedure = 0 THEN otap_constants.OTAP_NUM_TEST_FAILED ELSE otap_constants.OTAP_NUM_TEST_PASSED END;
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
       WHERE owner                        = l_schema_to_use
         AND trigger_name                 = l_trigger_name
         AND NVL(trigger_type, 'n/a')     = NVL(l_trigger_type, NVL(trigger_type, 'n/a'))
         AND NVL(triggering_event, 'n/a') = NVL(l_trigger_event, NVL(triggering_event, 'n/a'))
         AND NVL(table_owner, 'n/a')      = NVL(l_table_owner, NVL(table_owner, 'n/a'))
         AND NVL(table_name, 'n/a')       = NVL(l_table_name, NVL(table_name, 'n/a'))
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

  FUNCTION has_constraint( p_table_name      IN            VARCHAR2
                         , o_errors             OUT NOCOPY VARCHAR2
                         , p_constraint_type IN            VARCHAR2 DEFAULT 'C'
                         , p_column_name     IN            VARCHAR2 DEFAULT NULL
                         , p_constraint      IN            VARCHAR2 DEFAULT NULL
                         , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_constraint';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_constraint  INTEGER;
    l_constraint_type CHAR(1 CHAR);
    l_table_name      VARCHAR2(128 CHAR);
    l_column_name     VARCHAR2(128 CHAR);
    l_constraint_name VARCHAR2(128 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_table_name      := otap_string.reduce(p_table_name, 128);
    l_column_name     := otap_string.reduce(p_column_name, 128);
    l_constraint_name := otap_string.reduce(p_constraint, 128);
    l_constraint_type := otap_string.reduce(UPPER(p_constraint_type), 1);
    IF     l_table_name        IS NOT NULL
       AND LENGTH(l_table_name) > 0
       AND l_constraint_type   IN ('P', 'U', 'R', 'C', 'F', 'O', 'V', 'H')
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_constraint
        FROM dba_constraints dco
        LEFT OUTER JOIN dba_cons_columns dcc
          ON dco.owner                        = dcc.owner
         AND dco.constraint_name              = dcc.constraint_name
         AND dco.table_name                   = dcc.table_name
       WHERE dco.owner                        = l_schema_to_use
         AND dco.table_name                   = l_table_name
         AND NVL(dcc.column_name, 'n/a')      = NVL(l_column_name, NVL(dcc.column_name, 'n/a'))
         AND dco.constraint_name              = NVL(l_constraint_name, dco.constraint_name)
         AND dco.constraint_type              = l_constraint_type
      ;
      -- we may find more than one entry for combined primary keys
      l_test_passed := CASE WHEN l_has_constraint = 0 THEN otap_constants.OTAP_NUM_TEST_FAILED ELSE otap_constants.OTAP_NUM_TEST_PASSED END;
    ELSE
      -- missing mandatory table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE WHEN l_table_name IS NULL THEN 'p_table_name(NULL) ' END ||
                                                CASE
                                                  WHEN l_constraint_type NOT IN ('P', 'U', 'R', 'C', 'F', 'O', 'V', 'H')
                                                  THEN 'p_constraint_type(' || NVL(p_constraint_type, 'NULL') || ') '
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Table name NULL or invalid constraint type');
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
  END has_constraint;

  FUNCTION has_ref_constraint( p_table_name      IN            VARCHAR2
                             , o_errors             OUT NOCOPY VARCHAR2
                             , p_constraint_type IN            VARCHAR2 DEFAULT 'R'
                             , p_column_name     IN            VARCHAR2 DEFAULT NULL
                             , p_constraint      IN            VARCHAR2 DEFAULT NULL
                             , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                             , p_r_table_name    IN            VARCHAR2 DEFAULT NULL
                             , p_r_column_name   IN            VARCHAR2 DEFAULT NULL
                             , p_r_constraint    IN            VARCHAR2 DEFAULT NULL
                             , p_r_schema        IN            VARCHAR2 DEFAULT NULL
                             , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                             )
    RETURN INTEGER
  IS
    l_script            VARCHAR2(1024 CHAR)    := 'otap_schema.has_ref_constraint';
    l_test_passed       INTEGER;
    l_expected          INTEGER;
    l_has_constraint    INTEGER;
    l_constraint_type   CHAR(1 CHAR);
    l_table_name        VARCHAR2(128 CHAR);
    l_column_name       VARCHAR2(128 CHAR);
    l_constraint_name   VARCHAR2(128 CHAR);
    l_schema_to_use     VARCHAR2(128 CHAR);
    l_r_table_name      VARCHAR2(128 CHAR);
    l_r_column_name     VARCHAR2(128 CHAR);
    l_r_constraint_name VARCHAR2(128 CHAR);
    l_r_schema          VARCHAR2(128 CHAR);
    l_errors            VARCHAR2(32767 CHAR);
  BEGIN
    l_errors            := NULL;
    l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected          := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_table_name        := otap_string.reduce(p_table_name, 128);
    l_column_name       := otap_string.reduce(p_column_name, 128);
    l_constraint_name   := otap_string.reduce(p_constraint, 128);
    l_r_table_name      := otap_string.reduce(p_r_table_name, 128);
    l_r_column_name     := otap_string.reduce(p_r_column_name, 128);
    l_r_constraint_name := otap_string.reduce(p_r_constraint, 128);
    l_r_schema          := otap_string.reduce(p_r_schema, 128);
    l_constraint_type   := otap_string.reduce(UPPER(p_constraint_type), 1);
    IF     l_table_name        IS NOT NULL
       AND LENGTH(l_table_name) > 0
       AND l_constraint_type   IN ('R', 'F')
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_constraint
        FROM dba_constraints dco
        LEFT OUTER JOIN dba_cons_columns dcc
          ON dco.owner           = dcc.owner
         AND dco.constraint_name = dcc.constraint_name
         AND dco.table_name      = dcc.table_name
        LEFT OUTER JOIN dba_cons_columns dcr
          ON dco.r_owner                        = dcr.owner
         AND dco.r_constraint_name              = dcr.constraint_name
       WHERE dco.owner                          = l_schema_to_use
         AND dco.table_name                     = l_table_name
         AND NVL(dcc.column_name, 'n/a')        = NVL(l_column_name, NVL(dcc.column_name, 'n/a'))
         AND dco.constraint_name                = NVL(l_constraint_name, dco.constraint_name)
         AND NVL(dco.r_owner, 'n/a')            = NVL(l_r_schema, NVL(dco.r_owner, 'n/a'))
         AND NVL(dco.r_constraint_name, 'n/a')  = NVL(l_r_constraint_name, NVL(dco.r_constraint_name, 'n/a'))
         AND NVL(dcr.table_name, 'n/a')         = NVL(l_r_table_name, NVL(dcr.table_name, 'n/a'))
         AND NVL(dcr.column_name, 'n/a')        = NVL(l_r_column_name, NVL(dcr.column_name, 'n/a'))
         AND dco.constraint_type                = l_constraint_type
      ;
      -- we may find more than one entry for combined primary keys
      l_test_passed := CASE WHEN l_has_constraint = 0 THEN otap_constants.OTAP_NUM_TEST_FAILED ELSE otap_constants.OTAP_NUM_TEST_PASSED END;
    ELSE
      -- missing mandatory table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE WHEN l_table_name IS NULL THEN 'p_table_name(NULL) ' END ||
                                                CASE
                                                  WHEN l_constraint_type NOT IN ('R', 'F')
                                                  THEN 'p_constraint_type(' || NVL(p_constraint_type, 'NULL') || ')'
                                                END
      ;
      otap_log.log(l_errors, l_script, 'Table name NULL or invalid constraint type');
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
  END has_ref_constraint;

  FUNCTION has_not_null_constraint( p_table_name      IN            VARCHAR2
                                  , p_column_name     IN            VARCHAR2
                                  , o_errors             OUT NOCOPY VARCHAR2
                                  , p_constraint      IN            VARCHAR2 DEFAULT NULL
                                  , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                                  )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_not_null_constraint';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_constraint  INTEGER;
    l_constraint_type CHAR(1 CHAR);
    l_table_name      VARCHAR2(128 CHAR);
    l_column_name     VARCHAR2(128 CHAR);
    l_constraint_name VARCHAR2(128 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_table_name      := otap_string.reduce(p_table_name, 128);
    l_column_name     := otap_string.reduce(p_column_name, 128);
    l_constraint_name := otap_string.reduce(p_constraint, 128);
    l_constraint_type := 'C';
    IF     l_table_name         IS NOT NULL
       AND LENGTH(l_table_name)  > 0
       AND l_column_name        IS NOT NULL
       AND LENGTH(l_column_name) > 0
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_constraint
        FROM dba_constraints dco
        LEFT OUTER JOIN dba_cons_columns dcc
          ON dco.owner                                                   = dcc.owner
         AND dco.constraint_name                                         = dcc.constraint_name
         AND dco.table_name                                              = dcc.table_name
       WHERE dco.owner                                                   = l_schema_to_use
         AND dco.table_name                                              = l_table_name
         AND dcc.column_name                                             = l_column_name
         AND INSTR(UPPER(dco.search_condition_vc), UPPER(l_column_name)) > 0
         AND INSTR( otap_string.flatten( UPPER(dco.search_condition_vc)
                                       , 4000)
                  , 'IS NOT NULL'
                  )                                                      > 0
         AND dco.constraint_name                                         = NVL(l_constraint_name, dco.constraint_name)
         AND dco.constraint_type                                         = l_constraint_type
      ;
      -- we may find more than one entry for combined primary keys
      l_test_passed := CASE WHEN l_has_constraint = 0 THEN otap_constants.OTAP_NUM_TEST_FAILED ELSE otap_constants.OTAP_NUM_TEST_PASSED END;
    ELSE
      -- missing mandatory table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: ' || CASE WHEN l_table_name IS NULL THEN 'p_table_name(NULL) ' END ||
                                                CASE WHEN l_column_name IS NULL THEN 'p_column_name(NULL) ' END
      ;
      otap_log.log(l_errors, l_script, 'Table name or column name NULL');
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
  END has_not_null_constraint;

  FUNCTION has_index( p_table_name      IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_column_name     IN            VARCHAR2 DEFAULT NULL
                    , p_index_name      IN            VARCHAR2 DEFAULT NULL
                    , p_index_type      IN            VARCHAR2 DEFAULT NULL
                    , p_table_type      IN            VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN            VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN            VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN            VARCHAR2 DEFAULT NULL
                    , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_index';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_index       INTEGER;
    l_table_name      VARCHAR2(128 CHAR);
    l_column_name     VARCHAR2(128 CHAR);
    l_index_name      VARCHAR2(128 CHAR);
    l_index_type      VARCHAR2(27 CHAR);
    l_table_type      VARCHAR2(11 CHAR);
    l_uniqueness      VARCHAR2(9 CHAR);
    l_tablespace_name VARCHAR2(30 CHAR);
    l_partitioned     VARCHAR2(3 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_table_name      := otap_string.reduce(p_table_name, 128);
    l_column_name     := otap_string.reduce(p_column_name, 128);
    l_index_name      := otap_string.reduce(p_index_name, 128);
    l_index_type      := otap_string.reduce(UPPER(p_index_type), 27);
    l_table_type      := otap_string.reduce(UPPER(p_table_type), 11);
    l_uniqueness      := otap_string.reduce(UPPER(p_uniqueness), 9);
    l_tablespace_name := otap_string.reduce(p_tablespace_name, 30);
    l_partitioned     := otap_string.reduce(UPPER(p_partitioned), 3);
    IF    (    l_table_name        IS NOT NULL
           AND LENGTH(l_table_name) > 0
          )
       OR (    l_index_name        IS NOT NULL
           AND LENGTH(l_index_name) > 0
          )
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_index
        FROM dba_indexes dix
        LEFT OUTER JOIN dba_ind_columns dic
          ON dix.owner       = dic.index_owner
         AND dix.index_name  = dic.index_name
         AND dix.table_owner = dic.table_owner
         AND dix.table_name  = dic.table_name
       WHERE dix.owner                       = l_schema_to_use
         AND dix.index_name                  = NVL(l_index_name, dix.index_name)
         AND dix.table_name                  = NVL(l_table_name, dix.table_name)
         AND NVL(dic.column_name, 'n/a')     = NVL(l_column_name, NVL(dic.column_name, 'n/a'))
         AND NVL(dix.index_type, 'n/a')      = NVL(l_index_type, NVL(dix.index_type, 'n/a'))
         AND NVL(dix.table_type, 'n/a')      = NVL(l_table_type, NVL(dix.table_type, 'n/a'))
         AND NVL(dix.uniqueness, 'n/a')      = NVL(l_uniqueness, NVL(dix.uniqueness, 'n/a'))
         AND NVL(dix.tablespace_name, 'n/a') = NVL(l_tablespace_name, NVL(dix.tablespace_name, 'n/a'))
         AND NVL(dix.partitioned, 'n/a')     = NVL(l_partitioned, NVL(dix.partitioned, 'n/a'))
      ;
      -- we may find more than one entry for index columns
      l_test_passed := CASE WHEN l_has_index = 0 THEN otap_constants.OTAP_NUM_TEST_FAILED ELSE otap_constants.OTAP_NUM_TEST_PASSED END;
    ELSE
      -- table name or index name missing
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_table_name AND p_index_name NULL';
      otap_log.log(l_errors, l_script, 'Table name and index name NULL');
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
  END has_index;

  FUNCTION has_type( p_type_name       IN            VARCHAR2
                   , o_errors             OUT NOCOPY VARCHAR2
                   , p_typecode        IN            VARCHAR2 DEFAULT NULL
                   , p_attributes      IN            NUMBER   DEFAULT NULL
                   , p_methods         IN            NUMBER   DEFAULT NULL
                   , p_predefined      IN            VARCHAR2 DEFAULT NULL
                   , p_incomplete      IN            VARCHAR2 DEFAULT NULL
                   , p_final           IN            VARCHAR2 DEFAULT NULL
                   , p_persistable     IN            VARCHAR2 DEFAULT NULL
                   , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                   , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_type';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_type        INTEGER;
    l_type_name       VARCHAR2(128 CHAR);
    l_typecode        VARCHAR2(128 CHAR);
    l_predefined      VARCHAR2(3 CHAR);
    l_incomplete      VARCHAR2(3 CHAR);
    l_final           VARCHAR2(3 CHAR);
    l_persistable     VARCHAR2(3 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_type_name       := otap_string.reduce(p_type_name, 128);
    l_typecode        := otap_string.reduce(UPPER(p_typecode), 128);
    l_predefined      := otap_string.reduce(UPPER(p_predefined), 3);
    l_incomplete      := otap_string.reduce(UPPER(p_incomplete), 3);
    l_final           := otap_string.reduce(UPPER(p_final), 3);
    l_persistable     := otap_string.reduce(UPPER(p_persistable), 3);
    IF     l_type_name        IS NOT NULL
       AND LENGTH(l_type_name) > 0
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_type
        FROM dba_types
       WHERE owner                   = l_schema_to_use
         AND type_name               = l_type_name
         AND NVL(typecode, 'n/a')    = NVL(l_typecode, NVL(typecode, 'n/a'))
         AND NVL(attributes, -1)     = NVL(p_attributes, NVL(attributes, -1))
         AND NVL(methods, -1)        = NVL(p_methods, NVL(methods, -1))
         AND NVL(predefined, 'n/a')  = NVL(l_predefined, NVL(predefined, 'n/a'))
         AND NVL(incomplete, 'n/a')  = NVL(l_incomplete, NVL(incomplete, 'n/a'))
         AND NVL(final, 'n/a')       = NVL(l_final, NVL(final, 'n/a'))
         AND NVL(persistable, 'n/a') = NVL(l_persistable, NVL(persistable, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_type, l_errors, l_script);
    ELSE
      -- type name missing
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_type_name(NULL)';
      otap_log.log(l_errors, l_script, 'Type name NULL');
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
  END has_type;

  FUNCTION has_sequence( p_sequence_name   IN            VARCHAR2
                       , o_errors             OUT NOCOPY VARCHAR2
                       , p_table_name      IN            VARCHAR2 DEFAULT NULL
                       , p_column_name     IN            VARCHAR2 DEFAULT NULL
                       , p_min_value       IN            NUMBER   DEFAULT NULL
                       , p_max_value       IN            NUMBER   DEFAULT NULL
                       , p_increment_by    IN            NUMBER   DEFAULT NULL
                       , p_cycle_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_order_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_cache_size      IN            NUMBER   DEFAULT NULL
                       , p_scale_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_extend_flag     IN            VARCHAR2 DEFAULT NULL
                       , p_sharded_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_session_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_keep_value      IN            VARCHAR2 DEFAULT NULL
                       , p_table_owner     IN            VARCHAR2 DEFAULT NULL
                       , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                       )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_sequence';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_sequence    INTEGER;
    l_sequence_name   VARCHAR2(128 CHAR);
    l_table_name      VARCHAR2(128 CHAR);
    l_column_name     VARCHAR2(128 CHAR);
    l_table_owner     VARCHAR2(128 CHAR);
    l_cycle_flag      VARCHAR2(1 CHAR);
    l_order_flag      VARCHAR2(1 CHAR);
    l_scale_flag      VARCHAR2(1 CHAR);
    l_extend_flag     VARCHAR2(1 CHAR);
    l_sharded_flag    VARCHAR2(1 CHAR);
    l_session_flag    VARCHAR2(1 CHAR);
    l_keep_value      VARCHAR2(1 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_sequence_name   := otap_string.reduce(p_sequence_name, 128);
    l_table_name      := otap_string.reduce(p_table_name, 128);
    l_column_name     := otap_string.reduce(p_column_name, 128);
    l_table_owner     := otap_string.reduce(p_table_owner, 128);
    l_cycle_flag      := otap_string.reduce(UPPER(p_cycle_flag), 1);
    l_order_flag      := otap_string.reduce(UPPER(p_order_flag), 1);
    l_scale_flag      := otap_string.reduce(UPPER(p_scale_flag), 1);
    l_extend_flag     := otap_string.reduce(UPPER(p_extend_flag), 1);
    l_sharded_flag    := otap_string.reduce(UPPER(p_sharded_flag), 1);
    l_session_flag    := otap_string.reduce(UPPER(p_session_flag), 1);
    l_keep_value      := otap_string.reduce(UPPER(p_keep_value), 1);
    IF    (    l_sequence_name        IS NOT NULL
           AND LENGTH(l_sequence_name) > 0
          )
       OR (    l_table_name         IS NOT NULL
           AND LENGTH(l_table_name)  > 0
           AND l_column_name        IS NOT NULL
           AND LENGTH(l_column_name) > 0
          )
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_sequence
        FROM dba_sequences dbs
        LEFT OUTER JOIN dba_tab_identity_cols dti
          ON dbs.sequence_name  = dti.sequence_name
         AND dti.owner = NVL(l_table_owner, l_schema_to_use)
       WHERE dbs.sequence_owner = l_schema_to_use
         AND dbs.sequence_name  = NVL(l_sequence_name, dbs.sequence_name)
         AND NVL(dti.table_name, 'n/a')   = NVL(l_table_name, NVL(dti.table_name, 'n/a'))
         AND NVL(dti.column_name, 'n/a')  = NVL(l_column_name, NVL(dti.column_name, 'n/a'))
         AND NVL(cycle_flag, 'n/a')       = NVL(l_cycle_flag, NVL(cycle_flag, 'n/a'))
         AND NVL(order_flag, 'n/a')       = NVL(l_order_flag, NVL(order_flag, 'n/a'))
         AND NVL(scale_flag, 'n/a')       = NVL(l_scale_flag, NVL(scale_flag, 'n/a'))
         AND NVL(extend_flag, 'n/a')      = NVL(l_extend_flag, NVL(extend_flag, 'n/a'))
         AND NVL(sharded_flag, 'n/a')     = NVL(l_sharded_flag, NVL(sharded_flag, 'n/a'))
         AND NVL(session_flag, 'n/a')     = NVL(l_session_flag, NVL(session_flag, 'n/a'))
         AND NVL(keep_value, 'n/a')       = NVL(l_keep_value, NVL(keep_value, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_sequence, l_errors, l_script);
    ELSE
      -- either sequence name or table and column name must be
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_sequence_name and (p_table_name or p_column_name) NULL';
      otap_log.log(l_errors, l_script, 'Sequence name and table or column name is NULL');
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
  END has_sequence;

  FUNCTION has_scheduler_job( p_job_name        IN            VARCHAR2
                            , o_errors             OUT NOCOPY VARCHAR2
                            , p_job_style       IN            VARCHAR2 DEFAULT NULL
                            , p_job_type        IN            VARCHAR2 DEFAULT NULL
                            , p_job_action      IN            VARCHAR2 DEFAULT NULL
                            , p_schedule_type   IN            VARCHAR2 DEFAULT NULL
                            , p_repeat_interval IN            VARCHAR2 DEFAULT NULL
                            , p_job_class       IN            VARCHAR2 DEFAULT NULL
                            , p_logging_level   IN            VARCHAR2 DEFAULT NULL
                            , p_store_output    IN            VARCHAR2 DEFAULT NULL
                            , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                            , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                            )
    RETURN INTEGER
  IS
    l_script          VARCHAR2(1024 CHAR)    := 'otap_schema.has_scheduler_job';
    l_test_passed     INTEGER;
    l_expected        INTEGER;
    l_has_job         INTEGER;
    l_job_name        VARCHAR2(128 CHAR);
    l_job_style       VARCHAR2(17 CHAR);
    l_job_type        VARCHAR2(16 CHAR);
    l_job_action      VARCHAR2(4000 CHAR);
    l_schedule_type   VARCHAR2(12 CHAR);
    l_repeat_interval VARCHAR2(4000 CHAR);
    l_job_class       VARCHAR2(128 CHAR);
    l_logging_level   VARCHAR2(11 CHAR);
    l_store_output    VARCHAR2(5 CHAR);
    l_schema_to_use   VARCHAR2(128 CHAR);
    l_errors          VARCHAR2(32767 CHAR);
  BEGIN
    l_errors          := NULL;
    l_test_passed     := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected        := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_job_name        := otap_string.reduce(p_job_name, 128);
    l_job_style       := otap_string.reduce(UPPER(p_job_style), 17);
    l_job_type        := otap_string.reduce(UPPER(p_job_type), 16);
    l_job_action      := otap_string.reduce(otap_string.flatten(UPPER(p_job_action), 4000), 4000);
    l_schedule_type   := otap_string.reduce(UPPER(p_schedule_type), 12);
    l_repeat_interval := otap_string.reduce(UPPER(p_repeat_interval), 4000);
    l_job_class       := otap_string.reduce(UPPER(p_job_class), 128);
    l_logging_level   := otap_string.reduce(UPPER(p_logging_level), 11);
    l_store_output    := otap_string.reduce(UPPER(p_store_output), 5);
    IF     l_job_name        IS NOT NULL
       AND LENGTH(l_job_name) > 0
    THEN
      -- schema
      l_schema_to_use := otap_string.reduce(TRIM(NVL(p_schema, SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'))), 128);
      -- check
      SELECT COUNT(*)
        INTO l_has_job
        FROM dba_scheduler_jobs
       WHERE owner                                    = l_schema_to_use
         AND job_name                                 = l_job_name
         AND NVL(job_style, 'n/a')                    = NVL(l_job_style, NVL(job_style, 'n/a'))
         AND NVL(job_type, 'n/a')                     = NVL(l_job_type, NVL(job_type, 'n/a'))
         AND NVL( otap_string.reduce( otap_string.flatten( UPPER(job_action)
                                                         , 4000
                                                         )
                                    , 4000
                                    )
                , 'n/a'
                )                                     = NVL(l_job_action, NVL(otap_string.reduce(otap_string.flatten(UPPER(job_action), 4000), 4000), 'n/a'))
         AND NVL(schedule_type, 'n/a')                = NVL(l_schedule_type, NVL(schedule_type, 'n/a'))
         AND NVL(TRIM(UPPER(repeat_interval)), 'n/a') = NVL(l_repeat_interval, NVL(TRIM(UPPER(repeat_interval)), 'n/a'))
         AND NVL(job_class, 'n/a')                    = NVL(l_job_class, NVL(job_class, 'n/a'))
         AND NVL(logging_level, 'n/a')                = NVL(l_logging_level, NVL(logging_level, 'n/a'))
         AND NVL(store_output, 'n/a')                 = NVL(l_store_output, NVL(store_output, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_job, l_errors, l_script);
    ELSE
      -- job name must be set
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_job_name(NULL)';
      otap_log.log(l_errors, l_script, 'Scheduler job name is NULL');
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
  END has_scheduler_job;

  FUNCTION has_user( p_username              IN            VARCHAR2
                   , o_errors                   OUT NOCOPY VARCHAR2
                   , p_account_status        IN            VARCHAR2 DEFAULT NULL
                   , p_default_tablespace    IN            VARCHAR2 DEFAULT NULL
                   , p_temporary_tablespace  IN            VARCHAR2 DEFAULT NULL
                   , p_local_temp_tablespace IN            VARCHAR2 DEFAULT NULL
                   , p_profile               IN            VARCHAR2 DEFAULT NULL
                   , p_password_versions     IN            VARCHAR2 DEFAULT NULL
                   , p_authentication_type   IN            VARCHAR2 DEFAULT NULL
                   , p_proxy_only_connect    IN            VARCHAR2 DEFAULT NULL
                   , p_protected             IN            VARCHAR2 DEFAULT NULL
                   , p_read_only             IN            VARCHAR2 DEFAULT NULL
                   , p_expected_result       IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN INTEGER
  IS
    l_script                VARCHAR2(1024 CHAR)    := 'otap_schema.has_user';
    l_test_passed           INTEGER;
    l_expected              INTEGER;
    l_has_user              INTEGER;
    l_username              VARCHAR2(128 CHAR);
    l_account_status        VARCHAR2(32 CHAR);
    l_default_tablespace    VARCHAR2(30 CHAR);
    l_temporary_tablespace  VARCHAR2(30 CHAR);
    l_local_temp_tablespace VARCHAR2(30 CHAR);
    l_profile               VARCHAR2(128 CHAR);
    l_password_versions     VARCHAR2(17 CHAR);
    l_authentication_type   VARCHAR2(8 CHAR);
    l_proxy_only_connect    VARCHAR2(1 CHAR);
    l_protected             VARCHAR2(3 CHAR);
    l_read_only             VARCHAR2(3 CHAR);
    l_errors                VARCHAR2(32767 CHAR);
  BEGIN
    l_errors                := NULL;
    l_test_passed           := otap_constants.OTAP_NUM_TEST_UNDEFINED;
    l_expected              := NVL(p_expected_result, otap_constants.OTAP_NUM_TEST_PASSED);
    l_username              := otap_string.reduce(p_username, 128);
    l_account_status        := otap_string.reduce(UPPER(p_account_status), 32);
    l_default_tablespace    := otap_string.reduce(p_default_tablespace, 30);
    l_temporary_tablespace  := otap_string.reduce(p_temporary_tablespace, 30);
    l_local_temp_tablespace := otap_string.reduce(p_local_temp_tablespace, 30);
    l_profile               := otap_string.reduce(UPPER(p_profile), 128);
    l_password_versions     := otap_string.reduce(p_password_versions, 17);
    l_authentication_type   := otap_string.reduce(UPPER(p_authentication_type), 8);
    l_proxy_only_connect    := otap_string.reduce(UPPER(p_proxy_only_connect), 1);
    l_protected             := otap_string.reduce(UPPER(p_protected), 3);
    l_read_only             := otap_string.reduce(UPPER(p_read_only), 3);
    IF     p_username        IS NOT NULL
       AND LENGTH(p_username) > 0
    THEN
      -- check
      SELECT COUNT(*)
        INTO l_has_user
        FROM dba_users
       WHERE username                            = l_username
         AND account_status                      = NVL(l_account_status, account_status)
         AND default_tablespace                  = NVL(l_default_tablespace, default_tablespace)
         AND temporary_tablespace                = NVL(l_temporary_tablespace, temporary_tablespace)
         AND NVL(local_temp_tablespace, 'n/a')   = NVL(l_local_temp_tablespace, NVL(local_temp_tablespace, 'n/a'))
         AND profile                             = NVL(l_profile, profile)
         AND TRIM(NVL(password_versions, 'n/a')) = NVL(l_password_versions, TRIM(NVL(password_versions, 'n/a')))
         AND NVL(authentication_type, 'n/a')     = NVL(l_authentication_type, NVL(authentication_type, 'n/a'))
         AND NVL(proxy_only_connect, 'n/a')      = NVL(l_proxy_only_connect, NVL(proxy_only_connect, 'n/a'))
         AND NVL(protected, 'n/a')               = NVL(l_protected, NVL(protected, 'n/a'))
         AND NVL(read_only, 'n/a')               = NVL(l_read_only, NVL(read_only, 'n/a'))
      ;
      -- we should find one or zero entries
      l_test_passed := count_chk(l_has_user, l_errors, l_script);
    ELSE
      -- job name must be set
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_errors            := 'Not allowed: p_username(NULL)';
      otap_log.log(l_errors, l_script, 'User name is NULL');
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
  END has_user;

END;
/