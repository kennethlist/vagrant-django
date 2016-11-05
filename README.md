# django-environment-in-vagrant v0.1

## Starting the virtual machine development environment

The following command will start the environment:

    vagrant up

The first time this command is issued it will provision the virtual machine via the `vagrant_setup.sh` script.

## Connecting and setting up the virtual environment in the virtual machine

SSH into the virtual machine:

    vagrant ssh
    
Always run the following command to use the proper python virtual environment:

    workon site

The source code is shared with the virtual machine in this directory:

    cd ~/site

## Folder structure
```
~/site

│   README.md
│   Vagrantfile
│   vagrant_setup.sh
│
├───myproject (example)
│       manage.py
├───────myproject
│           requirements.txt
│           settings.py
│           urls.py
│           wsgi.py
│           __init__.py
│
└───static
```
    
## Existing Project

Clone your Django repo into the `myproject` folder:

    cd ~/site/myproject
    git clone <URL> .

Where `myproject` is the name of your new website or project.


## Required Setup

Install the required python packages:
    workon site
    cd ~/site
    pip install -r requirements.txt


## Creating a new Django project

Create a new Django project.

    cd ~/site/myproject
    django-admin.py startproject myproject .



## Launch

Setup the database models and run migrations:

    ./manage.py migrate

You can now start the development web server. Make sure to include the port number to connect externally:

    ./manage.py runserver 0.0.0.0:8000

(Optional) Create an Admin user
	
	./manage.py createsuperuser
		

## Database Credentials
**Postgres**
```
User: vagrant
Password: vagrant
Database: vagrant
```
**MySQL**
```
User: root
Password: vagrant
Port: 3306
```



## Solr schema.xml location
```
/usr/share/solr/conf/schema.xml
```

http://YOUR_IP:8080/solr
