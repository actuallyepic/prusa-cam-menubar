APP_NAME := PrusaCam

.PHONY: build run clean install uninstall package

build:
	@./scripts/build.sh

run:
	@./scripts/run.sh

clean:
	@rm -rf ./build

install:
	@./scripts/install.sh

uninstall:
	@./scripts/uninstall.sh

package:
	@./scripts/package.sh
