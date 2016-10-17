SELECT trunc(first_time) DAY,
     count(*) NB_SWITCHS,
     trunc(count(*)*log_size/1024/1024/1024) TOTAL_SIZE_GB,
     to_char(count(*)/24,'9999.9') AVG_SWITCHS_PER_HOUR
FROM v$loghist,(select avg(bytes) log_size from v$log)
GROUP BY trunc(first_time),log_size order by TOTAL_SIZE_GB
/

############
 select trunc(COMPLETION_TIME),count(*)*20/1024 size_in_MB
 from gv$archived_log
 group by  trunc(COMPLETION_TIME) order by size_in_MB;

############# Daily log switching report

SPOOL c:\temp\log_history.out

WHENEVER SQLERROR CONTINUE

ttitle left 'Current Date - Time' skip 1 -
left '==========================' skip 2

select to_char(sysdate, 'DD-MM-YY HH24:MI') "Current Date/Time" from dual
/
ttitle off

ttitle left 'Log History Switching Stats (Last couple of months)' skip 1 -
left '===================================================' skip 2


set lines 132
set pages 100

col A format a10 heading "Month"
col B format a25 heading "Archive Date"
col C format 999 heading "Switches"

compute AVG of C on A
compute AVG of C on REPORT

break on A skip 1 on REPORT skip 1

select to_char(trunc(first_time), 'Month') A ,
to_char(trunc(first_time), 'Day : DD-Mon-YYYY') B ,
count(*) C
from v$log_history
where trunc(first_time) > last_day(sysdate-100) +1
group by trunc(first_time)
/

ttitle off