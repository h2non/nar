{
  rm
  nar
  expect
  version
} = require './lib/helper'

describe 'nar', ->

  describe 'API', (_) ->

    it 'should expose the Nar class', ->
      expect nar .to.be.an 'function'

    it 'should expose the package version', ->
      expect nar.VERSION .to.be.a 'string'

  describe 'create archive', ->

    describe 'default', (_) ->

      before ->
        @nar = nar.create!

      it 'should have the package object', ->
        expect @nar.pkg .to.be.an 'object'
        expect @nar.pkg.name .to.be.equal 'nar'

      it 'should have the proper package path', ->
        expect @nar.pkg-path .to.match /package.json/

      it 'should use the default options', ->
        expect @nar.options.base .to.be.equal process.cwd!
        expect @nar.options.dependencies .to.be.true
        expect @nar.options.binary .to.be.false
        expect @nar.options.dev-dependencies .to.be.false
        expect @nar.options.peer-dependencies .to.be.true

      it 'should have the default package path', ->
        expect @nar.pkg-path .to.be.equal "#{@nar.options.base}/package.json"

      it 'should exists the package file', ->
        expect @nar.exists! .to.be.true

    describe 'package manifest', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/basic/a/b"

      before ->
        @nar = nar.create!

      after ->
        process.chdir "#{__dirname}/../"

      it 'should discover in higher directories', ->
        expect @nar.discover! .to.not.throw
        expect @nar.pkg-path .to.be.equal "#{__dirname}/fixtures/basic/package.json"

      it 'should add the node binary', ->
        expect @nar.options.binary .to.be.true

      it 'should add dependencies by default', ->
        expect @nar.options.dependencies .to.be.true

      it 'should add devDependencies', ->
        expect @nar.options.dev-dependencies .to.be.true

      it 'should not add peerDepedencies', ->
        expect @nar.options.peer-dependencies .to.be.false

      describe 'dependecies matching', (_) ->

        it 'should match dependencies', ->
          expect @nar.match-deps!dep .to.be.deep.equal ['hu']

        it 'should compress files', (done) ->
          @nar.compress done

        after ->
          rm "#{__dirname}/fixtures/basic/a/b/test.nar"


