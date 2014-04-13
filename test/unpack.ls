{
  fs
  rm
  mk
  chdir
  exists
  expect
} = require './lib/helper'
unpack = require '../lib/unpack'

describe 'unpack', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'tarball', (_) ->

    options =
      path: "#{orig}/sample.tar"
      dest: dest

    before -> mk dest
    after -> rm dest

    it 'should unpackº files', (done) ->
      files = 0
      unpack options
        .on 'error', -> throw it
        .on 'entry', -> files += 1
        .on 'end', ->
          expect files .to.be.equal 6
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

    before -> mk dest
    after -> rm dest

    it 'should unpack files', (done) ->
      files = 0
      unpack options
        .on 'error', -> throw it
        .on 'entry', -> files += 1
        .on 'end', ->
          expect files .to.be.equal 6
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

    before -> mk dest
    after -> rm dest

    it 'should unpack files', (done) ->
      files = 0
      unpack options
        .on 'error', -> throw it
        .on 'entry', -> files += 1
        .on 'end', ->
          expect files .to.be.equal 6
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

  describe 'default destination', (_) ->

    options =
      path: "#{orig}/sample.tar"

    before -> mk dest
    before -> chdir dest
    after -> chdir "#{dest}/../../"
    after -> rm dest

    it 'should not return an error', (done) ->
      files = 0
      unpack options
        .on 'error', -> throw it
        .on 'entry', -> files += 1
        .on 'end', ->
          expect files .to.be.equal 6
          done!

    it 'should exist file', ->
      expect exists "#{dest}/package.json" .to.be.true

  describe 'error', (_) ->

    describe 'tar file' (_) ->

      options =
        path: "#{orig}/sample.tar"
        dest: dest
        gzip: yes

      before -> mk dest
      after -> rm dest

      it 'should return an file header check error', (done) ->
        files = 0
        unpack options
          .on 'entry', -> files += 1
          .on 'error', (err) ->
            expect files .to.be.equal 0
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

      before -> mk dest
      after -> rm dest

      it 'should return a checksum verification error', (done) ->
        files = 0
        unpack options
          .on 'entry', -> files += 1
          .on 'error', (err) ->
            expect files .to.be.equal 0
            expect err.message .to.match /checksum verification failed/i
            done!

      it 'should not exist files', ->
        expect exists "#{dest}/package.json" .to.be.false

    describe 'source', (_) ->

      options =
        path: "#{orig}/nonexistent.tar"
        dest: dest

      before -> mk dest
      after -> rm dest

      it 'should return a ENOENT read error', (done) ->
        files = 0
        unpack options
          .on 'entry', -> files += 1
          .on 'error', (err) ->
            expect files .to.be.equal 0
            expect err.code .to.be.equal 'ENOENT'
            done!

      it 'should not exist files', ->
        expect exists "#{dest}/package.json" .to.be.false

