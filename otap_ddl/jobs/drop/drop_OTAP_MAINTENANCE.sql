-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
DECLARE
  l_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO l_count FROM user_scheduler_jobs WHERE job_name = 'OTAP_MAINTENANCE';
  IF l_count = 1
  THEN
    -- drop the job
    DBMS_SCHEDULER.DISABLE(name => 'OTAP_MAINTENANCE', force => TRUE);
    DBMS_SCHEDULER.DROP_JOB(job_name => 'OTAP_MAINTENANCE', force => TRUE);
    DBMS_OUTPUT.PUT_LINE('Disabled and dropped job OTAP_MAINTENANCE');
  ELSE
    -- inform job does not exist
    DBMS_OUTPUT.PUT_LINE('WARNING Job OTAP_MAINTENANCE does not exist, do nothing');
  END IF;
END;
/