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
  FUNCTION has_table( p_table_name      IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
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
  FUNCTION has_column( p_table_name      IN            VARCHAR2
                     , p_column_name     IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_data_type       IN            VARCHAR2 DEFAULT NULL
                     , p_data_length     IN            NUMBER   DEFAULT NULL
                     , p_data_precision  IN            NUMBER   DEFAULT NULL
                     , p_data_scale      IN            NUMBER   DEFAULT NULL
                     , p_nullable        IN            VARCHAR2 DEFAULT NULL
                     , p_data_default    IN            VARCHAR2 DEFAULT NULL
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_package
  * Checks if a given package exists. Check if header and body, if available, are valid by default.
  *
  * @param p_package_name The name of the package, take as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_package_type The object type of the package. PACKAGE or PACKAGE BODY. Not case sensitive. Invalid values cause test result undefined.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_package( p_package_name    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_package_type    IN            VARCHAR2 DEFAULT 'PACKAGE'
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_procedure
  * Checks if a given procedure or function exists. If package is given, the package procedure or function
  * is checked.
  *
  * @param p_procedure_name The name of the procedure or function, take as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_procedure_type Procedure type, mandatory. Either FUNCTION (default) or PROCEDURE. Not case sensitive. Invalid values cause test result undefined.
  * @param p_package_name Either NULL (normal functions and procedures) or a package name for package functions and procedures. Case sensitive.
  * @param p_return_type Either NULL (procedures) or the return data type of a function. Not case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_procedure( p_procedure_name  IN            VARCHAR2
                        , o_errors             OUT NOCOPY VARCHAR2
                        , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_procedure_type  IN            VARCHAR2 DEFAULT 'FUNCTION'
                        , p_package_name    IN            VARCHAR2 DEFAULT NULL
                        , p_return_type     IN            VARCHAR2 DEFAULT NULL
                        , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                        )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_trigger
  * Checks if a given trigger exists.
  *
  * @param p_trigger_name The name of the trigger, take as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_trigger_type The trigger type as in USER_TRIGGERS. Optional. Not case sensitive. Invalid values cause test failed.
  * @param p_trigger_event The triggering event as in USER_TRIGGERS. Optional. Not case sensitive.
  * @param p_table_owner The table owner as in USER_TRIGGERS. Optional. Case sensitive.
  * @param p_table_name The table name as in USER_TRIGGERS. Optional. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_trigger( p_trigger_name    IN            VARCHAR2
                      , o_errors             OUT NOCOPY VARCHAR2
                      , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_trigger_type    IN            VARCHAR2 DEFAULT NULL
                      , p_trigger_event   IN            VARCHAR2 DEFAULT NULL
                      , p_table_owner     IN            VARCHAR2 DEFAULT NULL
                      , p_table_name      IN            VARCHAR2 DEFAULT NULL
                      , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                      )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_object
  * Checks if a given database object exists in DBA_OBJECTS.
  *
  * @param p_object_name The name of the object, take as is. Case sensitive.
  * @param p_object_type The object type of the given object. Mandatory. Object must be unique identifiable, otherwise test will result in undefined. Not case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_object( p_object_name     IN            VARCHAR2
                     , p_object_type     IN            VARCHAR2
                     , o_errors             OUT NOCOPY VARCHAR2
                     , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                     )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_constraint
  * Checks if a given table has a constraint of the given type. Optional you can specify column and constraint name.
  * Supported constraint types:
  * C - Check constraint on a table
  * P - Primary key
  * U - Unique key
  * R - Referential integrity - use has_ref_constraint for more options
  * V - With check option, on a view
  * O - With read only, on a view
  * H - Hash expression
  * F - Constraint that involves a REF column - use has_ref_constraint for more options
  * S is not supported, could not find or create an example to examine. SUPPLEMENTAL LOG clause only reflects in CDEF$ and CCOL$.
  *
  * @param p_table_name Mandatory. The table to be checked for constraint, take as is. Case sensitive. Missing value will cause test to fail.
  * @param o_error Error information, if any, on the test executed.
  * @param p_constraint_type Mandatory. A valid constraint type. Not case sensitive. Wrong values will cause the test to fail.
  * @param p_column_name Optional. The column that is part of the constraint. Case sensitive.
  * @param p_constraint Optional. The name of the constraint. Case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_constraint( p_table_name      IN            VARCHAR2
                         , o_errors             OUT NOCOPY VARCHAR2
                         , p_constraint_type IN            VARCHAR2 DEFAULT 'C'
                         , p_column_name     IN            VARCHAR2 DEFAULT NULL
                         , p_constraint      IN            VARCHAR2 DEFAULT NULL
                         , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                         )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_ref_constraint
  * Checks if a given table has a reference constraint. You may also use has_constraint. But if you want to check the
  * referenced owner, constraint, column and table, you have to use this function.
  *
  * @param p_table_name Mandatory. The table to be checked for the reference constraint, take as is. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_constraint_type Mandatory. A valid ref constraint type. Not case sensitive. Only 'R' and 'F' allowed, 'R' on invalid or empty values.
  * @param p_column_name Optional. The column that is part of the reference constraint. Case sensitive.
  * @param p_constraint Optional. The name of the reference constraint. Case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_r_table_name Optional. The referenced table of the reference constraint, take as is. Case sensitive.
  * @param p_r_column_name Optional. The referenced column that is part of the reference constraint. Case sensitive.
  * @param p_r_constraint Optional. The name of the referenced constraint by the reference constraint. Case sensitive.
  * @param p_r_schema Optional. The reference schema of the constraint. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_ref_constraint( p_table_name      IN            VARCHAR2
                             , o_errors             OUT NOCOPY VARCHAR2
                             , p_constraint_type IN            VARCHAR2 DEFAULT 'R'
                             , p_column_name     IN            VARCHAR2 DEFAULT NULL
                             , p_constraint      IN            VARCHAR2 DEFAULT NULL
                             , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                             , p_r_table_name    IN            VARCHAR2 DEFAULT NULL
                             , p_r_column_name   IN            VARCHAR2 DEFAULT NULL
                             , p_r_constraint    IN            VARCHAR2 DEFAULT NULL
                             , p_r_schema        IN            VARCHAR2 DEFAULT NULL
                             , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                             )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_not_null_constraint
  * Checks if a given table column has a not null check constraint. Optional you can specify the constraint name. NOT NULL constraint is
  * somewhat special as it is recommended for inline creation, which generates system constraint names. You are also free to create it
  * outbound. Therefore in most cases the constraint name is not defined or may change on recreation. Also NULLABLE may not reflect an
  * existing outbound NOT NULL constraint. This function checks also the definition, which has the generated format: "COLUMN_NAME" IS NOT NULL.
  * Any outbund declaration will probably look different. Therefore the term "IS NOT NULL" and the column name is searched after UPPER conversion
  * of SEARCH_CONDITION_VC. Will not work for search conditions > 4000 char.
  *
  * @param p_table_name Mandatory. The table to be checked for NOT NULL constraint, take as is. Case sensitive. Missing value will cause test to fail.
  * @param p_column_name Mandator. The column that is checked for the NOT NULL constraint. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_constraint Optional. The name of the constraint. Case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_not_null_constraint( p_table_name      IN            VARCHAR2
                                  , p_column_name     IN            VARCHAR2
                                  , o_errors             OUT NOCOPY VARCHAR2
                                  , p_constraint      IN            VARCHAR2 DEFAULT NULL
                                  , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                  , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                                  )
    RETURN INTEGER
  ;
/*
  -- table name guaranteed, column can be null, index not in dba_ind_columns
  FUNCTION has_index( p_table_name      IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_column_name     IN            VARCHAR2 DEFAULT NULL
                    , p_index_name      IN            VARCHAR2 DEFAULT NULL
                    , p_index_type      IN            VARCHAR2 DEFAULT NULL
                    , p_table_type      IN            VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN            VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN            VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN            VARCHAR2 DEFAULT NULL
                    , p_last_analyzed   IN            DATE     DEFAULT NULL
                    , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  ;
*/
END;
/
