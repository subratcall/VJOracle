set linesize 140
select /*+ RULE */
          e.owner ||'.'|| e.segment_name  segment_name,tablespace_name, x.hladdr addr,
          e.extent_id  extent#,
          x.dbablk - e.block_id + 1  block#,
          x.tch,
         l.child#
        from
          sys.v$latch_children  l,
          sys.x$bh  x,
        sys.dba_extents  e
      where
        x.hladdr   in (select * from (select addr from v$latch_children
     where name = 'cache buffers chains'
     order by sleeps desc ,misses desc) where rownum < 7)  and
        e.file_id = x.file# and
        x.hladdr = l.addr and
        x.dbablk between e.block_id and e.block_id + e.blocks -1
        order by x.tch desc 
 /
