-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- Provides test functions related to schema objects.
CREATE OR REPLACE PACKAGE otap_schema
AS

  /**
  * This package provides the internal available test functions for schema objects which
  * are used by OTAP_API. All functions use PLSQL variable types as they are behind OTAP_API.
  *
  * All functions return a numeric test result as defined in otap_constants.OTAP_NUM_TEST_PASSED,
  * otap_constants.OTAP_NUM_TEST_FAILED, otap_constants.OTAP_NUM_TEST_UNDEFINED.
  *
  * Test functions never manage session variables, but they always provide an error output. Decisions
  * based on session objects, e.g. which schema to use, must be managed by OTAP_API.
  */

  /** FUNCTION otap_schema.has_table
  * Tests if a table exists and returns a numeric test result.
  *
  * @param p_table_name The name of the table, taken as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_table( p_table_name      IN     VARCHAR2
                    , o_errors             OUT VARCHAR2
                    , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_column
  * Tests basically if a table column exists. Additional tests on the column can be added by using the additional
  * parameters with default NULL. The expected values have to match the content of DBA_TAB_COLUMNS for the given table,
  * column and schema.
  *
  * If checking defaults, it is limited to defaults not longer than 4000 char, using the DATA_DEFAULT_VC column. Expressions
  * must match all chars in the default, like quotation. Use q-syntax where possible to define correct strings, e.g.
  * SELECT q'[SYS_CONTEXT('USERENV', 'OS_USER')]' FROM dual;
  *
  * @param p_table_name The name of the table, taken as is. Case sensitive.
  * @param p_column_name The column name of the table, taken as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_data_type Optional check the datatype of the column. Ignored if NULL. NOT case sensitive.
  * @param p_data_length Optional check the data length of the column. Ignored if NULL.
  * @param p_data_precision Optional check the data precision of the column. Ignored if NULL. Results in test error if datatype is not NUMBER.
  * @param p_data_scale Optional check the data scale of the column. Ignored if NULL. Results in test error if datatype is not NUMBER or TIMESTAMP.
  * @param p_nullable Optional check if the column is nullable. Ignored if NULL. NOT case sensitive.
  * @param p_data_default Optional check the default for the column. Ignored if NULL. Must match all chars, including ' and ". Limited to defaults shorter than 4000 chars.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_column( p_table_name      IN     VARCHAR2
                     , p_column_name     IN     VARCHAR2
                     , o_errors             OUT VARCHAR2
                     , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_data_type       IN     VARCHAR2 DEFAULT NULL
                     , p_data_length     IN     NUMBER   DEFAULT NULL
                     , p_data_precision  IN     NUMBER   DEFAULT NULL
                     , p_data_scale      IN     NUMBER   DEFAULT NULL
                     , p_nullable        IN     VARCHAR2 DEFAULT NULL
                     , p_data_default    IN     VARCHAR2 DEFAULT NULL
                     , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_package
  * Checks if a given package exists. Check if header and body, if available, are valid by default.
  *
  * @param p_package_name The name of the package, take as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_package_type The object type of the package. PACKAGE or PACKAGE BODY. Not case sensitive. Invalid values translate to PACKAGE.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_package( p_package_name    IN     VARCHAR2
                      , o_errors             OUT VARCHAR2
                      , p_schema          IN     VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_package_type    IN     VARCHAR2 DEFAULT 'PACKAGE'
                      , p_expected_result IN     NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  ;

END;
/

/* SQLs for schema objects
-- package functions and procedures - only package joins with object_id, not package body, no result
SELECT dbo.owner
     , dbo.object_name
     , dbo.object_type
     , dbo.status
     , dbp.procedure_name
     , CASE
         WHEN dbr.position       = 0
          AND dbr.argument_name IS NULL
         THEN 'FUNCTION'
         ELSE 'PROCEDURE'
       END AS procedure_type
     , CASE
         WHEN dbr.position       = 0
          AND dbr.argument_name IS NULL
         THEN dbr.data_type
         ELSE NULL
       END AS return_type
  FROM dba_objects dbo
  LEFT OUTER JOIN dba_procedures dbp
    ON dbo.object_id    = dbp.object_id
  LEFT OUTER JOIN dba_arguments dbr
    ON dbp.object_id     = dbr.object_id
   AND dbp.subprogram_id = dbr.subprogram_id
   AND dbr.sequence      = 1
 WHERE dbo.owner        = 'OTAP'
   AND dbo.object_type  = 'PACKAGE'
   AND dbo.object_name  = 'OTAP_RESULTS_UTIL'
;

-- package function and procedure parameter
SELECT dbo.owner
     , dbo.object_name
     , dbo.object_type
     , dbo.status
     , dbp.procedure_name
     , dbr.argument_name
     , dbr.data_type
     , dbr.position
  FROM dba_objects dbo
  LEFT OUTER JOIN dba_procedures dbp
    ON dbo.object_id    = dbp.object_id
  LEFT OUTER JOIN dba_arguments dbr
    ON dbp.object_id      = dbr.object_id
   AND dbp.subprogram_id  = dbr.subprogram_id
   AND dbr.argument_name IS NOT NULL
 WHERE dbo.owner            = 'OTAP'
   AND dbo.object_type      = 'PACKAGE'
   AND dbo.object_name      = 'OTAP_RESULTS_UTIL'
   AND dbp.procedure_name   = 'WRITE_TEST_RESULT'
--   AND dbp.procedure_name   = 'MAX_TEXT_SIZE'
;

-- functions, procedures and trigger
SELECT dbo.owner
     , dbo.object_name
     , dbo.object_type
     , dbo.status
     , dbp.procedure_name
     , CASE
         WHEN dbr.position       = 0
          AND dbr.argument_name IS NULL
         THEN 'FUNCTION'
         ELSE 'PROCEDURE'
       END AS procedure_type
     , CASE
         WHEN dbr.position       = 0
          AND dbr.argument_name IS NULL
         THEN dbr.data_type
         ELSE NULL
       END AS return_type
  FROM dba_objects dbo
  LEFT OUTER JOIN dba_procedures dbp
    ON dbo.object_id    = dbp.object_id
  LEFT OUTER JOIN dba_arguments dbr
    ON dbp.object_id     = dbr.object_id
   AND dbp.subprogram_id = dbr.subprogram_id
   AND dbr.sequence      = 1
 WHERE dbo.owner        = 'OTAP'
   AND dbo.object_type IN ('FUNCTION', 'PROCEDURE', 'TRIGGER')
--   AND dbo.object_name  = 'DUMMY_PROCEDURE'
;

-- parameters functions and procedures
SELECT dbo.owner
     , dbo.object_name
     , dbo.object_type
     , dbo.status
     , dbp.procedure_name
     , dbr.argument_name
     , dbr.data_type
     , dbr.position
  FROM dba_objects dbo
  LEFT OUTER JOIN dba_procedures dbp
    ON dbo.object_id    = dbp.object_id
  LEFT OUTER JOIN dba_arguments dbr
    ON dbp.object_id     = dbr.object_id
   AND dbp.subprogram_id = dbr.subprogram_id
   AND dbr.argument_name IS NOT NULL
 WHERE dbo.owner            = 'OTAP'
   AND dbo.object_type     IN ('FUNCTION', 'PROCEDURE')
   AND dbo.object_name      = 'DUMMY_FUNCTION'
;

*/