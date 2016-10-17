--Grid Control Queries


--list All Database Target details monitored thru grid

select t.host_name
 as     host
 , ip.property_value IP
 , t.target_name
 as     name
 , decode ( t.type_qualifier4
 , ' '
 , 'Normal'
 , t.type_qualifier4 )
 as     type
 , dbv.property_value
 as     version
 , port.property_value port
 , SID.property_value SID
 , logmode.property_value
 as     "Log Mode"
 , oh.property_value
 as     "Oracle Home"
 from mgmt$target t
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'DBVersion' ) dbv
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'Port' ) port
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'SID' ) sid
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'log_archive_mode' ) logmode
 , ( select p.target_guid
 , p.property_value
 from mgmt$target_properties p
 where p.property_name = 'OracleHome' ) oh
 , ( select tp.target_name
 as     host_name
 , tp.property_value
 from mgmt$target_properties tp
 where tp.target_type = 'host'
 and tp.property_name = 'IP_address' ) ip
 where t.target_guid = port.target_guid
 and port.target_guid = sid.target_guid
 and sid.target_guid = dbv.target_guid
 and dbv.target_guid = logmode.target_guid
 and logmode.target_guid = oh.target_guid
 and t.host_name = ip.host_name
 order by 1, 3;


--If you are having performance hit on Grid database, use following SQL to locate most active segemnts.
--You can then think of archiving data in grid else moving them on speedy spindles.

    select sum ( B.logical_reads_total )
     , sum ( B.physical_reads_total )
     , sum ( B.physical_writes_total )
     , sum ( buffer_busy_waits_total )
     , c.object_name
     , c.owner
     from DBA_HIST_SNAPSHOT A
     , DBA_HIST_SEG_STAT B
     , dba_objects C
     where A.Snap_id = b.snap_id
     and c.object_id = b.obj#
     and A.BEGIN_INTERVAL_TIME >= to_Date ( '17-May-2011 08:00'
     , 'DD-MON-YYYY HH24:MI' )
     and A.END_INTERVAL_TIME <= to_Date ( '17-May-2011 12:00'
     , 'DD-MON-YYYY HH24:MI' )
     group by c.object_name
     , c.owner
     order by 1 desc;

    Change order by
    1: For most Read Segments
    3: For most Writes on a segment
    4: For Waits


--List RAC databases and their Attributes like ClusterName, Dataguard Status.
--Change "property_name" attribute per your need

SELECT mgmt$target.host_name
 , mgmt$target.target_name
 , mgmt$target.target_type
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 and ( mgmt$target.target_type = 'rac_database' )
 and ( mgmt$target_properties.property_name in ( 'RACOption'
 , 'DBName'
 , 'DBDomain'
 , 'DBVersion'
 , 'ClusterName'
 , 'DataGuardStatus'
 , 'MachineName'
 , 'Role'
 , 'SID' ) )
 order by mgmt$target.host_name, mgmt$target.target_name,
mgmt$target_properties.property_name;  


--List Machine_Names, CPU Count & Database Verion for Licensing

SELECT mgmt$target.host_name
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 AND ( mgmt$target_properties.property_name in ( 'CPUCount','DBVersion' ) )
 GROUP BY mgmt$target.host_name
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 order by mgmt$target.host_name;


--List Targets with TNS Listener ports configured :

SELECT mgmt$target.host_name
 , mgmt$target.target_name
 , mgmt$target.target_type
 , mgmt$target_properties.property_name
 , mgmt$target_properties.property_value
 FROM mgmt$target
 , mgmt$target_properties
 WHERE ( mgmt$target.target_name = mgmt$target_properties.target_name )
 AND ( mgmt$target.target_type = mgmt$target_properties.target_type )
 and ( mgmt$target.target_type = 'oracle_listener' )
 and ( mgmt$target_properties.property_name = 'Port' );