.DEFAULT_GOAL := all

.PHONY: all shelly clean
all: shelly

shelly:
	@shelly generate --upgrade

clean:
	@rm -vf gup
