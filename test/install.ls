{ fs, rm, mk, chdir, exists, expect, server, static-server } = require './lib/helper'
install = require '../lib/install'

describe 'install', ->

  mock = http = null
  dest = "#{__dirname}/fixtures/.tmp"
  orig = "#{__dirname}/fixtures/archives"

  before (done) ->
    http := static-server orig, -> done!

  before (done) ->
    mock := server -> done!


  after (done) ->
    http.close -> done!

  after (done) ->
    mock.stop -> done!

  describe 'local', (_) ->

    before ->
      rm dest
      mk dest
      chdir dest

    after ->
      chdir "#{__dirname}/.."
      rm dest

    options = path: "#{orig}/sample.nar"

    describe 'valid', (_) ->

      it 'should install', (done) ->
        install options .on 'end', ->
          expect it.dest .to.match /node_modules\/pkg/
          done!

      it 'should exists package.json', ->
        expect exists "node_modules/pkg/package.json" .to.be.true

      it 'should exists .nar.json', ->
        expect exists "node_modules/pkg/.nar.json" .to.be.true

      it 'should exists node_modules', ->
        expect exists "node_modules/pkg/node_modules" .to.be.true

  describe 'remote', (_) ->

    options = path: 'http://127.0.0.1:8883/sample.nar'

    before ->
      rm dest
      mk dest
      chdir dest

    after ->
      chdir "#{__dirname}/.."
      rm dest

    describe 'valid', (_) ->

      it 'should install', (done) ->
        install options .on 'end', ->
          expect it.dest .to.match /node_modules\/pkg/
          done!

      it 'should exists package.json', ->
        expect exists "node_modules/pkg/package.json" .to.be.true

      it 'should exists .nar.json', ->
        expect exists "node_modules/pkg/.nar.json" .to.be.true

      it 'should exists node_modules', ->
        expect exists "node_modules/pkg/node_modules" .to.be.true

    describe 'invalid', (_) ->

      it 'should emit an error if 404 status is returned', (done) ->
        install { url: 'http://127.0.0.1:8882/invalid', dest: '.' }
          .on 'error', (err, code) ->
            expect err .to.be.an 'object'
            expect code .to.be.equal 404
            expect exists "#{dest}/invalid" .to.be.false
            done!

      it 'should emit an error if cannot resolve the host', (done) ->
        install { url: 'http://nonexistenthost/download', dest: '.', timeout: 1000 }
          .on 'error', ->
            expect it .to.match /ENOTFOUND|ESOCKETTIMEDOUT/
            done!

      it 'should emit an error if cannot connect', (done) ->
        install { url: 'http://127.0.0.1:54321', dest: '.', timeout: 2000 }
          .on 'error', ->
            expect it .to.match /ECONNREFUSED/
            done!

      it 'should emit an error if timeout exceeds', (done) ->
        install { url: 'http://127.0.0.1:8882/timeout', dest: '.', timeout: 2000 }
          .on 'error', ->
            expect it .to.match /ETIMEDOUT|ESOCKETTIMEDOUT/
            done!
