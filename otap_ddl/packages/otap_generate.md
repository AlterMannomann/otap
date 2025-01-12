# otap_generate
Description of the generate options available with package otap_generate.

- [table_tests](#function-otap_generatetable_tests)
- [column_tests](#function-otap_generatecolumn_tests)
- [trigger_tests](#function-otap_generatetrigger_tests)
- [package_tests](#function-otap_generatepackage_tests)
- [pkg_procedures](#function-otap_generatepkg_procedures)
- [schema_tests](#function-otap_generateschema_tests)
- [disclaimer and AI disclosure](#disclaimer)
- [Back to main](../../README.md)

## FUNCTION otap_generate.table_tests
Generates the test scripts for the tables of the given schema with the current available otap schema functions. Provides group (tables) and name (table name) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_schema* The schema to generate the table tests for. Default is current schema.
- *p_like_table* The like experession for the tables to generate tests for. Can also be a specific table name. Case sensitive.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## FUNCTION otap_generate.column_tests
Generates the test scripts for the columns of a given table and schema with the current available otap schema functions. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_table* Mandatory. The table name to get column tests for. Case sensitive.
- *p_like_column* The like experession for the columns to generate tests for. Can also be a specific column name. Case sensitive.
- *p_schema* The schema to generate the column tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_excl_default* Exclude system generated content in data_default. This objects tend to be unstable over updates. To inlude them, set the parameter to NULL or any default content string that disables test on default.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## FUNCTION otap_generate.trigger_tests
Generates the test scripts for the trigger of the given schema with the current available otap schema functions. Provides group (trigger) and name (table trigger, non table trigger) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_schema* The schema to generate the trigger tests for. Default is current schema.
- *p_like_trigger* The like experession for the trigger to generate tests for. Can also be a specific trigger name. Case sensitive.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## FUNCTION otap_generate.package_tests
Generates the test scripts for the packages of the given schema with the current available otap schema functions. Provides group (package) and name (package function and procedures) management. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_schema* The schema to generate the package tests for. Default is current schema.
- *p_like_trigger* The like experession for the packages to generate tests for. Can also be a specific package name. Case sensitive.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## FUNCTION otap_generate.pkg_procedures
Generates the test scripts for the package procedures and functions of the given package with the current available otap schema functions. Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_package_name* Mandatory. Package name for tests on the functions and procedures. Case sensitive.
- *p_like_procedure* The like experession for the package function or procedure to generate tests for. Can also be a specific function or procedure name. Case sensitive.
- *p_schema* The schema to generate the package tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## FUNCTION otap_generate.schema_tests
Generates the test scripts for the current available otap schema functions. Provides set, group and name management.  Limited to line size 4000 but not to rows, like DBMS_OUTPUT. It is up to you how you spool the content to files.

Parameter:
- *p_schema* The schema to generate the tests for. Default is current schema.
- *p_title_prefix* An optional title prefix for set, group and test names. Limited to 10 chars.
- *p_show_header* Used to surpress header comments, init, count and finish section. Default 1 will contain all sections, otherwise skipped.

*Return* An OTAP_VIEW_RESULT_REC object as table type OTAP_VIEW_RESULT_TBL.
## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

For further questions on copyleft and usage see [contact](CONTACT.md).

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
