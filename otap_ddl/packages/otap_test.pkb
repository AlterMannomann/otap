-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_test
AS
  -- for description see header file
  --========= package session variables =========--
  -- define private package sesstion variables and set defaults
  session_record OTAP_SESSION := otap_session( SYS_CONTEXT('USERENV', 'SESSION_USER')
                                             , otap_constants.OTAP_DEFAULT_TEST_SET
                                             , otap_constants.OTAP_DEFAULT_TEST_GROUP
                                             , otap_constants.OTAP_DEFAULT_TEST_NAME
                                             , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                             , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                             , otap_constants.OTAP_DEFAULT_PREFIX
                                             , 0
                                             , 0
                                             , FALSE
                                             , TRUE
                                             , FALSE
                                             )
  ;

  FUNCTION init_test( p_test_count      IN NUMBER   DEFAULT 0
                    , p_test_set        IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_SET
                    , p_test_group      IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_TEST_GROUP
                    , p_prefix          IN VARCHAR2 DEFAULT otap_constants.OTAP_DEFAULT_PREFIX
                    , p_name_precedence IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                    , p_include_pkg     IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    , p_persist         IN NUMBER   DEFAULT otap_constants.OTAP_NUM_FALSE
                    -- internal variables from caller environment DO NOT SET them explicitely
                    -- currently no save way exists to get the correct values otherwise
                    , p_schema          IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_user            IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_USER')
                    , p_executor        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'SESSION_USER')
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_plan.init_test( p_test_count
                                    , p_test_set
                                    , p_test_group
                                    , p_prefix
                                    , p_name_precedence
                                    , p_include_pkg
                                    , p_persist
                                    , p_schema
                                    , p_user
                                    , p_executor
                                    , session_record
                                    )
    ;
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.init_test', 'otap_test.init_test call');
      END IF;
      RAISE;
  END init_test;

  FUNCTION current_settings
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_plan.current_test_setting(session_record);
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.current_test_setting', 'otap_test.current_test_setting call');
      END IF;
      RAISE;
  END current_settings;

  FUNCTION set_test_name(p_test_name IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_plan.set_test_name(p_test_name, session_record);
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_name', 'otap_test.set_test_name call');
      END IF;
      RAISE;
  END set_test_name;

  FUNCTION set_test_group(p_test_group IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_plan.set_test_group(p_test_group, session_record);
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_group', 'otap_test.set_test_group call');
      END IF;
      RAISE;
  END set_test_group;

  FUNCTION set_test_set(p_test_set IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_plan.set_test_set(p_test_set, session_record);
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.set_test_set', 'otap_test.set_test_set call');
      END IF;
      RAISE;
  END set_test_set;

  FUNCTION has_table( p_table_name   IN            VARCHAR2
                    , p_schema       IN            VARCHAR2     DEFAULT NULL
                    , p_description  IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  IS
    l_message VARCHAR2(4000);
  BEGIN
    otap_plan.verify_otap_session(session_record);
    l_message := otap_schema.has_table(p_table_name, session_record, p_schema, p_description);
    otap_plan.verify_otap_session(session_record);
    RETURN l_message;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE != -20099
      THEN
        otap_util.log(SQLERRM, 'otap_test.has_table', 'otap_test.has_table call');
      END IF;
      RAISE;
  END has_table;

END;
/