-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
CREATE OR REPLACE PACKAGE BODY otap_api
AS
  -- for description see header file

  FUNCTION has_table( p_table_name   IN            VARCHAR2
                    , o_otap_session IN OUT NOCOPY OTAP_SESSION
                    , p_schema       IN            VARCHAR2     DEFAULT NULL
                    , p_description  IN            VARCHAR2     DEFAULT NULL
                    )
    RETURN VARCHAR2
  IS
    l_script          VARCHAR2(1024)                  := 'otap_api.has_table';
    l_start           TIMESTAMP;
    l_end             TIMESTAMP;
    l_error_count     NUMBER;
    l_result          NUMBER;
    l_errors          otap_results.test_errors%TYPE;
    l_schema          otap_results.db_schema%TYPE;
    l_desc            otap_results.test_desc%TYPE;
    l_default_message VARCHAR2(256)                   := 'Test table exists: ';
  BEGIN
    l_start       := SYSTIMESTAMP;
    l_error_count := 0;
    -- own begin-end for the transaction after the function
    BEGIN
      -- own begin-end block for the function itself and prepare
      BEGIN
        -- handle table name is NULL - failed with test_errors
        IF    p_table_name              IS NULL
           OR LENGTH(TRIM(p_table_name)) = 0
        THEN
          l_result := otap_constants.OTAP_NUM_TEST_FAILED;
          l_errors := 'Usage error has_table: table name missing';
        ELSE
          -- handle session var is NULL - undefined with test errors
          IF o_otap_session IS NOT NULL
          THEN
            -- handle schema, if NULL
            l_schema := TRIM(NVL(p_schema, o_otap_session.db_schema));
            -- handle description
            l_desc   := NVL(p_description, l_default_message || l_schema || '.' || p_table_name);
            l_result := otap_schema.has_table( p_table_name
                                             , l_schema
                                             , l_desc
                                             )
            ;
          ELSE
            l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
            l_errors := 'Internal error has_table: OTAP_SESSION variable is NULL';
          END IF;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
        -- consume error
        -- set error indicator and error collector
        l_result := otap_constants.OTAP_NUM_TEST_UNDEFINED;
        l_errors := TRIM(SUBSTR('Internal error has_table: ' || SQLERRM, 1, 4000));
      END;
      l_end := SYSTIMESTAMP;
      -- set session variable according current value, a part where otap could fail

      -- try to write the test record

      -- return result to OTAP_TEST

    EXCEPTION
      WHEN OTHERS THEN
        -- consume error
        -- set error indicator and error collector

        -- try again to write a record with the new informations, which may again raise an exception
    END;
    -- return result or let exception happen

  END has_table;

END;
/