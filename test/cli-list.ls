{ rm, mk, exec, chdir, exists, expect } = require './lib/helper'

describe 'CLI', (_) ->

  archives = "#{__dirname}/fixtures/archives"

  describe 'list', (_) ->

    stdout = null

    before -> chdir archives

    after -> chdir "#{__dirname}/.."

    describe 'default', (_) ->

      it 'should create the archive', (done) ->
        exec 'data', <[list sample]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should print the table', ->
        expect stdout .to.match /destination/i
        expect stdout .to.match /size/i
        expect stdout .to.match /type/i

      it 'should have a valid table content', ->
        expect stdout .to.match /dependency/
        expect stdout .to.match /package/
        expect stdout .to.match /node_modules\/some/

    describe '--no-table', (_) ->

      it 'should create the archive', (done) ->
        exec 'data', <[list sample --no-table]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0
          done!

      it 'should not print the table', ->
        expect stdout .to.not.match /destination/i
        expect stdout .to.not.match /size/i
        expect stdout .to.not.match /type/i

      it 'should have a valid stdout', ->
        expect stdout .to.match /test\.tar/
        expect stdout .to.match /some\.tar/
        expect stdout .to.match /node_modules\/some/
        expect stdout .to.match /KB/

    describe 'error', (_) ->

      it 'should not create the archive', (done) ->
        exec 'data', <[list ../invalid]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 1
          done!

      it 'should have a valid error', ->
        expect stdout .to.match /given path is not a file/i
