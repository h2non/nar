{ rm, mk, exec, chdir, exists, expect } = require './lib/helper'

describe 'CLI', (_) ->

  dest = "#{__dirname}/fixtures/.tmp"

  xdescribe 'get', (_) ->

    describe 'default', (_) ->

      before ->
        rm dest
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'close', <[get ../archives/sample]>, ->
          expect it .to.be.equal 0
          done!

    describe '--output', (_) ->

      output = "#{dest}/output"
      stdout = null

      before ->
        mk output
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should get the archive', (done) ->
        exec 'data', <[get ../archives/sample --no-clean -o]> ++ [ output ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{output}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /test\-1\.0\.0\.nar/
        expect stdout .to.match /finished/i

    describe '--debug', (_) ->

      stdout = null

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should get the archive', (done) ->
        exec 'data', <[get ../archives/sample --no-clean --debug -o]> ++ [ dest ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /get/i
        expect stdout .to.match /finished/i

      it 'should have a valid debug stdout', ->
        expect stdout .to.match /\> node/i
        expect stdout .to.match /sample\.js/i
        expect stdout .to.match /end/i

    describe '--verbose', (_) ->

      stdout = null

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should get the archive', (done) ->
        exec 'data', <[get ../archives/sample --no-clean --verbose -o]> ++ [ dest ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /extract/i
        expect stdout .to.match /some.tar/i
        expect stdout .to.match /get/i
        expect stdout .to.match /finished/i

      it 'should have a valid verbose stdout', ->
        expect stdout .to.match /\> node/i
        expect stdout .to.match /sample\.js/i
        expect stdout .to.match /end/i
