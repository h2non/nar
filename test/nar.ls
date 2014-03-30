{
  rm
  mk
  nar
  exists
  expect
  version
} = require './lib/helper'

describe 'nar', ->

  describe 'API', (_) ->

    it 'should expose the Nar class', ->
      expect nar .to.be.an 'function'

    it 'should expose the package version', ->
      expect nar.VERSION .to.be.a 'string'

  describe 'basic', ->

    describe '#create()', (_) ->

      before ->
        process.chdir "#{__dirname}/fixtures/basic/a/b"

      after ->
        rm "test-0.0.1.nar"

      after ->
        process.chdir "#{__dirname}/../"

      it 'should create the archive', (done) ->
        @nar = nar.create null, done

      it 'should have the package object', ->
        expect @nar.pkg .to.be.an 'object'
        expect @nar.pkg.name .to.be.equal 'test'

      it 'should have the proper package path', ->
        expect @nar.pkg-path .to.match /package.json/

      it 'should use the default options', ->
        expect @nar.options.base .to.be.equal process.cwd!
        expect @nar.options.dependencies .to.be.true
        expect @nar.options.binary .to.be.true
        expect @nar.options.dev-dependencies .to.be.true
        expect @nar.options.peer-dependencies .to.be.false

      it 'should have the default package path', ->
        expect @nar.pkg-path .to.be.equal "#{__dirname}/fixtures/basic/package.json"

      it 'should exists the package file', ->
        expect @nar.exists! .to.be.true

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

      describe 'files', (_) ->

        it 'should remove the temporary directory', ->
          expect exists @nar.tmp-dir .to.be.false

        it 'should exist the archive', ->
          expect exists './test-0.0.1.nar' .to.be.true

        it 'should match dependencies', ->
          expect @nar.match-deps!dep .to.be.deep.equal ['hu']

      describe '#extract()', (_) ->
        dest = "#{__dirname}/fixtures/.tmp"

        before ->
          mk dest

        after ->
          rm dest

        it 'should extract the archive', (done) ->
          @nar = nar.extract { dest }, done

        it 'should exist the temporal folder', ->
          expect exists @nar.tmp-dir .to.be.true

        it 'should exist the .nar.json file', ->
          expect exists "#{@nar.tmp-dir}/.nar.json" .to.be.true

        describe 'extracted files', (_) ->

          it 'should exist the package.json', ->
            expect exists "#{dest}/package.json" .to.be.true

          it 'should be a valid JSON', ->
            expect (require "#{dest}/package.json").name .to.be.equal 'test'

          describe 'nar manifest', (_) ->

            it 'should exist nar.json', ->
              expect exists "#{dest}/.nar.json" .to.be.true

            it 'should have a valid package name', ->
              expect (require "#{dest}/.nar.json").name .to.be.equal 'test'

            it 'should have the time property', ->
              expect (require "#{dest}/.nar.json").time .to.be.a 'number'

            it 'should have a valid info object', ->
              expect (require "#{dest}/.nar.json").info .to.be.deep.equal {
                platform: process.platform
                arch: process.arch
                version: process.version
              }

            it 'should have a valid manifest object', ->
              manifest = (require "#{dest}/.nar.json").manifest
              expect manifest.name .to.be.equal 'test'
              expect manifest.version .to.be.equal '0.0.1'
              expect manifest.archive .to.be.an 'object'

            describe 'files', (_) ->

              it 'should have a valid dependency file object', ->
                file = (require "#{dest}/.nar.json").files[0]
                expect file.archive .to.be.equal 'hu.tar'
                expect file.type .to.be.equal 'dependency'
                expect file.dest .to.be.equal 'node_modules/hu'
                expect file.checksum .to.be.a 'string'

              it 'should have the node binary file object', ->
                file = ((require "#{dest}/.nar.json").files.slice -1)[0]
                expect file.archive .to.be.equal 'node'
                expect file.type .to.be.equal 'binary'
                expect file.dest .to.be.equal '.node/bin'
                expect file.checksum .to.be.a 'string'

          it 'should exist the node_modules directory', ->
            expect exists "#{dest}/node_modules" .to.be.true

          it 'should exist the package dependency', ->
            expect exists "#{dest}/node_modules/hu" .to.be.true

          it 'should exist package.json in package dependency', ->
            expect exists "#{dest}/node_modules/hu/package.json" .to.be.true

          it 'should be a valid package.json dependency', ->
            expect (require "#{dest}/node_modules/hu/package.json").name .to.be.equal 'hu'

          it 'should exist the "a" directory', ->
            expect exists "#{dest}/a" .to.be.true

          it 'should exist the "b" directory', ->
            expect exists "#{dest}/a/b" .to.be.true

          it 'should exist the .node directory', ->
            expect exists "#{dest}/.node" .to.be.true

          it 'should exist the node binary', ->
            expect exists "#{dest}/.node/bin/node" .to.be.true

