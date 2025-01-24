-- (C) 2024 Michael Lindenau licensed via https://www.gnu.org/licenses/agpl-3.0.txt
-- and https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1
-- Not allowed to be used as AI training material without explicite permission.
-- A package to generate test scripts
CREATE OR REPLACE PACKAGE otap_generate
AS

  /**
  * Provides view functions to generate test scripts from schema objects.
  * WARNING This records just the current state of the schema. This does not mean that it is the correct
  * or desired state. Control and adjust the generated test calls to your need. This is a helper for
  * a simple start with schema tests, NOT with functional tests.
  */

  /** FUNCTION otap_generate.column_tests
  * Generates the test scripts for the columns of a given table and schema with the current available
  * otap schema functions. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get column tests for. Case sensitive.
  * @param p_like_column The like expression for the columns to generate tests for. Can also be a specific column name. Case sensitive.
  * @param p_schema The schema to generate the column tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION column_tests( p_table         IN VARCHAR2
                       , p_like_column   IN VARCHAR2 DEFAULT '%'
                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.table_tests
  * Generates the test scripts for the tables of the given schema with the current available
  * otap schema functions. Provides group (tables) and name (table name) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_table The like expression for the tables to generate tests for. Can also be a specific table name. Case sensitive.
  * @param p_schema The schema to generate the table tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION table_tests( p_like_table    IN VARCHAR2 DEFAULT '%'
                      , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                      , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.constraint_tests
  * Generates the test scripts for the constraints of a given table. Even if system objects are excluded, the generator will create
  * tests for system generated NOT NULL constraints, using all parameters apart the constraint name. Limited to line size 4000 but
  * not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get constraint tests for. Case sensitive.
  * @param p_like_constraints The like expression for the constraints to generate tests for. Can also be a specific constraint name. Case sensitive.
  * @param p_schema The schema to generate the constraint tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION constraint_tests( p_table            IN VARCHAR2
                           , p_like_constraints IN VARCHAR2 DEFAULT '%'
                           , p_schema           IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                           , p_title_prefix     IN VARCHAR2 DEFAULT NULL
                           , p_show_header      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                           , p_excl_sysgen      IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                           )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.index_tests
  * Generates the test scripts for the indexes of a given table. Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_table Mandatory. The table name to get index tests for. Case sensitive.
  * @param p_like_index The like expression for the indexes to generate tests for. Can also be a specific index name. Case sensitive.
  * @param p_schema The schema to generate the index tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION index_tests( p_table         IN VARCHAR2
                      , p_like_index    IN VARCHAR2 DEFAULT '%'
                      , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                      , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                      )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.trigger_tests
  * Generates the test scripts for the trigger of the given schema with the current available
  * otap schema functions. Provides group (trigger) and name (table trigger, non table trigger) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_trigger The like expression for the trigger to generate tests for. Can also be a specific trigger name. Case sensitive.
  * @param p_schema The schema to generate the trigger tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION trigger_tests( p_like_trigger  IN VARCHAR2 DEFAULT '%'
                        , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.procedure_tests
  * Generates the test scripts for the procedures and functions, including packages. with the current available
  * otap schema functions. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_procedure The like expression for the package function or procedure to generate tests for. Can also be a specific function or procedure name. Case sensitive.
  * @param p_package_name Optional. Package name for the functions and procedures. Case sensitive.
  * @param p_schema The schema to generate the package tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION procedure_tests( p_like_procedure IN VARCHAR2 DEFAULT '%'
                          , p_package_name   IN VARCHAR  DEFAULT NULL
                          , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                          , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                          , p_show_header    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          , p_excl_sysgen    IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.package_tests
  * Generates the test scripts for the packages of the given schema with the current available
  * otap schema functions. Provides group (package) and name (package function and procedures) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_schema The schema to generate the package tests for. Default is current schema.
  * @param p_like_package The like expression for the packages to generate tests for. Can also be a specific package name. Case sensitive.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION package_tests( p_like_package  IN VARCHAR2 DEFAULT '%'
                        , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                        )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.view_tests
  * Generates the test scripts for the views of the given schema with the current available
  * otap schema functions. Provides group (views) and name (view name) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_like_view The like expression for the views to generate tests for. Can also be a specific view name. Case sensitive.
  * @param p_schema The schema to generate the view tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION view_tests( p_like_view     IN VARCHAR2 DEFAULT '%'
                     , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.schema_user_test
  * Generates the test script for the schema user processed.
  * Provides group (users) and name (simple user checks) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_schema The schema to generate the user test for.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION schema_user_test( p_schema        IN VARCHAR2 DEFAULT NULL
                           , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                           , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                           )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.related_user_tests
  * Generates the simple test scripts for a user list to be processed. User names will only be checked for user name and open account status.
  * Provides group (schema user) and name (schema user check) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_user_list The comma separated user list to generate the simple user tests for.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION related_user_tests( p_user_list     IN VARCHAR2 DEFAULT NULL
                             , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                             , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                             )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.type_tests
  * Generates the test scripts for the types of the given schema with the current available
  * otap schema functions. Provides name (types) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_type The like expression for the types to generate tests for. Can also be a specific type name. Case sensitive.
  * @param p_schema The schema to generate the type tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION type_tests( p_like_type     IN VARCHAR2 DEFAULT '%'
                     , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                     )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.sequence_tests
  * Generates the test scripts for the sequences of the given schema with the current available
  * otap schema functions. Provides name (sequences) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_sequence The like expression for the sequences to generate tests for. Can also be a specific sequence name. Case sensitive.
  * @param p_schema The schema to generate the sequence tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION sequence_tests( p_like_sequence IN VARCHAR2 DEFAULT '%'
                         , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                         , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                         , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                         )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.sched_job_tests
  * Generates the test scripts for the scheduler jobs of the given schema with the current available
  * otap schema functions. Provides name (scheduler jobs) management. Limited to line size 4000 but not
  * to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_like_job The like expression for the scheduler jobs to generate tests for. Can also be a specific scheduler job name. Case sensitive.
  * @param p_schema The schema to generate the scheduler job tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION sched_job_tests( p_like_job      IN VARCHAR2 DEFAULT '%'
                          , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                          , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                          , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                          )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.schema_tests
  * Generates the test scripts for the current available otap schema functions.
  * Provides set, group and name management.  Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * Including system generated objects is a good idea if your system is stable and you want to
  * ensure that no one changed the current state. With CI/CD or during development it is a really bad idea.
  *
  * There is no best option, some constraints like NOT NULL must be defined inline to count a column as NOT NULL.
  * With an additional added constraint, the column will be still marked as NULLABLE. Identity columns are another
  * issue, as you cannot define a name for the generated sequence. Make extra tests limited on the system generated
  * objects you rely on (like NOT NULL and identity).
  *
  * @param p_like_schema The LIKE expression for schema names. Default is current schema. % will generate for all schemas in the database, be careful.
  * @param p_required_user An optional comma separated list of users required to be checked by the schema test. Will not include the selected schemas. Useful for specific schemas and integration tests.
  * @param p_title_prefix An optional title prefix for set, group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  * @param p_excl_sysgen Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION schema_tests( p_like_schema   IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_required_user IN VARCHAR2 DEFAULT NULL
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       , p_excl_sysgen   IN INTEGER  DEFAULT otap_constants.OTAP_NUM_TRUE
                       )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.prepare
  * Maps the schema, object type and object to set, group and name, including the prefix, which prefixes the
  * set without delimiter and returns the function/procedure name for this mapping.
  *
  * If p_object_type is empty, p_object is not used at all and o_name is set to NULL. Only NOT NULL values included.
  *
  * The prefix gets cutted to max. 10 chars. Set, group and name are reduced to max. 30 chars. Delimiters are removed.
  *
  * @param p_title_prefix An optional title prefix. For function names cutted to 10 chars.
  * @param p_schema The schema to use for set. For function names cutted to 30 chars.
  * @param p_object_type The object type to use for group like tables, trigger and so on. For function names cutted to 30 chars.
  * @param p_object The object name to use for name. For function names cutted to 30 chars.
  * @param o_set The test set from schema and prefix. Limited to 256 chars.
  * @param o_group The test group from object type. Limited to 256 chars.
  * @param o_name The test name from object name. Limited to 256 chars.
  *
  * @return A valid function/procedure name of pattern test_(p_title_prefix)<o_set>(_<o_group>(_<o_name>)) with maximum length 128.
  */
  FUNCTION prepare( p_title_prefix IN             VARCHAR2
                  , p_schema       IN             VARCHAR2
                  , p_object_type  IN             VARCHAR2
                  , p_object       IN             VARCHAR2
                  , o_set             OUT NOCOPY  VARCHAR2
                  , o_group           OUT NOCOPY  VARCHAR2
                  , o_name            OUT NOCOPY  VARCHAR2
                  )
    RETURN VARCHAR2
  ;

  /** PROCEDURE otap_generate.prepare
  * Does the same as the function but does not return a function name.
  */
  PROCEDURE prepare( p_title_prefix IN             VARCHAR2
                   , p_schema       IN             VARCHAR2
                   , p_object_type  IN             VARCHAR2
                   , p_object       IN             VARCHAR2
                   , o_set             OUT NOCOPY  VARCHAR2
                   , o_group           OUT NOCOPY  VARCHAR2
                   , o_name            OUT NOCOPY  VARCHAR2
                   )
  ;
  -- utility functions
  PROCEDURE set_gen_type(p_gen_type IN VARCHAR2);
  FUNCTION get_gen_type
    RETURN VARCHAR2
  ;
  FUNCTION get_code_prefix
    RETURN VARCHAR2
  ;
  FUNCTION get_code_prefix_len
    RETURN NUMBER
  ;
  FUNCTION get_code_postfix
    RETURN VARCHAR2
  ;
  FUNCTION get_code_pad
    RETURN VARCHAR
  ;
  -- header
  FUNCTION build_script_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                              , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                              , p_object_type   IN VARCHAR2 DEFAULT NULL
                              , p_object        IN VARCHAR2 DEFAULT NULL
                              , p_scope         IN VARCHAR2 DEFAULT '%'
                              , p_script_count  IN NUMBER   DEFAULT 0
                              , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                              )
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION build_function_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                , p_object_type   IN VARCHAR2 DEFAULT NULL
                                , p_object        IN VARCHAR2 DEFAULT NULL
                                , p_scope         IN VARCHAR2 DEFAULT '%'
                                , p_script_count  IN NUMBER   DEFAULT 0
                                , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                                )
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION build_procedure_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                                 , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                                 , p_object_type   IN VARCHAR2 DEFAULT NULL
                                 , p_object        IN VARCHAR2 DEFAULT NULL
                                 , p_scope         IN VARCHAR2 DEFAULT '%'
                                 , p_script_count  IN NUMBER   DEFAULT 0
                                 , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                                 )
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION get_header( p_title_prefix  IN VARCHAR2 DEFAULT NULL
                     , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                     , p_object_type   IN VARCHAR2 DEFAULT NULL
                     , p_object        IN VARCHAR2 DEFAULT NULL
                     , p_scope         IN VARCHAR2 DEFAULT '%'
                     , p_script_count  IN NUMBER   DEFAULT 0
                     , p_show_header   IN NUMBER   DEFAULT otap_constants.OTAP_NUM_TRUE
                     )
    RETURN otap_view_result_tbl PIPELINED
  ;
  -- footer
  FUNCTION build_script_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION build_function_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION build_procedure_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  ;
  FUNCTION get_footer(p_show_header IN NUMBER DEFAULT otap_constants.OTAP_NUM_TRUE)
    RETURN otap_view_result_tbl PIPELINED
  ;
  -- development helper
  -- determines if a column of a system table or view is NULLABLE, checks the values
  -- and determines the NVL to use for compares on the column. Provides the column
  -- name or the expression for the column name, e.g. table_name or NVL(table_name, 'n/a').
  -- owner of given table is always SYS. Message type is either NVL (0) or variable declaration (1).
  FUNCTION get_dba_col_details( p_table_name  IN VARCHAR2
                              , p_column_name IN VARCHAR2
                              , p_msg_type    IN NUMBER   DEFAULT 0
                              )
    RETURN VARCHAR2
  ;

END;
/

