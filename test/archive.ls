{
  rm
  mk
  nar
  read
  exists
  expect
  version
} = require './lib/helper'
Archive = require '../lib/archive'

describe 'Archive', ->

  describe 'options', (_) ->

    before ->
      @archive = new Archive

    after ->
      rm "nar-#{version}.nar"

    it 'should have the default options', ->
      expect @archive.options.binary .to.be.false
      expect @archive.options.dependencies .to.be.true
      expect @archive.options.dev-dependencies .to.be.false

    describe 'values', (_) ->

      it 'should have a valid temporal directory', ->
        expect @archive.tmpdir .to.match /nar-nar/

      it 'should have a proper output path', ->
        expect @archive.output .to.match /nar-(.*)\.nar/

      it 'should have a valid package name', ->
        expect @archive.name .to.be.equal 'nar'

      it 'should have a valid archive file name', ->
        expect @archive.file .to.match /nar-(.*)/

    describe 'dependencies matching', (_) ->

      it 'should match package dependencies', ->
        expect @archive.dependencies .to.be.an 'object'

      it 'should have runtime dependencies', ->
        expect @archive.dependencies.run .to.be.an 'array'

      it 'should have a valid runtime dependency', ->
        expect @archive.dependencies.run .to.include 'hu'

      it 'should not have dev dependencies', ->
        expect @archive.dependencies.dev .to.be.equal undefined

      it 'should not have peer dependencies', ->
        expect @archive.dependencies.peer .to.be.an 'array'

    describe 'compression', (_) ->

      before ->
        @archive.compress!

      it 'should compress files sucessfully', (done) ->
        @archive.on 'end', done

