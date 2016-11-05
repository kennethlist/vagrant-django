#!/bin/bash

PROJECT_DIR=/home/vagrant/site
USER_HOME=/home/vagrant
MYSQL_ROOT_PASSWORD='vagrant'

# This function is called at the very bottom of the file
main() {
  echo "Seting up environment. This may take a few minutes..."
  install_core_components
  install_databases
  setup_virtual_env
  install_apache
  install_solr
  install_mailhog
  echo ""
  echo "Environment is now setup."
  echo ""
}

install_core_components() {
  echo "Updating package repositories..."
  apt-get update

  echo "Installing git..."
  apt-get -y install git

  echo "Installing pip.."
  apt-get -y install python-setuptools
  easy_install -U pip

  echo "Installing required packages for NFS file sharing for vagrant..."
  apt-get -y install nfs-common

  echo "Installing required packages for python package 'psycopg2'..."
  apt-get -y install python-dev libpq-dev

  echo "Installing required packages for pillow..."
  apt-get -y install libtiff5-dev libjpeg-turbo8 libjpeg-turbo8-dev libjpeg8 libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python-tk

  ## Fix pip ssl warnings
  apt-get -y install libffi-dev libssl-dev

  echo "Installing virtualenvwrapper from pip..."
  pip install virtualenvwrapper
}

install_databases(){
  echo "Installing required packages for postgres..."
  apt-get -y install postgresql

  echo "Configuring postgres..."
  sudo -u postgres psql -c "create user vagrant with password 'vagrant';"
  sudo -u postgres psql -c "create database vagrant;"
  sudo -u postgres psql -c "grant all privileges on database vagrant to vagrant;"

  echo "Installing mysql server"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
  sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"
  apt-get -y install mysql-server libmysqlclient-dev

  # echo "Updating mysql configs in /etc/mysql/my.cnf."
  # sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
  # sudo service mysql restart

  echo "source /usr/local/bin/virtualenvwrapper.sh" >> ${USER_HOME}/.bashrc
  echo "Seting up virtual environment.."
  sudo su - vagrant /bin/bash -c "source /usr/local/bin/virtualenvwrapper.sh;cd ${PROJECT_DIR};mkvirtualenv --always-copy --python=`which python` site; pip install pyopenssl ndg-httpsclient pyasn1; deactivate;"
}


install_apache() {
  echo "Installing Apache and WSGI..."
  apt-get -y install apache2 libapache2-mod-wsgi

  cat > /etc/apache2/sites-available/000-default.conf <<EOF
<VirtualHost *:80>
    Alias /media/ /home/vagrant/site/myproject/myproject/static/media

    <Directory /home/vagrant/site/myproject/myproject/static/media>
        Require all granted
    </Directory>

    Alias /static /home/vagrant/site/myproject/myproject/static
    <Directory /home/vagrant/site/myproject/myproject/static>
        Require all granted
    </Directory>

    <Directory /home/vagrant/site/myproject/myproject>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>

    WSGIDaemonProcess myproject python-path=/home/vagrant/site/myproject:/home/vagrant/.virtualenvs/site/lib/python2.7/site-packages
    WSGIProcessGroup myproject
    WSGIScriptAlias / /home/vagrant/site/myproject/myproject/wsgi.py

</VirtualHost>
EOF

  service apache2 restart
}

install_solr(){
  ##
  #	Setup Solr
  ##
  echo "Installing Solr..."
  apt-get -y install openjdk-7-jdk
  apt-get -y install solr-tomcat
  service tomcat6 restart
}

install_mailhog(){
  echo "Installing MailHog..."
  apt-get -y install golang
  echo "GOPATH=\$HOME/go" >> ${USER_HOME}/.bashrc
  echo "PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin" >> ${USER_HOME}/.bashrc
  sudo su - vagrant /bin/bash -c "export GOPATH=\$HOME/go; export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin; go get github.com/mailhog/mhsendmail"

  # Download binary from github
  sudo su - vagrant -c "wget --quiet -O ~/mailhog https://github.com/mailhog/MailHog/releases/download/v0.2.0/MailHog_linux_386 && chmod +x ~/mailhog"
    
  # Make it start on reboot
  sudo tee /etc/init/mailhog.conf <<EOL
description "Mailhog"
start on runlevel [2345]
stop on runlevel [!2345]
respawn
pre-start script
    exec su - vagrant -c "/usr/bin/env ~/mailhog > /dev/null 2>&1 &"
end script
EOL
    
  sudo service mailhog start
}


##
#	Run Setup
##
main
exit 0