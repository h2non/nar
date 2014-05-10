{ fs, rm, mk, chdir, exists, expect, static-server } = require './lib/helper'
run = require '../lib/run'

describe 'run', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'basic', (_) ->

    stdout = stderr = commands = ''
    options =
      path: "#{orig}/sample.nar"
      dest: dest
      clean: no
      args:
        start: "--os #{process.platform} --path ${PATH} --invalid ${_INVALID_}"

    before ->
      rm dest
      mk dest

    after -> rm dest

    it 'should run the archive', (done) ->
      run options
        .on 'error', done
        .on 'command', -> commands += it
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

    describe 'commands', (_) ->

      it 'should match echo command', ->
        expect commands .to.match /echo \'prestart 1\'/i

      it 'should match sample.js', ->
        expect commands .to.match /sample\.js/i

    describe 'files', (_) ->

      it 'should exist .nar.json', ->
        expect exists "#{dest}/.nar.json" .to.be.true

      it 'should exist package.json', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should exist node_modules', ->
        expect exists "#{dest}/node_modules" .to.be.true

  describe 'remote', (_) ->

    stdout = http = stderr = commands = ''
    options =
      path: 'http://localhost:8883/sample.nar'
      dest: dest
      clean: no
      args:
        start: "--os #{process.platform} --path ${PATH} --invalid ${_INVALID_}"

    before (done) ->
      http := static-server orig, -> done!

    before ->
      rm dest
      mk dest

    after -> rm dest

    after (done) ->
      http.close -> done!

    it 'should download and run the archive', (done) ->
      run options
        .on 'error', done
        .on 'command', -> commands += it
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

    describe 'commands', (_) ->

      it 'should match echo command', ->
        expect commands .to.match /echo \'prestart 1\'/i

      it 'should match sample.js', ->
        expect commands .to.match /sample\.js/i

    describe 'files', (_) ->

      it 'should exist .nar.json', ->
        expect exists "#{dest}/.nar.json" .to.be.true

      it 'should exist package.json', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should exist node_modules', ->
        expect exists "#{dest}/node_modules" .to.be.true
