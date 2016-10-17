--connect / as sysasm
spool asm<#>_Generic_ASM_metadata.html
-- ASM Versions 10.1, 10.2, 11.1  & 11.2
SET MARKUP HTML ON
set echo on

set pagesize 200

alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

select 'THIS ASM REPORT WAS GENERATED AT: ==)> ' , sysdate " "  from dual;


select 'HOSTNAME ASSOCIATED WITH THIS ASM INSTANCE: ==)> ' , MACHINE " " from v$session where program like '%SMON%';

select * from v$asm_diskgroup;

SELECT * FROM  V$ASM_DISK ORDER BY GROUP_NUMBER,DISK_NUMBER;  

SELECT SUBSTR(d.name,1,16) AS asmdisk, d.mount_status, d.state,
     dg.name AS diskgroup FROM V$ASM_DISKGROUP dg, V$ASM_DISK d
     WHERE dg.group_number = d.group_number;


SELECT * FROM V$ASM_CLIENT;

 SELECT dg.name AS diskgroup, SUBSTR(c.instance_name,1,12) AS instance,
    SUBSTR(c.db_name,1,12) AS dbname, SUBSTR(c.SOFTWARE_VERSION,1,12) AS software,
    SUBSTR(c.COMPATIBLE_VERSION,1,12) AS compatible
    FROM V$ASM_DISKGROUP dg, V$ASM_CLIENT c  
    WHERE dg.group_number = c.group_number;

select * from V$ASM_ATTRIBUTE;

select * from v$asm_operation;
select * from gv$asm_operation;


select * from v$version;


select * from   V$ASM_ACFSSNAPSHOTS;
select * from   V$ASM_ACFSVOLUMES;
select * from   V$ASM_FILESYSTEM;
select * from   V$ASM_VOLUME;
select * from   V$ASM_VOLUME_STAT;

select * from   V$ASM_USER;
select * from   V$ASM_USERGROUP;
select * from   V$ASM_USERGROUP_MEMBER;

select * from   V$ASM_DISK_IOSTAT;
select * from   V$ASM_DISK_STAT;
select * from   V$ASM_DISKGROUP_STAT;

select * from   V$ASM_TEMPLATE;

show parameter asm
show parameter cluster
show parameter instance_type
show parameter instance_name
show parameter spfile

show sga

!echo "select '" > /tmp/gpnptool.sql 2> /dev/null
! $ORACLE_HOME/bin/gpnptool get >> /tmp/gpnptool.sql 2>> /dev/null
!echo "'  from dual;" >> /tmp/gpnptool.sql 2>> /dev/null
! cat /tmp/gpnptool.sql 
set echo off




spool off

exit

