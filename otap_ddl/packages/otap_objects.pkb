-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_objects
AS
  -- for description see header file
  PROCEDURE otap_session_verify(p_otap_session IN OTAP_SESSION)
  IS
    l_script    VARCHAR2(1024) := 'otap_objects.otap_session_verify';
    l_statement VARCHAR2(32767);
    l_message   VARCHAR2(4000);
    l_delimiter VARCHAR2(1);
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
       OR p_otap_session.session_start               IS NULL
       OR p_otap_session.session_id                  IS NULL
       OR p_otap_session.error_count                 IS NULL
       OR p_otap_session.session_view_id             IS NULL
    THEN
      l_delimiter := '';
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
OR p_otap_session.include_packages            IS NULL
OR p_otap_session.session_start               IS NULL
OR p_otap_session.session_id                  IS NULL
OR p_otap_session.error_count                 IS NULL
OR p_otap_session.session_view_id             IS NULL]'
      ;
      -- if we fail, find out the columns that are NULL
      l_message := 'ERROR otap_objects.otap_session_verify. Invalid OTAP_SESSION object. NULL errors: ';
      IF p_otap_session IS NULL
      THEN
        l_message := l_message || 'Complete OTAP_SESSION object';
      ELSE
        -- check the fields
        IF p_otap_session.test_executor IS NULL OR LENGTH(TRIM(p_otap_session.test_executor)) = 0
        THEN
          l_message := l_message || l_delimiter || 'test_executor';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.test_set IS NULL OR LENGTH(TRIM(p_otap_session.test_set)) = 0
        THEN
          l_message := l_message || l_delimiter || 'test_set';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.test_group IS NULL OR LENGTH(TRIM(p_otap_session.test_group)) = 0
        THEN
          l_message := l_message || l_delimiter || 'test_group';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.test_name IS NULL OR LENGTH(TRIM(p_otap_session.test_name)) = 0
        THEN
          l_message := l_message || l_delimiter || 'test_name';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.db_user IS NULL OR LENGTH(TRIM(p_otap_session.db_user)) = 0
        THEN
          l_message := l_message || l_delimiter || 'db_user';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.db_schema IS NULL OR LENGTH(TRIM(p_otap_session.db_schema)) = 0
        THEN
          l_message := l_message || l_delimiter || 'db_schema';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.test_prefix IS NULL OR LENGTH(TRIM(p_otap_session.test_prefix)) = 0
        THEN
          l_message := l_message || l_delimiter || 'test_prefix';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.test_count IS NULL
        THEN
          l_message := l_message || l_delimiter || 'test_count';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.intended_count IS NULL
        THEN
          l_message := l_message || l_delimiter || 'intended_count';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.persist_test IS NULL
        THEN
          l_message := l_message || l_delimiter || 'persist_test';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.name_precedence IS NULL
        THEN
          l_message := l_message || l_delimiter || 'name_precedence';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.include_packages IS NULL
        THEN
          l_message := l_message || l_delimiter || 'include_packages';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.session_start IS NULL
        THEN
          l_message := l_message || l_delimiter || 'session_start';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.session_id IS NULL
        THEN
          l_message := l_message || l_delimiter || 'session_id';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.error_count IS NULL
        THEN
          l_message := l_message || l_delimiter || 'error_count';
          l_delimiter := ',';
        END IF;
        IF p_otap_session.session_view_id IS NULL
        THEN
          l_message := l_message || l_delimiter || 'session_view_id';
          l_delimiter := ',';
        END IF;
      END IF;
      otap_util.log('EXCEPTION -20099 ' || l_message, 'otap_objects.otap_session_verify', l_statement);
      RAISE_APPLICATION_ERROR(-20099, l_message);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_verify;

  FUNCTION otap_session_show(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_show';
    l_message VARCHAR2(4000);
  BEGIN
    -- verify the current object
    otap_objects.otap_session_verify(p_otap_session);
    -- build the message
    l_message := 'Current test settings' || otap_constants.OTAP_LF ||
                 'Test session id: ' || p_otap_session.session_id || otap_constants.OTAP_LF ||
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
                 'Persist: ' || CASE WHEN p_otap_session.persist_test THEN otap_constants.OTAP_CHAR_TRUE_YES ELSE otap_constants.OTAP_CHAR_FALSE_NO END || otap_constants.OTAP_LF ||
                 'Current view id: ' || CASE WHEN p_otap_session.session_view_id = 0 THEN 'Not set' ELSE p_otap_session.session_view_id END || otap_constants.OTAP_LF ||
                 'Test start: ' || TO_CHAR(p_otap_session.session_start, 'YYYY-MM-DD HH24:MI:SS')
    ;
    RETURN SUBSTR(l_message, 1, 4000);
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_show;

  FUNCTION otap_session_set( p_test_count          IN            NUMBER
                           , p_test_set            IN            VARCHAR2
                           , p_test_group          IN            VARCHAR2
                           , p_test_name           IN            VARCHAR2
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
    l_script    VARCHAR2(1024) := 'otap_objects.otap_session_set';
    l_message   VARCHAR2(4000);
    l_delimiter VARCHAR2(1);
  BEGIN
    -- verify the current object
    otap_objects.otap_session_verify(o_otap_session);
    -- now verify the input
    IF    p_schema    IS NULL
       OR p_user      IS NULL
       OR p_executor  IS NULL
    THEN
      l_message := 'ERROR otap_objects.otap_session_set. Invalid OTAP_SESSION initialization. NULL errors: ';
      l_delimiter := '';
      IF p_schema IS NULL
      THEN
        l_message := l_message || l_delimiter || 'p_schema';
        l_delimiter := ',';
      END IF;
      IF p_user IS NULL
      THEN
        l_message := l_message || l_delimiter || 'p_user';
        l_delimiter := ',';
      END IF;
      IF p_executor IS NULL
      THEN
        l_message := l_message || l_delimiter || 'p_executor';
      END IF;
      l_message := l_message || ' The variable default should never be overwritten by users.';
      otap_util.log('EXCEPTION -20099 ' || l_message, l_script, 'p_schema IS NULL OR p_user IS NULL OR p_executor IS NULL');
      RAISE_APPLICATION_ERROR(-20099, l_message);
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
        o_otap_session.test_prefix := otap_constants.OTAP_DEFAULT_PREFIX;
        otap_util.log('ERROR checking otap test prefix ' || p_prefix || ' delimiters _, $, # not allowed', l_script, 'REGEXP_INSTR(p_prefix, ''[_|$|#]'') = 0');
      END IF;
    ELSE
      -- leave prefix as defined, log error
      o_otap_session.test_prefix := otap_constants.OTAP_DEFAULT_PREFIX;
      otap_util.log('ERROR checking otap test prefix ' || p_prefix || ' length, only length 1-4 allowed', l_script, 'LENGTH(p_prefix) <= 4 OR LENGTH(p_prefix) > 0');
    END IF;
    -- check bool values
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
    -- now start setting the new values
    o_otap_session.test_executor   := p_executor;
    o_otap_session.db_user         := p_user;
    o_otap_session.db_schema       := p_schema;
    o_otap_session.intended_count  := NVL(p_test_count, 0);
    -- keep old values if not specified
    o_otap_session.test_set        := NVL(p_test_set, o_otap_session.test_set);
    o_otap_session.test_group      := NVL(p_test_group, o_otap_session.test_group);
    o_otap_session.test_name       := NVL(p_test_name, o_otap_session.test_name);
    -- reset other session values
    o_otap_session.test_count      := 0;
    o_otap_session.error_count     := 0;
    o_otap_session.session_start   := SYSDATE;
    o_otap_session.session_id      := otap_test_session_seq.NEXTVAL;
    -- set view id equal to session id
    o_otap_session.session_view_id := o_otap_session.session_id;
    l_message := otap_objects.otap_session_show(o_otap_session);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_set;

  FUNCTION otap_session_copy(p_otap_session IN OTAP_SESSION)
    RETURN OTAP_SESSION
  IS
    l_script        VARCHAR2(1024) := 'otap_objects.otap_session_copy';
    l_otap_session  OTAP_SESSION;
  BEGIN
    -- verify the current object
    otap_objects.otap_session_verify(p_otap_session);
    l_otap_session := otap_session( p_otap_session.test_executor
                                  , p_otap_session.test_set
                                  , p_otap_session.test_group
                                  , p_otap_session.test_name
                                  , p_otap_session.db_user
                                  , p_otap_session.db_schema
                                  , p_otap_session.test_prefix
                                  , p_otap_session.test_count
                                  , p_otap_session.intended_count
                                  , p_otap_session.persist_test
                                  , p_otap_session.name_precedence
                                  , p_otap_session.include_packages
                                  , p_otap_session.session_start
                                  , p_otap_session.session_id
                                  , p_otap_session.error_count
                                  , p_otap_session.session_view_id
                                  )
    ;
    RETURN l_otap_session;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_copy;

  FUNCTION otap_session_set_test_set( p_test_set     IN            VARCHAR2
                                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                    )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_set_test_set';
    l_message VARCHAR2(4000);
  BEGIN
    otap_objects.otap_session_verify(o_otap_session);
    IF LENGTH(p_test_set) > 256
    THEN
      o_otap_session.test_set := SUBSTR(p_test_set, 1, 256);
      otap_util.log('ERROR test set name length exceed 256 chars. Test set ' || p_test_set || ' cutted to 256 chars.', l_script, 'LENGTH(p_test_set) > 256');
    ELSE
      o_otap_session.test_set := NVL(p_test_set, otap_constants.OTAP_DEFAULT_TEST_SET);
    END IF;
    l_message := 'Current test set: ' || o_otap_session.test_set;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_set_test_set;

  FUNCTION otap_session_set_test_group( p_test_group   IN            VARCHAR2
                                      , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                      )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_set_test_group';
    l_message VARCHAR2(4000);
  BEGIN
    otap_objects.otap_session_verify(o_otap_session);
    IF LENGTH(p_test_group) > 256
    THEN
      o_otap_session.test_group := SUBSTR(p_test_group, 1, 256);
      otap_util.log('ERROR test group name length exceed 256 chars. Test group ' || p_test_group || ' cutted to 256 chars.', l_script, 'LENGTH(p_test_group) > 256');
    ELSE
      o_otap_session.test_group := NVL(p_test_group, otap_constants.OTAP_DEFAULT_TEST_GROUP);
    END IF;
    l_message := 'Current test group: ' || o_otap_session.test_group;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_set_test_group;

  FUNCTION otap_session_set_test_name( p_test_name    IN            VARCHAR2
                                     , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                     )
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_set_test_name';
    l_message VARCHAR2(4000);
  BEGIN
    otap_objects.otap_session_verify(o_otap_session);
    IF LENGTH(p_test_name) > 256
    THEN
      o_otap_session.test_name := SUBSTR(p_test_name, 1, 256);
      otap_util.log('ERROR test name length exceed 256 chars. Test name ' || p_test_name || ' cutted to 256 chars.', l_script, 'LENGTH(p_test_name) > 256');
    ELSE
      o_otap_session.test_name := NVL(p_test_name, otap_constants.OTAP_DEFAULT_TEST_NAME);
    END IF;
    l_message := 'Current test: ' || o_otap_session.test_name;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_set_test_name;

  FUNCTION otap_session_get_test_id(p_otap_session IN OTAP_SESSION)
    RETURN NUMBER
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_get_test_id';
  BEGIN
    otap_objects.otap_session_verify(p_otap_session);
    RETURN p_otap_session.session_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_get_test_id;

  PROCEDURE otap_session_add_test( p_test_passed  IN NUMBER
                                 , o_otap_session IN OUT NOCOPY OTAP_SESSION
                                 )
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_add_test';
  BEGIN
    otap_objects.otap_session_verify(o_otap_session);
    o_otap_session.test_count := o_otap_session.test_count + 1;
    IF p_test_passed != otap_constants.OTAP_NUM_TEST_PASSED
    THEN
      o_otap_session.error_count := o_otap_session.error_count + 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_add_test;

  FUNCTION otap_session_summary(p_otap_session IN OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_summary';
    l_message VARCHAR2(4000);
  BEGIN
    otap_objects.otap_session_verify(p_otap_session);
    l_message := 'Summary id: ' || TRIM(TO_CHAR(p_otap_session.session_id)) ||
                 ' tests: ' || TRIM(TO_CHAR(p_otap_session.test_count)) ||
                 CASE WHEN p_otap_session.intended_count > 0 THEN ' from ' || TRIM(TO_CHAR(p_otap_session.intended_count)) END ||
                 ' errors: ' || TRIM(TO_CHAR(p_otap_session.error_count)) ||
                 ' run time: ' || TRIM(TO_CHAR(((SYSDATE - p_otap_session.session_start) DAY TO SECOND))) ||
                 ' started: ' || TO_CHAR(p_otap_session.session_start, 'YYYY-MM-DD HH24:MI:SS')
    ;
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_summary;

  FUNCTION otap_session_finish(o_otap_session IN OUT NOCOPY OTAP_SESSION)
    RETURN VARCHAR2
  IS
    l_script  VARCHAR2(1024) := 'otap_objects.otap_session_finish';
    l_message VARCHAR2(4000);
  BEGIN
    -- object gets verified by summary for old session
    l_message := otap_objects.otap_session_summary(o_otap_session) || otap_constants.OTAP_LF;
    -- reset values
    o_otap_session.test_count     := 0;
    o_otap_session.error_count    := 0;
    o_otap_session.intended_count := 0;
    o_otap_session.test_set       := otap_constants.OTAP_DEFAULT_TEST_SET;
    o_otap_session.test_group     := otap_constants.OTAP_DEFAULT_TEST_GROUP;
    o_otap_session.test_name      := otap_constants.OTAP_DEFAULT_TEST_NAME;
    o_otap_session.session_start  := SYSDATE;
    o_otap_session.session_id     := otap_test_session_seq.NEXTVAL;
    -- do not update the session_view_id so it will keep the old or any set value
    -- every init will set the session_view_id to the current session id
    l_message := l_message || otap_objects.otap_session_show(o_otap_session);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END otap_session_finish;

END;
/
