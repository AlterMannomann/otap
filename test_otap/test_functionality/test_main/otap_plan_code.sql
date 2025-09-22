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
  -- session object fake
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

  -- init_test is the only function, that has some options to be not intrusive
  -- not intrusive it is only a wrapper for otap_objects.otap_session_set
  l_return := otap_plan.init_test( 1
                                 , 'Moin'
                                 , 'MoinMoin'
                                 , 'Mooooin'
                                 , 'moin'
                                 , 'eng'
                                 , otap_constants.OTAP_NUM_TRUE
                                 , otap_constants.OTAP_NUM_FALSE
                                 , otap_constants.OTAP_NUM_FALSE
                                 , SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , SYS_CONTEXT('USERENV', 'CURRENT_USER')
                                 , SYS_CONTEXT('USERENV', 'SESSION_USER')
                                 , l_otap_session
                                 )
  ;
  l_return := otap_test.ok((l_otap_session.intended_count = 1), 'otap_plan.init_test check intended_count');
  l_return := otap_test.ok((l_otap_session.test_set = 'Moin'), 'otap_plan.init_test check test_set');
  l_return := otap_test.ok((l_otap_session.test_group = 'MoinMoin'), 'otap_plan.init_test check test_group');
  l_return := otap_test.ok((l_otap_session.test_name = 'Mooooin'), 'otap_plan.init_test check test_name');
  l_return := otap_test.ok((l_otap_session.test_prefix = 'MOIN'), 'otap_plan.init_test check test_prefix');
  l_return := otap_test.ok((l_otap_session.session_language = 'ENG'), 'otap_plan.init_test check session_language');
  l_return := otap_test.ok((l_otap_session.session_id != 0 AND l_otap_session.session_id = l_otap_session.session_view_id), 'otap_plan.init_test check session_id');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_PLAN failed', 'otap_plan.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_PLAN failed', SQLERRM);
END;
/