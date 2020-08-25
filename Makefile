MAKEFLAGS += --silent

.PHONY: install upgrade $(MAKECMDGOALS)

install: $(shell ls -d */ | sed -e 's/\//.install/')
	echo "DONE"

git.install credentials.install theming.install: personal.install

aws.install: python.install

%.install: apt.install
	if [ -f $*/install.sh ]; then \
		bash $*/install.sh; \
	fi 
	echo "Installed $*"
