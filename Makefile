MAKEFLAGS += --silent

OS=$(shell ./pkg-manager/get-os.sh)
GURUBASH=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
INSTALL=$(GURUBASH)/pkg-manager/install-if-missing.$(OS).sh

# A component is a directory holding an install*.sh; tasks/ and scripts/ are not one.
# Goals are not phony: a phony goal skips the %.install pattern rule.
COMPONENTS=$(patsubst %/,%,$(sort $(dir $(wildcard */install*.sh))))

.PHONY: install check-os pkg-manager.install
.EXPORT_ALL_VARIABLES:

install: check-os $(addsuffix .install,$(COMPONENTS))
	echo "DONE"

check-os:
	/bin/bash ./pkg-manager/get-os.sh

pkg-manager.install:
	/bin/bash pkg-manager/install.$(OS).sh
	echo "Configured package manager"

python.install: personal.install

ai.install: python.install

git.install credentials.install theming.install: personal.install

aws.install: python.install

%.install: pkg-manager.install
	if [ -f $*/install.$(OS).sh ]; then \
		/bin/bash $*/install.$(OS).sh; \
	fi
	if [ -f $*/install.sh ]; then \
		/bin/bash $*/install.sh; \
	fi
	echo "Installed $*"

