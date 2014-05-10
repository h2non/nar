{ rm, mk, cwd, exec, read, chdir, exists, expect, version } = require './lib/helper'

describe 'CLI', ->

  describe 'extract', ->

    dir = "#{__dirname}/fixtures/.tmp"
    stdout = null

    describe 'basic', (_) ->

      before ->
        mk dir
        chdir dir

      after ->
        rm dir
        chdir "#{__dirname}/.."

      it 'should extract the archive files', (done) ->
        exec 'close', <[extract ../archives/sample]>, (code) ->
          expect code .to.be.equal 0 if it isnt 8
          done!

      it 'should exists the package.json', ->
        expect exists "#{dir}/package.json" .to.be.true

      it 'should be a valid package.json file', ->
        expect (read "#{dir}/package.json" .name) .to.be.equal 'test'

      it 'should exists .nar.json', ->
        expect exists "#{dir}/.nar.json" .to.be.true

      it 'should be a valid .nar.json file', ->
        expect (read "#{dir}/.nar.json" .name) .to.be.equal 'test'

      it 'should exists the .hidden hidden file', ->
        expect exists "#{dir}/.hidden" .to.be.true

      it 'should exists the sample.js files', ->
        expect exists "#{dir}/a/b/sample.js" .to.be.true

      it 'should exists the node_modules directory', ->
        expect exists "#{dir}/node_modules" .to.be.true

      it 'should not exists another nested dependency', ->
        expect exists "#{dir}/node_modules/some/node_modules/another" .to.be.true

    describe '--output', (_) ->

      before ->
        mk dir
        chdir dir

      after ->
        rm dir
        chdir "#{__dirname}/.."

      it 'should extract the archive files', (done) ->
        exec 'close', <[extract ../archives/sample -o]> ++ [dir], ->
          expect it .to.be.equal 0 if it isnt 8
          done!

      it 'should exists the package.json', ->
        expect exists "#{dir}/package.json" .to.be.true

    describe '--debug', (_) ->

      before ->
        mk dir
        chdir dir

      after ->
        rm dir
        chdir "#{__dirname}/.."

      it 'should extract the archive files', (done) ->
        exec 'data', <[extract ../archives/sample --debug]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 0 if it isnt 8
          done!

      it 'should exists the package.json', ->
        expect exists "#{dir}/package.json" .to.be.true

      it 'should output the extract report', ->
        expect stdout .to.match /extract /i
        expect stdout .to.match /extracted/i

      it 'should output the extraced files', ->
        expect stdout .to.match /some\.tar/i
        expect stdout .to.match /test\.tar/i
        expect stdout .to.match /package\.json/i
        expect stdout .to.match /\.nar\.json/i

    describe 'error', (_) ->

      before ->
        mk dir
        chdir dir

      after ->
        rm dir
        chdir "#{__dirname}/.."

      it 'should extract the archive files', (done) ->
        exec 'data', <[extract ../invalid --debug]>, (data, code) ->
          stdout := data
          expect code .to.be.equal 1
          done!

      it 'should exists the package.json', ->
        expect stdout .to.match /the given path is not/i
