DELETE FROM fetchmail_server;
DELETE FROM ir_mail_server;
UPDATE ir_cron SET active = False;
UPDATE ir_config_parameter SET VALUE = 'accept' WHERE KEY = 'server.mode';
UPDATE ir_config_parameter SET VALUE = 'https://beurtvaartadres.blueminds.nl/api' WHERE KEY = 'bva.editor.api.url';
UPDATE res_users SET login='admin', password = 'admin' WHERE id = 2;
