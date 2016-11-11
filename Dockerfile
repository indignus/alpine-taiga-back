FROM alpine
MAINTAINER indignus

RUN apk --no-cache --update add python3 postgresql-dev libxslt-dev libxml2-dev libjpeg-turbo-dev zeromq-dev && \
    apk add --no-cache --virtual .build-dependencies musl-dev python3-dev linux-headers \ 
      git zlib-dev libjpeg-turbo-dev gcc && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools uwsgi && \
    mkdir -p /usr/local/taiga && adduser -D -h /usr/local/taiga taiga && \
    git clone https://github.com/taigaio/taiga-back.git /usr/local/taiga/taiga-back && \
    mkdir /usr/local/taiga/logs && \
    cd /usr/local/taiga/taiga-back && \
    git checkout stable && \
    LIBRARY_PATH=/lib:/usr/lib /bin/sh -c "pip install -r requirements.txt" && \
    touch /usr/local/taiga/taiga-back/settings/dockerenv.py && \
    rm -r /root/.cache && \
    apk del .build-dependencies

COPY ./entrypoint.sh /
EXPOSE 8000
CMD ["/entrypoint.sh"]
