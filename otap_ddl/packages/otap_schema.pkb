-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_schema
AS
  -- for description see header file
  FUNCTION has_table( p_table_name   IN            VARCHAR2
                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                    , p_schema       IN            VARCHAR2     DEFAULT NULL
                    , p_description  IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  IS
    l_script            VARCHAR2(1024) := 'otap_schema.has_table';
    l_default_message   VARCHAR2(256)  := 'Test table exists: ';
    l_has_table         INTEGER;
    l_test_passed       INTEGER;
    l_schema_to_use     VARCHAR2(130);
    l_table_name        VARCHAR2(130);
    l_test_result       VARCHAR2(256);
    l_test_description  VARCHAR2(256);
    l_errors            VARCHAR2(4000);
    l_statement         VARCHAR2(32767);
    l_start             TIMESTAMP;
    l_end               TIMESTAMP;
    l_tmp_otap_session  OTAP_SESSION;
  BEGIN
    l_start := SYSTIMESTAMP;
    -- verify OTAP_SESSION object
    otap_objects.otap_session_verify(o_otap_session);
    l_errors     := NULL;
    l_table_name := TRIM(p_table_name);
    IF     l_table_name        IS NOT NULL
       AND LENGTH(l_table_name) > 0
    THEN
      -- check description
      l_schema_to_use := TRIM(NVL(p_schema, o_otap_session.db_schema));
      l_test_description := NVL(p_description, l_default_message || l_schema_to_use || '.' || l_table_name);
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
        l_statement := q'[SELECT COUNT(*)
 INTO l_has_table
 FROM dba_tables
WHERE table_name = '"' || l_table_name || '"'
  AND owner      = '"' || l_schema_to_use || '"']'
        ;
        l_errors := 'Check table ' || l_table_name || ' with schema ' || l_schema_to_use || ' results in count ' || l_has_table;
        otap_util.log(l_errors, l_script, l_statement);
      END IF;
    ELSE
      -- invalid table name
      l_test_passed       := otap_constants.OTAP_NUM_TEST_UNDEFINED;
      l_statement         := 'l_table_name IS NOT NULL AND LENGTH(l_table_name) > 0';
      l_errors            := 'Missing table name';
      l_test_description  := l_default_message || 'ERROR name missing';
      l_schema_to_use     := NVL(p_schema, o_otap_session.db_schema);
      otap_util.log(l_errors, l_script, l_statement);
    END IF;
    -- due to a possible schema override prepare a temporary object with the schema used
    l_tmp_otap_session            := otap_objects.otap_session_copy(o_otap_session);
    l_tmp_otap_session.db_schema  := l_schema_to_use;
    l_end                         := SYSTIMESTAMP;
    otap_plan.write_test_result(l_test_description, l_tmp_otap_session, l_test_passed, l_start, l_end, l_errors);
    -- now update the session record with new test done
    otap_objects.otap_session_add_test(l_test_passed, o_otap_session);
    l_test_result := otap_util.format_test_result(l_test_passed, l_test_description);
    RETURN l_test_result;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        -- log unhandled exceptions
        otap_util.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
      END IF;
      RAISE;
  END has_table;

END;
/