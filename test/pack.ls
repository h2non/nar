{
  rm
  mk
  exists
  expect
} = require './lib/helper'
pack = require '../lib/pack'

describe 'pack', ->

  dest = "#{__dirname}/fixtures/.tmp"

  describe 'default', (_) ->

    options =
      name: 'test'
      src: "#{__dirname}/fixtures/basic"
      dest: dest

    before ->
      mk dest

    after ->
      rm dest

    it 'should create the file', (done) ->
      pack options, (err, data) ->
        expect err .to.not.exist
        expect data.name .to.be.equal 'test'
        expect data.archive .to.be.equal 'test.tar'
        expect data.path .to.be.equal "#{dest}/test.tar"
        expect data.checksum .to.be.a 'string'
        done!

    it 'should exist the tarball', ->
      expect exists "#{dest}/test.tar" .to.be.true

  describe 'custom options', (_) ->

    options =
      name: 'test-1.0.0'
      src: "#{__dirname}/fixtures/basic"
      dest: dest
      patterns: [ '**', '.*' ]
      ext: 'nar'
      gzip: yes

    before ->
      mk dest

    after ->
      rm dest

    it 'should create the file', (done) ->
      pack options, (err, data) ->
        expect err .to.not.exist
        expect data.name .to.be.equal 'test-1.0.0'
        expect data.archive .to.be.equal 'test-1.0.0.nar'
        expect data.path .to.be.equal "#{dest}/test-1.0.0.nar"
        expect data.checksum .to.be.a 'string'
        done!

    it 'should exist the tarball', ->
      expect exists "#{dest}/test-1.0.0.nar" .to.be.true

  describe 'invalid path', (_) ->

    describe 'source', (_) ->

      options =
        name: 'test'
        src: "#{__dirname}/fixtures/nonexistent"
        dest: dest

      before ->
        mk dest

      after ->
        rm dest

      it 'should return an invalid path error', (done) ->
        pack options, (err, data) ->
          expect err .to.instanceof Error
          expect err .to.match /source path do not/
          done!

      it 'should exist the tar file', ->
        expect exists "#{dest}/test.tar" .to.be.false

    describe 'destination', (_) ->
      dest = "#{__dirname}/nonexistent"

      options =
        name: 'test'
        src: "#{__dirname}/fixtures/basic"
        dest: dest

      it 'should return an invalid path error', (done) ->
        pack options, (err, data) ->
          expect err .to.instanceof Error
          expect err .to.match /destination path do not/
          done!

      it 'should exist the tar file', ->
        expect exists dest .to.be.false

