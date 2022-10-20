#!/bin/bash

read -r -p 'database: ' database

if [ -z "$database" ]
then
   echo "database name is required!"
   exit 1;
fi

su - postgres -c "psql $database" < AFTER_RESTORE.sql
