{ rm, mk, chdir, exists, expect, spawn } = require './lib/helper'
create = require '../lib/create-exec'
{ tmpdir } = require 'os'

describe 'create exec', ->

  dest = "#{tmpdir!}nar-testing"

  describe 'basic', (_) ->
    output = "#{dest}/test-1.0.0.nar"

    before ->
      rm dest
      mk dest
      chdir "#{__dirname}/fixtures/basic"

    before ->
      @archive = create dest: dest

    after ->
      chdir "#{__dirname}/.."
      rm dest

    it 'should compress files sucessfully', (done) ->
      entries = 0
      @archive
        .on 'error', -> throw it
        .on 'entry', -> entries += 1
        .on 'end', ->
          expect it .to.be.equal output
          expect entries > 7 .to.be.true
          done!

    it 'should exists the file', ->
      expect (output |> exists) .to.be.true

    it 'should execute the file as binary', (done) ->
      chdir dest
      return done! if process.platform is 'win32'
      (spawn 'bash', [ output, 'extract' ])
        .on 'close', (code) ->
          expect code .to.be.equal 0
          done!

    it 'should exists the .nar directory', ->
      expect ("#{dest}/.nar" |> exists) .to.be.true

    it 'should exists the node binary', ->
      expect ("#{dest}/.nar/bin/node" |> exists) .to.be.true

    it 'should exists the nar package.json', ->
      expect ("#{dest}/.nar/nar/package.json" |> exists) .to.be.true

    it 'should exists the sample package.json', ->
      expect ("#{dest}/package.json" |> exists) .to.be.true
