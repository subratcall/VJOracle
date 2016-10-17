--Finding CPU Usage at Oracle session level
select 
   ss.username,
   se.SID,
   VALUE/100 cpu_usage_seconds
from
   v$session ss, 
   v$sesstat se, 
   v$statname sn
where
   se.STATISTIC# = sn.STATISTIC#
and
   NAME like '%CPU used by this session%'
and
   se.SID = ss.SID
and 
   ss.status='ACTIVE'
and 
   ss.username is not null
order by VALUE desc;