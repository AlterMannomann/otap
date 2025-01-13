# otap_test
Description of the test options available with package otap_test.

- [init_test](#function-otap_testinit_test)
- [finish_test](#function-otap_testfinish_test)
- [finish_test_with_exit_code](#function-otap_testfinish_test_with_exit_code)
- [has_table](#function-otap_testhas_table)
- [has_column](#function-otap_testhas_column)
- [has_package](#function-otap_testhas_package)
- [has_procedure](#function-otap_schemahas_procedure)
- [has_trigger](#function-otap_testhas_trigger)
- [has_object](#function-otap_schemahas_object)
- [current_summary](#function-otap_testcurrent_summary)
- [set_test_name](#function-otap_testset_test_name)
- [set_test_group](#function-otap_testset_test_group)
- [set_test_set](#function-otap_testset_test_set)
- [get_session_id](#function-otap_testget_session_id)
- [get_report_id](#function-otap_testget_report_id)
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
## FUNCTION otap_test.finish_test
Resets the OTAP_SESSION object. Will set a new session id, reset the counters and the names for test set, group and name. When a test session is finished, the result is available with view OTAP_LATEST_RESULTS_V. If intended count is set, a test record about executed and expected tests is written. This test record is not included in the count test compare.

Does nothing if intented count is not set or 0.

Parameter:
- *p_write_count_rec* The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE (1) or otap_constants.OTAP_NUM_FALSE (0). Default is otap_constants.OTAP_NUM_TRUE.

*Return* A summary of the old session and details of the new session as text message LF delimited.

*Exception* -20099 Internal error, invalid OTAP_SESSION object.
## FUNCTION otap_test.finish_test_with_exit_code
This function is for automation purposes. It translates and returns an exit code that can be uses in CMD and shell scripts
to handle reactions based on the output of a test session, e.g. if test is passed you don't need probably the test report. Or you want
your build to fail, if test is not passed.

Equal to finish_test apart from the return value check and translation. Undefined overrules failed. If undefined is returned, also
failed tests may be contained in the current test report. If you finish a test session without any test run, the result is UNDEFINED.

Parameter:
- *p_write_count_rec* The indicator, if record count test should be done and written. Either otap_constants.OTAP_NUM_TRUE or otap_constants.OTAP_NUM_FALSE.

*Return* A positive integer as result. 0 = success, all tests passed. 1 = at least one test failed. 2 = at least one test undefined.

*Exception* -20099 Internal error, invalid OTAP_SESSION object.
## FUNCTION otap_test.has_table
Tests if a table exists or not and outputs the test result. Wrapper for otap_api.has_table. Writes and adds the test result for the current active test session.

Parameter:
- *p_table_name* The table name of the table, taken as is. If not case sensitive you must provide the table name in UPPERCASE.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the table must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_expected_result* The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).

*Return* The test result as text.
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
- *p_nullable* Optional check if the column is nullable. Ignored if NULL. NOT case sensitive.
- *p_data_default* Optional check the default for the column. Ignored if NULL. Must match all chars, including ' and ". Limited to defaults shorter than 4000 chars.
- *p_expected_result* The expected test result, 1 (Passed), -1 (FAILED), 0 (UNDEFINED). Default is 1 (Passed).

*Return* The test result as text.
## FUNCTION otap_test.has_package
Checks if a given package exists. Check if header and body, if available, are valid by default.

Parameter:
- *p_package_name* The name of the package, take as is. Case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the package must exist in this schema. Case sensitive.
- *p_description* The test description if any. If not given, a description is generated, see template.
- *p_package_type* The object type of the package. PACKAGE or PACKAGE BODY. Not case sensitive. Invalid values cause test result undefined.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.
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
## FUNCTION otap_schema.has_object
Checks if a given database object exists.

Parameter:
- *p_object_name* The name of the object, take as is. Case sensitive.
- *p_object_type* The object type of the given object. Mandatory. Object must be unique identifiable, otherwise test will result in undefined. Not case sensitive.
- *p_schema* A schema override of the current test session if needed, taken as is. If given the procedure or function must exist in this schema. Case sensitive.
- *p_expected_result* The expected test result as number. Default is test passed. See otap_constants.

*Return* The test result as text.
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
## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

For further questions on copyleft and usage see [contact](CONTACT.md).

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
