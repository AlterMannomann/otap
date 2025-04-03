-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- Executes the test code for otap_log that handles parameter as currently set.
-- Parameter can be changed before running this code to test different parameter.
-- The test name must be set outside of this code.
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  l_return VARCHAR2(4000 CHAR);
  l_stamp  TIMESTAMP;
  l_finish TIMESTAMP;
  l_debug  INTEGER;
BEGIN
  l_stamp   := SYSTIMESTAMP;
  otap_log.log('OTAP_TEST: Basic error logging test');
  l_finish  := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check basic message logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Basic error logging test'
     AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
     AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
     AND identifier         = otap_constants.OTAP_INTERNAL_ERROR
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
     AND timestamp         <= l_finish
  ;
  l_stamp   := SYSTIMESTAMP;
  otap_log.log('OTAP_TEST: Full error logging test', 'otap_log.sql', 'My statement');
  l_finish  := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check full message logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Full error logging test'
     AND TO_CHAR(script)    = 'otap_log.sql'
     AND TO_CHAR(statement) = 'My statement'
     AND identifier         = otap_constants.OTAP_INTERNAL_ERROR
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
     AND timestamp         <= l_finish
  ;
  l_stamp   := SYSTIMESTAMP;
  otap_log.log('OTAP_TEST: Full warning logging test', 'otap_log.sql', 'My statement', otap_constants.OTAP_INTERNAL_WARNING);
  l_finish  := SYSTIMESTAMP;
  SELECT otap_test.is_eq(COUNT(*), 1, 'Check full warning logging')
    INTO l_return
    FROM sperrorlog
   WHERE TO_CHAR(message)   = 'OTAP_TEST: Full warning logging test'
     AND TO_CHAR(script)    = 'otap_log.sql'
     AND TO_CHAR(statement) = 'My statement'
     AND identifier         = otap_constants.OTAP_INTERNAL_WARNING
     AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
     AND timestamp         >= l_stamp
     AND timestamp         <= l_finish
  ;
  l_return := otap_test.throws_ok('otap_log.log(RPAD(''X'', 38000, ''x''));', -6502, NULL, 'Check exception on message too long for VARCHAR2');
  -- check debug state and test if on or test positive debug mode disabled
  l_debug := otap_util.get_config_value(otap_constants.OTAP_CFG_DEBUG_MODE);
  IF l_debug = otap_constants.OTAP_NUM_FALSE
  THEN
    l_stamp := SYSTIMESTAMP;
    otap_log.log(p_log_message => 'OTAP_TEST: Should not log with identifier not OTAP_ERROR/OTAP_WARNING', p_identifier => 'MY DEBUG');
    l_finish  := SYSTIMESTAMP;
    SELECT otap_test.is_eq(COUNT(*), 0, 'Check only error logging if not debug mode')
      INTO l_return
      FROM sperrorlog
     WHERE TO_CHAR(message)   = 'OTAP_TEST: Should not log with identifier not OTAP_ERROR/OTAP_WARNING'
       AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
       AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
       AND identifier         = 'MY DEBUG'
       AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
       AND timestamp         >= l_stamp
       AND timestamp         <= l_finish
    ;
  ELSE
    l_stamp := SYSTIMESTAMP;
    otap_log.log(p_log_message => 'OTAP_TEST: Should log with identifier not OTAP_ERROR/OTAP_WARNING', p_identifier => 'MY DEBUG');
    l_finish  := SYSTIMESTAMP;
    SELECT otap_test.is_eq(COUNT(*), 1, 'Check debug logging')
      INTO l_return
      FROM sperrorlog
     WHERE TO_CHAR(message)   = 'OTAP_TEST: Should log with identifier not OTAP_ERROR/OTAP_WARNING'
       AND TO_CHAR(script)    = otap_constants.OTAP_INTERNAL_NA
       AND TO_CHAR(statement) = otap_constants.OTAP_INTERNAL_NA
       AND identifier         = 'MY DEBUG'
       AND username           = otap_constants.OTAP_INTERNAL_SCHEMA
       AND timestamp         >= l_stamp
       AND timestamp         <= l_finish
    ;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    otap_log.log('Test block OTAP_LOG failed', 'otap_log.sql', SQLERRM);
    l_return := otap_test.test_error('Complete test block OTAP_LOG failed', SQLERRM);
END;
/