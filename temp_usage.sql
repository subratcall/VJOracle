select s.sid || ',' || s.serial# sid,
s.username,
u.tablespace,
a.sql_text,
round(((u.blocks*p.value)/1024/1024),2) size_mb
from v$sort_usage u,
v$session s,
v$sqlarea a,
v$parameter p
where s.saddr = u.session_addr
and a.address (+) = s.sql_address
and a.hash_value (+) = s.sql_hash_value
and p.name = 'db_block_size'
and s.username != 'SYSTEM'
group by
s.sid || ',' || s.serial#,
s.username,
a.sql_text,
u.tablespace,
round(((u.blocks*p.value)/1024/1024),2);

-----------------------

SELECT   b.TABLESPACE
       , b.segfile#
       , b.segblk#
       , ROUND (  (  ( b.blocks * p.VALUE ) / 1024 / 1024 ), 2 ) size_mb
       , a.SID
       , a.serial#
       , a.username
       , a.osuser
       , a.program
       , a.status
    FROM v$session a
       , v$sort_usage b
       , v$process c
       , v$parameter p
   WHERE p.NAME = 'db_block_size'
     AND a.saddr = b.session_addr
     AND a.paddr = c.addr
ORDER BY b.TABLESPACE
       , b.segfile#
       , b.segblk#
       , b.blocks;