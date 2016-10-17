(unmrdorc22) ora920:/home/oracle $ cat /admin/dba/scripts/misc_checks.sh
#!/bin/bash

num_args=$#
if [ $num_args -eq 1 ]; then
  export ORACLE_SID=$1
  export ORACLE_HOME=/usr/oracle/product/9.2.0
else
  echo " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "
  echo " @        Please Enter Database Name (ORACLE_SID)        @ "
  echo " @           e.g.  misc_check.ksh  ORCL               @ "
  echo " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ "
  exit
fi
# temporaty files
export TMP_FILE=/tmp/spacecheck_${ORACLE_SID}.rpt

#person to notify
export EMAIL_ALERT='Andrey.Dekanovich@mkcorp.com;Anatoly.Sedov@mkcorp.com'

# for user notification
echo `date` "Started misc checks for ${ORACLE_SID}"

${ORACLE_HOME}/bin/sqlplus -s /nolog << EOF
set time on
set echo on
set feedback on
set serveroutput on
connect / as sysdba
select instance_name from v\$instance;
-- new orders agreement checks
exec  oraadmin.sp_job_state_check(685,15,'${EMAIL_ALERT}');
-- long lock checks
exec  oraadmin.sp_lock_state_check(15,'Andrey.Dekanovich@mkcorp.com;Anatoly.Sedov@mkcorp.com');
EOF

echo `date` "Finished misc checks for ${ORACLE_SID}"
