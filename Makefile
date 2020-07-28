MAKEFLAGS += --silent

.PHONY: install upgrade $(MAKECMDGOALS)

install: $(shell ls -d */ | sed -e 's/\//.install/')
	echo "DONE"

upgrade:
	sudo apt update
	sudo apt upgrade

git.install credentials.install theming.install: personal.install

%.install: upgrade
	if [ -f $*/install.sh ]; then \
		bash $*/install.sh; \
	fi 
	echo "Installed $*"