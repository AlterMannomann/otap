# Package otap_test
Description of the test options available with package otap_test. For a detailed description see [package header](otap_test.pks).

- [init_test](#function-otap_testinit_test)
- [finish_test](#function-otap_testfinish_test)
- [finish_test_with_exit_code](#function-otap_testfinish_test_with_exit_code)
- [has_table](#function-otap_testhas_table)
- [has_column](#function-otap_testhas_column)
- [has_package](#function-otap_testhas_package)
- [has_procedure](#function-otap_schemahas_procedure)
- [has_trigger](#function-otap_testhas_trigger)
- [has_object](#function-otap_schemahas_object)
- [has_constraint](#function-otap_testhas_constraint)
- [has_ref_constraint](#function-otap_testhas_ref_constraint)
- [has_not_null_constraint](#function-otap_testhas_not_null_constraint)
- [has_index](#function-otap_testhas_index)
- [has_type](#function-otap_testhas_type)
- [has_sequence](#function-otap_testhas_sequence)
- [has_scheduler_job](#function-otap_testhas_scheduler_job)
- [has_user](#function-otap_testhas_user)
- [ok](#function-otap_testok)
- [is_eq](#function-otap_testis_eq)
- [match_regex](#function-otap_testmatch_regex)
- [alike](#function-otap_testalike)
- [current_summary](#function-otap_testcurrent_summary)
- [set_test_name](#function-otap_testset_test_name)
- [set_test_group](#function-otap_testset_test_group)
- [set_test_set](#function-otap_testset_test_set)
- [get_session_id](#function-otap_testget_session_id)
- [get_report_id](#function-otap_testget_report_id)
- [generate functionality](#generate-functionality)
  - [generate_set_type](#procedure-otap_testgenerate_set_type)
  - [generate_type](#function-otap_testgenerate_type)
  - [generate_schema_tests](#function-otap_testgenerate_schema_tests)
  - [generate_table_tests](#function-otap_testgenerate_table_tests)
  - [generate_column_tests](#function-otap_testgenerate_column_tests)
  - [generate_trigger_tests](#function-otap_testgenerate_trigger_tests)
  - [generate_package_tests](#function-otap_testgenerate_package_tests)
  - [generate_procedure_tests](#function-otap_testgenerate_procedure_tests)
- [disclaimer and AI disclosure](#disclaimer)
- [Back to main](../../README.md)

## FUNCTION otap_test.init_test
This function is at some points equal to pgTap plan. As plan is a reserved name in Oracle, even calling a package function plan lead to errors. The name init would have been sufficient, but to avoid Oracle naming conflicts pgTap plan equivalent in otap is init_test.

This function is optional. If you do not execute this, the default settings will be used. Ensure proper naming of your test functions and preocedures to make it work as desired without initialization.

Function will set internal package variables for the duration of the session. If you open a different test session (without changing the database session), make sure that you run finish_test or init_test before, if needed.

Main functionality is setting the amount of tests to expect. If greater than 0 this will include a test report section containing differences in tests expected and tests executed.

Parameter:
- *p_test_count* The amount of tests expected to be executed when called.
- *p_test_set* The name of the test set applied if the name of the executed test procedure or function does not provide a test set name or name precendence is disabled.
- *p_test_group* The name of the test group applied if the name of the executed test procedure or function does not provide a test group name or name precendence is disabled.
- *p_test_name* The name of the test name applied if the name of the executed test procedure or function does not provide a test name or name precendence is disabled.
- *p_prefix* The prefix to use for identifying test functions and procedures. Limited to 4 chars. Test functions and procedures must have a trailing delimiter _ after the prefix to be identified.
- *p_name_precedence* Can disable the naming conventions for otap. If set to otap_constants.OTAP_NUM_FALSE, all tests will run under the defined test set and group, set by init_test.
- *p_include_pkg* Can enable to search also packages and package procedures and functions that fit the naming convention with the given prefix, if set to otap_constants.OTAP_NUM_TRUE. **Currently not implemented**
- *p_persist* Can enable to persist the test results longer than the current default of PRESERVE_DAYS in OTAP_CONFIG, if set to otap_constants.OTAP_NUM_TRUE.

*Return* Current session settings LF delimited.

Examples:

    -- simple init, do not check test count
    SELECT otap.otap_test.init FROM dual;
    -- simple init, expect 20 tests to run
    SELECT otap.otap_test.init(20) FROM dual;
    -- typical options
    SELECT otap.otap_test.init( p_test_count => 20
                              , p_test_set => 'My next test set'
                              , p_test_group => 'My next test group'
                              , p_test_name => 'My next test name'
                              , p_persist => otap.otap_constants.get_otap_num_true
                              ) FROM dual;

## FUNCTION otap_test.finish_test
Resets the OTAP_SESSION object. Will set a new session id, reset the counters and the names for test set, group and name. When a test session is finished, the result is available with view OTAP_LATEST_RESULTS_V. If intended count is set, a test record about executed and expected tests is written. This test record is not included in the count test compare.

Parameter:
- *p_write_count_rec* The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE (1) or otap_constants.OTAP_NUM_FALSE (0). Default is otap_constants.OTAP_NUM_TRUE. Setting has no effect if intented count is not set or 0.

*Return* A summary of the old session and details of the new session as text message LF delimited.

*Exception* -20099 Internal error, invalid OTAP_SESSION object.

Examples:

    -- simple and default finish
    SELECT otap.otap_test.finish_test FROM dual;
    -- overwrite count setting, do not create test count
    SELECT otap.otap_test.finish_test(otap_constants.get_otap_num_false) FROM dual;

## FUNCTION otap_test.finish_test_with_exit_code
This function is for automation purposes. It translates and returns an exit code that can be uses in CMD and shell scripts
to handle reactions based on the output of a test session, e.g. if test is passed you don't need probably the test report. Or you want
your build to fail, if test is not passed.

Equal to finish_test apart from the return value check and translation. Undefined overrules failed. If undefined is returned, also
failed tests may be contained in the current test report. If you finish a test session without any test run, the result is UNDEFINED.

Parameter:
- *p_write_count_rec* The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE. Setting has no effect if intented count is not set or 0.

*Return* A positive integer as result. 0 = success, all tests passed. 1 = at least one test failed. 2 = at least one test undefined.

*Exception* -20099 Internal error, invalid OTAP_SESSION object.

Examples:

    -- example using finish code in scripts
    COLUMN EXIT_CODE NEW_VAL EXIT_CODE
    SELECT otap.otap_test.finish_test_with_exit_code AS EXIT_CODE FROM dual;
    EXIT &EXIT_CODE
    -- example using finish code in functions
    CREATE OR REPLACE test_my_testing
      RETURN NUMBER
    IS
      l_return NUMBER;
    BEGIN
      -- do init and some tests
      l_return := otap.otap_test.finish_test_with_exit_code;
      -- persist report id or reports if needed
      RETURN l_return;
    END IF;

## FUNCTION otap_test.has_table
Tests if a table exists or not and outputs the test result. Wrapper for otap_api.has_table. Writes and adds the test result for the current active test session.

Parameter:
- *p_table_name* The table name of the table, taken as is. If not case sensitive you must provide the table name in UPPERCASE.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).

*Return* The test result as text.

Examples:

    -- simple table check assuming executed while your test schema is active
    SELECT otap.otap_test.has_table('MY_TABLE') FROM dual;
    -- all parameters
    SELECT otap.otap_test.has_table( p_table_name => 'MY_TABLE'
                                   , p_schema => 'MY_SCHEMA'
                                   , p_description => 'Testing MY_TABLE'
                                   , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                   ) FROM dual;

## FUNCTION otap_test.has_column
Tests if a table column exists. Additional tests on the column can be added by using the additional parameters with default NULL. The expected values have to match the content of DBA_TAB_COLUMNS for the given table, column and schema.

If checking defaults, it is limited to defaults not longer than 4000 char, using the DATA_DEFAULT_VC column. Expressions must match all chars in the default, like quotation. Use q-syntax where possible to define correct strings, e.g. *SELECT q'[SYS_CONTEXT('USERENV', 'OS_USER')]' FROM dual;*

Parameter:
- *p_table_name* The name of the table, taken as is. Case sensitive.
- *p_column_name* The column name of the table, taken as is. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and column must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_data_type* Optional check the datatype of the column. Ignored if NULL. NOT case sensitive.
- *p_data_length* Optional check the data length of the column. Ignored if NULL.
- *p_data_precision* Optional check the data precision of the column. Ignored if NULL. Results in test error if datatype is not NUMBER.
- *p_data_scale* Optional check the data scale of the column. Ignored if NULL. Results in test error if datatype is not NUMBER or TIMESTAMP.
- *p_nullable* Optional check if the column is nullable. Value as defined in USER_TAB_COLUMNS, 'Y' or 'N'. Ignored if NULL. NOT case sensitive.
- *p_data_default* Optional check the default for the column. Ignored if NULL. Must match all chars, including ' and ". Limited to defaults shorter than 4000 chars.
- *p_expected_result* The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).

*Return* The test result as text.

Examples:

    -- simple column check assuming executed while your test schema is active
    SELECT otap.otap_test.has_column('MY_TABLE', 'MY_COLUMN') FROM dual;
    -- all parameters
    SELECT otap.otap_test.has_column( p_table_name => 'MY_TABLE'
                                    , p_column_name => 'MY_COLUMN'
                                    , p_schema => 'MY_SCHEMA'
                                    , p_description => 'Testing MY_TABLE column'
                                    , p_data_type => 'NUMBER'
                                    , p_data_length => 22
                                    , p_data_precision => 1
                                    , p_data_scale => 0
                                    , p_nullable => 'Y'
                                    , p_data_default => '0'
                                    , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                    ) FROM dual;

## FUNCTION otap_test.has_package
Checks if a given package exists. Check if header and body, if available, are valid by default.

Parameter:
- *p_package_name* The name of the package, take as is. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the package must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_package_type* The object type of the package. PACKAGE or PACKAGE BODY. Not case sensitive. Invalid values cause test result undefined.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple package check assuming executed while your test schema is active
    SELECT otap.otap_test.has_package('MY_PACKAGE') FROM dual;
    -- all parameters
    SELECT otap.otap_test.has_package( p_package_name => 'MY_PACKAGE'
                                     , p_schema => 'MY_SCHEMA'
                                     , p_description => 'MY_PACKAGE test'
                                     , p_package_type => 'PACKAGE BODY'
                                     , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                     ) FROM dual;

## FUNCTION otap_schema.has_procedure
Checks if a given procedure or function exists. If package is given, the package procedure or function is checked.

Parameter:
- *p_procedure_name* The name of the procedure or function, take as is. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_procedure_type* Procedure type, mandatory. Either FUNCTION (default) or PROCEDURE. Not case sensitive. Invalid values cause test result undefined.
- *p_package_name* Either NULL (normal functions and procedures) or a package name for package functions and procedures. Case sensitive.
- *p_return_type* Either NULL (procedures) or the return data type of a function. Not case sensitive.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple function check assuming executed while your test schema is active
    SELECT otap.otap_test.has_procedure('MY_FUNCTION') FROM dual;
    -- all parameters
    SELECT otap.otap_test.has_procedure( p_procedure_name => 'MY_FUNCTION'
                                       , p_schema => 'MY_SCHEMA'
                                       , p_description => 'My description'
                                       , p_procedure_type => 'FUNCTION'
                                       , p_package_name => 'MY_PACKAGE'
                                       , p_return_type => 'NUMBER'
                                       , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                       ) FROM dual;

## FUNCTION otap_test.has_trigger
Checks if a given trigger exists.

Parameter:
- *p_trigger_name* The name of the trigger, take as is. Case sensitive.
- *p_schema* The schema to use. If NULL current schema is used. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_trigger_type* The trigger type as in USER_TRIGGERS. Optional. Not case sensitive. Invalid values cause test failed.
- *p_trigger_event* The triggering event as in USER_TRIGGERS. Optional. Not case sensitive.
- *p_table_owner* The table owner as in USER_TRIGGERS. Optional. Case sensitive.
- *p_table_name* The table name as in USER_TRIGGERS. Optional. Case sensitive.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple trigger check assuming executed while your test schema is active
    SELECT otap.otap_test.has_trigger('MY_INSERT_TRIGGER') FROM dual;
    -- all parameters
    SELECT otap.otap_test.has_trigger( p_trigger_name => 'MY_INSERT_TRIGGER'
                                     , p_schema => 'MY_SCHEMA'
                                     , p_description => 'My description'
                                     , p_trigger_type => 'BEFORE EACH ROW'
                                     , p_trigger_event => 'INSERT'
                                     , p_table_owner => 'MY_SCHEMA'
                                     , p_table_name => 'MY_TABLE'
                                     , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                     ) FROM dual;

## FUNCTION otap_schema.has_object
Checks if a given database object exists.

Parameter:
- *p_object_name* The name of the object, take as is. Case sensitive.
- *p_object_type* The object type of the given object. Mandatory. Object must be unique identifiable, otherwise test will result in undefined. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple object check assuming executed while your test schema is active
    SELECT otap.otap_test.has_object('MY_TYPE') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_object( p_object_name => 'MY_TYPE'
                                    , p_object_type => 'TYPE'
                                    , p_schema => 'MY_SCHEMA'
                                    , p_description => 'My description'
                                    , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                    ) FROM dual;

## FUNCTION otap_test.has_constraint
Checks if a given table has a constraint of the given type. Optional you can specify column and constraint name.

Supported constraint types:
- **C** - Check constraint on a table
- **P** - Primary key
- **U** - Unique key
- **R** - Referential integrity - use has_ref_constraint for more options
- **V** - With check option, on a view
- **O** - With read only, on a view
- **H** - Hash expression
- **F** - Constraint that involves a REF column - use has_ref_constraint for more options
- *S* is not supported, could not find or create an example to examine. SUPPLEMENTAL LOG clause only reflects in CDEF$ and CCOL$.

Parameter:
- *p_table_name* Mandatory. The table to be checked for constraint, take as is. Case sensitive. Missing value will cause test to fail.
- *p_constraint_type* Mandatory. A valid constraint type. Not case sensitive. Wrong values will cause the test to fail.
- *p_column_name* Optional. The column that is part of the constraint. Case sensitive.
- *p_constraint* Optional. The name of the constraint. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_constraint('MY_TABLE', 'P') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_constraint( p_table_name => 'MY_TABLE'
                                        , p_constraint_type => 'P'
                                        , p_column_name => 'MY_PK_COLUMN'
                                        , p_constraint => 'MY_TABLE_PK'
                                        , p_schema => 'MY_SCHEMA'
                                        , p_description => 'My description'
                                        , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                        ) FROM dual;

## FUNCTION otap_test.has_ref_constraint
Checks if a given table has a reference constraint. You may also use has_constraint. But if you want to check the referenced owner, constraint, column and table, you have to use this function.

Parameter:
- *p_table_name* Mandatory. The table to be checked for the reference constraint, take as is. Case sensitive.
- *p_constraint_type* Mandatory. A valid ref constraint type. Not case sensitive. Only 'R' and 'F' allowed, 'R' on invalid or empty values.
- *p_column_name* Optional. The column that is part of the reference constraint. Case sensitive.
- *p_constraint* Optional. The name of the reference constraint. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_r_table_name* Optional. The referenced table of the reference constraint, take as is. Case sensitive.
- *p_r_column_name* Optional. The referenced column that is part of the reference constraint. Case sensitive.
- *p_r_constraint* Optional. The name of the referenced constraint by the reference constraint. Case sensitive.
- *p_r_schema* Optional. The reference schema of the constraint. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_ref_constraint('MY_TABLE', 'R') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_ref_constraint( p_table_name => 'MY_TABLE'
                                            , p_constraint_type => 'R'
                                            , p_column_name => 'MY_FK_COLUMN'
                                            , p_constraint => 'MY_TABLE_FK'
                                            , p_schema => 'MY_SCHEMA'
                                            , p_r_table_name => 'MY_OTHER_TABLE'
                                            , p_r_column_name => 'MY_ID_COLUMN'
                                            , p_r_constraint => 'MY_OTHER_TABLE_PK'
                                            , p_r_schema => 'MY_SCHEMA'
                                            , p_description => 'My description'
                                            , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                            ) FROM dual;

## FUNCTION otap_test.has_not_null_constraint
Checks if a given table column has a not null check constraint. Optional you can specify the constraint name. NOT NULL constraint is somewhat special as it is recommended for inline creation, which generates system constraint names. You are also free to create it outbound. Therefore in most cases the constraint name is not defined or may change on recreation. Also NULLABLE may not reflect an existing outbound NOT NULL constraint. This function checks also the definition, which has the generated format: "COLUMN_NAME" IS NOT NULL. Any outbund declaration will probably look different. Therefore the term "IS NOT NULL" and the column name is searched after UPPER conversion of SEARCH_CONDITION_VC. Will not work for search conditions > 4000 char.

Parameter:
- *p_table_name* Mandatory. The table to be checked for NOT NULL constraint, take as is. Case sensitive. Missing value will cause test to fail.
- *p_column_name* Mandator. The column that is checked for the NOT NULL constraint. Case sensitive.
- *p_constraint* Optional. The name of the constraint. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_not_null_constraint('MY_TABLE', 'MY_COLUMN') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_not_null_constraint( p_table_name => 'MY_TABLE'
                                                 , p_column_name => 'MY_COLUMN'
                                                 , p_constraint => 'MY_NOT_NULL_CONSTRAINT'
                                                 , p_schema => 'MY_SCHEMA'
                                                 , p_description => 'My description'
                                                 , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                                 ) FROM dual;

## FUNCTION otap_test.has_index
Checks if a given index exists. You may specify table name or index name. Both values NULL will lead to test failed.

Parameter:
- *p_table_name* Mandatory if index name is NULL. The table name of the table that owns the index.
- *p_column_name* Optional. The column name used in the index. Case sensitive.
- *p_index_name* Mandatory if table name is NULL. The index name to check. Case sensitive.
- *p_index_type* Optional. The index type of the index to check. Not case sensitive.
- *p_table_type* Optional. The table type of the index to check. Not case sensitive.
- *p_uniqueness* Optional. The uniqueness of the index to check. Not case sensitive.
- *p_tablespace_name* Optional. The tablespace name used by the index to check. Case sensitive.
- *p_partitioned* Optional. The partitioned state of the index to check. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_index('MY_TABLE', 'MY_COLUMN', 'MY_INDEX') FROM dual;
    SELECT otap.otap_test.has_index(NULL, NULL, 'MY_INDEX') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_index( p_table_name => 'MY_TABLE'
                                   , p_column_name => 'MY_COLUMN'
                                   , p_index_name => 'MY_TABLE_PK'
                                   , p_index_type => 'NORMAL'
                                   , p_table_type => 'TABLE'
                                   , p_uniqueness => 'UNIQUE'
                                   , p_tablespace_name => 'MY_TABLESPACE'
                                   , p_partitioned => 'NO'
                                   , p_schema => 'MY_SCHEMA'
                                   , p_description => 'My description'
                                   , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                   ) FROM dual;

## FUNCTION otap_test.has_type
Checks if a given type exists. The type code (e.g. OBJECT, COLLECTION) is shown as sub object in the exist message.

Parameter:
- *p_type_name* Mandatory. The name of the type to check. Case sensitive.
- *p_typecode* Optional. The typecode like OBJECT of the type to check. Not case sensitive.
- *p_attributes* Optional. The number of type attributes to check.
- *p_methods* Optional. The number of type methods to check.
- *p_predefined* Optional. The predefined state of the type to check. Not case sensitive.
- *p_incomplete* Optional. The incomplete state of the type to check. Not case sensitive.
- *p_final* Optional. The final state of the type to check. Not case sensitive.
- *p_persistable* Optional. The persistable state of the type to check. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_type('MY_OBJECT') FROM dual;
    SELECT otap.otap_test.has_type('MY_OBJECT', 'OBJECT') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_type( p_type_name => 'MY_OBJECT'
                                  , p_typecode => 'OBJECT'
                                  , p_attributes => 5
                                  , p_methods => 2
                                  , p_predefined => 'NO'
                                  , p_incomplete => 'NO'
                                  , p_final => 'YES'
                                  , p_persistable => 'YES'
                                  , p_schema => 'MY_SCHEMA'
                                  , p_description => 'My description'
                                  , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                  ) FROM dual;

## FUNCTION otap_test.has_sequence
Checks if a given sequence exists. It can be identified either by the sequence name or the table and column name. If sequence name is NULL, table AND column name must be given to identify the sequence. In case the table owner differs from the sequence owner, the table owner can be specified. If not specified, the normal schema logic takes place.

Parameter:
- *p_sequence_name* Mandatory if not table and column name are given. The name of the sequence to check. Case sensitive.
- *p_table_name* Mandatory if sequence name is not given. The table name with the identity column that uses the sequence to check. Case sensitive.
- *p_column_name* Mandatory if sequence name is not given. The identity column name that uses the sequence to check. Case sensitive.
- *p_min_value* Optional. The minimum value attribute of the sequence to check.
- *p_max_value* Optional. The maximum value attribute of the sequence to check.
- *p_increment_by* Optional. The increment of the sequence to check.
- *p_cycle_flag* Optional. The cycle flag of the sequence to check. Not case sensitive.
- *p_order_flag* Optional. The order flag of the sequence to check. Not case sensitive.
- *p_cache_size* Optional. The cache size of the sequence to check.
- *p_scale_flag* Optional. The scale flag of the sequence to check. Not case sensitive.
- *p_extend_flag* Optional. The extend flag of the sequence to check. Not case sensitive.
- *p_sharded_flag* Optional. The sharded flag of the sequence to check. Not case sensitive.
- *p_session_flag* Optional. The session flag of the sequence to check. Not case sensitive.
- *p_keep_value* Optional. The keep value flag of the sequence to check. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_sequence('MY_SEQUENCE') FROM dual;
    SELECT otap.otap_test.has_sequence(NULL, 'MY_TABLE', 'MY_ID_COLUMN') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_sequence( p_sequence_name => 'MY_SEQUENCE'
                                      , p_table_name => 'MY_TABLE'
                                      , p_column_name => 'MY_ID_COLUMN'
                                      , p_min_value => 1
                                      , p_max_value => 9999999999999999999999999999
                                      , p_increment_by => 1
                                      , p_cycle_flag => 'Y'
                                      , p_order_flag => 'N'
                                      , p_cache_size => 0
                                      , p_scale_flag => 'N'
                                      , p_extend_flag => 'N'
                                      , p_sharded_flag => 'N'
                                      , p_session_flag => 'N'
                                      , p_keep_value => 'N'
                                      , p_table_owner => 'MY_TABLE_OWNER'
                                      , p_schema => 'MY_SCHEMA'
                                      , p_description => 'My description'
                                      , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                      ) FROM dual;


## FUNCTION otap_test.has_scheduler_job
Checks basically if a given scheduler job exists.

Parameter:
- *p_job_name* Mandatory. The name of the scheduler job to check. Case sensitive.
- *p_job_style* Optional. The job style of the scheduler job to check. Not case sensitive.
- *p_job_type* Optional. The job type of the scheduler job to check. Not case sensitive.
- *p_job_action* Optional. The job action of the scheduler job to check. Compares code with UPPER and flatten. Not case sensitive.
- *p_schedule_type* Optional. The schedule type of the scheduler job to check. Not case sensitive.
- *p_repeat_interval* Optional. The repeat interval of the scheduler job to check. Not case sensitive.
- *p_job_class* Optional. The job class of the scheduler job to check. Not case sensitive.
- *p_logging_level* Optional. The logging level indicator of the scheduler job to check. Not case sensitive.
- *p_store_output* Optional. The store output indicator of the scheduler job to check. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table and constraint must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_scheduler_job('MY_SCHEDULER_JOB') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_scheduler_job( p_job_name => 'MY_SCHEDULER_JOB'
                                           , p_job_style => 'REGULAR'
                                           , p_job_type => 'PLSQL_BLOCK'
                                           , p_job_action => 'start_my_job;'
                                           , p_schedule_type => 'CALENDAR'
                                           , p_repeat_interval => 'FREQ=WEEKLY;BYTIME=230000;BYDAY=MON,TUE,WED,THU,FRI'
                                           , p_job_class => 'DEFAULT_JOB_CLASS'
                                           , p_logging_level => 'FULL'
                                           , p_store_output => 'TRUE'
                                           , p_schema => 'MY_SCHEMA'
                                           , p_description => 'My description'
                                           , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                           ) FROM dual;

## FUNCTION otap_test.has_user
Checks basically if a given user exists.

Parameter:
- *p_username* Mandatory. The name of the database user to check. Case sensitive.
- *p_account_status* Optional. The account status of the database user to check. Not case sensitive.
- *p_default_tablespace* Optional. The default tablespace of the database user to check. Case sensitive.
- *p_temporary_tablespace* Optional. The temporary tablespace of the database user to check. Case sensitive.
- *p_local_temp_tablespace* Optional. The local temporary tablespace of the database user to check. Case sensitive.
- *p_profile* Optional. The profile setting of the database user to check. Not case sensitive.
- *p_password_versions* Optional. The password versions if any defined of the database user to check. Case sensitive.
- *p_authentication_type* Optional. The authentication type of the database user to check. Not case sensitive.
- *p_proxy_only_connect* Optional. The proxy only connect indicator of the database user to check. Not case sensitive.
- *p_protected* Optional. The protected state indicator of the database user to check. Not case sensitive.
- *p_read_only* Optional. The read only state indicator of the database user to check. Not case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple primary key check assuming executed while your test schema is active
    SELECT otap.otap_test.has_user('MY_USER') FROM dual;
    -- all parameter
    SELECT otap.otap_test.has_user( p_username => 'MY_USER'
                                  , p_account_status => 'OPEN'
                                  , p_default_tablespace => 'MY_TABLESPACE'
                                  , p_temporary_tablespace => 'TEMP'
                                  , p_local_temp_tablespace => 'TEMP'
                                  , p_profile => 'DEFAULT'
                                  , p_password_versions => '11G 12C'
                                  , p_authentication_type => 'PASSWORD'
                                  , p_proxy_only_connect => 'N'
                                  , p_protected => 'NO'
                                  , p_read_only => 'NO'
                                  , p_description => 'My description'
                                  , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                                  ) FROM dual;

## FUNCTION otap_test.ok
Checks if a boolean expression result is TRUE. To test for FALSE just set expected result to otap_constants.OTAP_NUM_TEST_FAILED. It is recommended to use a description as generated text does not contain details on the the test condition.

Parameter:
- *p_boolean* The result of a boolean expression to check.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple ok check, you don't need in all cases the () construct but I recommend to use it for an expression
    SELECT otap.otap_test.ok((2 = 2)) FROM dual;
    SELECT otap.otap_test.ok((1 = 2), 'My not working test') FROM dual;
    -- all parameter
    SELECT otap.otap_test.ok( p_boolean => (1 = 2)
                            , p_description => 'My NOW working test'
                            , p_expected_result => otap.otap_constants.get_otap_num_test_failed
                            ) FROM dual;

## FUNCTION otap_test.is_eq
Checks given data of type VARCHAR2, NUMBER and DATE against a given value. As "IS" is a reserved word in Oracle this is the equivalent of is and isnt. isnt is achieved by setting expected result to otap_constants.OTAP_NUM_TEST_FAILED.

Other types are more or less problematic, e.g. you can't declare in Oracle a function with date and timestamp parameter. If providing TIMESTAMP Oracle gets confused which function to use. Try to convert or cast the types to the base types. CAST will probably not preserve all information. TO_CHAR is almost always an option.

Passing simply NULL, NULL without that datatypes are defined by columns, the function will fail with ORA-06553: Too much declarations of is_eq. To do a NULL test, use, according to p_have datatype, **TO_CHAR(NULL)**, **TO_NUMBER(NULL)** or **TO_DATE(NULL)** so correct function signature is identified and function does not fail.

Parameter:
- *p_have* The data to check.
- *p_want* The expected data. Must have the same datatype as p_have.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple equal checks
    SELECT otap.otap_test.is_eq('test', 'test') FROM dual;
    SELECT otap.otap_test.is_eq(10, 10) FROM dual;
    SELECT otap.otap_test.is_eq(SYSDATE, SYSDATE) FROM dual;
    SELECT otap.otap_test.is_eq(NULL, TO_CHAR(NULL)) FROM dual;
    SELECT otap.otap_test.is_eq(NULL, TO_NUMBER(NULL)) FROM dual;
    SELECT otap.otap_test.is_eq(NULL, TO_DATE(NULL)) FROM dual;
    -- not equal check passing
    SELECT otap.otap_test.is_eq( p_have => 'test'
                               , p_want => 'xxx'
                               , p_expected_result => otap.otap_constants.get_otap_num_test_failed
                               ) FROM dual;
    -- you can use this for table data to be checked
    SELECT otap.otap_test.is_eq( p_have => my_char_column
                               , p_want => 'Expected value'
                               , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                               ) FROM my_table WHERE id = 1;
    SELECT otap.otap_test.is_eq( p_have => my_number_column
                               , p_want => 10
                               , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                               ) FROM my_table WHERE id = 1;
    SELECT otap.otap_test.is_eq( p_have => my_date_column
                               , p_want => TO_DATE('01.01.1984', 'DD.MM.YYYY')
                               , p_expected_result => otap.otap_constants.get_otap_num_test_passed
                               ) FROM my_table WHERE id = 1;

## FUNCTION otap_test.match_regex
Checks given data of type VARCHAR2 against an Oracle REGEX expression. Uses REGEXP_LIKE. **ATTENTION** Oracle REGEX implementation is not standard. Unix regex which work like charm take hours to implement in Oracle REGEX to work as desired. Test your expression well with Oracle before using it. As MATCHES is a reserved word this is the equivalent of matches, imatches, doesnt_match and doesnt_imatch.

Should result in 1 if successful checked. You may want to prepare a with block with different string to pass them through the regular expression.

Parameter:
- *p_have* The data to check.
- *p_regex* A valid Oracle regular expression that p_have must match.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_param* Parameter for REGEXP_LIKE. 'i' is case insensitive. See Oracle documentation for details, https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/Pattern-matching-Conditions.html#GUID-D2124F3A-C6E4-4CCA-A40E-2FFCABFD8E19.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple regex check, only AGCD in any combination and length allowed
    SELECT otap.otap_test.match_regex('AGCC', '^[ACGD]*$') FROM dual;
    -- case insensitive
    SELECT otap.otap_test.match_regex('acggacccdaad', '^[ACGD]*$', NULL, 'i') FROM dual;

## FUNCTION otap_test.alike
Checks given data of type VARCHAR2 against an Oracle LIKE expression. LIKE is currently more reliable and easier to use than Oracle REGEX implementation. But also much more limited. This is the equivalent of alike, ialike, unalike, inialike.

Parameter:
- *p_have* The data to check.
- *p_like* A valid Oracle like expression that p_have must match.
- *p_case_sensitive* Optional defines that the compared result is handled as case sensitive, if set to otap_constants.OTAP_NUM_TRUE.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.

Examples:

    -- simple LIKE check, must start with MY
    SELECT otap.otap_test.alike('MY_TABLE', 'MY%') FROM dual;

## FUNCTION otap_test.current_summary
Returns a string with a current summary of the test session. Session id, run time, tests executed and test in error.

*Return* An info message about the current package session variables.
## FUNCTION otap_test.set_test_name
Handles and sets the current active test name. If test name is longer than 256 chars it is cutted to 256 chars. If NULL is given, than otap_constants.OTAP_FALLBACK_DEFAULT_TEST_NAME is used. Only valid within one session, if session ends, test name is reset.

Test names are usually retrieved from the executed test function or procedure. Can be used to overwrite the group within a test function or procedure.

Parameter:
- *p_test_name* The test name to use for the next test.

*Return* The test name currently active as text message.
## FUNCTION otap_test.set_test_group
Handles and sets the current active test group. If test group name is longer than 256 chars it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_GROUP is used. Only valid within one session, if session ends, test name is reset.

Test group names are usually retrieved from the executed test function or procedure. Can be used to overwrite the group within a test function or procedure.

Parameter:
- *p_test_group* The test group name to use for the next tests.

*Return* The test group currently active as text message.
## FUNCTION otap_test.set_test_set
Handles and sets the current active test set. If test set name is longer than 256 chars it is cutted to 256 chars. If NULL is given than, otap_constants.OTAP_FALLBACK_DEFAULT_TEST_SET is used.

Test set names are usually retrieved from the executed test function or procedure. Can be used to overwrite the set within a test function or procedure.

Parameter:
- *p_test_set* The test set name to use for the next tests.

*Return* The test set currently active as text message.
## FUNCTION otap_test.get_session_id
Retrieves the current active test session id.

*Return* The current active test session id.
## FUNCTION otap_test.get_report_id
Retrieves the last view id from finsih or the current active test session id. Usually used in views.

*Return* The last view id or the current active test session id.
## Generate functionality
All generate functions only require the otap user role as they operate only on meta data. They run independent of test sessions. For the like parameter syntax the escape char is set to backslash "\".

### PROCEDURE otap_test.generate_set_type
Sets the generation type. Default is script (S). Options are procedure (P) or function (F). Fallback on errors is script. This setting is only valid within the current session.

- *p_gen_type* A valid generation type. See otap_constants.OTAP_GEN_TYPE_ variables.
### FUNCTION otap_test.generate_type
*Return* The current active generation type for the current session.
### FUNCTION otap_test.generate_schema_tests
Generates the test scripts for the current available otap schema functions using by default the current schema. Test set gets defined as schema, group represents the object types, like tables, triggers and so on. No translation provided. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Including system generated objects is a good idea if your system is stable and you want to ensure that no one changed the current state. With CI/CD or during development, when objects get recreated, it is a really bad idea. Excluded by default are objects beginning with SYS_ for system generated object or containing $ or # chars, which may occur anywhere in the name of system objects.

There is no best option, some constraints like NOT NULL must be defined inline to count a column as NOT NULL. With an additional added constraint, the column will be still marked as NULLABLE. Identity columns are another issue, as you cannot define a name for the generated sequence. Make extra tests limited on the system generated objects you rely on (like NOT NULL and identity).

- *p_like_schema* The LIKE expression for schema names. Default is current schema. % will generate for all schemas in the database, be careful Underlying objects are not limited. Case sensitive.
- *p_title_prefix* An optional title prefix for set, group and test names. Limited to 10 chars. Will be added without delimiter to the processed schema.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_table_tests
Generates the test scripts for the tables of the given schema with the current available otap schema functions. Provides set (schema), group (tables) and name (table name) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_like_table* The LIKE expression for tables names for the given schema. Default is %, all tables. Underlying objects like columns are not limited. Case sensitive.
- *p_schema* Mandatory. The schema to generate the table tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars. Will be added without delimiter to the test set created.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_column_tests
Generates the test scripts for the columns of a given table and schema with the current available otap schema functions. Provides set (schema), group (tables) and name (table name) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_table* Mandatory. The table name to get column tests for. Case sensitive.
- *p_like_column* The LIKE expression for column names for the given schema and table. Can also be a specific column name. Default is %, all columns. Underlying objects are not limited. Case sensitive.
- *p_schema* Mandatory. The schema to generate the column tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_trigger_tests
Generates the test scripts for the trigger of the given schema with the current available otap schema functions. Provides set (schema), group (triggers) and name (table trigger, non table trigger) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_like_trigger* The like expression for the trigger to generate tests for the given schema. Can also be a specific trigger name. Default is %, all trigger. Underlying objects are not limited. Case sensitive.
- *p_schema* The schema to generate the trigger tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_package_tests
Generates the test scripts for the packages of the given schema with the current available otap schema functions. Provides set (schema), group (package) and name (package function and procedures) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_like_package* The like expression for the package to generate tests for the given schema. Can also be a specific package name. Default is %, all packages. Underlying objects are not limited. Case sensitive.
- *p_schema* The schema to generate the package tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_, # or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_procedure_tests
Generates the test scripts for the procedures and functions, including packages. with the current available otap schema functions. Provides set (schema), group (procedures) and names (function, procedure, package type) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_like_procedure* The like expression for the procedure (function, procedure, package type) to generate tests for the given schema. Can also be a specific procedure name. Default is %, all procedures. Underlying objects are not limited. Case sensitive.
- *p_package_name* Optional. Package name for the functions and procedures. Case sensitive.
- *p_schema* The schema to generate the package tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
### FUNCTION otap_test.generate_view_tests
Generates the test scripts for the views of the given schema with the current available otap schema functions. Provides set (schema), group (views) and name (view name) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

- *p_like_view* The like expression for the views to generate tests for the given schema. Can also be a specific view name. Default is %, all views. Underlying objects are not limited. Case sensitive.
- *p_schema* The schema to generate the view tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.
- *p_excl_sysgen* Used to ignore system generated objects identified by SYS_ or $. Default 1 will ignore system generated objects, otherwise included.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

For further questions on copyleft and usage see [contact](CONTACT.md).

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
