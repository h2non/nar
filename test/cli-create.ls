{ rm, mk, cwd, exec, chdir, exists, expect, version } = require './lib/helper'

describe 'CLI', ->

  describe 'create', ->

    dest = "#{__dirname}/fixtures/.tmp"
    stdout = null

    describe 'basic', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        rm dest
        chdir "#{__dirname}/.."

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/
        expect stdout .to.match /test-1\.0\.0.nar/

    describe '--debug', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        rm dest
        chdir "#{__dirname}/.."

      it 'should create the archive', (done) ->
        exec 'data', <[create ../basic --debug]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /created in/
        expect stdout .to.match /test-1\.0\.0.nar/

      it 'should have a valid debug output', ->
        expect stdout .to.match /add \[/i
        expect stdout .to.match /package\.json/
        expect stdout .to.match /\.nar\.json/
        expect stdout .to.match /node_modules\/another/
        expect stdout .to.match /sample\.js/

    describe 'error', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        rm dest
        chdir "#{__dirname}/.."

      it 'should create the archive', (done) ->
        exec 'data', <[create ../invalid ]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 1
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/test-1.0.0.nar" .to.be.false

      it 'should stdout a valid error', ->
        expect stdout .to.match /path do not exists/i
