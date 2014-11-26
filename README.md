django-project-template
=======================

Empty Django project template with various basic configuration files

Usage:

* rename PROJECT-dir
* set your project name inside files
** celery.py
** wsgi.py
* copy conf/vagrant/Vagrantfile.template to repository root as Vagrantfile
* Modify bootstrap_common and set PROJECT_NAME, DATABASE_* and ENV_NAME

Additional steps (optional):

* check Vagrantfile for IP address, hostname etc.
* edit local_apps/setup.py