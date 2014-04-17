{ rm, mk, exec, chdir, exists, expect, version } = require './lib/helper'

describe 'CLI', (_) ->

  dest = "#{__dirname}/fixtures/.tmp"

  describe 'run', (_) ->

    describe 'default', (_) ->

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'close', <[run ../archives/sample.nar]>, ->
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

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --no-clean -o]> ++ [ output ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{output}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /test 1\.0\.0/
        expect stdout .to.match /finished/i

    describe '--debug', (_) ->

      stdout = null

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --no-clean --debug -o]> ++ [ dest ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /run/i
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

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --no-clean --verbose -o]> ++ [ dest ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{dest}/package.json" .to.be.true

      it 'should have a valid stdout', ->
        expect stdout .to.match /extract/i
        expect stdout .to.match /some.tar/i
        expect stdout .to.match /run/i
        expect stdout .to.match /finished/i

      it 'should have a valid verbose stdout', ->
        expect stdout .to.match /\> node/i
        expect stdout .to.match /sample\.js/i
        expect stdout .to.match /end/i

    describe '--args-start', (_) ->

      stdout = null

      before ->
        process.env.ENV = 'dev'
        mk dest
        chdir dest

      after ->
        process.env.ENV = ''
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --verbose --args-start]> ++ ['--env ${ENV}'], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should have a valid stdout', ->
        expect stdout .to.match /run /i
        expect stdout .to.match /prestart/
        expect stdout .to.match /start/

      it 'should have a print the start argument', ->
        expect stdout .to.match /\> --env/
        expect stdout .to.match /\> dev/

    describe '--args-prestart', (_) ->

      stdout = null

      before ->
        process.env.ENV = 'dev'
        mk dest
        chdir dest

      after ->
        process.env.ENV = ''
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --verbose --args-prestart]> ++ ['--env ${ENV}'], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should have a valid stdout', ->
        expect stdout .to.match /run /i
        expect stdout .to.match /prestart/
        expect stdout .to.match /start/

      it 'should have a print the start argument', ->
        expect stdout .to.match /\--env dev/

    describe '--no-hooks', (_) ->

      stdout = null

      before ->
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'data', <[run ../archives/sample --verbose --no-hooks]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should have a valid stdout', ->
        expect stdout .to.match /run /i
        expect stdout .to.not.match /\[prestart\]/
        expect stdout .to.match /start/
        expect stdout .to.not.match /\[stop\]/
        expect stdout .to.match /finished/i

    describe 'error', (_) ->

      stdout = null

      it 'should not run an invalid archive', (done) ->
        exec 'data', <[run ../invalid --verbose]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 1
          done!

      it 'should have a valid path error', ->
        expect stdout .to.match /invalid archive path/i
