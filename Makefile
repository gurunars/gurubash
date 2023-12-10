MAKEFLAGS += --silent

OS=$(shell ./pkg-manager/get-os.sh)

.PHONY: install upgrade $(MAKECMDGOALS)

install: check-os $(shell ls -d */ | sed -e 's/\//.install/')
	echo "DONE"

check-os:
	/bin/bash ./pkg-manager/get-os.sh

pkg-manager.install:
	/bin/bash pkg-manager/install.$(OS).sh
	echo "Configured package manager"

python.install: personal.install

git.install credentials.install theming.install: personal.install

aws.install: python.install

%.install: pkg-manager.install
	if [ -f $*/install.$(OS).sh ]; then \
		/bin/bash $*/install.$(OS).sh; \
	fi
	echo "Installed $*"
