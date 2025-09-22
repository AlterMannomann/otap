-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- independent code block, able to deal with different setup settings

-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return        VARCHAR2(4000 CHAR);
  l_stamp         TIMESTAMP;
  l_finish        TIMESTAMP;
  l_otap_session  OTAP_SESSION;
  l_alt_session   OTAP_SESSION;
  l_want          VARCHAR2(4000 CHAR);
  l_have          VARCHAR2(4000 CHAR);
BEGIN
  -- use init defaults for fake session
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 0
                                , 0
                                )
  ;
  l_return := otap_test.throws_ok( 'otap_objects.otap_session_verify(NULL);'
                                 , -20099
                                 , NULL
                                 , 'otap_objects.otap_session_verify parameter NULL exception'
                                 )
  ;
  -- must be handled in plsql blocks to verify possible exceptions, putting them in code blocks for throws_ok
  -- makes code almost unreadable and unmanageable.
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify default session record');
  EXCEPTION
    WHEN OTHERS THEN
      l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify default session record unexpected exception');
  END;
  l_otap_session.test_executor := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify executor NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor NULL unexpected exception');
      END IF;
  END;
  l_otap_session.test_executor := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify executor empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor empty string unexpected exception');
      END IF;
  END;
  -- check oversize, THIS WILL GET A PROBLEM IF A USERNAME IS LONGER THAN 128 CHARS
  BEGIN
    l_otap_session.test_executor := RPAD('A', 128, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify executor too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify executor too long unexpected exception');
      END IF;
  END;
  -- reset test executor
  l_otap_session.test_executor := SYS_CONTEXT('USERENV', 'SESSION_USER');
  -- check test set
  -- check test set
  l_otap_session.test_set := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_set NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set NULL unexpected exception');
      END IF;
  END;
  l_otap_session.test_set := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_set empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.test_set := RPAD('A', 256, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_set too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_set too long unexpected exception');
      END IF;
  END;
  -- reset test set
  l_otap_session.test_set := otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET;
  -- check test group
  l_otap_session.test_group := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_group NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group NULL unexpected exception');
      END IF;
  END;
  l_otap_session.test_group := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_group empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.test_group := RPAD('A', 256, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_group too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_group too long unexpected exception');
      END IF;
  END;
  -- reset test_group
  l_otap_session.test_group := otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP;
  -- check test_name
  l_otap_session.test_name := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_name NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name NULL unexpected exception');
      END IF;
  END;
  l_otap_session.test_name := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_name empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.test_name := RPAD('A', 256, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_name too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_name too long unexpected exception');
      END IF;
  END;
  -- reset test_name
  l_otap_session.test_name := otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME;
  -- check db_user
  l_otap_session.db_user := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_user NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user NULL unexpected exception');
      END IF;
  END;
  l_otap_session.db_user := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_user empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.db_user := RPAD('A', 128, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_user too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_user too long unexpected exception');
      END IF;
  END;
  -- reset db_user
  l_otap_session.db_user := SYS_CONTEXT('USERENV', 'CURRENT_USER');
  -- check db_schema
  l_otap_session.db_schema := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_schema NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema NULL unexpected exception');
      END IF;
  END;
  l_otap_session.db_schema := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_schema empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.db_schema := RPAD('A', 128, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify db_schema too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify db_schema too long unexpected exception');
      END IF;
  END;
  -- reset db_schema
  l_otap_session.db_schema := SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
  -- check test_prefix
  l_otap_session.test_prefix := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_prefix NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix NULL unexpected exception');
      END IF;
  END;
  l_otap_session.test_prefix := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_prefix empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.test_prefix := RPAD('A', 4, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_prefix too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_prefix too long unexpected exception');
      END IF;
  END;
  -- reset test_prefix
  l_otap_session.test_prefix := otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX;
  -- check session_language
  l_otap_session.session_language := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_language NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language NULL unexpected exception');
      END IF;
  END;
  l_otap_session.session_language := ' ';
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language empty string');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_language empty string');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language empty string unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.session_language := RPAD('A', 3, 'a') || 'oversize';
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language too long');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_language too long');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_language too long unexpected exception');
      END IF;
  END;
  -- reset session_language
  l_otap_session.session_language := otap_constants.OTAP_INTERNAL_NA;
  -- check test_count
  l_otap_session.test_count := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_count NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_count NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_count NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.test_count := 9999999999999999999999999999999999999999;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_count numeric overflow');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify test_count numeric overflow');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify test_count numeric overflow unexpected exception');
      END IF;
  END;
  -- reset test_count
  l_otap_session.test_count := 0;
  -- check intended_count
  l_otap_session.intended_count := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify intended_count NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify intended_count NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify intended_count NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.intended_count := 9999999999999999999999999999999999999999;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify intended_count numeric overflow');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify intended_count numeric overflow');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify intended_count numeric overflow unexpected exception');
      END IF;
  END;
  -- reset intended_count
  l_otap_session.intended_count := 0;
  -- check session_id
  l_otap_session.session_id := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_id NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_id NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_id NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.session_id := 9999999999999999999999999999999999999999;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_id numeric overflow');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_id numeric overflow');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_id numeric overflow unexpected exception');
      END IF;
  END;
  -- reset session_id
  l_otap_session.session_id := 0;
  -- check error_count
  l_otap_session.error_count := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify error_count NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify error_count NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify error_count NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.error_count := 9999999999999999999999999999999999999999;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify error_count numeric overflow');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify error_count numeric overflow');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify error_count numeric overflow unexpected exception');
      END IF;
  END;
  -- reset error_count
  l_otap_session.error_count := 0;
  -- check session_view_id
  l_otap_session.session_view_id := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_view_id NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_view_id NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_view_id NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_otap_session.session_view_id := 9999999999999999999999999999999999999999;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_view_id numeric overflow');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -6502
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_view_id numeric overflow');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_view_id numeric overflow unexpected exception');
      END IF;
  END;
  -- reset session_view_id
  l_otap_session.session_view_id := 0;
  -- check persist_test
  l_otap_session.persist_test := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify persist_test NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify persist_test NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify persist_test NULL unexpected exception');
      END IF;
  END;
  -- reset persist_test
  l_otap_session.persist_test := FALSE;
  -- check name_precedence
  l_otap_session.name_precedence := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify name_precedence NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify name_precedence NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify name_precedence NULL unexpected exception');
      END IF;
  END;
  -- reset name_precedence
  l_otap_session.name_precedence := TRUE;
  -- check include_packages
  l_otap_session.include_packages := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify include_packages NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify include_packages NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify include_packages NULL unexpected exception');
      END IF;
  END;
  -- reset include_packages
  l_otap_session.include_packages := FALSE;
  -- check session_start
  l_otap_session.session_start := NULL;
  BEGIN
    otap_objects.otap_session_verify(l_otap_session);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_start NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_verify session_start NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_verify session_start NULL unexpected exception');
      END IF;
  END;
  -- reset session_start
  l_otap_session.session_start := SYSDATE;
  -- check otap_session_show
  l_want := 'Current test settings' || otap_constants.OTAP_INTERNAL_LF ||
            'Test session id: ' || l_otap_session.session_id || otap_constants.OTAP_INTERNAL_LF ||
            'Test set: ' || l_otap_session.test_set || otap_constants.OTAP_INTERNAL_LF ||
            'Test group: ' || l_otap_session.test_group || otap_constants.OTAP_INTERNAL_LF ||
            'Test name: ' || l_otap_session.test_name || otap_constants.OTAP_INTERNAL_LF ||
            'Executor: ' || l_otap_session.test_executor || otap_constants.OTAP_INTERNAL_LF ||
            'DB user: ' || l_otap_session.db_user || otap_constants.OTAP_INTERNAL_LF ||
            'DB schema: ' || l_otap_session.db_schema || otap_constants.OTAP_INTERNAL_LF ||
            'Test identifier prefix: ' || l_otap_session.test_prefix || otap_constants.OTAP_INTERNAL_LF ||
            'Session language: ' || l_otap_session.session_language || otap_constants.OTAP_INTERNAL_LF ||
            'Current tests:' || l_otap_session.test_count || otap_constants.OTAP_INTERNAL_LF ||
            'Expected tests: ' || CASE WHEN l_otap_session.intended_count > 0 THEN TO_CHAR(l_otap_session.intended_count) ELSE 'Not set' END || otap_constants.OTAP_INTERNAL_LF ||
            'Name precedence: ' || CASE WHEN l_otap_session.name_precedence THEN otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES ELSE otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO END || otap_constants.OTAP_INTERNAL_LF ||
            'Include packages: ' || CASE WHEN l_otap_session.include_packages THEN otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES ELSE otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO END || otap_constants.OTAP_INTERNAL_LF ||
            'Persist: ' || CASE WHEN l_otap_session.persist_test THEN otap_constants.OTAP_FALLBACK_TEXT_TRUE_YES ELSE otap_constants.OTAP_FALLBACK_TEXT_FALSE_NO END || otap_constants.OTAP_INTERNAL_LF ||
            'Current view id: ' || CASE WHEN l_otap_session.session_view_id = 0 THEN 'Not set' ELSE TO_CHAR(l_otap_session.session_view_id) END || otap_constants.OTAP_INTERNAL_LF ||
            'Test start: ' || TO_CHAR(l_otap_session.session_start, 'YYYY-MM-DD HH24:MI:SS')
  ;
  l_have := otap_objects.otap_session_show(l_otap_session);
  l_return := otap_test.is_eq(l_have, l_want, 'otap_objects.otap_session_show check output');
  -- check otap_session_set
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok( (    l_otap_session.intended_count = 10
                             AND l_otap_session.test_set = 'Bla'
                             AND l_otap_session.test_group = 'Bla'
                             AND l_otap_session.test_name = 'Bla'
                             AND l_otap_session.test_prefix = 'BLA' -- uppercase conversion
                             AND l_otap_session.session_language = 'BLA' -- uppercase conversion
                             AND NOT l_otap_session.name_precedence
                             AND l_otap_session.include_packages
                             AND l_otap_session.persist_test
                             AND l_otap_session.db_schema = 'Bla'
                             AND l_otap_session.db_user = 'Bla'
                             AND l_otap_session.test_executor = 'Bla'
                            )
                          , 'otap_objects.otap_session_set check value assignments'
                          )
  ;
  -- prepare test and error count for additional test of reset
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 10
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 5
                                , 0
                                )
  ;
  l_return := otap_objects.otap_session_set( -10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok( (    l_otap_session.intended_count = 0
                             AND l_otap_session.test_set = 'Bla'
                             AND l_otap_session.test_group = 'Bla'
                             AND l_otap_session.test_name = 'Bla'
                             AND l_otap_session.test_prefix = 'BLA' -- uppercase conversion
                             AND l_otap_session.session_language = 'BLA' -- uppercase conversion
                             AND (NOT l_otap_session.name_precedence)
                             AND l_otap_session.include_packages
                             AND l_otap_session.persist_test
                             AND l_otap_session.db_schema = 'Bla'
                             AND l_otap_session.db_user = 'Bla'
                             AND l_otap_session.test_executor = 'Bla'
                            )
                          , 'otap_objects.otap_session_set check negative intended count not possible'
                          )
  ;
  l_return := otap_test.ok((l_otap_session.test_count = 0 AND l_otap_session.error_count = 0), 'otap_objects.otap_session_set check reset test/error count');
  -- reset session record for NULL exceptions
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 0
                                , 0
                                )
  ;
  BEGIN
    l_return := otap_objects.otap_session_set( 10
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 0
                                             , 1
                                             , 1
                                             , NULL
                                             , 'Bla'
                                             , 'Bla'
                                             , l_otap_session
                                             )
    ;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_schema NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_set p_schema NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_schema NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_return := otap_objects.otap_session_set( 10
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 0
                                             , 1
                                             , 1
                                             , 'Bla'
                                             , NULL
                                             , 'Bla'
                                             , l_otap_session
                                             )
    ;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_user NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_set p_user NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_user NULL unexpected exception');
      END IF;
  END;
  BEGIN
    l_return := otap_objects.otap_session_set( 10
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 'Bla'
                                             , 0
                                             , 1
                                             , 1
                                             , 'Bla'
                                             , 'Bla'
                                             , NULL
                                             , l_otap_session
                                             )
    ;
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_executor NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_set p_executor NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_set p_executor NULL unexpected exception');
      END IF;
  END;
  -- check prefix
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Blabla'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_prefix = otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX), 'otap_objects.otap_session_set check prefix too long');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla_'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_prefix = otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX), 'otap_objects.otap_session_set check prefix invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'B$a'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_prefix = otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX), 'otap_objects.otap_session_set check prefix invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , '#Bla'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_prefix = otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX), 'otap_objects.otap_session_set check prefix invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , NULL
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_prefix = otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX), 'otap_objects.otap_session_set check prefix invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 10
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.name_precedence = FALSE), 'otap_objects.otap_session_set check name precedence bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , -10
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.name_precedence = FALSE), 'otap_objects.otap_session_set check name precedence bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , NULL
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.name_precedence = TRUE), 'otap_objects.otap_session_set check name precedence NULL to TRUE');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 10
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.include_packages = TRUE), 'otap_objects.otap_session_set check include packages bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , -10
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.include_packages = TRUE), 'otap_objects.otap_session_set check include packages bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , NULL
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.include_packages = FALSE), 'otap_objects.otap_session_set check include packages NULL to FALSE');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.persist_test = TRUE), 'otap_objects.otap_session_set check persist test bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , -10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.persist_test = TRUE), 'otap_objects.otap_session_set check persist test bool invalid');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , NULL
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.persist_test = FALSE), 'otap_objects.otap_session_set check persist test NULL to FALSE');
  l_return := otap_objects.otap_session_set( 10
                                           , NULL
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_set = 'Bla'), 'otap_objects.otap_session_set check test set NULL ignore');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , NULL
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_group = 'Bla'), 'otap_objects.otap_session_set check test group NULL ignore');
  l_return := otap_objects.otap_session_set( 10
                                           , 'Bla'
                                           , 'Bla'
                                           , NULL
                                           , 'Bla'
                                           , 'Bla'
                                           , 1
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  l_return := otap_test.ok((l_otap_session.test_name = 'Bla'), 'otap_objects.otap_session_set check test name NULL ignore');
  -- reset session object
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 0
                                , 0
                                )
  ;
  -- copy it as is
  l_alt_session := l_otap_session;
  -- wait a second to get difference in start time
  DBMS_SESSION.sleep(1);
  l_return := otap_objects.otap_session_set( 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , 0
                                           , 1
                                           , 1
                                           , 'Bla'
                                           , 'Bla'
                                           , 'Bla'
                                           , l_otap_session
                                           )
  ;
  -- compare session id
  l_return := otap_test.ok((l_otap_session.session_id != l_alt_session.session_id), 'otap_objects.otap_session_set check new session id');
  l_return := otap_test.ok((l_otap_session.session_view_id != l_alt_session.session_view_id), 'otap_objects.otap_session_set check new session view id');
  l_return := otap_test.ok((l_otap_session.session_start != l_alt_session.session_start), 'otap_objects.otap_session_set check new session start');
  -- check otap_session_copy
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 0
                                , 0
                                )
  ;
  l_alt_session := otap_objects.otap_session_copy(l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_executor = l_alt_session.test_executor), 'otap_objects.otap_session_copy check test_executor');
  l_return := otap_test.ok((l_otap_session.test_set = l_alt_session.test_set), 'otap_objects.otap_session_copy check test_set');
  l_return := otap_test.ok((l_otap_session.test_group = l_alt_session.test_group), 'otap_objects.otap_session_copy check test_group');
  l_return := otap_test.ok((l_otap_session.test_name = l_alt_session.test_name), 'otap_objects.otap_session_copy check test_name');
  l_return := otap_test.ok((l_otap_session.db_user = l_alt_session.db_user), 'otap_objects.otap_session_copy check db_user');
  l_return := otap_test.ok((l_otap_session.db_schema = l_alt_session.db_schema), 'otap_objects.otap_session_copy check db_schema');
  l_return := otap_test.ok((l_otap_session.test_prefix = l_alt_session.test_prefix), 'otap_objects.otap_session_copy check test_prefix');
  l_return := otap_test.ok((l_otap_session.session_language = l_alt_session.session_language), 'otap_objects.otap_session_copy check session_language');
  l_return := otap_test.ok((l_otap_session.test_count = l_alt_session.test_count), 'otap_objects.otap_session_copy check test_count');
  l_return := otap_test.ok((l_otap_session.intended_count = l_alt_session.intended_count), 'otap_objects.otap_session_copy check intended_count');
  l_return := otap_test.ok((l_otap_session.persist_test = l_alt_session.persist_test), 'otap_objects.otap_session_copy check persist_test');
  l_return := otap_test.ok((l_otap_session.name_precedence = l_alt_session.name_precedence), 'otap_objects.otap_session_copy check name_precedence');
  l_return := otap_test.ok((l_otap_session.include_packages = l_alt_session.include_packages), 'otap_objects.otap_session_copy check include_packages');
  l_return := otap_test.ok((l_otap_session.session_start = l_alt_session.session_start), 'otap_objects.otap_session_copy check session_start');
  l_return := otap_test.ok((l_otap_session.session_id = l_alt_session.session_id), 'otap_objects.otap_session_copy check session_id');
  l_return := otap_test.ok((l_otap_session.error_count = l_alt_session.error_count), 'otap_objects.otap_session_copy check error_count');
  l_return := otap_test.ok((l_otap_session.session_view_id = l_alt_session.session_view_id), 'otap_objects.otap_session_copy check session_view_id');
  l_alt_session.test_executor := 'Oha';
  l_return := otap_test.ok((l_otap_session.test_executor != l_alt_session.test_executor AND l_alt_session.test_executor = 'Oha'), 'otap_objects.otap_session_copy check copy object independent');
  l_otap_session.test_executor := 'Olala';
  l_return := otap_test.ok((l_otap_session.test_executor != l_alt_session.test_executor AND l_alt_session.test_executor = 'Oha' AND l_otap_session.test_executor = 'Olala'), 'otap_objects.otap_session_copy check source object independent');
  -- check otap_session_set_test_xxx
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 0
                                , 0
                                , 0
                                )
  ;
  l_return := otap_objects.otap_session_set_test_set('Oha', l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_set = 'Oha'), 'otap_objects.otap_session_set_test_set check');
  l_return := otap_objects.otap_session_set_test_set(RPAD('Oha', 300), l_otap_session);
  l_return := otap_test.ok((LENGTH(l_otap_session.test_set) = 256), 'otap_objects.otap_session_set_test_set check length cut');
  l_return := otap_objects.otap_session_set_test_set(NULL, l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_set = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET), 'otap_objects.otap_session_set_test_set check NULL fallback');
  l_return := otap_objects.otap_session_set_test_group('Oha', l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_group = 'Oha'), 'otap_objects.otap_session_set_test_group check ');
  l_return := otap_objects.otap_session_set_test_group(RPAD('Oha', 300), l_otap_session);
  l_return := otap_test.ok((LENGTH(l_otap_session.test_group) = 256), 'otap_objects.otap_session_set_test_group check length cut');
  l_return := otap_objects.otap_session_set_test_group(NULL, l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_group = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP), 'otap_objects.otap_session_set_test_group check NULL fallback');
  l_return := otap_objects.otap_session_set_test_name('Oha', l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_name = 'Oha'), 'otap_objects.otap_session_set_test_name check ');
  l_return := otap_objects.otap_session_set_test_name(RPAD('Oha', 300), l_otap_session);
  l_return := otap_test.ok((LENGTH(l_otap_session.test_name) = 256), 'otap_objects.otap_session_set_test_name check length cut');
  l_return := otap_objects.otap_session_set_test_name(NULL, l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_name = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME), 'otap_objects.otap_session_set_test_name check NULL fallback');
  l_return := otap_objects.otap_session_set_language('eng', l_otap_session);
  l_return := otap_test.ok((l_otap_session.session_language = 'ENG'), 'otap_objects.otap_session_set_language check');
  l_return := otap_objects.otap_session_set_language('deutsch', l_otap_session);
  l_return := otap_test.ok((l_otap_session.session_language = 'DEU'), 'otap_objects.otap_session_set_language check length cut');
  l_return := otap_objects.otap_session_set_language(NULL, l_otap_session);
  l_return := otap_test.ok((l_otap_session.session_language = otap_constants.OTAP_INTERNAL_NA), 'otap_objects.otap_session_set_language check NULL fallback');
  -- get functions
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                                , otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 0
                                , 0
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE
                                , 11
                                , 0
                                , 12
                                )
  ;
  l_return := otap_test.ok((otap_objects.otap_session_get_language(l_otap_session) = otap_constants.OTAP_INTERNAL_NA), 'otap_objects.otap_session_get_language check');
  l_return := otap_test.ok((otap_objects.otap_session_get_test_id(l_otap_session) = 11), 'otap_objects.otap_session_get_test_id check');
  l_return := otap_test.ok((otap_objects.otap_session_get_report_id(l_otap_session) = 12), 'otap_objects.otap_session_get_report_id check');
  l_return := otap_objects.otap_session_set_session_view_id(13, l_otap_session);
  l_return := otap_test.ok((otap_objects.otap_session_get_report_id(l_otap_session) = 13), 'otap_objects.otap_session_set_session_view_id check');
  otap_objects.otap_session_add_test(otap_constants.OTAP_NUM_TEST_PASSED, l_otap_session);
  otap_objects.otap_session_add_test(otap_constants.OTAP_NUM_TEST_FAILED, l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_count = 2 AND l_otap_session.error_count = 1), 'otap_objects.otap_session_add_test check');
  otap_objects.otap_session_add_test(256, l_otap_session);
  l_return := otap_test.ok((l_otap_session.test_count = 3 AND l_otap_session.error_count = 2), 'otap_objects.otap_session_add_test check any value for failed');
  l_want := 'Summary id: ' || TRIM(TO_CHAR(l_otap_session.session_id)) ||
            ' tests: ' || TRIM(TO_CHAR(l_otap_session.test_count)) ||
            CASE WHEN l_otap_session.intended_count > 0 THEN ' from ' || TRIM(TO_CHAR(l_otap_session.intended_count)) END ||
            ' errors: ' || TRIM(TO_CHAR(l_otap_session.error_count)) ||
            ' run time: ' || TRIM(TO_CHAR(((SYSDATE - l_otap_session.session_start) DAY TO SECOND))) ||
            ' started: ' || TO_CHAR(l_otap_session.session_start, 'YYYY-MM-DD HH24:MI:SS')
  ;
  l_return := otap_test.is_eq(otap_objects.otap_session_summary(l_otap_session), l_want, 'otap_objects.otap_session_summary check');
  l_otap_session := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                , 'Set1'
                                , 'Group1'
                                , 'Name1'
                                , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , otap_constants.OTAP_FALLBACK_DEFAULT_PREFIX
                                , otap_constants.OTAP_INTERNAL_NA
                                , 10
                                , 10
                                , FALSE
                                , TRUE
                                , FALSE
                                , SYSDATE-10
                                , 0
                                , 5
                                , 0
                                )
  ;
  l_alt_session := otap_objects.otap_session_copy(l_otap_session);
  l_return := otap_objects.otap_session_finish(l_otap_session);
  l_return := otap_test.ok( (    l_otap_session.test_count = 0
                             AND l_otap_session.error_count = 0
                             AND l_otap_session.intended_count = 0
                             AND l_otap_session.test_set = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET
                             AND l_otap_session.test_group = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP
                             AND l_otap_session.test_name = otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME
                             AND l_otap_session.session_id > l_alt_session.session_id
                             AND l_otap_session.session_start > l_alt_session.session_start
                            )
                          , 'otap_objects.otap_session_finish check'
                          )
  ;
  l_otap_session := otap_objects.otap_session_test_setup(l_alt_session, 'Jo', 'Jo', 'Jo');
  l_return := otap_test.ok( (    l_otap_session.test_set = 'Jo'
                             AND l_otap_session.test_group = 'Jo'
                             AND l_otap_session.test_name = 'Jo'
                            )
                          , 'otap_objects.otap_session_test_setup check'
                          )
  ;
  l_otap_session := otap_objects.otap_session_test_setup(l_alt_session, NULL, NULL, NULL);
  l_return := otap_test.ok( (    l_otap_session.test_set = 'Test setup'
                             AND l_otap_session.test_group = 'Session test setup'
                             AND l_otap_session.test_name = 'Session test setup checks'
                            )
                          , 'otap_objects.otap_session_test_setup default check'
                          )
  ;
  l_otap_session := otap_objects.otap_session_test_setup(l_alt_session, RPAD('Jo', 300, 'a'), RPAD('Jo', 300, 'a'), RPAD('Jo', 300, 'a'));
  l_return := otap_test.ok( (    LENGTH(l_otap_session.test_set) = 256
                             AND LENGTH(l_otap_session.test_group) = 256
                             AND LENGTH(l_otap_session.test_name) = 256
                            )
                          , 'otap_objects.otap_session_test_setup check cut strings'
                          )
  ;
  BEGIN
    l_otap_session := otap_objects.otap_session_test_setup(NULL, NULL, NULL, NULL);
    l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_test_setup check full NULL');
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -20099
      THEN
        l_return := otap_test.ok(TRUE, 'otap_objects.otap_session_test_setup check full NULL');
      ELSE
        l_return := otap_test.ok(FALSE, 'otap_objects.otap_session_test_setup check full NULL unexpected exception');
      END IF;
  END;
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_OBJECTS failed', 'otap_objects.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_OBJECTS failed', SQLERRM);
END;
/