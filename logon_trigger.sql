create or replace trigger tr_after_logon
    after logon on database WHEN (USER = 'BAR')
    begin
            execute immediate 'alter session set optimizer_features_enable=''11.2.0.3''';
    end;
/



CREATE OR REPLACE TRIGGER SYS.TR_BPM_LOGON_trace
  AFTER LOGON
  ON DATABASE
  ENABLE
  declare
  v_user varchar2(30):=user;
  sql_stmt1 varchar2(256) :='alter session set sql_trace=true';
  begin
   if (v_user='BPM_ETL_EXTRACT') THEN
execute immediate 'ALTER SESSION SET TRACEFILE_IDENTIFIER=''BPM_ETL''';
execute immediate 'alter session set timed_statistics=true';
execute immediate 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 12''';
    end if;
 end;
 /