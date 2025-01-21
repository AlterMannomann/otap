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

  /** FUNCTION otap_schema.has_index
  * Checks if a given index exists. You may specify table name or index name. Both values NULL will lead to test failed.
  *
  * @param p_table_name Mandatory if index name is NULL. The table name of the table that owns the index.
  * @param o_error Error information, if any, on the test executed.
  * @param p_column_name Optional. The column name used in the index. Case sensitive.
  * @param p_index_name Mandatory if table name is NULL. The index name to check. Case sensitive.
  * @param p_index_type Optional. The index type of the index to check. Not case sensitive.
  * @param p_table_type Optional. The table type of the index to check. Not case sensitive.
  * @param p_uniqueness Optional. The uniqueness of the index to check. Not case sensitive.
  * @param p_tablespace_name Optional. The tablespace name used by the index to check. Case sensitive.
  * @param p_partitioned Optional. The partitioned state of the index to check. Not case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_index( p_table_name      IN            VARCHAR2
                    , o_errors             OUT NOCOPY VARCHAR2
                    , p_column_name     IN            VARCHAR2 DEFAULT NULL
                    , p_index_name      IN            VARCHAR2 DEFAULT NULL
                    , p_index_type      IN            VARCHAR2 DEFAULT NULL
                    , p_table_type      IN            VARCHAR2 DEFAULT NULL
                    , p_uniqueness      IN            VARCHAR2 DEFAULT NULL
                    , p_tablespace_name IN            VARCHAR2 DEFAULT NULL
                    , p_partitioned     IN            VARCHAR2 DEFAULT NULL
                    , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                    , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                    )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_type
  * Checks if a given type exists.
  *
  * @param p_type_name Mandatory. The name of the type to check. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_typecode Optional. The typecode like OBJECT of the type to check. Not case sensitive.
  * @param p_attributes Optional. The number of type attributes to check.
  * @param p_methods Optional. The number of type methods to check.
  * @param p_predefined Optional. The predefined state of the type to check. Not case sensitive.
  * @param p_incomplete Optional. The incomplete state of the type to check. Not case sensitive.
  * @param p_final Optional. The final state of the type to check. Not case sensitive.
  * @param p_persistable Optional. The persistable state of the type to check. Not case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_type( p_type_name       IN            VARCHAR2
                   , o_errors             OUT NOCOPY VARCHAR2
                   , p_typecode        IN            VARCHAR2 DEFAULT NULL
                   , p_attributes      IN            NUMBER   DEFAULT NULL
                   , p_methods         IN            NUMBER   DEFAULT NULL
                   , p_predefined      IN            VARCHAR2 DEFAULT NULL
                   , p_incomplete      IN            VARCHAR2 DEFAULT NULL
                   , p_final           IN            VARCHAR2 DEFAULT NULL
                   , p_persistable     IN            VARCHAR2 DEFAULT NULL
                   , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                   , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_sequence
  * Checks if a given sequence exists. It can be identified either by the sequence name or the table and column name.
  * If sequence name is NULL, table AND column name must be given to identify the sequence. In case the table owner
  * differs from the sequence owner, the table owner can be specified. If not specified, the normal schema logic takes
  * place.
  *
  * @param p_sequence_name Mandatory if not table and column name are given. The name of the sequence to check. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_table_name Mandatory if sequence name is not given. The table name with the identity column that uses the sequence to check. Case sensitive.
  * @param p_column_name Mandatory if sequence name is not given. The identity column name that uses the sequence to check. Case sensitive.
  * @param p_min_value Optional. The minimum value attribute of the sequence to check.
  * @param p_max_value Optional. The maximum value attribute of the sequence to check.
  * @param p_increment_by Optional. The increment of the sequence to check.
  * @param p_cycle_flag Optional. The cycle flag of the sequence to check. Not case sensitive.
  * @param p_order_flag Optional. The order flag of the sequence to check. Not case sensitive.
  * @param p_cache_size Optional. The cache size of the sequence to check.
  * @param p_scale_flag Optional. The scale flag of the sequence to check. Not case sensitive.
  * @param p_extend_flag Optional. The extend flag of the sequence to check. Not case sensitive.
  * @param p_sharded_flag Optional. The sharded flag of the sequence to check. Not case sensitive.
  * @param p_session_flag Optional. The session flag of the sequence to check. Not case sensitive.
  * @param p_keep_value Optional. The keep value flag of the sequence to check. Not case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_sequence( p_sequence_name   IN            VARCHAR2
                       , o_errors             OUT NOCOPY VARCHAR2
                       , p_table_name      IN            VARCHAR2 DEFAULT NULL
                       , p_column_name     IN            VARCHAR2 DEFAULT NULL
                       , p_min_value       IN            NUMBER   DEFAULT NULL
                       , p_max_value       IN            NUMBER   DEFAULT NULL
                       , p_increment_by    IN            NUMBER   DEFAULT NULL
                       , p_cycle_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_order_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_cache_size      IN            NUMBER   DEFAULT NULL
                       , p_scale_flag      IN            VARCHAR2 DEFAULT NULL
                       , p_extend_flag     IN            VARCHAR2 DEFAULT NULL
                       , p_sharded_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_session_flag    IN            VARCHAR2 DEFAULT NULL
                       , p_keep_value      IN            VARCHAR2 DEFAULT NULL
                       , p_table_owner     IN            VARCHAR2 DEFAULT NULL
                       , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                       )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_scheduler_job
  * Checks basically if a given scheduler job exists.
  *
  * @param p_job_name Mandatory. The name of the scheduler job to check. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_job_style Optional. The job style of the scheduler job to check. Not case sensitive.
  * @param p_job_type Optional. The job type of the scheduler job to check. Not case sensitive.
  * @param p_job_action Optional. The job action of the scheduler job to check. Compares code with UPPER and flatten. Not case sensitive.
  * @param p_schedule_type Optional. The schedule type of the scheduler job to check. Not case sensitive.
  * @param p_repeat_interval Optional. The repeat interval of the scheduler job to check. Not case sensitive.
  * @param p_job_class Optional. The job class of the scheduler job to check. Not case sensitive.
  * @param p_logging_level Optional. The logging level indicator of the scheduler job to check. Not case sensitive.
  * @param p_store_output Optional. The store output indicator of the scheduler job to check. Not case sensitive.
  * @param p_schema The schema to use. If NULL current schema is used. Case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_scheduler_job( p_job_name        IN            VARCHAR2
                            , o_errors             OUT NOCOPY VARCHAR2
                            , p_job_style       IN            VARCHAR2 DEFAULT NULL
                            , p_job_type        IN            VARCHAR2 DEFAULT NULL
                            , p_job_action      IN            VARCHAR2 DEFAULT NULL
                            , p_schedule_type   IN            VARCHAR2 DEFAULT NULL
                            , p_repeat_interval IN            VARCHAR2 DEFAULT NULL
                            , p_job_class       IN            VARCHAR2 DEFAULT NULL
                            , p_logging_level   IN            VARCHAR2 DEFAULT NULL
                            , p_store_output    IN            VARCHAR2 DEFAULT NULL
                            , p_schema          IN            VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                            , p_expected_result IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                            )
    RETURN INTEGER
  ;

  /** FUNCTION otap_schema.has_user
  * Checks basically if a given user exists.
  *
  * @param p_username Mandatory. The name of the database user to check. Case sensitive.
  * @param o_error Error information, if any, on the test executed.
  * @param p_account_status Optional. The account status of the database user to check. Not case sensitive.
  * @param p_default_tablespace Optional. The default tablespace of the database user to check. Case sensitive.
  * @param p_temporary_tablespace Optional. The temporary tablespace of the database user to check. Case sensitive.
  * @param p_local_temp_tablespace Optional. The local temporary tablespace of the database user to check. Case sensitive.
  * @param p_profile Optional. The profile setting of the database user to check. Not case sensitive.
  * @param p_password_versions Optional. The password versions if any defined of the database user to check. Case sensitive.
  * @param p_authentication_type Optional. The authentication type of the database user to check. Not case sensitive.
  * @param p_proxy_only_connect Optional. The proxy only connect indicator of the database user to check. Not case sensitive.
  * @param p_protected Optional. The protected state indicator of the database user to check. Not case sensitive.
  * @param p_read_only Optional. The read only state indicator of the database user to check. Not case sensitive.
  * @param p_expected_result The expected test result as number. Default is test passed. See otap_constants.
  *
  * @return The test result as number, either otap_constants.OTAP_NUM_TEST_PASSED, otap_constants.OTAP_NUM_TEST_FAILED or otap_constants.OTAP_NUM_TEST_UNDEFINED.
  */
  FUNCTION has_user( p_username              IN            VARCHAR2
                   , o_errors                   OUT NOCOPY VARCHAR2
                   , p_account_status        IN            VARCHAR2 DEFAULT NULL
                   , p_default_tablespace    IN            VARCHAR2 DEFAULT NULL
                   , p_temporary_tablespace  IN            VARCHAR2 DEFAULT NULL
                   , p_local_temp_tablespace IN            VARCHAR2 DEFAULT NULL
                   , p_profile               IN            VARCHAR2 DEFAULT NULL
                   , p_password_versions     IN            VARCHAR2 DEFAULT NULL
                   , p_authentication_type   IN            VARCHAR2 DEFAULT NULL
                   , p_proxy_only_connect    IN            VARCHAR2 DEFAULT NULL
                   , p_protected             IN            VARCHAR2 DEFAULT NULL
                   , p_read_only             IN            VARCHAR2 DEFAULT NULL
                   , p_expected_result       IN            NUMBER   DEFAULT otap_constants.OTAP_NUM_TEST_PASSED
                   )
    RETURN INTEGER
  ;

/* TO DO
FUNCTION has_user
FUNCTION is_database

*/
END;
/
