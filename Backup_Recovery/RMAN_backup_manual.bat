run {
allocate channel d1 type disk; 
allocate channel d2 type disk; 
allocate channel d3 type disk; 
allocate channel d4 type disk; 
allocate channel d5 type disk; 
backup as compressed backupset incremental level 0 filesperset 15 format 'E:\db_backup\vj12c\rman\full\full_cold_VJ12C_%t_%s_%p.db' database tag='full_cold_11072014';
backup as compressed backupset current controlfile format 'E:\db_backup\vj12c\rman\ctrl\full_cold_CTL_VJ12C_%T_%s_%p.ctl';
backup spfile format 'E:\db_backup\vj12c\rman\ctrl\full_cold_spfile_VJ12C_%T_%s_%p.ora';
release channel d1;
release channel d2;
release channel d3;
release channel d4;
release channel d5;
}