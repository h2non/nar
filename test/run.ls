{
  fs
  rm
  mk
  chdir
  exists
  expect
} = require './lib/helper'
run = require '../lib/run'

describe 'run', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'basic', (_) ->

    stdout = stderr = messages = ''
    options =
      path: "#{orig}/sample.nar"
      dest: dest
      args:
        start: "--os #{process.platform} --path ${PATH} --invalid ${_INVALID_}"

    before -> rm dest
    before -> mk dest
    after -> rm dest

    it 'should run the archive', (done) ->
      run options
        .on 'error', -> throw it
        .on 'message', -> messages += it
        .on 'stdout', -> stdout += it
        .on 'stderr', -> stderr += it
        .on 'end', -> done!

    it 'should have empty stderr', ->
      expect stderr.length .to.be.equal 0

    describe 'stdout', (_) ->

      it 'should match "prestart"', ->
        expect stdout .to.match /prestart 1/

      it 'should match node string', ->
        expect stdout .to.match /node/

      it 'should match the script file', ->
        expect stdout .to.match /sample\.js/

      it 'should match the platform as aditional flag', ->
        expect stdout .to.match /--os/
        expect stdout .to.match new RegExp process.platform

      it 'should match the path variable as aditional flag', ->
        expect stdout .to.match /--path/
        expect stdout .to.match new RegExp process.env.PATH

      it 'should match the invalid flag and no variable value', ->
        expect stdout .to.match /--invalid\n/
        expect stdout .to.not.match new RegExp '${_INVALID_}'

    describe 'messages', (_) ->

      it 'should match "Extracting archive"', ->
        expect messages .to.match /Extracting archive/i

      it 'should match running command', ->
        expect messages .to.match /running command/i

    describe 'files', (_) ->

      it 'should exist .nar.json', ->
        expect exists "#{dest}/.nar.json" .to.be.true

      it 'should exist package.json', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should exist node_modules', ->
        expect exists "#{dest}/node_modules" .to.be.true
