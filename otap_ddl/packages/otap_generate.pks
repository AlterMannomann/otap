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
  * @param p_like_column The like experession for the columns to generate tests for. Can also be a specific column name. Case sensitive.
  * @param p_schema The schema to generate the column tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_excl_default Exclude system generated content in data_default. This objects tend to be unstable over updates. To inlude them, set the parameter to NULL or any default content string that disables test on default.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION column_tests( p_table         IN VARCHAR2
                       , p_like_column   IN VARCHAR2 DEFAULT '%'
                       , p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_excl_default  IN VARCHAR2 DEFAULT '$'
                       , p_show_header   IN INTEGER  DEFAULT 1
                       )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.table_tests
  * Generates the test scripts for the tables of the given schema with the current available
  * otap schema functions. Provides group (tables) and name (table name) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_schema The schema to generate the table tests for. Default is current schema.
  * @param p_like_table The like experession for the tables to generate tests for. Can also be a specific table name. Case sensitive.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION table_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                      , p_like_table    IN VARCHAR2 DEFAULT '%'
                      , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                      , p_show_header   IN INTEGER  DEFAULT 1
                      )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.trigger_tests
  * Generates the test scripts for the trigger of the given schema with the current available
  * otap schema functions. Provides group (trigger) and name (table trigger, non table trigger) management.
  * Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_schema The schema to generate the trigger tests for. Default is current schema.
  * @param p_like_trigger The like experession for the trigger to generate tests for. Can also be a specific trigger name. Case sensitive.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION trigger_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_like_trigger  IN VARCHAR2 DEFAULT '%'
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT 1
                        )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.pkg_procedures
  * Generates the test scripts for the package procedures and functions of the given package with the current available
  * otap schema functions. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how
  * you spool the content to files.
  *
  * @param p_package_name Mandatory. Package name for tests on the functions and procedures. Case sensitive.
  * @param p_like_procedure The like experession for the package function or procedure to generate tests for. Can also be a specific function or procedure name. Case sensitive.
  * @param p_schema The schema to generate the package tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION pkg_procedures( p_package_name   IN VARCHAR
                         , p_like_procedure IN VARCHAR2 DEFAULT '%'
                         , p_schema         IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                         , p_title_prefix   IN VARCHAR2 DEFAULT NULL
                         , p_show_header    IN INTEGER  DEFAULT 1
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
  * @param p_like_trigger The like experession for the packages to generate tests for. Can also be a specific package name. Case sensitive.
  * @param p_title_prefix An optional title prefix for group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION package_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                        , p_like_package  IN VARCHAR2 DEFAULT '%'
                        , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                        , p_show_header   IN INTEGER  DEFAULT 1
                        )
    RETURN otap_view_result_tbl PIPELINED
  ;

  /** FUNCTION otap_generate.schema_tests
  * Generates the test scripts for the current available otap schema functions.
  * Provides set, group and name management.  Limited to line size 4000 but not to rows,
  * like DBMS_OUTPUT. It is up to you how you spool the content to files.
  *
  * @param p_schema The schema to generate the tests for. Default is current schema.
  * @param p_title_prefix An optional title prefix for set, group and test names. Limited to 10 chars.
  * @param p_show_header Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
  *
  * @return An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
  */
  FUNCTION schema_tests( p_schema        IN VARCHAR2 DEFAULT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA')
                       , p_title_prefix  IN VARCHAR2 DEFAULT NULL
                       , p_show_header   IN INTEGER  DEFAULT 1
                       )
    RETURN otap_view_result_tbl PIPELINED
  ;

END;
/
