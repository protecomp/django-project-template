#!/usr/bin/env bash

# VAGRANT PROVISIONING SCRIPT FOR UBUNTU 14.04

## CONFIGURATION ##

PROJECT_NAME=PROJECT
DATABASE_NAME=PROJECT_DB
DATABASE_USER=PROJECT_DB_USER
ENV_NAME=PROJECT_ENV

cp -f ~/development/conf/vagrant/gitconfig ~/.gitconfig
cp -f ~/development/conf/vagrant/bash_aliases ~/.bash_aliases

# Fix locale vars
locale-gen fi_FI.UTF-8
cat <<END > /tmp/locale && mv /tmp/locale /etc/default/locale
LANG=en_US.UTF-8
LC_CTYPE=fi_FI.UTF-8
LC_NUMERIC=fi_FI.UTF-8
LC_TIME=fi_FI.UTF-8
LC_COLLATE=fi_FI.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_ALL=
END

# Add all required keys to known hosts
cat <<END | ssh-keyscan -f- > /etc/ssh/ssh_known_hosts
github.com
bitbucket.org
END

# Auto-selection of fast nearby mirrors for apt
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt saucy main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt saucy-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt saucy-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt saucy-security main restricted universe multiverse" \
    | cat - /etc/apt/sources.list > /tmp/newsources && mv /tmp/newsources /etc/apt/sources.list

# Before installing packages, disable all user interaction in apt:
export DEBIAN_FRONTEND=noninteractive 

# System software installation
apt-get update
apt-get install -y vim git nginx pwgen
apt-get install -y python-dev python-setuptools gettext
apt-get install -y avahi-daemon
apt-get install -y ack-grep
dpkg-divert --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep

apt-get install -y python-mysqldb python-imaging python-crypto libevent-dev

MYSQL_ROOT_PW=$(pwgen 14 1)
echo "mysql-server-5.1 mysql-server/root_password password $MYSQL_ROOT_PW" | debconf-set-selections
echo "mysql-server-5.1 mysql-server/root_password_again password $MYSQL_ROOT_PW" | debconf-set-selections

cat <<END > /root/.my.cnf
[client]
password = $MYSQL_ROOT_PW
END

# MySQL
apt-get install -y mysql-server libmysqlclient-dev mysql-client

# Memcached stuff
apt-get install -y libmemcached-dev

apt-get autoremove -y

easy_install pip
pip install virtualenv
pip install virtualenvwrapper
pip install ipython
pip install mercurial


# MySQL conf
cat <<END > /etc/mysql/conf.d/vagrant.cnf
[client]
default-character-set = utf8

[mysqld]
character-set-server  = utf8
collation-server      = utf8_swedish_ci
character_set_server   = utf8
collation_server       = utf8_swedish_ci
END

service mysql restart

mkdir /home/vagrant/logs
mkdir /home/vagrant/staticfiles
mkdir /home/vagrant/uploads
# ~/virtualenvs created by mkvirtualenv below
ln -s /vagrant_src /home/vagrant/development

MYSQL_USER_PW=$(pwgen 8 1)

mysqladmin -u root -p$MYSQL_ROOT_PW create $DATABASE_NAME
mysql -u root -e "CREATE USER $DATABASE_USER@localhost IDENTIFIED BY '$MYSQL_USER_PW'"
mysql -u root -e "GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO $DATABASE_USER@localhost"

cat <<END > /home/vagrant/.my.cnf
[client]
user = $DATABASE_USER
password = $MYSQL_USER_PW
database = $DATABASE_NAME
END

cat <<END >> /home/vagrant/.bashrc

export WORKON_HOME=/home/vagrant/virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
END

# User software and dev environment installation
export WORKON_HOME=/home/vagrant/virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv --system-site-packages $ENV_NAME && deactivate

cat <<END > /home/vagrant/virtualenvs/$ENV_NAME/.project
/home/vagrant/development
END

ln -sf /home/vagrant/development/conf/vagrant/nginx.conf /etc/nginx/sites-enabled/$PROJECT_NAME.conf
rm -f /etc/nginx/sites-enabled/default

rm /home/vagrant/virtualenvs/$ENV_NAME/bin/postactivate /home/vagrant/virtualenvs/$ENV_NAME/bin/predeactivate
ln -sf /home/vagrant/development/conf/vagrant/postactivate /home/vagrant/virtualenvs/$ENV_NAME/bin/postactivate
ln -sf /home/vagrant/development/conf/vagrant/predeactivate /home/vagrant/virtualenvs/$ENV_NAME/bin/predeactivate
sed -i -e "s/www-data/vagrant/g" /etc/nginx/nginx.conf

workon $ENV_NAME
cd /home/vagrant/development
pip install -r conf/pip-requirements.txt

# always install ipython and Fabric inside virtualenv
pip install --upgrade --force-reinstall ipython
pip install --upgrade --force-reinstall Fabric

chown -R vagrant:vagrant /home/vagrant/
