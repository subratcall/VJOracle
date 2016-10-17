BEGIN
  dbms_network_acl_admin.create_acl (
                acl             => 'oracle_smtp.xml',
                description     => 'Normal Access',
                principal       => 'SYS',
                is_grant        => TRUE,
                privilege       => 'connect',
                start_date      => null,
                end_date        => null
        );

end;
/

BEGIN

  dbms_network_acl_admin.assign_acl (
  acl => 'oracle_smtp.xml',
  host => 'vcorpmsg01.mkcorp.com',
  lower_port => 25,
  upper_port => NULL);
END;
/

BEGIN
  dbms_network_acl_admin.assign_acl (
  acl => 'oracle_smtp.xml',
  host => '*',
  lower_port => NULL,
  upper_port => NULL);
END;
/


BEGIN
  dbms_network_acl_admin.add_privilege (
  acl                  => 'oracle_smtp.xml',
  principal            => 'DBA_ADMIN',
  is_grant             => TRUE,
  privilege            => 'connect',
  start_date           => null,
  end_date             => null);
END;
/

BEGIN
  dbms_network_acl_admin.add_privilege (
  acl                  => 'oracle_smtp.xml',
  principal            => 'SYSTEM',
  is_grant             => TRUE,
  privilege            => 'connect',
  start_date           => null,
  end_date             => null);
END;
/

