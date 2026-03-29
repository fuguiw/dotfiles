SHELL := /bin/bash

.PHONY: install link check list

install link:
	./scripts/install.sh

check:
	bash -n scripts/install.sh
	zsh -n home/.zshrc home/.zprofile
	git config --file home/.gitconfig --list >/dev/null
	python3 -m json.tool home/.claude/settings.json >/dev/null
	bash scripts/test_install.sh

list:
	find home config -type f | sort
