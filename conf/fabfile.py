#-*- coding: utf-8 -*-
import os

from fabric.api import *  # NoQA
from protecomp.fabric.deploy import *  # NoQA
from protecomp.fabric.server_settings import *  # NoQA
from protecomp.fabric.util import *  # NoQA

env.local_base  = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../'))

@task
def staging():
    """Run commands on staging servers"""
    env.remote_base = "/project/root/dir"
    env.user = "project_user"
    env.roledefs = single_host('staging-server-hostname.tld')


@task
def testing():
    """Run commands on testservers"""
    env.remote_base = "/project/root/dir"
    env.user = "project_user"
    env.roledefs = single_host('testserver-hostname.tld')


# General configuration common for all environments
# These will be appended to local_base/remote_base
env.manage_path      = 'manage.py'
env.virtualenv_path  = 'virtualenv'
env.pip_requirements = 'conf/pip-requirements.txt'