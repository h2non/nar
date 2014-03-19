WISP = ./node_modules/wisp/bin/wisp.js
WISP_MODULE = ./node_modules/wisp/
MOCHA = ./node_modules/.bin/mocha

default: all
all: test
browser: test
compile: mkdir
test: compile runtest

mkdir:
  mkdir -p lib

index:
  cat src/nar.wisp | $(WISP) --source-uri src/nar.wisp --no-map > ./lib/nar.js

clean:
  rm -rf lib/*

runtest:
  $(MOCHA) --reporter spec --ui tdd --compilers wisp:$(WISP_MODULE)

loc:
  wc -l src/*

