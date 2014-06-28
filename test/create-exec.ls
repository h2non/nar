{ rm, mk, chdir, exists, expect, spawn } = require './lib/helper'
create = require '../lib/create-exec'

describe 'create exec', ->

  dest = "#{__dirname}/fixtures/.tmp"

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
      return done! if process.platform is 'win32'
      (spawn 'bash', [ output, 'extract' ])
        .on 'close', (code) ->
          expect code .to.be.equal 0
          done!
