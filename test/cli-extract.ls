{
  rm
  mk
  cwd
  exec
  exists
  expect
  version
} = require './lib/helper'

describe 'CLI', (_) ->

  describe 'extract', (_) ->

    describe 'basic', (_) ->
      dir = "#{__dirname}/fixtures/.tmp"

      before ->
        mk dir
        process.chdir dir

      after ->
        rm dir
        process.chdir "#{__dirname}/.."

      it 'should create the temporal archive', (done) ->
        exec 'close', <[create]>, ->
          expect exists "#{dir}/nar-#{version}.nar" .to.be.true
          expect it .to.be.equal 0
          done!

      it 'should extract the archive files', (done) ->
        exec 'close', <[extract]>, ->
          if it isnt 8
            expect it .to.be.equal 0
          done!

      it 'should exists the package.json', ->
        expect exists "#{dir}/package.json" .to.be.true

      it 'should be a valid package.json file', ->
        expect (require "#{dir}/package.json" .name) .to.be.equal 'nar'

      it 'should exists the node_modules directory', ->
        expect exists "#{dir}/node_modules" .to.be.true

      it 'should exists the exists the package dependency directory', ->
        expect exists "#{dir}/node_modules/commander" .to.be.true

      it 'should exists the exists the package.json in dependency', ->
        expect exists "#{dir}/node_modules/commander/package.json" .to.be.true

