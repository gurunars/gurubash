
MAKEFLAGS += --silent

OS=$(shell /bin/bash ./core/pkg-manager/get-os.sh)
GURUBASH=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
INSTALL=$(GURUBASH)/core/pkg-manager/install-if-missing.$(OS).sh

# `make` installs the core: its directories holding an install*.sh.
# Goals are not phony: a phony goal skips the %.install pattern rule.
CORE=$(patsubst core/%/,%,$(sort $(dir $(wildcard core/*/install*.sh))))

component_dir=$(patsubst %/,%,$(firstword $(wildcard core/$(1)/ extensions/$(1)/)))

.PHONY: install check-os pkg-manager.install
.EXPORT_ALL_VARIABLES:

install: check-os $(addsuffix .install,$(CORE))
	echo "DONE"

check-os:
	/bin/bash ./core/pkg-manager/get-os.sh

# bins are made executable here because the checkout may not carry the bit.
pkg-manager.install:
	/bin/bash core/pkg-manager/install.$(OS).sh
	find core/pkg-manager/bins -type f -exec chmod +x {} +
	echo "Configured package manager"

python.install: personal.install

git.install credentials.install theming.install: personal.install

# An extension's `requires` go first: `aws.install: python.install`.
$(foreach r,$(wildcard extensions/*/requires),$(eval $(patsubst extensions/%/requires,%,$(r)).install: $(addsuffix .install,$(shell cat $(r)))))

%.install: pkg-manager.install
	$(if $(call component_dir,$*),,$(error No core component or extension named $*))
	if [ -f $(call component_dir,$*)/install.$(OS).sh ]; then \
		/bin/bash $(call component_dir,$*)/install.$(OS).sh; \
	fi
	if [ -f $(call component_dir,$*)/install.sh ]; then \
		/bin/bash $(call component_dir,$*)/install.sh; \
	fi
	if [ -d $(call component_dir,$*)/bins ]; then \
		find $(call component_dir,$*)/bins -type f -exec chmod +x {} +; \
	fi
	echo "Installed $*"
