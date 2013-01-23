#!/bin/bash

apt-get update
apt-get remove dragonplayer amarok bluedevil kopete ktorrent quassel kppp akregator
apt-get install git vim-nox pylint debhelper devscripts python-setuptools
apt-get install python-support ipython yakuake pidgin chromium-browser dia vls
apt-get autoremove
apt-get upgrade
