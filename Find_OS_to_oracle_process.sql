select s.sid, s.serial#, s.username,
       to_char(s.logon_time,'DD-MON HH24:MI:SS') logon_time,
       p.pid oraclepid, p.spid "ServerPID", s.process "ClientPID",
       s.program clientprogram, s.module, s.machine, s.osuser,
       s.status, s.last_call_et
from  v$session s, v$process p
where p.spid=nvl('&unix_process',' ')
and s.paddr=p.addr
order by s.sid
/ 
