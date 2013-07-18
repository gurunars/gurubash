#!/bin/bash

apt-get update
apt-get remove dragonplayer amarok bluedevil kopete ktorrent quassel kppp akregator
apt-get install vim-nox pylint debhelper devscripts python-setuptools python-support ipython yakuake
apt-get autoremove
apt-get upgrade
