{
  rm
  mk
  cwd
  exec
  read
  exists
  expect
  version
} = require './lib/helper'

describe 'CLI', (_) ->

  xdescribe 'extract', (_) ->

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
          expect it .to.be.equal 0 if it isnt 8
          done!

      it 'should exists the package.json', ->
        expect exists "#{dir}/package.json" .to.be.true

      it 'should be a valid package.json file', ->
        expect (read "#{dir}/package.json" .name) .to.be.equal 'nar'

      it 'should exists .nar.json', ->
        expect exists "#{dir}/.nar.json" .to.be.true

      it 'should be a valid .nar.json file', ->
        expect (read "#{dir}/.nar.json" .name) .to.be.equal 'nar'

      it 'should exists the README file', ->
        expect exists "#{dir}/README.md" .to.be.true

      it 'should exists the .npmignore hidden file', ->
        expect exists "#{dir}/.npmignore" .to.be.true

      it 'should exists the lib directory', ->
        expect exists "#{dir}/lib" .to.be.true

      it 'should exists the lib/nar.js files', ->
        expect exists "#{dir}/lib/nar.js" .to.be.true

      it 'should exists the node_modules directory', ->
        expect exists "#{dir}/node_modules" .to.be.true

      it 'should exists the package dependency directory', ->
        expect exists "#{dir}/node_modules/commander" .to.be.true

      it 'should exists the exists the package.json in dependency', ->
        expect exists "#{dir}/node_modules/commander/package.json" .to.be.true

      it 'should be a valid dependency package.json', ->
        expect (read "#{dir}/node_modules/commander/package.json" .name) .to.be.equal 'commander'

      it 'should not exists a devDependency package', ->
        expect exists "#{dir}/node_modules/mocha" .to.be.false
