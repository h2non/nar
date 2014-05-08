{ rm, mk, exec, chdir, exists, expect } = require './lib/helper'

describe 'CLI', (_) ->

  dest = "#{__dirname}/fixtures/.tmp"

  describe 'install', (_) ->

    describe 'default', (_) ->

      before ->
        rm dest
        mk dest
        chdir dest

      after ->
        chdir "#{__dirname}/.."
        rm dest

      it 'should run the archive', (done) ->
        exec 'close', <[install ../archives/sample]>, ->
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

      it 'should install the archive', (done) ->
        exec 'data', <[install ../archives/sample --clean -o]> ++ [ output ], (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should exists the archive', ->
        expect exists "#{output}/package.json" .to.be.true

    describe '--debug', (_) ->

      stdout = null

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
