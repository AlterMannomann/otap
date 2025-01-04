-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
DECLARE
  l_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_count FROM user_scheduler_jobs WHERE job_name = 'OTAP_MAINTENANCE';
  IF l_count = 0
  THEN
    -- install job
    DBMS_SCHEDULER.CREATE_JOB( job_name => 'OTAP_MAINTENANCE'
                             , job_type => 'PLSQL_BLOCK'
                             , job_action => 'otap_results_util.result_cleanup;'
                             , repeat_interval => 'FREQ=WEEKLY;BYTIME=230000;BYDAY=MON,TUE,WED,THU,FRI'
                             , enabled => FALSE
                             , auto_drop => FALSE
                             , comments => 'otap test result cleanup'
                             )
    ;
    DBMS_SCHEDULER.SET_ATTRIBUTE( name => 'OTAP_MAINTENANCE'
                                , attribute => 'store_output'
                                , value => TRUE
                                )
    ;
    DBMS_SCHEDULER.SET_ATTRIBUTE( name => 'OTAP_MAINTENANCE'
                                , attribute => 'logging_level'
                                , value => DBMS_SCHEDULER.LOGGING_FULL
                                )
    ;
    DBMS_SCHEDULER.enable(name => 'OTAP_MAINTENANCE');
    DBMS_OUTPUT.PUT_LINE('Created and enabled job OTAP_MAINTENANCE');
  ELSE
    -- inform that job exists
    DBMS_OUTPUT.PUT_LINE('WARNING Job OTAP_MAINTENANCE already exists, do nothing');
  END IF;
END;
/