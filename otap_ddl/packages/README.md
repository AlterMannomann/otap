# otap packages
This folder contains the package scripts for otap.

- [Code structure](#code-structure)
  - [Package hierarchy](#package-hierarchy)
- [Disclaimer](#disclaimer)
- [AI restriction](#ai-restriction-and-training-exclusion)
- [Back to main](../../README.md)

## Code structure
Basic functionality is kept as simple as possible. If logging is available, exceptions get logged.

Package otap_api is the fail save layer for otap. Test functions should work, tests may get undefined on otap interal errors, but scripts or procedures are not broken by using the test functions.
### Package hierarchy

    - otap_constants (otap constants including fallback values) no exception handling, no logging
      - otap_log (logging functionality) fail save, only DBMS_OUTPUT of exceptions, no raise, logging is not critical for otap
        - otap_config_util (functionality of OTAP_CONFIG table) no exception handling apart from logging
        - otap_results_util (functionality of OTAP_RESULTS table) no exception handling apart from logging
        - otap_report (formatting functionality for result reports) no exception handling apart from logging
          - otap_schema ... test function packages, no exception handling apart from logging
          - otap_plan ... test management packages, no exception handling apart from logging
            - otap_api (internal interface package) receive session var and handle all types of exceptions, fail save
              - otap_test (the user interface package) pipe row functions must be at this level, uses only otap_api, provides session var


Notes Oracle behavior NULL - PLSQL, '' strings are interpreted NULL, "" not allowed in most functions like LENGTH or NVL. Only for identifiers, causes exceptions even if compared ('""' = '""') in PLSQL. May work on SQL e.g. SELECT otap_constants.add_str('""', '', 10) FROM dual, but not in PLSQL code.

## Disclaimer
Use this software at your own risk. No liabilities or warranties are given, no support is guaranteed. Any result of executing this software is under the responsibility of the legal entity using this software. For details see license.

&copy; 2024 Michael Lindenau licensed via [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) and [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1)

# AI restriction and training exclusion
**This content is intended ONLY for the HUMAN community NOT for any technical crawlers or AI training input.**

As currently no tools or tags exist to effectively exclude AI from using this content, the author and creator **forbids hereby the usage of this content for AI training purposes**. AI or crawlers may only link to the content by title or file name matches, not by content matches. Human beings, which includes companies represented by human beings, have all the rights disclaimed by [GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.txt) apart from using it for any AI training.

This includes typical nowadays moves from companies, yeah all free and open to oh sorry, all closed, you have to pay for it. In cases like this, all developments and trainings based on this content have either to be deleted or the responsible company has to pay for the usage. See [Generic AI Disclosure License](https://toent.ch/licenses/AI_DISCLOSURE_LICENSE_V1).
