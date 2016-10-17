select /*+ ordered */
   s.owner,
   s.segment_name||decode(s.partition_name,NULL,'','.'||s.partition_name)
    segment_name,
   s.tablespace_name, s.next_extent/1024 next_extent,
   f.max_free/1024 max_free
from ( select /*+ ordered */
      s.owner, s.segment_name, s.partition_name, s.tablespace_name,
   decode(t.allocation_type,
      'SYSTEM',decode(sign(16-s.extents),1,64*1024,
         decode(sign(79-s.extents),1,1024*1024,
         decode(sign(199-s.extents),1,8*1024*1024,64*1024*1024))),
      s.next_extent) next_extent, s.extents, s.max_extents
   from dba_segments s, dba_tablespaces t
   where t.tablespace_name = s.tablespace_name
    and t.contents != 'UNDO' ) s,
   ( select /*+ ordered */
      t.tablespace_name, nvl(max(f.bytes),0) max_free
   from dba_tablespaces t, dba_free_space f
   where f.tablespace_name (+) = t.tablespace_name
   group by t.tablespace_name ) f
where f.tablespace_name = s.tablespace_name
and f.max_free < s.next_extent
order by 1, 2, 3
/
