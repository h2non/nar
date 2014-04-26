{ fs, rm, mk, chdir, exists, expect, server, request } = require './lib/helper'
download = require '../lib/download'

describe 'download', ->

  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  describe 'remote', (_) ->

    before (done) ->
      server -> done!

    before-each ->
      rm dest
      mk dest
      chdir dest

    after-each ->
      chdir "#{__dirname}/.."
      rm dest

    describe 'normal', (_) ->

      it 'should do a request', (done) ->
        stream = fs.create-write-stream "#{dest}/archive.nar"
        request 'http://localhost:8882/download/archive.nar' .pipe stream
        stream.on 'close', ->
          expect exists "#{dest}/archive.nar" .to.be.true
          done!

    describe 'authentication', (_) ->

      it 'should do a request with authentication', (done) ->
        stream = fs.create-write-stream "#{dest}/archive-auth.nar"
        options = auth: { user: 'nar', pass: 'passw0rd' }
        request 'http://localhost:8882/download/auth/archive.nar', options .pipe stream
        stream.on 'close', ->
          expect exists "#{dest}/archive-auth.nar" .to.be.true
          done!
