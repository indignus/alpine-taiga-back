#!/bin/sh
cd /usr/local/taiga/taiga-back/

#echo "Waiting for Postgresql to be available..." 
#while !{nc -z $PGHOST 5432}; do sleep 1; done

cat > /usr/local/taiga/taiga-back/settings/local.py <<EOF
from .common import *

MEDIA_URL = "$SCHEME://$HOSTNAME/media/"
STATIC_URL = "$SCHEME://$HOSTNAME/static/"
ADMIN_MEDIA_PREFIX = "$SCHEME://$HOSTNAME/static/admin/"
SITES["front"]["scheme"] = "$SCHEME"
SITES["front"]["domain"] = "$HOSTNAME"

SECRET_KEY = "$SECRET_KEY"

DEBUG = False
TEMPLATE_DEBUG = False
PUBLIC_REGISTER_ENABLED = True


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
threads = 60

socket = 0.0.0.0:8000
http = 0.0.0.0:80

chdir = /usr/local/taiga/taiga-back/
module = taiga.wsgi:application

vacuum = true
EOF

python manage.py migrate --noinput
python manage.py loaddata initial_user
python manage.py loaddata initial_project_templates
python manage.py loaddata initial_role
python manage.py compilemessages
python manage.py collectstatic --noinput

uwsgi --ini /usr/local/taiga/uwsgi.ini
