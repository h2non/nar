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
	cat src/helper.ls | $(LS) -c -s -b > ./lib/helper.js
	cat src/commands/create.ls | $(LS) -c -s -b > ./lib/commands/create.js

mocha:
	cat test/lib/helper.ls | $(LS) -c -s -b > ./test/lib/helper.js
	$(MOCHA) --timeout 10000 --reporter spec --ui tdd --compilers ls:$(LS_MODULE)

release:
	@$(call release, patch)

release-minor:
	@$(call release, minor)

publish: release
	git push --tags origin HEAD:master
	npm publish

loc:
	wc -l src/*
