{ rm, mk, nar, read, chdir, exists, expect, version, is-executable } = require './lib/helper'
{ symlink-sync } = require 'fs'

describe 'nar', ->

  describe 'API', (_) ->

    it 'should expose the Nar class', ->
      expect nar .to.be.an 'object'

    it 'should expose the create method', ->
      expect nar.create .to.be.a 'function'

    it 'should expose the extract method', ->
      expect nar.extract .to.be.a 'function'

    it 'should expose the list method', ->
      expect nar.list .to.be.a 'function'

    it 'should expose the run method', ->
      expect nar.run .to.be.a 'function'

    it 'should expose the package version', ->
      expect nar.VERSION .to.be.equal version

  describe 'E2E', ->
    platform = "#{process.platform}-#{process.arch}"

    describe 'complex', ->

      dest = "#{__dirname}/fixtures/.tmp"
      orig = "#{__dirname}/fixtures/complex"

      before ->
        rm dest
        mk dest
        chdir dest

      before ->
        rm "#{orig}/node_modules/.bin"
        mk "#{orig}/node_modules/.bin"
        symlink-sync "#{orig}/node_modules/hu/package.json" "#{orig}/node_modules/.bin/hu"

      after ->
        chdir "#{__dirname}/.."
        rm dest

      describe 'create', (_) ->

        options = path: "#{orig}"

        it 'should create the archive', (done) ->
          nar.create options
            .on 'error', -> throw it
            .on 'end', ->
              expect it .to.be.equal "#{dest}/test-0.1.0-#{platform}.nar"
              done!

        it 'should exists the archive', ->
          expect exists "#{dest}/test-0.1.0-#{platform}.nar" .to.be.true

      describe 'extract', (_) ->

        options = path: "#{dest}/test-0.1.0-#{platform}.nar"

        it 'should create the archive', (done) ->
          nar.extract options
            .on 'error', -> throw it
            .on 'end', -> done!

        it 'should exists package.json', ->
          expect exists "#{dest}/package.json" .to.be.true

        it 'should exists the node binary', ->
          expect exists "#{dest}/.node/bin/node" .to.be.true

        it 'should exists nar.json', ->
          expect exists "#{dest}/.nar.json" .to.be.true

        it 'should exists main.js', ->
          expect exists "#{dest}/main.js" .to.be.true

        it 'should exists node_modules', ->
          expect exists "#{dest}/node_modules" .to.be.true

        it 'should exists hu dependency', ->
          expect exists "#{dest}/node_modules/hu/package.json" .to.be.true

        it 'should exists dev dependency', ->
          expect exists "#{dest}/node_modules/dev/package.json" .to.be.true

        it 'should exists .bin directory', ->
          expect exists "#{dest}/node_modules/.bin" .to.be.true

        it 'should exists .bin/hu', ->
          expect exists "#{dest}/node_modules/.bin/hu" .to.be.true

        it 'should have execution permissions', ->
          expect (is-executable "#{dest}/node_modules/.bin/hu") .to.be.true

        it 'should not exists test directory', ->
          expect exists "#{dest}/test" .to.be.false

        describe 'ignored', (_) ->

          it 'should not exists .gitignore', ->
            expect exists "#{dest}/.gitignore" .to.be.false

          it 'should not exists .narignore', ->
            expect exists "#{dest}/.narignore" .to.be.false

      describe 'run', (_) ->

        stdout = stderr = messages = commands = ''
        options = path: "#{dest}/test-0.1.0-#{platform}.nar"

        it 'should create the archive', (done) ->
          nar.run options
            .on 'error', done
            .on 'message', -> messages += "#{it}\n"
            .on 'command', -> commands += "#{it}\n"
            .on 'stdout', -> stdout += it
            .on 'stderr', -> stderr += it
            .on 'end', -> done!

        it 'should exists package.json', ->
          expect exists "#{dest}/package.json" .to.be.true

        it 'should exists the node binary', ->
          expect exists "#{dest}/.node/bin/node" .to.be.true

        it 'should exists nar.json', ->
          expect exists "#{dest}/.nar.json" .to.be.true

        it 'should have a valid command entries', ->
          expect commands .to.match /echo \'prestart 1\'/
          expect commands .to.match /node\.sh main/
          expect commands .to.match /rm \-rf/

        it 'should have a valid stdout', ->
          expect stdout .to.match /prestart 1/

        it 'should have a valid stderr', ->
          expect stderr.length .to.be.equal 0

    describe 'global', ->

      dest = "#{__dirname}/fixtures/.tmp"
      orig = "#{__dirname}/fixtures/global"

      before ->
        rm dest
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      describe 'create', (_) ->

        options = path: "#{orig}"

        it 'should create the archive', (done) ->
          nar.create options
            .on 'error', -> throw it
            .on 'end', ->
              expect it .to.be.equal "#{dest}/global-#{platform}.nar"
              done!

        it 'should exists the archive', ->
          expect exists "#{dest}/global-#{platform}.nar" .to.be.true

      describe 'extract', (_) ->

        options = path: "#{dest}/global-#{platform}.nar"

        it 'should create the archive', (done) ->
          nar.extract options
            .on 'error', -> throw it
            .on 'end', -> done!

        it 'should exists package.json', ->
          expect exists "#{dest}/package.json" .to.be.true

        it 'should exists the node binary', ->
          expect exists "#{dest}/.node/bin/node" .to.be.true

        it 'should exists npm as global dependency', ->
          expect exists "#{dest}/.node/lib/node/npm/package.json" .to.be.true

        it 'should exists npm binary in .node', ->
          expect exists "#{dest}/.node/bin/npm" .to.be.true

        it 'should exists nar.json', ->
          expect exists "#{dest}/.nar.json" .to.be.true

        it 'should exists global.js', ->
          expect exists "#{dest}/global.js" .to.be.true

        it 'should exists node_modules', ->
          expect exists "#{dest}/node_modules" .to.be.true

        it 'should exists node_modules/some', ->
          expect exists "#{dest}/node_modules/some" .to.be.true

        it 'should exists node_modules/some/index', ->
          expect exists "#{dest}/node_modules/some/index.js" .to.be.true

        it 'should exists node_modules/some/node_modules/peer', ->
          expect exists "#{dest}/node_modules/some/node_modules/peer" .to.be.true

        describe 'ignored', (_) ->

          it 'should exists .narignore', ->
            expect exists "#{dest}/.narignore" .to.be.false
