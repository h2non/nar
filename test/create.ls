{
  rm
  mk
  nar
  read
  chdir
  exists
  expect
  version
} = require './lib/helper'
create = require '../lib/create'

describe 'create', ->

  dest = "#{__dirname}/fixtures/.tmp"

  describe 'basic', (_) ->

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
      @archive
        .on 'error', -> throw it
        .on 'end', ->
          expect it .to.be.equal "#{dest}/test-1.0.0.nar"
          done!

  describe 'complex', (_) ->

    before ->
      rm dest
      mk dest
      chdir "#{__dirname}/fixtures/complex/test" # discover

    before ->
      @archive = create dest: dest

    after ->
      chdir "#{__dirname}/.."
      rm dest

    it 'should compress files sucessfully', (done) ->
      @archive
        .on 'error', -> throw it
        .on 'end', ->
          expect it .to.be.equal "#{dest}/test-0.1.0.nar"
          done!
