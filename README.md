![OtapLogo](https://github.com/user-attachments/assets/b2ffe1ea-b139-43bd-a204-79bed632aa52)
# UNDER CONSTRUCTION
Recommended to fully reinstall otap schema after updates. Currently only update support for DBA install.
### Current changes
- Add new schema test functions
- Moved generate access to otap_test.
- Fixed LIKE issue in generate, LIKE option only valid for the base objects, depending objects like columns and functions are not limited by given LIKE option.
- otap can now grant the otap user role to others
### Next steps
- Provide generate options PROCEDURE and FUNCTION which can be stored, used and automatically run from a testing schema
- Extend otap_generate, include new functions
- Extend otap_schema (has_type, is_object_valid ...)
- Enhance documentation
- Integrate schema setup into dba setup for one step installation
### Current state
Pre-alpha, basically stable with following tests (package otap_test):
- search conditions for schema functions still lack in different cases, fix is in work
- has_table
- has_column
- has_package
- has_procedure
- has_trigger
- has_object
- has_constraint
- has_ref_constraint
- has_not_null_constraint
- ok (boolean compare check)
- is_eq (VARCHAR2, NUMBER and DATE compare check including NULL checks, see [documentation](./otap_ddl/packages/otap_test.md))
- match_regex (regular expression check on strings)
- match_like (LIKE expression check on strings)
- result view: otap_latest_test_results_v

Every function supports different optional parameters (not complete in sense of available object options) to narrow the exist check. If exist check fails this does not necessarily mean the object does not exist at all. It just doesn't exist in the specified way for the test. Exist function do not check for the reason currently. Every test has to pass two steps, the test it self and no errors by wrong usage or internal problems. Result shows the test result itself in the report, Setup shows any errors either caused by usage or otap itself.

Test results have THREE states: Passed, Failed and UNDEFINED.

otap tries to be fail safe as much as possible. UNDEFINED is used for any state otap discovered, either by usage error, like NULL for mandatory values, or internal errors where otap does not behave as expected. otap can not avoid all exceptions, but reduce them to not fail a test run, if it is run automatically. Errors will get logged additionally in SPERRORLOG, created by installation, and signalled by the return value.

Every test function supports also the parameter *p_expected_result*. The default result is 1 (passed - otap_constants.get_otap_num_test_passed). Possible other values are 0 (UNDEFINED - otap_constants.get_otap_num_test_undefined) or -1 (failed - otap_constants.get_otap_num_test_failed).

The finish_test function is also available as a function with exit code (otap_test.finish_test_with_exit_code). This can be used to automate test execution and handle actions depending on test outcome.

For function and generation overview see currently [otap_test package description](./otap_ddl/packages/otap_test.md).

See [simple_test_setup.sql](./otap_test/basic/simple_test_setup.sql) for a first impression. Design is made to support other languages on system base, not on user base. Templates exist that can be translated. Layout orientation left, middle and right is supported for languages that read from right to left. This needs also adjustment on the templates to reorganize columns right to left. Supports test procedures or scripts.

![otap_simple_test](https://github.com/user-attachments/assets/27bf12b7-7fea-42ea-9056-e4e0881c9d47)

Basic otap test script started, see [master script](./otap_test/otap_test_master.sql) and [test log](./otap_test/otap_test_result.log).

**SQL Developer 23.x not recommmended for development** Refresh of objects after reinstall does not work, not even after log out and log in again. Relogin has no effect at all. Wrong object code in memory. Shutdown and restart of SQL Developer needed in case of doubts (in most cases with a good reason) to ensure propper mapping of objects and object code. Works only more (or less) with stable database schemas. Last failing version 23.1. Currently it is a user tool, not a developer tool. Oracle should rename it to SQL User.
# otap - Oracle Test Automation Protocol
Automated testing for Oracle databases. Can be used with [SOSL](https://github.com/AlterMannomann/sosl).

**Will never support system columns of type LONG for examination.** Since 9i Oracle itself recommends using LOB and CLOB. But even with current 23ai version, system tables have still LONG and no transform like TO_CLOB is working with normal SQL. Dumping system DBA tables to other tables is not an option. Overhead for implementation is just to big and error prone.

## Setup
- you need DBA rights to install the basic otap schema and user role. On install you can define the otap user name and the name of the otap user role.
- Use [otap_dba_setup.sql](./setup/otap_dba_setup.sql) as DBA to install the otap schema and give the necessary rights.
  - You can use the DBA install also for updates (usually grants). It will try to identify the otap user, if it exists in the database.
  - Use [otap_setup.sql](./setup/otap_setup.sql) as otap user to install the schema objects. Currently you should reinstall the schema objects after branch updates. See [otap_cleanup.sql](./setup/otap_cleanup.sql). Update mode for schema objects is not supported yet.
- Grant your defined otap user role (default OTAP_USER) to the users, that should be able to execute otap tests.
- Users with the otap user roles can access the package OTAP_TEST and the view OTAP_LATEST_TEST_RESULTS_V.
- You may want to create synonyms, so the otap schema is not needed for qualifying the package or view.
## Usage
To run a test simply call it

    SELECT otap.otap_test.has_table('MY_TABLE') FROM dual;

To run a test set with report run the following:

    --  will setup default set, group and name, no check of tests executed
    SELECT otap.otap_test.init_test FROM dual;
    -- OPTIONAL set test set for schema
    SELECT otap.otap_test.set_test_set('OTAP schema') FROM dual;
    -- OPTIONAL set test group for tables
    SELECT otap.otap_test.set_test_group('OTAP tables') FROM dual;
    -- OPTIONAL set test name for table
    SELECT otap.otap_test.set_test_name('OTAP table SPERRORLOG') FROM dual;
    -- run your tests
    SELECT otap.otap_test.has_table( p_table_name => 'SPERRORLOG'
                                   , p_schema => 'OTAP'
                                   ) FROM dual;
    -- ...
    -- finish test
    SELECT otap.otap_test.finish_test FROM dual;
    -- get the result
    SELECT result_text FROM otap.otap_latest_test_results_v;

For options and parameters see package description.

To generate schema tests simply pass the schema and execute

    SELECT result_text FROM TABLE(otap.otap_generate.schema_tests('MY_SCHEMA'));

Or ensure that the current schema is the one you want to have test scripts for, then just simply

    SELECT result_text FROM TABLE(otap.otap_generate.schema_tests);

You may spool the content to a file, make sure to set heading, paging and other things off to the get a working script. See [schema_test.sql](./otap_gen/tests/schema_test.sql) for setup and [generated_otap_schema_tests.sql](./otap_test/schema/generated_otap_schema_tests.sql) for the result showing all current functions active.
## Known issues
A list of known issues that will not be fixed.
### Persisted tests
In case of sequence cycle for session id, situations may occur where stored tests are no longer uniquely identified by session id. Still date and db user can help to distinguish the tests. In this cases it is recommended, to delete on of the tests with equal session id.
## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

For further questions on copyleft and usage see [contact](CONTACT.md).

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
