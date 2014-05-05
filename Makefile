LS = ./node_modules/.bin/lsc
LS_MODULE = ./node_modules/LiveScript/
MOCHA = ./node_modules/.bin/mocha

define release
	VERSION=`node -pe "require('./package.json').version"` && \
	NEXT_VERSION=`node -pe "require('semver').inc(\"$$VERSION\", '$(1)')"` && \
	node -e "\
		var j = require('./package.json');\
		j.version = \"$$NEXT_VERSION\";\
		var s = JSON.stringify(j, null, 2);\
		require('fs').writeFileSync('./package.json', s);" && \
	git commit -m "release $$NEXT_VERSION" -- package.json && \
	git tag "$$NEXT_VERSION" -m "Version $$NEXT_VERSION"
endef

default: all
all: test
test: compile mocha

mkdir:
	mkdir -p lib/commands

clean:
	rm -rf lib

compile: clean mkdir
	cat src/nar.ls | $(LS) -c -s -b > ./lib/nar.js
	cat src/cli.ls | $(LS) -c -s -b > ./lib/cli.js
	cat src/extract.ls | $(LS) -c -s -b > ./lib/extract.js
	cat src/pack.ls | $(LS) -c -s -b > ./lib/pack.js
	cat src/unpack.ls | $(LS) -c -s -b > ./lib/unpack.js
	cat src/list.ls | $(LS) -c -s -b > ./lib/list.js
	cat src/utils.ls | $(LS) -c -s -b > ./lib/utils.js
	cat src/create.ls | $(LS) -c -s -b > ./lib/create.js
	cat src/run.ls | $(LS) -c -s -b > ./lib/run.js
	cat src/download.ls | $(LS) -c -s -b > ./lib/download.js
	cat src/install.ls | $(LS) -c -s -b > ./lib/install.js
	cat src/get.ls | $(LS) -c -s -b > ./lib/get.js
	cat src/status.ls | $(LS) -c -s -b > ./lib/status.js
	cat src/commands/create.ls | $(LS) -c -s -b > ./lib/commands/create.js
	cat src/commands/extract.ls | $(LS) -c -s -b > ./lib/commands/extract.js
	cat src/commands/run.ls | $(LS) -c -s -b > ./lib/commands/run.js
	cat src/commands/list.ls | $(LS) -c -s -b > ./lib/commands/list.js
	cat src/commands/install.ls | $(LS) -c -s -b > ./lib/commands/install.js
	cat src/commands/get.ls | $(LS) -c -s -b > ./lib/commands/get.js

mocha:
	cat test/lib/helper.ls | $(LS) -c -s -b > ./test/lib/helper.js
	$(MOCHA) --timeout 10000 --reporter spec --ui tdd --compilers ls:$(LS_MODULE)

release:
	@$(call release,patch)

release-minor:
	@$(call release,minor)

publish: test release
	git push --tags origin HEAD:master
	npm publish

loc:
	wc -l src/*
