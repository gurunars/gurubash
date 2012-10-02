#!/bin/sh

set -e

PROJECT_DIRECTORY=`git rev-parse --show-toplevel`
cd $PROJECT_DIRECTORY

echo "Preparing the environment"
make setup

PROJECT_NAME=`cd src && python setup.py --name`

cd src

echo "Running pep8"
pep8 $PROJECT_NAME

echo "Running pylint to detect errors"
pylint -E $PROJECT_NAME

echo "Running unittests"
nosetests .

cd $PROJECT_DIRECTORY

echo "Building deb package locally"
dpkg-buildpackage -rfakeroot -uc -us -sa -tc -D -I.git
