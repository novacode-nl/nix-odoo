-- odoo user
CREATE user odoo WITH createdb superuser;

-- Because postgres runs in single user mode,
-- create database with OS username.
-- CREATE DATABASE odoo;
