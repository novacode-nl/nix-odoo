DELETE FROM fetchmail_server;
DELETE FROM ir_mail_server;
DELETE FROM auth_saml_token;
DELETE FROM auth_saml_provider;
DELETE FROM ir_config_parameter WHERE key = 'auth_totp.policy';
DELETE FROM account_online_link;
DELETE FROM printnode_printer;

UPDATE res_users SET login='admin', password = 'admin' WHERE id = 2;
UPDATE res_users SET totp_secret = NULL;

UPDATE ir_cron SET active = False;
UPDATE ir_config_parameter SET VALUE = 'accept' WHERE KEY = 'server.mode';
UPDATE ir_config_parameter SET VALUE = 'False' WHERE KEY = 'auth_saml.allow_saml_uid_and_internal_password';
UPDATE ir_config_parameter SET VALUE = 'True' WHERE KEY = 'email.validator.staging.test_environment.partner';
