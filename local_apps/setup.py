#!/usr/bin/env python
from setuptools import setup, find_packages

setup(
    name="Local_apps",
    version="0.0.0",
    url = 'http://github.com/protecomp/django-project-template',
    author = '',
    author_email = '',
    description = 'Local apps and libraries for Django project template',
    packages=find_packages(),
    install_requires=[
        'Django >= 1.6',
    ],
    include_package_data=True,
)
