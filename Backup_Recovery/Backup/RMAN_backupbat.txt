rem RMAN hot backup for windows

set ORACLE_HOME=c:\oracle\11203
SET ORACLE_SID=%1%
rem SET RMAN_DB=%2%
rem SET CATALOG_PASS=%3%
SET LEVELBCK=%2%
rem SET CATALOG_PASS=rman/%CATALOG_PASS%@%RMAN_DB%
SET RMAN_DEST=J:\DB_Backup\%ORACLE_SID%\rman
SET LOG_DEST=J:\DB_Backup\%ORACLE_SID%\rman\LOGS
SET NLS_LANG=AMERICAN_AMERICA.UTF8
SET TMPDIR=J:\DB_Backup

@echo on

cd %TMPDIR%

REM This bit generates the RMAN script to backup database,
REM archivelogs and control file and then crosscheck output.
echo run { > rman_%ORACLE_SID%.rcv
echo allocate channel d1 type disk; >> rman_%ORACLE_SID%.rcv
echo allocate channel d2 type disk; >> rman_%ORACLE_SID%.rcv
echo allocate channel d3 type disk; >> rman_%ORACLE_SID%.rcv
echo backup incremental level %LEVELBCK% format '%RMAN_DEST%\DBF_%ORACLE_SID%_t%%t_s%%s_p%%p.db' database;>>rman_%ORACLE_SID%.rcv
echo sql 'alter system archive log current'; >>rman_%ORACLE_SID%.rcv
echo backup archivelog all format '%RMAN_DEST%\ARC_%ORACLE_SID%_t%%t_s%%s_p%%p.arc';>>rman_%ORACLE_SID%.rcv
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
echo release channel; >> rman_%ORACLE_SID%.rcv
echo exit >> rman_%ORACLE_SID%.rcv

REM This starts RMAN, executes the script created earlier, then exits.
cd %RMAN_DEST%
if %LEVELBCK%==1 goto INCR
if %LEVELBCK%==0 goto FULL

:FULL
del %RMAN_DEST%*.* /q
rem rman target / catalog=%CATALOG_PASS% cmdfile=%TMPDIR%rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %TMPDIR\rman_%ORACLE_SID%.rcv
goto END
:INCR
rem rman target / catalog=%CATALOG_PASS% cmdfile=%TMPDIR%rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%rman_%ORACLE_SID%.log
rman target / nocatalog cmdfile=%TMPDIR%\rman_%ORACLE_SID%.rcv msglog=%LOG_DEST%\rman_%ORACLE_SID%.log
rem del %TMPDIR%\rman_%ORACLE_SID%.rcv
:END


rem http://www.jobacle.nl/?p=849