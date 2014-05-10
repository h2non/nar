{ rm, mk, exec, chdir, exists, expect, server, static-server  } = require './lib/helper'

describe 'CLI', (_) ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"
  http = mock = stdout = null

  describe 'get', (_) ->

    before (done) ->
      http := static-server orig, -> done!

    before (done) ->
      mock := server -> done!

    after (done) ->
      http.close -> done!

    after (done) ->
      mock.stop -> done!

    describe 'default', (_) ->

      before ->
        rm dest
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'close', <[get http://127.0.0.1:8883/sample.nar]>, ->
          expect it .to.be.equal 0
          expect exists 'sample.nar' .to.be.true
          done!

    describe '--output', (_) ->

      output = "#{dest}/output"

      before -> stdout := null

      before ->
        mk output
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should get the archive', (done) ->
        exec 'data', <[get http://127.0.0.1:8883/sample.nar -o]> ++ [ output ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{output}/sample.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /downloading/i
        expect stdout .to.match /downloaded in/i

    describe 'authentication', (_) ->

      output = "#{dest}/output"

      before -> stdout := null

      before ->
        mk output
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should get the archive', (done) ->
        exec 'data', <[get http://127.0.0.1:8882/download/auth/archive.nar -u nar -p passw0rd -f app.nar]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "app.nar" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /downloading/i
        expect stdout .to.match /downloaded in/i
