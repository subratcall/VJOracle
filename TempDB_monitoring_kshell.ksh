+++++++++++++++++++++++++++++++++++++++++++++++++++++
#!/bin/ksh
#set -x
#       Script Name:  tmp_tblspace_usage_tracking.ksh
#       
#               
#

. ~oracle/.ora_prdcndw1 > /dev/null

$ORACLE_HOME/bin/sqlplus -s /nolog <<EOD
connect / as sysdba
--
declare
id     number;
BEGIN
select system.tmp_usageid.nextval into id from dual;
--
insert into system.tmp_tblspace_usage
select id, s.username, se.sid, s.session_num, se.status, s.tablespace, 
(s.blocks*16384)/(1024*1024) used_MB, s.contents,s.segtype, sq.sql_text, sysdate 
from v$sort_usage s , v$session se, v$sqlarea sq
where s.session_num=se.serial#
and s.sqladdr= sq.address;
commit;
END;
/
exit;
EOD
