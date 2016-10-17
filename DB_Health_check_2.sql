SET MARKUP HTML ON

set feedback off
set serverout on
set wrap off
set pages 300
set lines 150
col file_name for a50
col name for a50
col member for a50
col file_id for a5
col "Percent Used" for a20
col segment_name for a30
col tablespace_name for a30
col STATUS for a16
col owner for a20
col table_name for a35
col index_name for a35
col username format a25
col default_tablespace format a25
col temporary_tablespace format a25

SPOOL Database_Health_Report.html

PROMPT ================================================================
PROMPT DATABASE HEALTH CHECK REPORT
PROMPT ================================================================

PROMPT
PROMPT
PROMPT DATABASE STATUS
PROMPT =================
select INSTANCE_NAME,STATUS,DATABASE_STATUS,ACTIVE_STATE,STARTUP_TIME from v$instance;

PROMPT
PROMPT
PROMPT DATABASE UPTIME
PROMPT =================

select
   'Hostname : ' || host_name
   ,'Instance Name : ' || instance_name
   ,'Started At : ' || to_char(startup_time,'DD-MON-YYYY HH24:MI:SS') stime
   ,'Uptime : ' || floor(sysdate - startup_time) || ' days(s) ' ||
   trunc( 24*((sysdate-startup_time) -
   trunc(sysdate-startup_time))) || ' hour(s) ' ||
   mod(trunc(1440*((sysdate-startup_time) -
   trunc(sysdate-startup_time))), 60) ||' minute(s) ' ||
   mod(trunc(86400*((sysdate-startup_time) -
   trunc(sysdate-startup_time))), 60) ||' seconds' uptime
from
   sys.v_$instance;


PROMPT
PROMPT
PROMPT TOTAL DATABASE USAGE
PROMPT =====================
select (select sum(bytes/1048576) from dba_data_files) "Data Mb",
(select NVL(sum(bytes/1048576),0) from dba_temp_files) "Temp Mb",
(select sum(bytes/1048576)*max(members) from v$log) "Redo Mb",
(select sum(bytes/1048576) from dba_data_files) +
(select NVL(sum(bytes/1048576),0) from dba_temp_files) +
(select sum(bytes/1048576)*max(members) from v$log) "Total Mb"
from dual;


PROMPT
PROMPT
PROMPT DB PHYSICAL SIZE
PROMPT ==================
select sum(bytes/1024/1024) "DB Physical Size(MB)" from dba_data_files;


PROMPT
PROMPT
PROMPT DB ACUTAL SIZE
PROMPT ================
select sum(bytes/1024/1024) "DB Actual Size(MB)" from dba_segments;


PROMPT
PROMPT
PROMPT DATABASE NAME AND MODE
PROMPT ========================
select name, open_mode, log_mode from v$database;



PROMPT
PROMPT
PROMPT COUNT OF TABLESPACES
PROMPT =====================
select count(*) AS "No. of tablespaces" from v$tablespace;


PROMPT
PROMPT
PROMPT COUNT OF DATAFILES
PROMPT ===================
select count(*) AS "No. of Datafiles" from dba_data_files;


PROMPT
PROMPT
PROMPT COUNT OF INVALID OBJECTS
PROMPT ==========================
select count(*) from dba_objects where status='INVALID';


PROMPT
PROMPT
PROMPT COUNT OF ARCHIVED GENERATED LAST DAY
PROMPT =====================================
Select count(*) "No. of Archive Logs generated" from v$log_history  where to_char(first_time,'dd-mon-rrrr') in (to_char(sysdate-1,'dd-mon-rrrr'));


PROMPT
PROMPT
PROMPT LIBRARY CACHE HIT RATIO. THIS VALUE SHOULD BE GREATER 90%
PROMPT =========================================================
select (sum(pins)/(sum(pins)+sum(reloads))) * 100 "Library Cache Hit Ratio" from v$librarycache;


PROMPT
PROMPT
PROMPT SGA STATISTICS
PROMPT ===============
set serveroutput on;
DECLARE
libcac number(10,2);
rowcac number(10,2);
bufcac number(10,2);
redlog number(10,2);
spsize number;
blkbuf number;
logbuf number;
BEGIN
select value into redlog from v$sysstat
where name = 'redo log space requests';
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
select value into spsize from v$parameter where name = 'shared_pool_size';
select value into blkbuf from v$parameter where name = 'db_block_buffers';
select value into logbuf from v$parameter where name = 'log_buffer';
dbms_output.put_line('> SGA CACHE STATISTICS');
dbms_output.put_line('> ********************');
dbms_output.put_line('> SQL Cache Hit rate = '||libcac);
dbms_output.put_line('> Dict Cache Hit rate = '||rowcac);
dbms_output.put_line('> Buffer Cache Hit rate = '||bufcac);
dbms_output.put_line('> Redo Log space requests = '||redlog);
dbms_output.put_line('> ');
dbms_output.put_line('> INIT.ORA SETTING');
dbms_output.put_line('> ****************');
dbms_output.put_line('> Shared Pool Size = '||spsize||' Bytes');
dbms_output.put_line('> DB Block Buffer = '||blkbuf||' Blocks');
dbms_output.put_line('> Log Buffer = '||logbuf||' Bytes');
dbms_output.put_line('> ');
if
libcac < 99 then dbms_output.put_line('*** HINT: Library Cache too low! Increase the Shared Pool Size.');
END IF;
if
rowcac < 85 then dbms_output.put_line('*** HINT: Row Cache too low! Increase the Shared Pool Size.');
END IF;
if
bufcac < 90 then dbms_output.put_line('*** HINT: Buffer Cache too low! Increase the DB Block Buffer value.');
END IF;
if
redlog > 100 then dbms_output.put_line('*** HINT: Log Buffer value is rather low!');
END IF;
END;
/



PROMPT
PROMPT
PROMPT LOCKS
PROMPT =======
SELECT
   inst_id,
   sid sess,
   (select sql_hash_value from gV$session s where s.sid=lk.sid and s.inst_id = lk.inst_id) SQL_HASH_VALUE,
   ctime, id1, id2, trim(lmode) lmode, request, type,
   (select status from gv$session vs where vs.sid = lk.sid and vs.inst_id = lk.inst_id) SessStatus,
   (select object_name from dba_objects where object_id = id1) obj_locked,
   DECODE(request,0,'Holder: ','Waiter: ') position
FROM gV$LOCK lk
WHERE id1 IN (SELECT id1 FROM gv$LOCK WHERE lmode = 0)
ORDER BY id1,request


PROMPT
PROMPT
PROMPT DATAFILE USED  FREE SPAPCE
PROMPT ===========================
SELECT df.tablespace_name,
       df.file_name,
       df.size_mb,
       f.free_mb,
       df.max_size_mb,
       f.free_mb + (df.max_size_mb - df.size_mb) AS max_free_mb
FROM   (SELECT file_id,
               file_name,
               tablespace_name,
               TRUNC(bytes/1024/1024) AS size_mb,
               TRUNC(GREATEST(bytes,maxbytes)/1024/1024) AS max_size_mb
        FROM   dba_data_files) df,
       (SELECT TRUNC(SUM(bytes)/1024/1024) AS free_mb,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE  df.file_id = f.file_id (+)
ORDER BY df.tablespace_name,
         df.file_name;


PROMPT
PROMPT
PROMPT TEMP TABLESPACE USED FREE
PROMPT ==========================
SELECT tf.tablespace_name,
       tf.file_name,
       tf.size_mb,
       f.free_mb,
       tf.size_mb - f.free_mb as USED,
       tf.max_size_mb,
       f.free_mb + (tf.max_size_mb - tf.size_mb) AS max_free_mb
FROM   (SELECT file_id,
               file_name,
               tablespace_name,
               TRUNC(bytes/1024/1024) AS size_mb,
               TRUNC(GREATEST(bytes,maxbytes)/1024/1024) AS max_size_mb
        FROM   dba_temp_files) tf,
       (SELECT TRUNC(SUM(bytes)/1024/1024) AS free_mb,
               file_id
        FROM dba_free_space
        GROUP BY file_id) f
WHERE  tf.file_id = f.file_id (+)
ORDER BY tf.tablespace_name,
         tf.file_name;


PROMPT
PROMPT
PROMPT TABLESPACE USED  FREE SPAPCE
PROMPT ==============================
select
   fs.tablespace_name                          "Tablespace",
   (df.totalspace - fs.freespace)              "Used MB",
   fs.freespace                                "Free MB",
   df.totalspace                               "Total MB",
   round(100 * (fs.freespace / df.totalspace)) "Pct. Free"
from
   (select
      tablespace_name,
      round(sum(bytes) / 1048576) TotalSpace
   from
      dba_data_files
   group by
      tablespace_name
   ) df,
   (select
      tablespace_name,
      round(sum(bytes) / 1048576) FreeSpace
   from
      dba_free_space
   group by
      tablespace_name
   ) fs
where
   df.tablespace_name = fs.tablespace_name;


PROMPT
PROMPT
PROMPT TABLESPACE AVERAGE INCREASE PER DAY
PROMPT ====================================
SELECT b.tsname tablespace_name
, MAX(b.used_size_mb) cur_used_size_mb
, round(AVG(inc_used_size_mb),2)avg_increas_mb
FROM (
  SELECT a.days, a.tsname, used_size_mb
  , used_size_mb - LAG (used_size_mb,1)  OVER ( PARTITION BY a.tsname ORDER BY a.tsname,a.days) inc_used_size_mb
  FROM (
      SELECT TO_CHAR(sp.begin_interval_time,'MM-DD-YYYY') days
       ,ts.tsname
       ,MAX(round((tsu.tablespace_usedsize* dt.block_size )/(1024*1024),2)) used_size_mb
      FROM DBA_HIST_TBSPC_SPACE_USAGE tsu, DBA_HIST_TABLESPACE_STAT ts
       ,DBA_HIST_SNAPSHOT sp, DBA_TABLESPACES dt
      WHERE tsu.tablespace_id= ts.ts# AND tsu.snap_id = sp.snap_id
       AND ts.tsname = dt.tablespace_name  AND sp.begin_interval_time > sysdate-7
      GROUP BY TO_CHAR(sp.begin_interval_time,'MM-DD-YYYY'), ts.tsname
      ORDER BY ts.tsname, days
  ) A
) b GROUP BY b.tsname ORDER BY b.tsname;


PROMPT
PROMPT
PROMPT TABLESPACE GROWTH
PROMPT ===================
SELECT TO_CHAR (sp.begin_interval_time,'DD-MM-YYYY') days
, ts.tsname
 , max(round((tsu.tablespace_size* dt.block_size )/(1024*1024),2) ) cur_size_MB
 , max(round((tsu.tablespace_usedsize* dt.block_size )/(1024*1024),2)) usedsize_MB
 FROM DBA_HIST_TBSPC_SPACE_USAGE tsu
 , DBA_HIST_TABLESPACE_STAT ts
 , DBA_HIST_SNAPSHOT sp
 , DBA_TABLESPACES dt
 WHERE tsu.tablespace_id= ts.ts#
 AND tsu.snap_id = sp.snap_id
 AND ts.tsname = dt.tablespace_name
 AND ts.tsname NOT IN ('SYSAUX','SYSTEM')
 GROUP BY TO_CHAR (sp.begin_interval_time,'DD-MM-YYYY'), ts.tsname
 ORDER BY ts.tsname desc, days desc;


PROMPT
PROMPT
PROMPT TABLESPACE STATISTICS
PROMPT ======================
COL file_name FORMAT A45
select tablespace_name ,  file_name, autoextensible , bytes/1024/1024 "USED SPACE(MB)", maxbytes/1024/1024 " MAX SIZE(MB) " from dba_data_files order by tablespace_name,file_name;


PROMPT
PROMPT
PROMPT REDOLOG GROWTH RATE PER DAY
PROMPT ============================
SELECT A.*,
Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
FROM
(
   SELECT
   To_Char(First_Time,'YYYY-MM-DD') DAY,
   Count(1) Count#,
   Min(RECID) Min#,
   Max(RECID) Max#
FROM
   v$log_history
GROUP BY
   To_Char(First_Time,'YYYY-MM-DD')
ORDER
BY 1 DESC
) A,
(
SELECT
Avg(BYTES) AVG#,
Count(1) Count#,
Max(BYTES) Max_Bytes,
Min(BYTES) Min_Bytes
FROM
v$log
) B
;


PROMPT
PROMPT
PROMPT NUMBER OF CONNECTED SESSIONS
PROMPT =============================
select
       substr(a.spid,1,9) pid,
       substr(b.sid,1,5) sid,
       status,
       TO_CHAR(logon_time,'DD-Mon-YYYY HH24:MI:SS'),
       substr(b.serial#,1,5) ser#,
       substr(b.machine,1,6) box,
       substr(b.username,1,10) username,
       substr(b.osuser,1,8) os_user,
       substr(b.program,1,30) program
from v$session b, v$process a
where
b.paddr = a.addr
and type='USER'
order by status;



PROMPT
PROMPT
PROMPT IO ACTIVITIES
PROMPT ==============
select tablespace_name, regexp_replace(file_name,'^.*.\/.*.\/', '') file_name,sum(phyrds) reads, sum(phywrts) writes, sum(phyrds)+sum(phywrts) total from dba_data_files, v$filestat where file_id=file# group by tablespace_name, file_name order by tablespace_name, file_name;



PROMPT
PROMPT
PROMPT DATAFILE PHYSICAL READS AND WRITES
PROMPT ===================================
COL datafile FORMAT A45
select name datafile, phyrds reads, phywrts writes, phyrds+phywrts total from v$datafile a, v$filestat b where a.file# = b.file# order by total desc;


PROMPT
PROMPT
PROMPT BLOCKING QUERY
PROMPT ===============
select s1.username || '@' || s1.machine|| ' ( SID=' || s1.sid || ' )  is blocking '|| s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status from v$lock l1, v$session s1, v$lock l2, v$session s2 where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l2.request > 0 and l1.id1 = l2.id1 and l2.id2 = l2.id2;

PROMPT
PROMPT
PROMPT BLOCKER AND WAITER
PROMPT ===================
Select sid , decode(block,0,'NO','YES') Blocker , decode (request ,0,'NO','YES')WAITER from v$lock where request>0 or block>0 order by block desc;


PROMPT
PROMPT
PROMPT NO of USER CONNECTED
PROMPT =====================
select count(distinct username) "No. of users Connected" from v$session where username is not null;



PROMPT
PROMPT
PROMPT NO of SESSIONS CONNECTED
PROMPT =========================
Select count(*) AS "No of Sessions connected" from v$session where username is not null;


PROMPT
PROMPT
PROMPT DISTINCT USERNAME CONNECTED
PROMPT ============================
Select distinct(username) AS "USERNAME" from v$session;



PROMPT
PROMPT
PROMPT INVALID OBJECT LIST
PROMPT ====================
COL object_name FORMAT A40
select owner , object_name , object_type , status from dba_objects where status='INVALID' order by owner , object_type , object_name;


PROMPT
PROMPT
PROMPT SCHEDULED JOBS
PROMPT ===============
set lines 100
col owner for a8
col job_name for a10
col job_action for a10
col start_date for a10
col repeat_interval for a13
col state for a10
col last_start_date for a10
col next_run_date for a10
select OWNER,JOB_NAME,JOB_ACTION,START_DATE,REPEAT_INTERVAL,STATE,LAST_START_DATE,NEXT_RUN_DATE from dba_scheduler_jobs;


PROMPT
PROMPT
PROMPT DATAFILE IO
PROMPT =============
SELECT Substr(d.name,1,50) "File Name",
       f.phyblkrd "Blocks Read",
       f.phyblkwrt "Blocks Writen",
       f.phyblkrd + f.phyblkwrt "Total I/O"
FROM   v$filestat f,
       v$datafile d
WHERE  d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;


PROMPT
PROMPT
PROMPT DISPLAY LONG RUNNING OPERATIONS
PROMPT ================================
COLUMN sid FORMAT 999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.sid,
       s.serial#,
       s.machine,
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct
FROM   v$session s,
       v$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.serial# = sl.serial#;

Spool off
