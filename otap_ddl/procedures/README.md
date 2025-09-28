# otap procedures
This folder contains the procedure scripts for otap.

- [Back to main](../../README.md)

## Procedure otap.run_tests
This procedure is a high level procedure (it only uses otap_test), that collects procedures and package procedures which fit the defined prefix and a like search expression. Setup is not trivial and may raise security issues. It expects procedures not having any parameter, not even parameter with default values.
### Basic concept
Basically it provides an option to run tests completely in the database, without external scripts and sqlplus. So the complete testing workflow is in the database. It executes identified procedures as dynamic sql, which has security impacts regarding needed rights. It has the ability to extract automatically test set, test group and test name from a procedure, if name precedence is set and naming fits the run_tests rules. Only valid packages and procedures are included in the search.

The test schema is responsible to execute otap.run_tests and prepare the session record.

    -- example, called by test schema
    ALTER SESSION SET CURRENT_SCHEMA = 'APP_SCHEMA';
    DECLARE
      l_return    VARCHAR2(4000);
      l_exit_code NUMBER;
    BEGIN
      l_return := otap.otap_test.init_test( p_test_count => 10 -- intended test count
                                          , p_test_set => 'My test set'
                                          , p_test_group => 'My test group'
                                          , p_test_name => 'Test'
                                          , p_prefix => 'TST1'
                                          , p_name_precedence => otap_constants.OTAP_NUM_FALSE -- if procedures set the names
                                          , p_include_pkg => otap_constants.OTAP_NUM_TRUE -- if packages should be included
                                          , p_schema => 'APP_SCHEMA' -- if current schema not set with ALTER SESSION
                                          )
      ;
      -- you might use otap.otap_test.get_session_id and store it for later use
      otap.run_tests('%');
      l_exit_code := otap.otap_test.finish_test_with_exit_code(otap_constants.OTAP_NUM_TRUE); -- add count test
      -- actions depending on exit code go here
    END;
    /

### Recommended setup
To minimize security impacts, it is recommended to have to database schema, one that contains the application to test and one that holds only the test procedures. The application grants execute rights on the test objects to the testing schema. The testing schema grants execution rights on the test procedures to otap. To minimize necessary grants it is recommended to use a limited amount of packages, where only package grants are needed. The execution rights must be granted explicitly to otap, as role rights do not support dynamic execution of role granted objects.
#### Limitations
The test procedures can't use any otap functionality that relies on dynamic execution like otap_test.throw functions unless the execution rights for the dynamic executed application functions is explicitly granted to otap. In save and decoupled test systems it may be considered to grant otap EXECUTE ANY PROCEDURE. Due to security impacts this is not recommended.

As run_tests should be run with the test schema, all otap functionality access must be qualified by otap schema, if no synonyms are configured.
#### Grants
The following explicite grants from otap are needed to allow the test schema to execute otap functionality in procedures, role grant is NOT sufficient.

    GRANT EXECUTE ON otap.run_tests TO test_schema;
    GRANT EXECUTE ON otap.otap_test TO test_schema;

Likewise the test schema must grant its procedures and packages explicitly to otap.

    GRANT EXECUTE ON test_schema.TEST_001_SET_GROUP_TESTNAME TO otap;
    GRANT EXECUTE ON test_schema.pkg_test TO otap;

And the application schema must grant explicite execution rights to the test schema.
#### Test procedure naming rules
The only delimiter allowed is underscore "_".
##### Disabled name precedence
It is expected, that a name part follows the underscore. Otherwise the procedure is ignored. Moreover the procedures are responsible to set the test set, test group and test names.

    <prefix>_<procedure name>, e.g. TEST_MYPROC

If procedures should execute in a defined order, it is recommended to add some optional order number to the procedure name.

    <prefix>_<optional order number>_<procedure name>, e.g. TEST_001_MYPROC
#### Enabled name precedence
Procedures might still set the names for test set, test group and test name. If not the names are extracted from the procedure names, the session record definition is used as fallback, if name parts are missing.

    <prefix>_<optional order number>_<set name>_<group name>_<test name>, e.g. TEST_001_MYSET_MYGROUP_MYTEST
    or
    <prefix>_<set name>_<group name>_<test name>, e.g. TEST_MYSET_MYGROUP_MYTEST
## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
