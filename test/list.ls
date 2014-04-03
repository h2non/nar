{
  rm
  mk
  fs
  spy
  once
  exists
  expect
  uncaught
} = require './lib/helper'
list = require '../lib/list'

describe 'list', ->

  archives = "#{__dirname}/fixtures/archives"

  describe 'tarball', (_) ->

    bus = null
    options = file: "#{archives}/sample.tar"

    before ->
      bus := list options

    it 'should emit the end event with an array of files', (done) ->
      entry = spy!
      bus.once 'end', once (files) ->
        expect files .to.be.an 'array'
        done!

    it 'should have the expected files', (done) ->
      bus.on 'end', once ->
        expect it.length .to.be.equal 6
        expect it[0].path .to.be.equal 'a/b/sample.js'
        done!

    it 'should not emit the error event', (done) ->
      error = spy!
      bus.on 'error', error
      bus.on 'end', once ->
        expect error.called .to.be.false
        done!

  describe 'gzip', (_) ->

    bus = null
    options =
      file: "#{archives}/sample.tar.gz"
      gzip: yes

    before ->
      bus := list options

    it 'should emit the end event with an array of files', (done) ->
      entry = spy!
      bus.once 'end', once (files) ->
        expect files .to.be.an 'array'
        done!

    it 'should have the expected files', (done) ->
      bus.on 'end', once ->
        expect it.length .to.be.equal 6
        expect it[0].path .to.be.equal 'a/b/sample.js'
        done!

    it 'should not emit the error event', (done) ->
      error = spy!
      bus.on 'error', error
      bus.on 'end', once ->
        expect error.called .to.be.false
        done!

  describe 'error', (_) ->

    bus = null
    listener = null
    options =
      file: "#{archives}/sample.tar.gz"
      gzip: no

    before ->
      uncaught!
      bus := list options

    it 'should emit the error event', (done) ->
      bus.on 'error', ->
        expect it .to.instanceof Error
        expect it .to.match /invalid tar/
        done!

  describe 'passing stream', (_) ->

    bus = null
    options =
      stream: fs.create-read-stream "#{archives}/sample.tar"

    before ->
      bus := list options

    it 'should emit the end event with an array of files', (done) ->
      entry = spy!
      bus.once 'end', once ->
        expect it .to.be.an 'array'
        expect it.length .to.be.equal 6
        done!
