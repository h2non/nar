{ fs, rm, mk, chdir, exists, expect, server } = require './lib/helper'
download = require '../lib/download'

describe 'download', ->

  mock = null
  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  before (done) ->
    mock := server -> done!

  before-each ->
    rm dest
    mk dest
    chdir dest

  after-each ->
    chdir "#{__dirname}/.."
    rm dest

  after (done) ->
    mock.stop -> done!

  describe 'normal', (_) ->

    options =
      url: 'http://127.0.0.1:8882/download/archive.nar'
      dest: '.'

    it 'should download file', (done) ->
      download options
        .on 'end', ->
          expect exists "#{dest}/archive.nar" .to.be.true
          done!

    describe 'invalid', (_) ->

      it 'should emit an error if 404 status is returned', (done) ->
        download { url: 'http://127.0.0.1:8882/invalid', dest: '.' }
          .on 'error', (err, code) ->
            expect err .to.be.an 'object'
            expect code .to.be.equal 404
            expect exists "#{dest}/invalid" .to.be.false
            done!

      it 'should emit an error if cannot resolve the host', (done) ->
        download { url: 'http://nonexistenthost/download', dest: '.', timeout: 1000 }
          .on 'error', ->
            expect it .to.match /ENOTFOUND|ETIMEDOUT|ESOCKETTIMEDOUT/
            done!

      it 'should emit an error if cannot connect', (done) ->
        download { url: 'http://127.0.0.1:54321', dest: '.', timeout: 2000 }
          .on 'error', ->
            expect it .to.match /ECONNREFUSED/
            done!

      it 'should emit an error if timeout exceeds', (done) ->
        download { url: 'http://127.0.0.1:8882/timeout', dest: '.', timeout: 2000 }
          .on 'error', ->
            expect it .to.match /ETIMEDOUT|ETIMEDOUT|ESOCKETTIMEDOUT/
            done!

  describe 'authentication', (_) ->

    describe 'options', (_) ->

      options =
        url: 'http://127.0.0.1:8882/download/auth/archive.nar'
        filename: 'archive-auth.nar'
        dest: '.'
        auth: user: 'nar', password: 'passw0rd'

      it 'should download archive using authentication', (done) ->
        download options
          .on 'end', ->
            expect exists "#{dest}/archive-auth.nar" .to.be.true
            done!

    describe 'URI', (_) ->

      options =
        url: 'http://nar:passw0rd@127.0.0.1:8882/download/auth/archive.nar'
        filename: 'archive-auth.nar'
        dest: '.'

      it 'should download archive using URI-level authentication', (done) ->
        download options
          .on 'end', ->
            expect exists "#{dest}/archive-auth.nar" .to.be.true
            done!

    describe 'invalid', (_) ->

      options =
        url: 'http://127.0.0.1:8882/download/auth/archive.nar'
        filename: 'archive-auth.nar'
        dest: '.'
        auth: user: 'nil', password: 'inval!d'

      it 'should not download the archive', (done) ->
        download options
          .on 'error', (err, code) ->
            expect err .to.match /invalid response code/i
            expect code .to.be.equal 404 # mock server returns 404
            done!
