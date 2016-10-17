rem RMAN hot backup for windows
REM USAGE
rem	rman_backup.bat <dbname> <bktype> <levelbck>
rem 	bktype 
rem   	- hot   -- DB backup + archive
rem   	- arch  -- archive
rem 	levelbck -- F full backup  - not part of incremental backup
rem 	levelbck -- 0 increment full (level 0)
rem 	levelbck -- 1 increment differential
rem 	levelbck -- 2 increment cumulative
rem	rman_backup.bat testdb hot 0  --for full backup
rem	rman_backup.bat testdb hot 1  --for incremental backup
rem	rman_backup.bat testdb hot 2  --for incremental cumulative backup
rem	rman_backup.bat testdb arch         --for archivelog backup


set ORACLE_HOME=C:\oracle\db_12rR1
SET ORACLE_SID=%1%
SET BKTYPE=%2%
rem SET RMAN_DB=%2%
rem SET CATALOG_PASS=%3%
SET LEVELBCK=%3%
rem SET CATALOG_PASS=rman/%CATALOG_PASS%@%RMAN_DB%
SET RMAN_DEST=G:\backup\%ORACLE_SID%\rman
SET LOG_DEST=G:\backup\%ORACLE_SID%\rman\log
SET NLS_LANG=AMERICAN_AMERICA.UTF8
SET TMPDIR=c:\Temp
SET rcvfile=%TMPDIR%\rman_%ORACLE_SID%.rcv

:: CREATE VARIABLE %TIMESTAMP%

for /f "tokens=1-8 delims=.:/-, " %%i in ('echo exit^|cmd /q /k"prompt $D $T"') do (
   for /f "tokens=2-4 delims=/-,() skip=1" %%a in ('echo.^|date') do (
set dow=%%i
set mm=%%j
set dd=%%k
set yy=%%l
set hh=%%m
set mi=%%n
set ss=%%o
)
)

@echo on

cd %TMPDIR%

REM This bit generates the RMAN script to backup database,
REM archivelogs and control file and then crosscheck output.
echo run { > %rcvfile%
echo allocate channel d1 type disk; >> %rcvfile%
echo allocate channel d2 type disk; >> %rcvfile%
echo allocate channel d3 type disk; >> %rcvfile%
echo allocate channel d4 type disk; >> %rcvfile%
echo allocate channel d5 type disk; >> %rcvfile%

if %BKTYPE%==hot goto HOTFULL
if %BKTYPE%==arch goto END

:HOTFULL
REM This starts RMAN, executes the script created earlier, then exits.
rem cd %RMAN_DEST%
if %LEVELBCK%==F goto FULL
if %LEVELBCK%==0 goto INCR0
if %LEVELBCK%==1 goto INCR1
if %LEVELBCK%==2 goto INCR2

set stime=Backup started on %date% at %time%


:FULL
set RMANLEVEL=full
del %RMAN_DEST%*.* /q
echo backup full filesperset 4 format '%RMAN_DEST%\full\FULL_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='full_backup';>> %rcvfile%
rem rman target / catalog=%CATALOG_PASS% cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %rcvfile%
goto END

:INCR0
set RMANLEVEL=incr0
del %RMAN_DEST%*.* /q
echo backup as compressed backupset incremental level 0 filesperset 4 format '%RMAN_DEST%\full\FULL_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='incr_full';>> %rcvfile%
rem rman target / catalog=%CATALOG_PASS% cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %rcvfile%
goto END

:INCR1
set RMANLEVEL=diff
echo backup as compressed backupset incremental level %LEVELBCK% filesperset 4 format '%RMAN_DEST%\incr\INCR_DIFF_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='incr_diff';>> %rcvfile%
rem rman target / catalog=%CATALOG_PASS% cmdfile=%rcvfile% msglog=%LOG_DEST%rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %rcvfile%
goto END

:INCR2
set RMANLEVEL=cumu
echo backup as compressed backupset incremental level %LEVELBCK% CUMULATIVE filesperset 4 format '%RMAN_DEST%\incr\INCR_CUMU_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='incr_cumu';>> %rcvfile%
rem rman target / catalog=%CATALOG_PASS% cmdfile=%rcvfile% msglog=%LOG_DEST%rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%rcvfile% msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %rcvfile%

:END
echo sql 'alter system archive log current'; >> %rcvfile%
rem echo backup archivelog all filesperset 30 format '%RMAN_DEST%\arch\ARC_%ORACLE_SID%_%%T_s%%s_p%%p.arc' delete input ;>> %rcvfile%
echo backup as compressed backupset archivelog all filesperset 30 format '%RMAN_DEST%\arch\ARC_%ORACLE_SID%_%%T_s%%s_p%%p.arc' ;>> %rcvfile%
echo backup as compressed backupset current controlfile format '%RMAN_DEST%\ctrl\CTL_%ORACLE_SID%_%%T_s%%s_p%%p.ctl';>> %rcvfile%
echo backup spfile format '%RMAN_DEST%\ctrl\spfile_%ORACLE_SID%_%%T_s%%s_p%%p.ora'; >> %rcvfile%
echo release channel d1; >> %rcvfile%
echo release channel d2; >> %rcvfile%
echo release channel d3; >> %rcvfile%
echo release channel d4; >> %rcvfile%
echo release channel d5; >> %rcvfile%
echo } >> %rcvfile%
echo allocate channel for maintenance type disk; >> %rcvfile%
echo delete archivelog all backed up 2 times to device type disk; >> %rcvfile%
rem echo sql 'alter system archive log current'; >> %rcvfile%
rem echo crosscheck backup; >> %rcvfile%
rem echo crosscheck backup of archivelog all; >> %rcvfile%
rem echo crosscheck backup of controlfile; >> %rcvfile%
rem echo delete expired backup; >> %rcvfile%
rem echo delete expired archivelog all; >> %rcvfile%
echo release channel; >> %rcvfile%
echo exit >> %rcvfile%

REM backup database with archivelogs
%ORACLE_HOME%\bin\rman target / nocatalog cmdfile=%rcvfile% msglog=%LOG_DEST%\%ORACLE_SID%_%BKTYPE%_%RMANLEVEL%_%mm%%dd%%yy%_%hh%%mi%%ss%.log

set etime=Backup completed on %date% at %time%

echo %stime% >> %LOG_DEST%\%ORACLE_SID%_%BKTYPE%_%RMANLEVEL%_%mm%%dd%%yy%_%hh%%mi%%ss%.log
echo %etime% >> %LOG_DEST%\%ORACLE_SID%_%BKTYPE%_%RMANLEVEL%_%mm%%dd%%yy%_%hh%%mi%%ss%.log

