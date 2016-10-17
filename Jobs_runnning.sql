set linesize 250
col sid for 9999 head 'Session|ID'
col spid head 'O/S|Process|ID'
col serial# for 9999999 head 'Session|Serial#'
col log_user for a10
col job for 9999999 head 'Job'
col broken for a1 head 'B'
col failures for 99 head "fail"
col last_date for a18 head 'Last|Date'
col this_date for a18 head 'This|Date'
col next_date for a18 head 'Next|Date'
col interval for 9999.000 head 'Run|Interval'
col what for a60
select j.sid,
s.spid,
s.serial#,
j.log_user,
j.job,
j.broken,
j.failures,
j.last_date||':'||j.last_sec last_date,
j.this_date||':'||j.this_sec this_date,
j.next_date||':'||j.next_sec next_date,
j.next_date - j.last_date interval,
j.what
from (select djr.SID,
dj.LOG_USER, dj.JOB, dj.BROKEN, dj.FAILURES,
dj.LAST_DATE, dj.LAST_SEC, dj.THIS_DATE, dj.THIS_SEC,
dj.NEXT_DATE, dj.NEXT_SEC, dj.INTERVAL, dj.WHAT
from dba_jobs dj, dba_jobs_running djr
where dj.job = djr.job ) j,
(select p.spid, s.sid, s.serial#
from v$process p, v$session s
where p.addr = s.paddr ) s
where j.sid = s.sid;

To Manage other user jobs:
exec SYS.dbms_ijob.broken(26,FALSE);