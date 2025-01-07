select module script_name from sys.v$session where sid = (SELECT sid FROM V$SESSION WHERE audsid = SYS_CONTEXT('userenv','sessionid') );
SHOW ALL