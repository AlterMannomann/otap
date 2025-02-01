@ECHO OFF
ECHO Exit code 0
CALL test.cmd 0
ECHO Return %ERRORLEVEL%
ECHO Exit code 1
CALL test.cmd 1
ECHO Return %ERRORLEVEL%
ECHO Exit code 2
CALL test.cmd 2
ECHO Return %ERRORLEVEL%
ECHO Exit code -1
CALL test.cmd -1
ECHO Return %ERRORLEVEL%