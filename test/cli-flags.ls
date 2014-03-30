{
  rm
  cwd
  exec
  expect
  suppose
  version
} = require './lib/helper'

describe 'CLI', (_) ->

  describe 'general flags', (_) ->

    it 'should return the expected version', (done) ->
      exec 'data', <[--version]>, ->
        expect it .to.match new RegExp "#{version}"
        done!

    it 'should show the help', (done) ->
      exec 'data', <[--help]>, ->
        expect it .to.match new RegExp "Usage examples"
        done!

    it 'should exit with 0 code', (done) ->
      exec 'close', <[--help]>, ->
        expect it .to.be.equal 0
        done!
