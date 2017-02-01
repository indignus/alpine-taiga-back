#!/bin/sh
cd /usr/local/taiga/taiga-back/

#echo "Waiting for Postgresql to be available..." 
#while !{nc -z $PGHOST 5432}; do sleep 1; done

cat > /usr/local/taiga/taiga-back/settings/local.py <<EOF
from .common import *

MEDIA_URL = "$SCHEME://$HOSTNAME/media/"
STATIC_URL = "$SCHEME://$HOSTNAME/static/"
STATIC_ROOT = "/usr/local/taiga/taiga-back/static"
SITES["api"]["scheme"] = "$SCHEME"
SITES["api"]["domain"] = "$HOSTNAME"
SITES["front"]["scheme"] = "$SCHEME"
SITES["front"]["domain"] = "$HOSTNAME"

SECRET_KEY = "$SECRET_KEY"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = False

ADMINS = (
    ("Admin", "$ADMIN_EMAIL"),
)

DEBUG = False

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "taiga",
        "HOST": "$PGHOST",
        "USER": "taiga",
        "PASSWORD": "$PGPASSWORD",
    }
}
EOF

cat > /usr/local/taiga/uwsgi.ini <<EOF
[uwsgi]
master = true
no-orphans = true
processes = 3
threads = 20
buffer-size = 32768
socket = 0.0.0.0:8000
uid = taiga
gid = taiga

chdir = /usr/local/taiga/taiga-back/
module = taiga.wsgi:application

vacuum = true
EOF

#initial setup
#python3 manage.py migrate --noinput
#python3 manage.py loaddata initial_user
#python3 manage.py loaddata initial_project_templates
#python3 manage.py loaddata initial_role
#python3 manage.py compilemessages
python3 manage.py collectstatic --noinput
set -x chown -R taiga:taiga /usr/local/taiga
uwsgi --ini /usr/local/taiga/uwsgi.ini
