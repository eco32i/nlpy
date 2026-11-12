SHELL_FILES := scripts/bootstrap.sh scripts/lib/*.sh scripts/modules/*.sh config/bin/tmux-copy tests/*.sh

.PHONY: lint test
lint:
	bash -n scripts/bootstrap.sh
	docker run --rm -v "$(CURDIR):/mnt" -w /mnt koalaman/shellcheck:stable -x $(SHELL_FILES)

test:
	tests/run.sh
