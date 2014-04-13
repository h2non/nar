{
  fs
  rm
  mk
  chdir
  exists
  expect
} = require './lib/helper'
extract = require '../lib/extract'

describe 'extract', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'basic', (_) ->

    options =
      path: "#{orig}/sample.nar"
      dest: dest

    before -> rm dest
    before -> mk dest
    after -> rm dest

    it 'should extract files', (done) ->
      files = 0
      extract options
        .on 'error', -> throw it
        .on 'entry', -> files += 1
        .on 'end', ->
          expect files .to.be.equal 9
          done!

    it 'should exist .nar.json', ->
      expect exists "#{dest}/.nar.json" .to.be.true

    it 'should exist package.json', ->
      expect exists "#{dest}/package.json" .to.be.true

    it 'should exist .hidden', ->
      expect exists "#{dest}/.hidden" .to.be.true

    it 'should exist node_modules directory', ->
      expect exists "#{dest}/node_modules" .to.be.true

    it 'should exist some package dependency', ->
      expect exists "#{dest}/node_modules/some/package.json" .to.be.true

    it 'should exist package nested dependency', ->
      expect exists "#{dest}/node_modules/some/node_modules/another/package.json" .to.be.true

    it 'should exist hidden file', ->
      expect exists "#{dest}/.hidden" .to.be.true

    it 'should exist sample.js', ->
      expect exists "#{dest}/a/b/sample.js" .to.be.true

  describe 'invalid', (_) ->

    describe 'path', (_) ->

      options =
        path: "#{orig}/invalid.nar"
        dest: dest

      it 'should not extract files', (done) ->
        files = 0
        extract options
          .on 'end', done
          .on 'error', ->
            expect it.message .to.match /do not exists or is invalid/i
            done!
