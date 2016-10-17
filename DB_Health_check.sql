--SQLPLUSW  performace/performace@orcl3 @D:\DB_Performace\Prod_Script\Prod_Script.bat
--Move_Daily_report_Prod.bat Contents:
FOR /F "tokens=1-4 delims=/ " %%I IN ('DATE /t') DO SET mydate=%%K-%%J-%%L
mydate=%%K-1-%%J-%%L
spool orcl.txt
prompt **---------------Database General Information-------------------------------**
SELECT DBID "DATABASE_ID", NAME "DB_NAME", LOG_MODE, OPEN_MODE, RESETLOGS_TIME  FROM V$DATABASE;
SELECT instance_name, status, to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') "DB Startup Time"
FROM   sys.v_$instance;
column "Host Name" format a15;
column "Host Address" format a15;
SELECT UTL_INADDR.GET_HOST_ADDRESS "Host Address", UTL_INADDR.GET_HOST_NAME "Host Name" FROM DUAL;
SELECT BANNER "VERSION" FROM V$VERSION;
col "Database Size" format a15;
col "Free space" format a15;
select round(sum(used.bytes) / 1024 / 1024/1024 ) || ' GB' "Database Size",
round(free.p / 1024 / 1024/1024) || ' GB' "Free space"
from (select bytes from v$datafile
union all select bytes from v$tempfile
union all select bytes from v$log) used,
(select sum(bytes) as p from dba_free_space) free
group by free.p;

prompt **-----------------Database SGA Parameters-------------------------------**
set line 200;
col name format a30;
col value format a20;
SELECT name, value from v$parameter
where name in ('sga_max_size', 'shared_pool_size', 'large_pool_size', 'db_cache_size', 'db_block_size', 'log_buffer');

prompt **---------------DB Characterset Information-------------------------------**
Select * from nls_database_parameters;
col name  format A60 heading "Control Files";
select name from   sys.v_$controlfile;
col member  format A40 heading "Redolog Files";
set line 200;
col archived format a15;
col status format a10;
col first_time format a20;
select a.group#, a.member, b.archived, b.status, b.first_time from v$logfile a, v$log b
where a.group# = b.group# order by a.group#;

prompt **---------------DB Profile and Default Information----------------------------**

set line 200;
col username format a25;
col profile format a20;
col default_tablespace format a25;
col temporary_tablespace format a25;
Select username, profile, default_tablespace, temporary_tablespace from dba_users;


prompt **---------------Users Log on Information---------------------------------**
set line 200;
col OSUSER format a40;
col STATUS format a15
col MACHINE format a35;
Select to_char(logon_time,'dd/mm/yyyy hh24:mi:ss') "Logon_Time",osuser,status,machine from v$session where type !='BACKGROUND';

prompt **---------------Monitoring Schema Growth Rate---------------------------**
select    obj.owner "Owner",  obj_cnt "Objects",  decode(seg_size, NULL, 0, seg_size) "Size in MB"
from (select owner, count(*) obj_cnt from dba_objects group by owner) obj,
(select owner, ceil(sum(bytes)/1024/1024) seg_size
    from dba_segments group by owner) seg
where obj.owner  = seg.owner(+)
order by 3 desc ,2 desc, 1;

prompt **------------------Largest object in Database------------------------------**
SET LINE 200;
col SEGMENT_NAME format a30;
col SEGMENT_TYPE format a30;
col BYTES format a30;
col TABLESPACE_NAME FORMAT A30;
SELECT * FROM (select SEGMENT_NAME, SEGMENT_TYPE, BYTES/1024/1024/1024 GB, TABLESPACE_NAME from dba_segments order by 3 desc ) WHERE ROWNUM <= 5;

prompt **--------------Number of Objects Created within 7 days-------------------**
select count(1) from user_objects where CREATED >= sysdate - 7;

prompt **--------------Count Invalid object in Database----------------------------**
Select owner, object_type, count(*) from dba_objects where status='INVALID' group by  owner, object_type;

prompt **--------------Check any Long job Currently running in Database----------**
SELECT SID, SERIAL#, opname, SOFAR, TOTALWORK,
ROUND(SOFAR/TOTALWORK*100,2) COMPLETE
FROM   V$SESSION_LONGOPS
WHERE TOTALWORK != 0 AND    SOFAR != TOTALWORK order by 1;

prompt **-----------------Monitor DML Lock------------------------------------**
SELECT s.sid, s. serial#, s.username, l.lock_type, s.osuser, s.machine,
    o.owner, o.object_name, ROUND(w.seconds_in_wait/60, 2) "Wait_Time"                
FROM
     v$session s, dba_locks l, dba_objects o, v$session_wait  w
WHERE   s.sid = l.session_id
  AND l.lock_type IN ('DML','DDL')
  AND l.lock_id1 = o.object_id
  AND l.session_id = w.sid
ORDER BY   s.sid;

prompt **-----------List Non-Sys owned tables in SYSTEM Tablespace-----------**
SELECT owner, table_name, tablespace_name FROM dba_tables WHERE tablespace_name = 'SYSTEM' AND owner NOT IN ('SYSTEM', 'SYS', 'OUTLN');

prompt **-----------------Track Redolog Generation-------------------------------**
select trunc(completion_time) logdate, count(*) logswitch, round((sum(blocks*block_size) / 1024 / 1024)) "REDO PER DAY(MB)"
from v$archived_log
group by trunc(completion_time)
order by 1;

prompt **------------------Tablespace Information--------------------------------**
col tablespace_name format a15 heading "Tablespace Name"
SELECT Total.name "Tablespace Name",
       nvl(Free_space, 0) Free_space,
       nvl(total_space-Free_space, 0) Used_space,
       total_space
FROM
  (select tablespace_name, sum(bytes/1024/1024) Free_Space
     from sys.dba_free_space
    group by tablespace_name
  ) Free,
  (select b.name,  sum(bytes/1024/1024) TOTAL_SPACE
     from sys.v_$datafile a, sys.v_$tablespace B
    where a.ts# = b.ts#
    group by b.name
  ) Total
WHERE Free.Tablespace_name(+) = Total.name
ORDER BY Total.name
/
prompt **---------------Shows Used/Free Space Per Datafile--------------------------**
prompt

set linesize 200
col file_name format a50 heading "Datafile Name"


SELECT SUBSTR (df.NAME, 1, 40) file_name, df.bytes / 1024 / 1024 allocated_mb,
         ((df.bytes / 1024 / 1024) - NVL (SUM (dfs.bytes) / 1024 / 1024, 0))
               used_mb,
         NVL (SUM (dfs.bytes) / 1024 / 1024, 0) free_space_mb
    FROM v$datafile df, dba_free_space dfs
   WHERE df.file# = dfs.file_id(+)
GROUP BY dfs.file_id, df.NAME, df.file#, df.bytes
ORDER BY file_name;

TTI off

prompt **---------------Report Tablespace < 10% free space----------------------------**
set pagesize 300;
set linesize 100;
column tablespace_name format a15 heading Tablespace;
column sumb format 999,999,999;
column extents format 9999;
column bytes format 999,999,999,999;
column largest format 999,999,999,999;
column Tot_Size format 999,999 Heading "Total Size(Mb)";
column Tot_Free format 999,999,999 heading "Total Free(Kb)";
column Pct_Free format 999.99 heading "% Free";
column Max_Free format 999,999,999 heading "Max Free(Kb)";
column Min_Add format 999,999,999 heading "Min space add (MB)";
select a.tablespace_name,sum(a.tots/1048576) Tot_Size,
sum(a.sumb/1024) Tot_Free, sum(a.sumb)*100/sum(a.tots) Pct_Free,
ceil((((sum(a.tots) * 15) - (sum(a.sumb)*100))/85 )/1048576) Min_Add
from (select tablespace_name,0 tots,sum(bytes) sumb
from sys.dba_free_space a
group by tablespace_name
union
select tablespace_name,sum(bytes) tots,0 from
sys.dba_data_files
group by tablespace_name) a
group by a.tablespace_name
having sum(a.sumb)*100/sum(a.tots) < 10
order by pct_free;

prompt **---------------File I/O statistics-------------------------------**

prompt

set linesize 150
col name format a50 heading "Datafile Name"
select name,PHYRDS "Physical Reads",PHYWRTS "Physical Writes",READTIM "Read Time(ms)",WRITETIM "Write Time(ms)",AVGIOTIM "Avg Time" from v$filestat, v$datafile where v$filestat.file#=v$datafile.file#;
set feedback on
prompt

rem -----------------------------------------------------------------------
rem Filename:   sga_stat.sql
rem Purpose:    Display database SGA statistics
rem -----------------------------------------------------------------------
prompt Recommendations:
prompt =======================
prompt * SQL Cache Hit rate ratio should be above 90%, if not then increase the Shared Pool Size.
prompt * Dict Cache Hit rate ratio should be above 85%, if not then increase the Shared Pool Size.
prompt * Buffer Cache Hit rate ratio should be above 90%, if not then increase the DB Block Buffer value.
prompt * Redo Log space requests should be less than 0.5% of redo entries, if not then increase log buffer.
prompt * Redo Log space wait time should be near to 0.
prompt
set serveroutput ON
DECLARE
      libcac number(10,2);
      rowcac number(10,2);
      bufcac number(10,2);
      redlog number(10,2);
      redoent number;
      redowaittime number;
BEGIN
select value into redlog from v$sysstat where name = 'redo log space requests';
select value into redoent from v$sysstat where name = 'redo entries';
select value into redowaittime from v$sysstat where name = 'redo log space wait time';
select 100*(sum(pins)-sum(reloads))/sum(pins) into libcac from v$librarycache;
select 100*(sum(gets)-sum(getmisses))/sum(gets) into rowcac from v$rowcache;
select 100*(cur.value + con.value - phys.value)/(cur.value + con.value) into bufcac
from v$sysstat cur,v$sysstat con,v$sysstat phys,v$statname ncu,v$statname nco,v$statname nph
where cur.statistic# = ncu.statistic#
        and ncu.name = 'db block gets'
        and con.statistic# = nco.statistic#
        and nco.name = 'consistent gets'
        and phys.statistic# = nph.statistic#
        and nph.name = 'physical reads';
dbms_output.put_line('SGA CACHE STATISTICS');
dbms_output.put_line('********************');
dbms_output.put_line('SQL Cache Hit rate = '||libcac);
dbms_output.put_line('Dict Cache Hit rate = '||rowcac);
dbms_output.put_line('Buffer Cache Hit rate = '||bufcac);
dbms_output.put_line('Redo Log space requests = '||redlog);
dbms_output.put_line('Redo Entries = '||redoent);
dbms_output.put_line('Redo log space wait time = '||redowaittime);
if
libcac < 90  then dbms_output.put_line('*** HINT: Library Cache too low! Increase the Shared Pool Size.');
END IF;
if
rowcac < 85  then dbms_output.put_line('*** HINT: Row Cache too low! Increase the Shared Pool Size.');
END IF;
if
bufcac < 90  then dbms_output.put_line('*** HINT: Buffer Cache too low! Increase the DB Block Buffer value.');
END IF;
if
redlog > 1000000 then dbms_output.put_line('*** HINT: Log Buffer value is rather low!');
END IF;
END;
/
spool off
exit