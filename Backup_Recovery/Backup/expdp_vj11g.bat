REM @echo off
set ORACLE_HOME=c:\oracle\11203
set ORACLE_SID=VJ11G
SET DUMPFILE_FOLDER="D:\dpdump"
SET ARCHIVE_PROGRAM="C:\Program Files\7-Zip\7z.exe"

@echo off
for /F "tokens=1-4 delims=/ " %%i in ('date /t') do (
set WD=%%i
set D=%%j
set M=%%k
set Y=%%l
) 
echo %D%%M%%Y%

SET BASE_NAME=%ORACLE_SID%_%M%%D%%Y%_fullexp
SET DUMPFILE_NAME=%BASE_NAME%.dmp
SET LOGFILE_NAME=%BASE_NAME%.log
SET BACKUP_FOLDER=%DUMPFILE_FOLDER%
SET BACKUP_FILENAME=%BASE_NAME%.zip

REM Script begin
REM expdp, full backup to "dir_exp", flashback_time=systimestamp for consistency
expdp '/ as sysdba' full=y directory=dir_exp dumpfile=%DUMPFILE_NAME% logfile=%LOGFILE_NAME%

REM IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM ren %DUMPFILE_FOLDER%\export.log %LOGFILE_NAME%

REM ##%ARCHIVE_PROGRAM% a -tzip %BACKUP_FOLDER%\%BACKUP_FILENAME% %DUMPFILE_FOLDER%\%DUMPFILE_NAME% %DUMPFILE_FOLDER%\%LOGFILE_NAME%
REM IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM DEL %DUMPFILE_FOLDER%\%DUMPFILE_NAME%
REM DEL %DUMPFILE_FOLDER%\%LOGFILE_NAME%

REM EXIT 0

REM :ERROR
REM EXIT 1

