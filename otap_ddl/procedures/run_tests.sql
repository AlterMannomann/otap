-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.

-- read setup configuration as written by DBA setup, path relative to setup caller
@@../setup/otap_setup_def.sql

/** PROCEDURE run_tests
* Runs test procedures and package procedures identified by the defined prefix of the current otap session record in the
* schema given by the current otap session record.
*
* Recommended usage:
* - Run otap.otap_test.init_test to set your preferences
* - Store the session id
* - Run otap.run_tests with the user and schema desired
* - Run otap.otap_test.finish_test_with_exit_code
* - Access the test result with the stored session id and do actions depending on the exit code
* Do not run init or finish within the test procedures. Also not forbidden, managing different session ids could get difficult.
*
* The following rules are applied:
* - test procedures must start with the defined prefix
* - the only allowed delimiter is underscore _
* - test procedures must NOT have any parameter, not even with default values
* - only valid test procedures are considered
* - test packages are identified by matching package procedures, if include packages is configured in the otap session record
* - the executor must have the necessary rights on the objects to test
* - if name precedence is set (default), the names of the procedures must match the naming rule
* - other schema/user need direct execute grant on otap_test package and run_tests procedure to use them in packages and procedures,
*   role is not sufficient
* - in reverse, other schema/user must directly grant execute on test functions to otap
*
* SECURITY IMPLICATIONS
* The need of direct grants makes grants at a certain level not manageable anymore. So procedures is a bad choice, if not
* assembled in a package. The package should ensure, that functionality called is not exposed to OTAP only to the user executing
* the test. Right management can get difficult and cause security breaches. Best way to deal with this, is a test user with
* access to the functions and procedures to test, that only has the test package granted to OTAP and no test object in its schema.
* Before calling, the default schema of the test user should be set to the schema to test. Nevertheless a lot of direct grants
* will be needed:
* - direct execute grant to the test user for all functions, procedures and packages from the application to test
* - direct execute grant to otap for all test procedures and packages of the test user to execute
* - direct execute grant to otap for all application objects that should be dynamically executed by otap, e.g. throw tests
*
* In any case the sqlplus script access is much more safer and reliable. It supports roles better and therefore is recommended.
* If used on a save test system, global EXECUTE ANY PROCEDURE rights for otap may help to overcome the restrictions, but are,
* anyway, a risk.
*
* Naming rules for test procedures:
* - general
*   - name starts with the defined prefix with added _ and another name part, pattern is <prefix>_<name>, e.g. TEST_MYTEST
* - name precedence is set
*   - pattern is <prefix>_<optional sort number>_<set name>_<group name>_<test name>, e.g. TEST_001_SET_GROUP_MYTEST
*     or <prefix>_<set name>_<group name>_<test name>, e.g. TEST_SET_GROUP_MYTEST
*     - optional sort number: only digits 0-9 allowed to be considered as optional sort number, otherwise interpreted as test set
*
* If name parts could not be identified, the current settings from the otap session record will be used. Everything after the
* fourth underscore _ is considered as test name. The procedure will set the names identified by procedure names using otap_test.
* As this can be overwritten by test procedures, no guarantee is given, that names match the expectation. The optional sort number
* can be used for ordering the test procedures, used order is procedure name ASC
*
* @param p_like The like expression for procedures and packages to execute. The like expression is applied after the prefix,
* e.g. using defaults results to pattern TEST\_%, where TEST is the prefix, escape char is \ and % is the like expression.
*
* @exception -20099 unhandled otap exception, procedure call exceptions will result in test errors.
*/

create or replace PROCEDURE run_tests(p_like IN VARCHAR2 DEFAULT '%')
IS
  l_script  VARCHAR2(1024 CHAR) := 'run_tests';
  l_schema  VARCHAR2(128 CHAR);
  l_like    VARCHAR2(256 CHAR);
  l_set     VARCHAR2(256 CHAR);
  l_group   VARCHAR2(256 CHAR);
  l_name    VARCHAR2(256 CHAR);
  l_header  VARCHAR2(10 CHAR);
  l_footer  VARCHAR2(10 CHAR);
  l_block   VARCHAR2(4000 CHAR);
  l_chunk   VARCHAR2(256 CHAR);
  l_return  VARCHAR2(4000 CHAR);
  l_chunks  NUMBER;
  l_start   NUMBER;
  l_end     NUMBER;
  l_pos     NUMBER;
  l_len     NUMBER;
  -- build call name (package prefix if needed and include_packages)
  CURSOR cur_tests_to_run( cp_schema IN VARCHAR2
                         , cp_like   IN VARCHAR2
                         )
  IS
      WITH base AS
         (SELECT dbo.owner
               , dbo.object_name
               , dbo.object_type
               , dbo.status
               , NVL(dbp.procedure_name, dbp.object_name) AS procedure_name
            FROM dba_objects dbo
            LEFT OUTER JOIN dba_procedures dbp
              ON dbp.owner        = dbo.owner
             AND dbp.object_name  = dbo.object_name
             AND dbp.object_type  = dbo.object_type
             AND dbp.is_procedure = 'YES'
           WHERE dbo.owner                 = cp_schema
             AND dbo.status                = 'VALID'
             AND dbo.object_type          IN ('PROCEDURE', 'PACKAGE')
         )
    SELECT base.owner
         , base.object_name
         , base.object_type
         , base.status
         , base.procedure_name
         , REGEXP_COUNT(base.procedure_name, '[_].') AS chunks
         , CASE
             WHEN base.object_type = 'PACKAGE'
             THEN base.owner || '.' || base.object_name || '.' || base.procedure_name
             ELSE base.owner || '.' || base.procedure_name
           END AS qualified_name
      FROM base
           -- ensure no parameter specified
     WHERE NOT EXISTS (SELECT 1
                         FROM dba_arguments ar
                        WHERE ar.position    > 0
                          AND ar.owner       = base.owner
                          AND ar.object_name = base.procedure_name
                      )
       AND UPPER(base.procedure_name) LIKE cp_like ESCAPE '\'
     ORDER BY base.procedure_name ASC
  ;
BEGIN
  l_schema := otap_test.get_schema;
  l_like   := otap_test.get_prefix || '\' || otap_constants.OTAP_INTERNAL_DELIMITER || NVL(p_like, '%');
  -- build header and footer for statement block
  l_header := 'BEGIN' || otap_constants.OTAP_INTERNAL_LF;
  l_footer := otap_constants.OTAP_INTERNAL_LF || 'END;';
  -- loop over records found
  FOR rec IN cur_tests_to_run(l_schema, l_like)
  LOOP
    -- extract names
    IF otap_test.name_precedence
    THEN
      -- get first element, add one to start after delimiter
      l_start := INSTR(rec.procedure_name, otap_constants.OTAP_INTERNAL_DELIMITER) + 1;
      l_pos   := 1;
      -- only process max. 4 chunks
      l_chunks := LEAST(4, rec.chunks);
      FOR i IN 1..l_chunks
      LOOP
        IF i = l_chunks
        THEN
          -- end reached
          l_end := 256;
        ELSE
          l_end := INSTR(rec.procedure_name, otap_constants.OTAP_INTERNAL_DELIMITER, l_start);
          l_len := l_end - l_start;
        END IF;
        -- get current chunk
        l_chunk := NVL(SUBSTR(rec.procedure_name, l_start, l_len), 'Undefined');
        IF i = 1 AND REGEXP_INSTR(l_chunk, '[^0123456789]') = 0
        THEN
          -- ignore optional order number, relative position stays 1
          l_start := l_end + 1;
        ELSE
          -- process chunk
          IF l_pos = 1
          THEN
            l_return := otap_test.set_test_set(l_chunk);
          ELSIF l_pos = 2
          THEN
            l_return := otap_test.set_test_group(l_chunk);
          ELSE
            l_return := otap_test.set_test_name(l_chunk);
          END IF;
          l_pos   := l_pos + 1;
          l_start := l_end + 1;
        END IF;
      END LOOP;
    END IF;
    -- decide if to consider, ignore otherwise
    IF (   rec.object_type = 'PROCEDURE'
        OR (    rec.object_type = 'PACKAGE'
            AND otap_test.include_packages
           )
       )
    THEN
      l_block := l_header || rec.qualified_name || ';' || l_footer;
      -- do extra block for exception handling
      BEGIN
        EXECUTE IMMEDIATE l_block;
      EXCEPTION
        WHEN OTHERS THEN
          l_return := otap_test.test_error('Procedure ' || rec.qualified_name || ' failed', SQLERRM);
      END;
    END IF;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -20099
    THEN
      otap_log.log(SQLERRM, l_script, 'Unhandled exception ' || l_script || ' call');
    END IF;
    RAISE;
END run_tests;
/
GRANT EXECUTE ON run_tests TO &OTAP_ROLE;