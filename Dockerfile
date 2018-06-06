FROM python:2.7.14-slim-stretch
# FROM python:2.7.14-alpine3.7
LABEL maintainer="Just van den Broecke <justb4@gmail.com>"

# These are default values,
# Override when running container via docker(-compose)

# General ENV settings
ENV LC_ALL="en_US.UTF-8" \
	LANG="en_US.UTF-8" \
	LANGUAGE="en_US.UTF-8" \
	# WSGI server settings, assumed is gunicorn  \
	CONTAINER_HOST=0.0.0.0 \
	CONTAINER_PORT=80 \
	WSGI_WORKERS=4 \
	WSGI_WORKER_TIMEOUT=12000 \
	WSGI_WORKER_CLASS='sync'

RUN apt-get update \
    && apt-get --no-install-recommends install -y netbase gdal-bin \
	&& apt autoremove -y  \
    && rm -rf /var/lib/apt/lists/*

# Don't use eventlet here, somehow failed on K8s nginx setup
# See https://github.com/smartemission/smartemission/issues/120#issuecomment-395089636
RUN pip install gunicorn==19.8.1 flask==1.0.2 requests==2.18.4

# Add entry-script and app to root dir
COPY entry.sh /
ADD app /app

# Install and Remove build-related packages for smaller image size
RUN chmod a+x /*.sh

EXPOSE ${CONTAINER_PORT}

ENTRYPOINT /entry.sh
