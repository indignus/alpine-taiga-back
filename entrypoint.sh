#!/bin/sh
cd /usr/local/taiga/taiga-back/
python3 manage.py collectstatic --noinput

#echo "Waiting for Postgresql to be available..."
#while !{nc -z $PG_HOST 5432}; do sleep 1; done

python3 manage.py migrate --noinput
python3 manage.py loaddata initial_user
python3 manage.py loaddata initial_project_templates
python3 manage.py loaddata initial_role

chown -R taiga /usr/local/taiga/logs
circusd /usr/local/taiga/circus.ini
tail -n 0 -f /usr/local/taiga/logs/* &
