{
  rm
  cwd
  exec
  mkdirp
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
      exec 'close', <[--help]>, ->
        expect it .to.be.equal 0
        done!

  describe '', (_) ->

    before ->
      process.chdir "#{__dirname}/fixtures/"

    after ->
      process.chdir cwd


