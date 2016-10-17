
Blocking Info
--For RAC or Standalone Databases

column sess format A20
SELECT substr(DECODE(request,0,'Holder: ','Waiter: ')||sid,1,12) sess,
           id1, id2, lmode, request, type, inst_id
     FROM GV$LOCK
    WHERE (id1, id2, type) IN
       (SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
         ORDER BY id1, request;
 
column sess format A20
SELECT substr(DECODE(request,0,'Holder: ','Waiter: ')||sid,1,12) sess,
       id1, id2, lmode, request, type, inst_id
 FROM GV$LOCK
WHERE (id1, id2, type) IN
   (SELECT id1, id2, type FROM GV$LOCK WHERE request>0)
     ORDER BY id1, request;
-------------------------------------------------
select
   blocking_session, sid, serial#, wait_class, seconds_in_wait
from v$session where blocking_session is not NULL
order by blocking_session;
-------------------------------------------------
SELECT chain_id, num_waiters, in_wait_secs, osid, blocker_osid, substr(wait_event_text,1,30)
 FROM v$wait_chains;
-------------------------------------------------
select s1.username || '@' || s1.machine
    || ' ( SID=' || s1.sid || ' )  is blocking '
    || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
    from v$lock l1, v$session s1, v$lock l2, v$session s2
    where s1.sid=l1.sid and s2.sid=l2.sid
    and l1.BLOCK=1 and l2.request > 0
    and l1.id1 = l2.id1
    and l2.id2 = l2.id2 ;
-------------------------------------------------
select l1.sid, ' IS BLOCKING ', l2.sid
from v$lock l1, v$lock l2
where l1.block =1 and l2.request > 0 and l1.id1=l2.id1 and l1.id2=l2.id2;
-------------------------------------------------


SELECT DECODE (l.BLOCK, 0, 'Waiting', 'Blocking ->') user_status
,CHR (39) || s.SID || ',' || s.serial# || CHR (39) sid_serial
,(SELECT instance_name FROM gv$instance WHERE inst_id = l.inst_id) conn_instance
,s.SID ,s.PROGRAM,s.osuser,s.machine
,DECODE (l.TYPE,'RT', 'Redo Log Buffer','TD', 'Dictionary'
,'TM', 'DML','TS', 'Temp Segments','TX', 'Transaction'
,'UL', 'User','RW', 'Row Wait',l.TYPE) lock_type
,DECODE (l.lmode,0, 'None',1, 'Null',2, 'Row Share',3, 'Row Excl.'
,4, 'Share',5, 'S/Row Excl.',6, 'Exclusive'
,LTRIM (TO_CHAR (lmode, '990'))) lock_mode ,ctime
,object_name
FROM gv$lock l
    JOIN gv$session s
         ON (l.inst_id = s.inst_id
AND l.SID = s.SID)
    JOIN gv$locked_object o
         ON (o.inst_id = s.inst_id
AND s.SID = o.session_id)
    JOIN dba_objects d
         ON (d.object_id = o.object_id)
    WHERE (l.id1, l.id2, l.TYPE) IN (SELECT id1, id2, TYPE
FROM gv$lock
WHERE request > 0)
ORDER BY id1, id2, ctime DESC;
  -------------------------------------------------
set echo off
set line 10000
column blocker format a11;
column blockee format a10;
column sid format 99999;
column blocker_module format a15 trunc;
column blockee_module format a15 trunc;

alter session set optimizer_mode=rule;

select a.inst_id,
(select username from gv$session s where s.inst_id=a.inst_id and s.sid=a.sid) blocker,
a.sid,
(select module from gv$session s where s.inst_id=a.inst_id and s.sid=a.sid) blocker_module ,
' is blocking ' "IS BLOCKING",
b.inst_id,
(select username from gv$session s where s.inst_id=b.inst_id and s.sid=b.sid) blockee,
b.sid ,
(select module from gv$session s where s.inst_id=b.inst_id and s.sid=b.sid) blockee_module
from gv$lock a, gv$lock b
where
a.block = 0
and b.request > 0
and a.id1 = b.id1
and a.id2 = b.id2
and a.sid = b.sid
order by 1, 2
/
alter session set optimizer_mode=choose;
-----------------------------------------------------------------------------------------------------
set lin 132
set pages 66
column "SID"          format 999
column "SER"          format 99999
column "Table"        format A10
column "SPID"         format A5
column "CPID"         format A5
column "OS User"      format A7
column "Table"        format A10
column "SQL Text"     format A40 wor
column "Mode"         format A20
column "Node"      format A10
column "Terminal"     format A8
select
  s.sid "SID", s.serial# "SER", o.object_name "Table", s.program "Programme",  s.osuser "OS User",
  s.machine "Node",  s.terminal "Terminal",
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>') "Mode",
  substr (c.sql_text, 1, 150) "SQL Text"
from v$lock l, v$lock d,  v$session s,  v$session b,  v$process p,  v$transaction t,  sys.dba_objects o,  v$open_cursor c
where l.sid = s.sid
  and o.object_id (+) = l.id1
  and c.hash_value (+) = s.sql_hash_value
  and c.address (+) = s.sql_address
  and s.paddr = p.addr
  and d.kaddr (+) = s.lockwait
  and d.id2 = t.xidsqn (+)
  and b.taddr (+) = t.addr
  and l.type = 'TM'
group by   o.object_name,  s.osuser, s.machine,  s.program,  s.terminal,  p.spid,  s.process,  s.sid,  s.serial#,
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>'),
  substr (c.sql_text, 1, 150)
order by
  decode (s.lockwait, null, 'Have Lock(s)', 'Waiting for <' || b.sid || '>') desc,  o.object_name asc,
  s.sid asc;
spool off;
-------------------------------------------------------
 Top 100 wait chain processes
 set pages 1000
 set lines 120
 set heading off
 column w_proc format a50 tru
 column instance format a20 tru
 column inst format a28 tru
 column wait_event format a50 tru
 column p1 format a16 tru
 column p2 format a16 tru
 column p3 format a15 tru
 column Seconds format a50 tru
 column sincelw format a50 tru
 column blocker_proc format a50 tru
 column waiters format a50 tru
 column chain_signature format a100 wra
 column blocker_chain format a100 wra
 
 SELECT * 
 FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name INSTANCE, 
 'INST #: '||instance INST,'Blocking Process: '||decode(blocker_osid,null,'<none>',blocker_osid)|| 
 ' from Instance '||blocker_instance BLOCKER_PROC,'Number of waiters: '||num_waiters waiters,
 'Wait Event: ' ||wait_event_text wait_event, 'P1: '||p1 p1, 'P2: '||p2 p2, 'P3: '||p3 p3,
 'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs sincelw,
 'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||decode(blocker_chain_id,null,
 '<none>',blocker_chain_id) blocker_chain
 FROM v$wait_chains wc,
 v$instance i
 WHERE wc.instance = i.instance_number (+)
 AND ( num_waiters > 0
 OR ( blocker_osid IS NOT NULL
 AND in_wait_secs > 10 ) )
 ORDER BY chain_id,
 num_waiters DESC)
 WHERE ROWNUM < 101;

11.2
set pages 1000
set lines 120
set heading off
column w_proc format a50 tru
column instance format a20 tru
column inst format a28 tru
column wait_event format a50 tru
column p1 format a16 tru
column p2 format a16 tru
column p3 format a15 tru
column Seconds format a50 tru
column sincelw format a50 tru
column blocker_proc format a50 tru
column fblocker_proc format a50 tru
column waiters format a50 tru
column chain_signature format a100 wra
column blocker_chain format a100 wra

SELECT * 
FROM (SELECT 'Current Process: '||osid W_PROC, 'SID '||i.instance_name INSTANCE, 
 'INST #: '||instance INST,'Blocking Process: '||decode(blocker_osid,null,'<none>',blocker_osid)|| 
 ' from Instance '||blocker_instance BLOCKER_PROC,
 'Number of waiters: '||num_waiters waiters,
 'Final Blocking Process: '||decode(p.spid,null,'<none>',
 p.spid)||' from Instance '||s.final_blocking_instance FBLOCKER_PROC, 
 'Program: '||p.program image,
 'Wait Event: ' ||wait_event_text wait_event, 'P1: '||wc.p1 p1, 'P2: '||wc.p2 p2, 'P3: '||wc.p3 p3,
 'Seconds in Wait: '||in_wait_secs Seconds, 'Seconds Since Last Wait: '||time_since_last_wait_secs sincelw,
 'Wait Chain: '||chain_id ||': '||chain_signature chain_signature,'Blocking Wait Chain: '||decode(blocker_chain_id,null,
 '<none>',blocker_chain_id) blocker_chain
FROM v$wait_chains wc,
 gv$session s,
 gv$session bs,
 gv$instance i,
 gv$process p
WHERE wc.instance = i.instance_number (+)
 AND (wc.instance = s.inst_id (+) and wc.sid = s.sid (+)
 and wc.sess_serial# = s.serial# (+))
 AND (s.inst_id = bs.inst_id (+) and s.final_blocking_session = bs.sid (+))
 AND (bs.inst_id = p.inst_id (+) and bs.paddr = p.addr (+))
 AND ( num_waiters > 0
 OR ( blocker_osid IS NOT NULL
 AND in_wait_secs > 10 ) )
ORDER BY chain_id,
 num_waiters DESC)
WHERE ROWNUM < 101;
--------------------------------------------------------

--Objects that have been lock for 2 minutes or more

SELECT SUBSTR(TO_CHAR(w.session_id),1,5) WSID, p1.spid WPID,
SUBSTR(s1.username,1,12) "WAITING User",
SUBSTR(s1.osuser,1,8) "OS User",
SUBSTR(s1.program,1,20) "WAITING Program",
s1.client_info "WAITING Client",
SUBSTR(TO_CHAR(h.session_id),1,5) HSID, p2.spid HPID,
SUBSTR(s2.username,1,12) "HOLDING User",
SUBSTR(s2.osuser,1,8) "OS User",
SUBSTR(s2.program,1,20) "HOLDING Program",
s2.client_info "HOLDING Client",
o.object_name "HOLDING Object"
FROM gv$process p1, gv$process p2, gv$session s1,
gv$session s2, dba_locks w, dba_locks h, dba_objects o
WHERE w.last_convert > 120
AND h.mode_held != 'None'
AND h.mode_held != 'Null'
AND w.mode_requested != 'None'
AND s1.row_wait_obj# = o.object_id
AND w.lock_type(+) = h.lock_type
AND w.lock_id1(+) = h.lock_id1
AND w.lock_id2 (+) = h.lock_id2
AND w.session_id = s1.sid (+)
AND h.session_id = s2.sid (+)
AND s1.paddr = p1.addr (+)
AND s2.paddr = p2.addr (+)
ORDER BY w.last_convert desc;
=====================================================================================

-- Display time waited for each wait class.
SELECT a.wait_class, sum(b.time_waited)/1000000 time_waited
FROM   v$event_name a
       JOIN v$system_event b ON a.name = b.event
GROUP BY a.wait_class;

-- Display the resource or event the session is waiting for.
SELECT sid, serial#, event, (seconds_in_wait/1000000) seconds_in_wait
FROM   v$session ORDER BY sid;

-- Display session wait information by wait class.
SELECT *
FROM   v$session_wait_class
--WHERE  sid = 134;
=====================================================================================

Last activity

select SID,SERIAL#,USERNAME,MACHINE,to_char(sysdate - last_call_et / 86400,'DD-MON-YYYY HH:MI:SS') Last_activity from v$session where USERNAME='ITM' order by  last_activity desc;
===================================================
