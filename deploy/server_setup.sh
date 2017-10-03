#!/usr/bin/env bash

# TODO: Set to URL of git repo.
PROJECT_GIT_URL='https://github.com/karim-aly/digital-library.git'

PROJECT_BASE_PATH='/usr/local/apps'
VIRTUALENV_BASE_PATH='/usr/local/virtualenvs'

# Set Ubuntu Language
locale-gen en_GB.UTF-8

# Install Python, SQLite and pip
apt-get update
apt-get install -y python3-dev sqlite python-pip supervisor nginx git

# Upgrade pip to the latest version.
pip install --upgrade pip
pip install virtualenv

mkdir -p $PROJECT_BASE_PATH
git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH/digital_library

mkdir -p $VIRTUALENV_BASE_PATH
virtualenv  $VIRTUALENV_BASE_PATH/digital_library

source $VIRTUALENV_BASE_PATH/digital_library/bin/activate
pip install -r $PROJECT_BASE_PATH/digital_library/requirements.txt

# Run migrations
cd $PROJECT_BASE_PATH/digital_library

# Setup Supervisor to run our uwsgi process.
cp $PROJECT_BASE_PATH/digital_library/deploy/supervisor_digital_library.conf /etc/supervisor/conf.d/digital_library.conf
supervisorctl reread
supervisorctl update
supervisorctl restart digital_library

# Setup nginx to make our application accessible.
cp $PROJECT_BASE_PATH/digital_library/deploy/nginx_digital_library.conf /etc/nginx/sites-available/digital_library.conf
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/digital_library.conf /etc/nginx/sites-enabled/digital_library.conf
systemctl restart nginx.service

echo "DONE! :)"
