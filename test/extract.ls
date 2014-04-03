{
  fs
  rm
  mk
  exists
  expect
} = require './lib/helper'
extract = require '../lib/extract'

describe 'extract', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'tarball', (_) ->

    options =
      path: "#{orig}/sample.tar"
      dest: dest

    before ->
      mk dest

    after ->
      rm dest

    it 'should extract files', (done) ->
      extract options, (err) ->
        expect err .to.not.exist
        done!

    it 'should exist package.json', ->
      expect exists "#{dest}/package.json" .to.be.true

    it 'should exist .hidden', ->
      expect exists "#{dest}/.hidden" .to.be.true

    it 'should exist node_modules directory', ->
      expect exists "#{dest}/node_modules" .to.be.true

    it 'should exist some package dependency', ->
      expect exists "#{dest}/node_modules/some/package.json" .to.be.true

    it 'should exist sample.js', ->
      expect exists "#{dest}/a/b/sample.js" .to.be.true

  describe 'gzip', (_) ->

    options =
      path: "#{orig}/sample.tar.gz"
      dest: dest
      gzip: yes

    before ->
      mk dest

    after ->
      rm dest

    it 'should extract files', (done) ->
      extract options, (err) ->
        expect err .to.not.exist
        done!

    it 'should exist package.json', ->
      expect exists "#{dest}/package.json" .to.be.true

    it 'should exist .hidden', ->
      expect exists "#{dest}/.hidden" .to.be.true

    it 'should exist node_modules directory', ->
      expect exists "#{dest}/node_modules" .to.be.true

    it 'should exist some package dependency', ->
      expect exists "#{dest}/node_modules/some/package.json" .to.be.true

    it 'should exist sample.js', ->
      expect exists "#{dest}/a/b/sample.js" .to.be.true

  describe 'checksum', (_) ->

    options =
      path: "#{orig}/sample.tar"
      dest: dest
      checksum: '50c3aaacaafa0fb55829aa553121f04f1a78400e'

    before ->
      mk dest

    after ->
      rm dest

    it 'should extract files', (done) ->
      extract options, (err) ->
        expect err .to.not.exist
        done!

    it 'should exist package.json', ->
      expect exists "#{dest}/package.json" .to.be.true

    it 'should exist .hidden', ->
      expect exists "#{dest}/.hidden" .to.be.true

    it 'should exist node_modules directory', ->
      expect exists "#{dest}/node_modules" .to.be.true

    it 'should exist some package dependency', ->
      expect exists "#{dest}/node_modules/some/package.json" .to.be.true

    it 'should exist sample.js', ->
      expect exists "#{dest}/a/b/sample.js" .to.be.true

  describe 'error', (_) ->

    describe 'tar file' (_) ->

      options =
        path: "#{orig}/sample.tar"
        dest: dest
        gzip: yes

      it 'should return an file header check error', (done) ->
        extract options, (err) ->
          expect err.code .to.be.equal 'Z_DATA_ERROR'
          expect err.message .to.match /incorrect header check/
          done!

      it 'should exist the tar file', ->
        expect exists "#{dest}/package.json" .to.be.false

    describe 'checksum', (_) ->

      options =
        path: "#{orig}/sample.tar"
        dest: dest
        checksum: 'invalid'

      it 'should return a checksum verification error', (done) ->
        extract options, (err) ->
          expect err .to.match /checksum verification failed/
          done!

      it 'should not exist files', ->
        expect exists "#{dest}/package.json" .to.be.false

    describe 'source', (_) ->

      options =
        path: "#{orig}/nonexistent.tar"
        dest: dest

      before ->
        mk dest

      after ->
        rm dest

      it 'should return a ENOENT read error', (done) ->
        extract options, (err) ->
          expect err.code .to.be.equal 'ENOENT'
          done!

      it 'should not exist files', ->
        expect exists "#{dest}/package.json" .to.be.false

    describe 'destination', (_) ->

      options =
        path: "#{orig}/sample.tar"
        dest: dest

      after -> rm dest

      it 'should not return an error', (done) ->
        extract options, (err) ->
          expect err .to.be.empty
          done!

      it 'should not exist files', ->
        expect exists "#{dest}/package.json" .to.be.true
