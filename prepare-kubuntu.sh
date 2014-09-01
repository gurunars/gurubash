#!/bin/bash

apt-get update
apt-get remove dragonplayer amarok bluedevil kopete ktorrent quassel kppp akregator
apt-get install vim-nox pylint debhelper devscripts python-setuptools ipython yakuake python-pip
apt-get autoremove
apt-get upgrade

pip install nose mock rednose virtualenv
