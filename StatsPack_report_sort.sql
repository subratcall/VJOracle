set pagesize 100
set linesize 119
col Execs     format 999,999,990    heading 'Executes';
col GPX       format 999,999,990.0  heading 'Gets|per Exec'  just c;
col RPX       format 999,999,990.0  heading 'Reads|per Exec' just c;
col RWPX      format 9,999,990.0    heading 'Rows|per Exec'  just c;
col Gets      format 9,999,999,990  heading 'Buffer Gets';
col Reads     format 9,999,999,990  heading 'Physical|Reads';
col Rw        format 9,999,999,990  heading 'Rows | Processed';
col hashval   format 99999999999    heading 'Hash Value';
col sql_text  format a1000           heading 'SQL statement'  ;
col rel_pct   format 999.9          heading '% of|Total';
col shm       format 999,999,999    heading 'Sharable   |Memory (bytes)';
col vcount    format 9,999          heading 'Version|Count';

col aa format a119 heading -
'      Shared_Mem   Parse_Calls  Disk_Reads Rows_Processed Buffer_Gets  Executions Gets_Per_Exec Cpu_Time(s) Elapsed_Time(s)' 
select aa
from
(
 select /*+ ordered use_nl (b st) */
          decode( st.piece
                , 0
                , lpad(to_char(e.sharable_mem,'99,999,999,999'),16)||' '||
                  lpad(to_char((e.parse_calls - nvl(b.parse_calls,0))
                               ,'999,999,999')
                      ,12)||' '||
                  lpad(to_char((e.disk_reads - nvl(b.disk_reads,0))
                               ,'999,999,999')
                      ,12)||' '||
                  lpad(to_char((nvl(e.rows_processed,0) - nvl(b.rows_processed,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad(to_char((e.buffer_gets - nvl(b.buffer_gets,0))
                               ,'999,999,999')
                      ,12)||' '||
                  lpad(to_char((e.executions - nvl(b.executions,0))
                              ,'999,999,999')
                      ,12)||' '||
                  lpad((to_char(decode(e.executions - nvl(b.executions,0)
                                     ,0, to_number(null)
                                     ,(e.buffer_gets - nvl(b.buffer_gets,0)) /
                                      (e.executions - nvl(b.executions,0)))
                               ,'999,999,990.0'))
                      ,14) ||' '||
                  lpad(  nvl(to_char(  (e.cpu_time - nvl(b.cpu_time,0))/1000000
                                   , '99990.00')
                       , ' '),10) || ' ' ||
                  lpad(  nvl(to_char(  (e.elapsed_time - nvl(b.elapsed_time,0))/1000000
                                   , '999990.00')
                       , ' '),10) || ' ' ||
--                  lpad(e.hash_value,10)||''||
                  decode(e.module,null,st.sql_text
                                      ,rpad('Module: '||e.module,125)||st.sql_text)
                , st.sql_text )aa
       from stats$sql_summary e
          , stats$sql_summary b
          , stats$sqltext     st
      where b.snap_id(+)         = 22441
        and b.dbid(+)            = e.dbid
        and b.instance_number(+) = e.instance_number
        and b.hash_value(+)      = e.hash_value
        and b.address(+)         = e.address
        and b.text_subset(+)     = e.text_subset
        and e.snap_id            = 22500
        and e.dbid               = 36396758
        and e.instance_number    = 1
        and e.hash_value         = st.hash_value
        and e.text_subset        = st.text_subset
--        and st.piece             <
        and e.executions         > nvl(b.executions,0)
--      order by e.sharable_mem desc, e.hash_value, st.piece )where rownum < 900 
--      order by (e.parse_calls - nvl(b.parse_calls,0)) desc, e.hash_value, st.piece )where rownum < 900
--      order by (e.disk_reads - nvl(b.disk_reads,0)) desc, e.hash_value, st.piece )where rownum < 900 
--      order by (e.buffer_gets - nvl(b.buffer_gets,0)) desc, e.hash_value, st.piece )where rownum < 900 
--      order by (e.executions - nvl(b.executions,0)) desc, e.hash_value, st.piece )where rownum < 900 
      order by (e.cpu_time - nvl(b.cpu_time,0)) desc, e.hash_value, st.piece )where rownum < 90000 
--      order by (e.elapsed_time - nvl(b.elapsed_time,0)) desc, e.hash_value, st.piece )where rownum < 900 
;
