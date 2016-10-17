rem RMAN hot backup for windows
REM USAGE
rem	rman_backup.bat <dbname> <bktype> <levelbck>
rem 	bktype 
rem   	- hot   -- DB backup + archive
rem   	- arch  -- archive
rem 	levelbck -- 0 full
rem 	levelbck -- 1 increment
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

for /F "tokens=1-4 delims=/ " %%i in ('date /t') do (
set WD=%%i
set D=%%j
set M=%%k
set Y=%%l
) 
@echo on

cd %TMPDIR%

REM This bit generates the RMAN script to backup database,
REM archivelogs and control file and then crosscheck output.
echo run { > rman_%ORACLE_SID%.rcv
echo allocate channel d1 type disk; >> rman_%ORACLE_SID%.rcv
echo allocate channel d2 type disk; >> rman_%ORACLE_SID%.rcv
echo allocate channel d3 type disk; >> rman_%ORACLE_SID%.rcv

if %BKTYPE%==hot goto HOTFULL
if %BKTYPE%==arch goto END

:HOTFULL
REM This starts RMAN, executes the script created earlier, then exits.
rem cd %RMAN_DEST%
if %LEVELBCK%==0 goto FULL
if %LEVELBCK%==1 goto INCR
if %LEVELBCK%==2 goto CUMU

:FULL
set RMANLEVEL=full
del %RMAN_DEST%*.* /q
echo backup full format '%RMAN_DEST%\FULL_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='full_backup';>>rman_%ORACLE_SID%.rcv
rem rman target / catalog=%CATALOG_PASS% cmdfile=%TMPDIR %rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %TMPDIR\rman_%ORACLE_SID%.rcv
goto END

:INCR
set RMANLEVEL=incr
echo backup incremental level %LEVELBCK% format '%RMAN_DEST%\INCR_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='incremental';>>rman_%ORACLE_SID%.rcv
rem rman target / catalog=%CATALOG_PASS% cmdfile=%TMPDIR%rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %TMPDIR%\rman_%ORACLE_SID%.rcv
goto END

:CUMU
set RMANLEVEL=cumu
echo backup incremental level %LEVELBCK% CUMULATIVE format '%RMAN_DEST%\CUMU_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database tag='cumulative';>>rman_%ORACLE_SID%.rcv
rem rman target / catalog=%CATALOG_PASS% cmdfile=%TMPDIR %rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%rman_%ORACLE_SID%.log
rem rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %TMPDIR%\rman_%ORACLE_SID%.rcv

:END
echo sql 'alter system archive log current'; >>rman_%ORACLE_SID%.rcv
echo backup archivelog all format '%RMAN_DEST%\ARC_%ORACLE_SID%_t%%t_s%%s_p%%p.arc' delete input ;>>rman_%ORACLE_SID%.rcv
echo backup current controlfile format '%RMAN_DEST%\CTL_%ORACLE_SID%_t%%t_s%%s_p%%p.ctl';>>rman_%ORACLE_SID%.rcv
echo release channel d1; >> rman_%ORACLE_SID%.rcv
echo release channel d2; >> rman_%ORACLE_SID%.rcv
echo release channel d3; >> rman_%ORACLE_SID%.rcv
echo } >> rman_%ORACLE_SID%.rcv
echo allocate channel for maintenance type disk; >> rman_%ORACLE_SID%.rcv
echo sql 'alter system archive log current'; >> rman_%ORACLE_SID%.rcv
echo crosscheck backup; >> rman_%ORACLE_SID%.rcv
echo crosscheck backup of archivelog all; >> rman_%ORACLE_SID%.rcv
echo crosscheck backup of controlfile; >> rman_%ORACLE_SID%.rcv
echo delete expired backup; >> rman_%ORACLE_SID%.rcv
echo delete expired archivelog all; >> rman_%ORACLE_SID%.rcv
echo release channel; >> rman_%ORACLE_SID%.rcv
echo exit >> rman_%ORACLE_SID%.rcv

REM backup database with archivelogs
%ORACLE_HOME%\bin\rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\%ORACLE_SID%_%BKTYPE%_%RMANLEVEL%_%M%%D%%Y%.log

