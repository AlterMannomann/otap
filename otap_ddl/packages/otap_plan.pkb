-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_plan
AS
  -- for description see header file
  PROCEDURE write_test_result( p_test_description IN VARCHAR2
                             , p_otap_session     IN OTAP_SESSION
                             , p_test_passed      IN NUMBER
                             , p_test_errors      IN VARCHAR2     DEFAULT NULL
                             )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_script            VARCHAR2(1024) := 'otap_plan.write_test_result';
    l_test_passed       INTEGER;
    l_test_description  VARCHAR2(256);
    l_errors            VARCHAR2(4000);
    l_to_delete         INTEGER;
  BEGIN
    IF LENGTH(TRIM(l_errors)) > 4000
    THEN
      l_errors := SUBSTR(TRIM(p_test_errors), 1, 4000);
    ELSE
      l_errors := TRIM(p_test_errors);
    END IF;
    IF p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)
    THEN
      l_test_passed := p_test_passed;
    ELSE
      l_test_passed := otap_constants.OTAP_NUM_TEST_FAILED;
      l_errors      := SUBSTR('Invalid test passed value: ' || p_test_passed || otap_constants.OTAP_LF || l_errors, 1, 4000);
      otap_util.log('ERROR The given value for test passed ' || p_test_passed || ' for test description ' || p_test_description || ' is not valid.', l_script, 'p_test_passed IN (otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_UNDEFINED)');
    END IF;
    IF p_test_description IS NULL
    THEN
      l_test_description := 'Unspecified test ' || TIMESTAMP_TO_SCN(SYSTIMESTAMP);
      l_errors           := SUBSTR('Missing test description' || otap_constants.OTAP_LF || l_errors, 1, 4000);
    ELSE
      IF LENGTH(p_test_description) > 256
      THEN
        l_test_description := SUBSTR(TRIM(p_test_description), 1, 256);
        l_errors           := SUBSTR('Test description too long, cutted' || otap_constants.OTAP_LF || l_errors, 1, 4000);
      ELSE
        l_test_description := TRIM(p_test_description);
      END IF;
    END IF;
    -- set delete flag as stored
    l_to_delete := CASE WHEN p_otap_session.persist_test THEN otap_constants.OTAP_NUM_FALSE ELSE otap_constants.OTAP_NUM_TRUE END;
    -- ready to insert
    INSERT INTO otap_results
      ( to_delete
      , test_passed
      , test_executor
      , test_set
      , test_group
      , test_name
      , test_desc
      , db_user
      , db_schema
      , test_errors
      ) VALUES ( l_to_delete
               , l_test_passed
               , p_otap_session.test_executor
               , p_otap_session.test_set
               , p_otap_session.test_group
               , p_otap_session.test_name
               , l_test_description
               , p_otap_session.db_user
               , p_otap_session.db_schema
               , l_errors
               )
    ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, l_script, 'otap_plan.write_test_result call');
      RAISE;
  END write_test_result;

  PROCEDURE write_count_result(p_otap_session IN OTAP_SESSION)
  IS
    l_script            VARCHAR2(1024) := 'otap_plan.write_count_result';
    l_test_passed       INTEGER;
    l_test_description  VARCHAR2(256);
    l_errors            VARCHAR2(4000);
  BEGIN
    -- only write a record, if intended count is set, do nothing otherwise
    IF p_otap_session.intended_count > 0
    THEN
      l_test_passed      := CASE WHEN p_otap_session.test_count = p_otap_session.intended_count THEN otap_constants.OTAP_NUM_TEST_PASSED ELSE otap_constants.OTAP_NUM_TEST_FAILED END;
      l_test_description := 'Expected test count result';
      l_errors           := NULL;
      write_test_result(l_test_description, p_otap_session, l_test_passed, l_errors);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, l_script, 'otap_plan.write_count_result call');
      RAISE;
  END write_count_result;

  FUNCTION current_test_setting(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    l_message := 'Current test settings' || otap_constants.OTAP_LF ||
                 'Test set: ' || p_otap_session.test_set || otap_constants.OTAP_LF ||
                 'Test group: ' || p_otap_session.test_group || otap_constants.OTAP_LF ||
                 'Test name: ' || p_otap_session.test_name || otap_constants.OTAP_LF ||
                 'Executor: ' || p_otap_session.test_executor || otap_constants.OTAP_LF ||
                 'DB user: ' || p_otap_session.db_user || otap_constants.OTAP_LF ||
                 'DB schema: ' || p_otap_session.db_schema || otap_constants.OTAP_LF ||
                 'Test identifier prefix: ' || p_otap_session.test_prefix || otap_constants.OTAP_LF ||
                 'Current tests:' || p_otap_session.test_count || otap_constants.OTAP_LF ||
                 'Expected tests: ' || CASE WHEN p_otap_session.intended_count > 0 THEN TO_CHAR(p_otap_session.intended_count) ELSE 'Not set' END || otap_constants.OTAP_LF ||
                 'Name precedence: ' || CASE WHEN p_otap_session.name_precedence THEN otap_constants.OTAP_CHAR_TRUE_YES ELSE otap_constants.OTAP_CHAR_FALSE_NO END || otap_constants.OTAP_LF ||
                 'Include packages: ' || CASE WHEN p_otap_session.include_packages THEN otap_constants.OTAP_CHAR_TRUE_YES ELSE otap_constants.OTAP_CHAR_FALSE_NO END || otap_constants.OTAP_LF ||
                 'Persist: ' || CASE WHEN p_otap_session.persist_test THEN otap_constants.OTAP_CHAR_TRUE_YES ELSE otap_constants.OTAP_CHAR_FALSE_NO END
    ;
    RETURN SUBSTR(l_message, 1, 4000);
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_plan.current_test_setting', 'otap_plan.current_test_setting call');
      RAISE;
  END current_test_setting;

  PROCEDURE verify_otap_session(p_otap_session IN OTAP_SESSION)
  IS
    l_statement VARCHAR2(32767);
  BEGIN
    -- we expect all fields to be NOT NULL including empty strings
    IF    p_otap_session                             IS NULL
       OR p_otap_session.test_executor               IS NULL
       OR LENGTH(TRIM(p_otap_session.test_executor))  = 0
       OR p_otap_session.test_set                    IS NULL
       OR LENGTH(TRIM(p_otap_session.test_set))       = 0
       OR p_otap_session.test_group                  IS NULL
       OR LENGTH(TRIM(p_otap_session.test_group))     = 0
       OR p_otap_session.test_name                   IS NULL
       OR LENGTH(TRIM(p_otap_session.test_name))      = 0
       OR p_otap_session.db_user                     IS NULL
       OR LENGTH(TRIM(p_otap_session.db_user))        = 0
       OR p_otap_session.db_schema                   IS NULL
       OR LENGTH(TRIM(p_otap_session.db_schema))      = 0
       OR p_otap_session.test_prefix                 IS NULL
       OR LENGTH(TRIM(p_otap_session.test_prefix))    = 0
       OR p_otap_session.test_count                  IS NULL
       OR p_otap_session.intended_count              IS NULL
       OR p_otap_session.persist_test                IS NULL
       OR p_otap_session.name_precedence             IS NULL
       OR p_otap_session.include_packages            IS NULL
    THEN
      l_statement := q'[p_otap_session                             IS NULL
OR p_otap_session.test_executor               IS NULL
OR LENGTH(TRIM(p_otap_session.test_executor))  = 0
OR p_otap_session.test_set                    IS NULL
OR LENGTH(TRIM(p_otap_session.test_set))       = 0
OR p_otap_session.test_group                  IS NULL
OR LENGTH(TRIM(p_otap_session.test_group))     = 0
OR p_otap_session.test_name                   IS NULL
OR LENGTH(TRIM(p_otap_session.test_name))      = 0
OR p_otap_session.db_user                     IS NULL
OR LENGTH(TRIM(p_otap_session.db_user))        = 0
OR p_otap_session.db_schema                   IS NULL
OR LENGTH(TRIM(p_otap_session.db_schema))      = 0
OR p_otap_session.test_prefix                 IS NULL
OR LENGTH(TRIM(p_otap_session.test_prefix))    = 0
OR p_otap_session.test_count                  IS NULL
OR p_otap_session.intended_count              IS NULL
OR p_otap_session.persist_test                IS NULL
OR p_otap_session.name_precedence             IS NULL
OR p_otap_session.include_packages            IS NULL]'
      ;
      otap_util.log('EXCEPTION -20099 invalid OTAP_SESSION object. Internal error. OTAP_TEST session_record must be complete, NULL not allowed. Not possible to continue. Test results will not reliable.', 'otap_plan.verify_otap_session', l_statement);
      RAISE_APPLICATION_ERROR(-20099, 'ERROR otap_plan.verify_otap_session. Internal error. OTAP_TEST session_record must be complete, NULL not allowed. Not possible to continue. Test results are not reliable.');
    END IF;
  END verify_otap_session;

  FUNCTION init_test( p_test_count          IN            NUMBER
                    , p_test_set            IN            VARCHAR2
                    , p_test_group          IN            VARCHAR2
                    , p_prefix              IN            VARCHAR2
                    , p_name_precedence     IN            NUMBER
                    , p_include_pkg         IN            NUMBER
                    , p_persist             IN            NUMBER
                    , p_schema              IN            VARCHAR2
                    , p_user                IN            VARCHAR2
                    , p_executor            IN            VARCHAR2
                    , o_otap_session        IN OUT NOCOPY OTAP_SESSION
                    )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_plan.init_test';
    l_message VARCHAR2(4000);
  BEGIN
    IF    p_schema    IS NULL
       OR p_user      IS NULL
       OR p_executor  IS NULL
    THEN
      otap_util.log('EXCEPTION -20099 invalid otap_test initialization. Internal error. Neither schema, user or executor can be NULL nor should they be set by the user', l_script, 'p_schema IS NULL OR p_user IS NULL OR p_executor IS NULL');
      RAISE_APPLICATION_ERROR(-20099, 'ERROR otap_plan.init_test. Internal error. Invalid otap_test initialization. Neither schema, user or executor can be NULL nor should they be set by the user');
    END IF;
    -- if test count is not 0 this is a reset, write a test count record, if intended count is set
    IF     o_otap_session.test_count      > 0
       AND (   o_otap_session.intended_count  > 0
            OR NVL(p_test_count, 0)           > 0
           )
    THEN
      -- write record with current values
      write_count_result(o_otap_session);
      -- reset test count
      o_otap_session.test_count     := 0;
    END IF;
    -- now start setting the new values
    o_otap_session.test_executor  := p_executor;
    o_otap_session.db_user        := p_user;
    o_otap_session.db_schema      := p_schema;
    IF NVL(p_test_count, 0) > 0
    THEN
      o_otap_session.intended_count := p_test_count;
    END IF;
    -- check prefix length
    IF    LENGTH(p_prefix) <= 4
       OR LENGTH(p_prefix) > 0
    THEN
      -- no delimiter allowed
      IF REGEXP_INSTR(p_prefix, '[_|$|#]') = 0
      THEN
        o_otap_session.test_prefix := UPPER(TRIM(p_prefix));
      ELSE
        otap_util.log('ERROR checking otap test prefix ' || p_prefix || ' delimiters _, $, # not allowed', l_script, 'REGEXP_INSTR(p_prefix, ''[_|$|#]'') = 0');
      END IF;
    ELSE
      -- leave prefix as defined, log error
      otap_util.log('ERROR checking otap test prefix ' || p_prefix || ' length, only length 1-4 allowed', l_script, 'LENGTH(p_prefix) <= 4 OR LENGTH(p_prefix) > 0');
    END IF;
    o_otap_session.test_set   := NVL(p_test_set, otap_constants.OTAP_DEFAULT_TEST_SET);
    o_otap_session.test_group := NVL(p_test_group, otap_constants.OTAP_DEFAULT_TEST_GROUP);
    IF NVL(p_name_precedence, otap_constants.OTAP_NUM_TRUE) IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
    THEN
      o_otap_session.name_precedence := (NVL(p_name_precedence, otap_constants.OTAP_NUM_TRUE) = otap_constants.OTAP_NUM_TRUE);
    END IF;
    IF NVL(p_include_pkg, otap_constants.OTAP_NUM_FALSE) IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
    THEN
      o_otap_session.include_packages := (NVL(p_include_pkg, otap_constants.OTAP_NUM_FALSE) = otap_constants.OTAP_NUM_TRUE);
    END IF;
    IF NVL(p_persist, otap_constants.OTAP_NUM_FALSE) IN (otap_constants.OTAP_NUM_TRUE, otap_constants.OTAP_NUM_FALSE)
    THEN
      o_otap_session.persist_test := (NVL(p_persist, otap_constants.OTAP_NUM_FALSE) = otap_constants.OTAP_NUM_TRUE);
    END IF;
    l_message := otap_plan.current_test_setting(o_otap_session);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, l_script, 'otap_plan.init_test call');
      END IF;
      RAISE;
  END init_test;

  FUNCTION set_test_name( p_test_name     IN            VARCHAR2
                        , o_otap_session  IN OUT NOCOPY OTAP_SESSION
                        )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    IF LENGTH(p_test_name) > 256
    THEN
      o_otap_session.test_name := SUBSTR(p_test_name, 1, 256);
      otap_util.log('ERROR test name length exceed 256 chars. Test name ' || p_test_name || ' cutted to 256 chars.', 'otap_plan.set_test_name', 'LENGTH(p_test_name) > 256');
    ELSE
      o_otap_session.test_name := NVL(p_test_name, otap_constants.OTAP_DEFAULT_TEST_NAME);
    END IF;
    l_message := 'Current test name: ' || o_otap_session.test_name;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_plan.set_test_name', 'otap_plan.set_test_name call');
      RAISE;
  END set_test_name;

  FUNCTION set_test_group( p_test_group    IN            VARCHAR2
                         , o_otap_session  IN OUT NOCOPY OTAP_SESSION
                         )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    IF LENGTH(p_test_group) > 256
    THEN
      o_otap_session.test_group := SUBSTR(p_test_group, 1, 256);
      otap_util.log('ERROR test group name length exceed 256 chars. Test group ' || p_test_group || ' cutted to 256 chars.', 'otap_plan.set_test_group', 'LENGTH(p_test_group) > 256');
    ELSE
      o_otap_session.test_group := NVL(p_test_group, otap_constants.OTAP_DEFAULT_TEST_GROUP);
    END IF;
    l_message := 'Current test group: ' || o_otap_session.test_group;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_plan.set_test_group', 'otap_plan.set_test_group call');
      RAISE;
  END set_test_group;

  FUNCTION set_test_set( p_test_set     IN            VARCHAR2
                       , o_otap_session IN OUT NOCOPY OTAP_SESSION
                       )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    IF LENGTH(p_test_set) > 256
    THEN
      o_otap_session.test_set := SUBSTR(p_test_set, 1, 256);
      otap_util.log('ERROR test set name length exceed 256 chars. Test set ' || p_test_set || ' cutted to 256 chars.', 'otap_plan.set_test_set', 'LENGTH(p_test_set) > 256');
    ELSE
      o_otap_session.test_set := NVL(p_test_set, otap_constants.OTAP_DEFAULT_TEST_SET);
    END IF;
    l_message := 'Current test set: ' || o_otap_session.test_set;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log(SQLERRM, 'otap_plan.set_test_set', 'SET test set for otap_test');
      RAISE;
  END set_test_set;

  PROCEDURE add_test(o_otap_session IN OUT NOCOPY OTAP_SESSION)
  IS
  BEGIN
    o_otap_session.test_count := o_otap_session.test_count + 1;
  EXCEPTION
    WHEN OTHERS THEN
      otap_util.log('EXCEPTION -20099 invalid OTAP_SESSION object. Internal error:' || SQLERRM, 'otap_plan.add_test', 'o_otap_session.test_count := o_otap_session.test_count + 1');
      RAISE_APPLICATION_ERROR(-20099, 'ERROR otap_plan.add_test. Internal error: ' || SQLERRM);
  END add_test;

  FUNCTION format_test_result( p_test_passed IN INTEGER
                             , p_description IN VARCHAR2
                             )
    RETURN VARCHAR2
  IS
    l_test_result VARCHAR2(256);
    l_statement   VARCHAR2(32767);
  BEGIN
    -- result column
    l_test_result := RPAD(otap_constants.translate_test_result(p_test_passed), 10, ' ');
    -- we still have 246 chars
    l_test_result := l_test_result || TRIM(SUBSTR(p_description, 1, 246));
    RETURN l_test_result;
  EXCEPTION
    WHEN OTHERS THEN
      l_statement := q'[l_test_result := RPAD(otap_constants.translate_test_result(p_test_passed), 10, ' ');
l_test_result := l_test_result || TRIM(SUBSTR(p_description, 1, 246));]'
      ;
      otap_util.log('Unexpected exception. Internal error:' || SQLERRM, 'otap_plan.format_test_result', l_statement);
      RAISE;
  END format_test_result;

END;
/