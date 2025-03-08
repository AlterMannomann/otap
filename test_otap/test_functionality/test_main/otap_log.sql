-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- sets the test name and calls the tests for this test name

-- basic schema and otap_constants tests already done, test log entries will remain, logging is always committed on success
SELECT otap_test.set_test_name('Verify otap_log functionality') FROM dual;
-- to verify package constants we use a anonymous PLSQL block
-- to not overload DBMS_OUTPUT only minimal summary output
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return VARCHAR2(4000);
  l_stamp  TIMESTAMP;
BEGIN
  l_stamp := SYSTIMESTAMP;
  otap_log.log('OTAP_TEST: Basic error logging test');
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check basic message logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Basic error logging test'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = otap_constants.OTAP_INTERNAL_ERROR
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  otap_log.log('OTAP_TEST: Full error logging test', 'otap_log.sql', 'My statement');
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check full message logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Full error logging test'
     AND TO_CHAR(script)    = 'otap_log.sql'
     AND TO_CHAR(statement) = 'My statement'
     AND identifier         = otap_constants.OTAP_INTERNAL_ERROR
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  l_return := otap_test.throws_ok('otap_log.log(RPAD(''X'', 38000, ''x''));', -6502, NULL, 'Check exception on message too long for VARCHAR2');
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_LOG failed', 'otap_log.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_LOG failed', SQLERRM);
END;
/