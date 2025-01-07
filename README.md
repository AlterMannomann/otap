# UNDER CONSTRUCTION
Current state: Pre-alpha with has_table, has_column, has_package, has_procedure test and result view. To do: Extend test functions, fix minor formatting issued, continue test otap with otap.

See [simple_test_setup.sql](./otap_test/simple_test_setup.sql) for a first impression. Design is made to support other languages on system base, not on user base. Templates exist that can be translated. Layout orientation left, middle and right is supported for languages that read from right to left. This needs also adjustment on the templates to reorganize columns right to left. Supports test procedures or scripts.

![otap_test_report](https://github.com/user-attachments/assets/10a7ed08-1e31-44f8-90f7-2a38c6b68113)

Basic otap test script started, see [master script](./otap_test/otap_test_master.sql) and [test log](./otap_test/otap_test_result.log).

**SQL Developer 23.x not recommmended for development** Refresh of objects after reinstall does not work, not even after log out and log in again. Relogin has no effect at all. Wrong object code in memory. Shutdown and restart of SQL Developer needed in case of doubts (in most cases with a good reason) to ensure propper mapping of objects and object code. Works only more (or less) with stable database schemas. Last failing version 23.1. Currently it is a user tool, not a developer tool. Oracle should rename it to SQL User.
# otap - Oracle Test Automation Protocol
Automated testing for Oracle databases. Can be used with [SOSL](https://github.com/AlterMannomann/sosl).

I would have preferred a PRIVATE TEMPORARY TABLE for results, but this construct did not support CLOB columns. Thus otap needs job execution rights to keep the OTAP_RESULTS table as small as possible with automatic result deletions. Otherwise some tests are probably worth to be persisted.

## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

For further questions on copyleft and usage see [contact](CONTACT.md).

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
