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
--and s.username != 'SYSTEM'
group by
s.sid || ',' || s.serial#,
s.username,
a.sql_text,
u.tablespace,
round(((u.blocks*p.value)/1024/1024),2);

SELECT S.sid || ‘,’ || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
P.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
COUNT(*) statements
FROM v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
WHERE T.session_addr = S.saddr
AND S.paddr = P.addr
AND T.tablespace = TBS.tablespace_name
GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
P.program, TBS.block_size, T.tablespace
ORDER BY sid_serial;
