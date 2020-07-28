MAKEFLAGS += --silent

.PHONY: install $(MAKECMDGOALS)

install: $(shell ls -d */ | sed -e 's/\//.install/')
	echo "DONE"

git.install credentials.install theming.install: personal.install

%.install:
	if [ -f $*/install.sh ]; then \
		bash $*/install.sh; \
	fi 
	echo "Installed $*"