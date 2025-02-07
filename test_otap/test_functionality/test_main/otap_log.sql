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
  l_stamp := SYSTIMESTAMP;
  otap_log.log(p_log_message => 'OTAP_TEST: Should not log with identifier not OTAP_ERROR', p_identifier => 'MY DEBUG');
  SELECT otap_test.is_eq(COUNT(*), 0, 'Check only error logging if not debug mode')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Should not log with identifier not OTAP_ERROR'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = 'MY DEBUG'
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  UPDATE otap_config SET config_value = otap_constants.OTAP_NUM_TRUE WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE;
  -- commit needed due to independent transaction
  COMMIT;
  otap_log.log(p_log_message => 'OTAP_TEST: Should log with identifier not OTAP_ERROR', p_identifier => 'MY DEBUG');
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check debug logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Should log with identifier not OTAP_ERROR'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = 'MY DEBUG'
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
  ;
  -- reset change
  UPDATE otap_config SET config_value = otap_constants.OTAP_NUM_FALSE WHERE config_name = otap_constants.OTAP_CFG_DEBUG_MODE;
  COMMIT;
END;
/