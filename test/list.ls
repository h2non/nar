{ rm, mk, fs, spy, once, exists, expect, uncaught } = require './lib/helper'
list = require '../lib/list'

describe 'list', ->

  dest = "#{__dirname}/fixtures/.tmp"
  archives = "#{__dirname}/fixtures/archives"

  describe 'sample', (_) ->

    options = path: "#{archives}/sample.nar"

    before ->
      rm dest

    before ->
      @bus = list options

    it 'should emit the end event with an array of files', (done) ->
      @bus.once 'end', once (files) ->
        expect files .to.be.an 'array'
        done!

    it 'should have the expected files', (done) ->
      @bus.on 'end', once ->
        expect it.length .to.be.equal 2
        expect it[0].archive .to.be.equal 'some.tar'
        done!

    it 'should not emit the error event', (done) ->
      error = spy!
      @bus.on 'error', error
      @bus.on 'end', once ->
        expect error.called .to.be.false
        done!

  describe 'error', (_) ->

    options = path: "#{archives}/invalid"

    before ->
      uncaught!
      @bus = list options

    it 'should emit the error event', (done) ->
      @bus.on 'error', ->
        expect it .to.instanceof Error
        expect it.message .to.match /the given path is not a file/
        done!
