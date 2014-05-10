{ rm, mk, exec, chdir, exists, expect, server, static-server } = require './lib/helper'

describe 'CLI', (_) ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"
  stdout = null

  describe 'install', (_) ->

    describe 'local', ->

      describe 'default', (_) ->

        before -> stdout := null

        before ->
          rm dest
          mk dest
          chdir dest

        after ->
          chdir "#{__dirname}/.."
          rm dest

        it 'should install the archive', (done) ->
          exec 'close', <[install ../archives/sample]>, ->
            expect it .to.be.equal 0
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

        it 'should install the archive', (done) ->
          exec 'data', <[install ../archives/sample --clean -o]> ++ [ output ], (data, code) ->
            stdout := data
            expect code .to.be.equal 0
            done!

        it 'should exists the archive', ->
          expect exists "#{output}/package.json" .to.be.true

      describe '--debug', (_) ->

        before -> stdout := null

        before ->
          mk dest
          chdir dest

        after ->
          chdir "#{__dirname}/.."
          rm dest

        it 'should install the archive', (done) ->
          exec 'data', <[install ../archives/sample --clean --debug -o]> ++ [ dest ], (data, code) ->
            stdout := data
            expect code .to.be.equal 0
            done!

        it 'should exists the archive', ->
          expect exists "#{dest}/package.json" .to.be.true

    describe 'remote', ->
      mock = http = null

      before -> stdout := null

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

        it 'should install the archive', (done) ->
          exec 'data', <[install http://127.0.0.1:8883/sample.nar]>, (data, code) ->
            expect code .to.be.equal 0
            stdout := data
            done!

        it 'should exists archive extract files', ->
          expect exists "#{dest}/node_modules/pkg/package.json" .to.be.true

        it 'should have a valid stdout', ->
          expect stdout .to.match /downloading archive/i
          expect stdout .to.match /installing archive/i
          expect stdout .to.match /installed in/i

      describe 'invalid', (_) ->

        before ->
          rm dest
          mk dest
          chdir dest

        after ->
          chdir "#{__dirname}/.."
          rm dest

        it 'should install the archive', (done) ->
          exec 'data', <[install http://127.0.0.1:8882/download/invalid]>, (data, code) ->
            expect code .to.not.equal 0
            stdout := data
            done!

        it 'should not exists archive extract files', ->
          expect exists "#{dest}/pkg/package.json" .to.be.false

        it 'should have a valid stdout', ->
          expect stdout .to.match /invalid response/i
          expect stdout .to.match /404 not found/i
