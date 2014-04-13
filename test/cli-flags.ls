{
  rm
  cwd
  exec
  expect
  version
} = require './lib/helper'

describe 'CLI', (_) ->

  describe 'general flags', (_) ->

    it 'should return the expected version', (done) ->
      exec 'data', <[--version]>, (data, code) ->
        expect data .to.match new RegExp version
        expect code .to.be.equal 0
        done!

    it 'should show the help', (done) ->
      exec 'data', <[--help]>, (data, code) ->
        expect data .to.match new RegExp 'Usage examples'
        expect code .to.be.equal 0
        done!
