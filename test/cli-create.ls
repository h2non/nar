{ rm, mk, cwd, exec, chdir, exists, expect, version } = require './lib/helper'

describe 'CLI', ->

  describe 'create', ->

    dest = "#{__dirname}/fixtures/.tmp"
    stdout = null

    describe 'basic', (_) ->

      before ->
        rm dest
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /test-1\.0\.0.nar/

    describe '--debug', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /test-1\.0\.0.nar/

      it 'should have a valid debug output', ->
        expect stdout .to.match /add \[/i
        expect stdout .to.match /package\.json/
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /sample\.js/

    describe '--binary', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug --binary]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0-#{process.platform}-#{process.arch}.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /test-1\.0\.0/

      it 'should have the npm dependency', ->
        expect stdout .to.match /\] node/

    describe '--binary-path', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug --binary-path]> ++ [process.exec-path], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0-#{process.platform}-#{process.arch}.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /test-1\.0\.0/

      it 'should have the npm dependency', ->
        expect stdout .to.match /\] node/

    describe '--global-dependencies', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug --global-dependencies npm]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /test-1\.0\.0.nar/

      it 'should have the npm dependency', ->
        expect stdout .to.match /npm-/

    describe '--executable', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug --executable]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0-#{process.platform}-#{process.arch}.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /test-1\.0\.0.nar/

      it 'should have the npm dependency', ->
        expect stdout .to.match /generating executable/i

    describe '--patterns', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug --patterns !.hidden]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /test-1\.0\.0.nar/

      it 'should not have the hidden file ignored by pattern', ->
        expect stdout .to.not.match /\.hidden/

    describe '--file', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive with custom file name', (done) ->
        exec 'data', <[create ../basic --file custom]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/custom.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /custom\.nar/

    describe '--omit-dependencies', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive with custom file name', (done) ->
        exec 'data', <[create ../basic --debug --omit-dependencies]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/i
        expect stdout .to.match /test-1.0.0\.nar/

      it 'should not match node_modules in stdout', ->
        expect stdout .to.not.match /node_modules/

    describe 'error', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should create the archive', (done) ->
        exec 'data', <[create ../invalid ]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 1
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.false

      it 'should stdout a valid error', ->
        expect stdout .to.match /path do not exists/i
