require! {
  fs
  path
  async
  crypto
  matchdep
  './pack'
  './extract'
  events.EventEmitter
  findup: 'findup-sync'
}
{ read, random, tmpdir, clone, extend, is-object, is-file, mk, now, stringify, vals, exists, checksum, EOL } = require './helper'


const nar-file = '.nar.json'
const ext = 'nar'
const ignore-files = <[ .gitignore .npmignore .buildignore .narignore ]>
const defaults =
  path: null
  binary: no
  dependencies: yes
  dev-dependencies: no
  peer-dependencies: yes

class Package extends EventEmitter

  (options, cb) ->
    @pkg = {}
    @options = options |> apply-options
    @pkg-path = @options.path |> discover-pkg
    # update package base path
    @options <<< path: @pkg-path |> path.dirname if @pkg-path

    @pkg = @pkg-path |> read-pkg-file if @pkg-path
    @options = @pkg |> apply-pkg-options @options, _ if @pkg

    @tmpdir = tmpdir @pkg.name
    @tmpdir |> create-dir

    @name = @pkg.name or 'unnamed'
    @file = get-filename @pkg
    @output = @file |> output-file _, @options.path
    @dependencies = @options |> match-dependencies _, @pkg

  clean: ->
    try
      rm @tmpdir
      rm @file if @file

  nar-config: ->
    { platform, arch, version } = process
    name: @name
    time: now!
    info: {
      platform
      arch
      version
    }
    manifest: @pkg
    files: []

  compress: (cb) ->
    nar-config = @nar-config!

    deps = (done) ~>
      config =
        dest: @tmpdir
        base: @options.path
        dependencies: @dependencies

      compress-dependencies config, ->
        nar-config.files = nar-config.files ++ it
        done!

    pkg = (done) ~>
      config =
        dest: @tmpdir
        base: @options.path
        name: @name

      compress-pkg config, ->
        it |> nar-config.files.push
        done!

    all = (done) ~>
      nar-config |> @compress-all _, done

    async.series [ deps, pkg, all ], ~>
      @clean!
      cb!

  write-config: (config, cb) ->
    file = @tmpdir |> path.join _, nar-file
    data = config |> stringify
    fs.writeFile file, data, (err) ->
      throw err if err
      cb!

  compress-all: (config, cb) ->
    options =
      name: @file
      dest: @options.path
      patterns: [ '*.tar', nar-file ]
      src: @tmpdir
      ext: 'nar'
      gzip: yes

    pack-all = (done) ->
      pack options, (err) ->
        throw err if err
        done!

    write-config = (done) ~>
      config |> @write-config _, done

    exec = ->
      async.series [ write-config, pack-all ], -> cb!

    add-binary = ~>
      copy process.exec-path, @tmpdir, ~>
        (path.basename it) |> options.patterns.push
        info =
          archive: 'node'
          dest: '.node/bin'
          type: 'binary'

        checksum it, ->
          info <<< checksum: it
          info |> config.files.push
          exec!

    if @options.binary
      add-binary!
    else
      exec!

compress-pkg = (options, cb) ->
  { dest, base, name } = options

  patterns = [ '**', '.*', '!node_modules/**' ] ++ ignore-files ++ (base |> get-ignored-files)

  options = {
    name, dest, patterns
    src: base
  }

  pkg-info =
    archive: "#{@name}.tar"
    dest: '.'
    type: 'package'

  pack options, (err, pkg) ->
    throw err if err
    checksum pkg.path, ->
      pkg-info <<< checksum: it
      cb pkg-info

compress-dependencies = (options, cb) ->
  { dest, base, dependencies } = options
  files = []

  find-pkg = ->
    it.map ->
      name: it
      dest: dest
      src: findup (it |> get-module-path), cwd: base

  is-valid = ->
    it and it.length

  calculate-checksum = (path, done) ->
    checksum ...

  create-pkg = (pkg, done) ->
    pkg-info =
      archive: pkg.archive
      dest: pkg.name |> path.join 'node_modules', _
      type: 'dependency'

    calculate-checksum pkg.path, ->
      pkg-info <<< checksum: it
      pkg-info |> files.push
      done null, pkg-info

  compress-pkg = (pkg, done) ->
    async.map pkg, pack, (err, results) ->
      return done err if err
      async.map results, create-pkg, done

  ((dependencies |> vals)
    .map find-pkg
    .filter is-valid)
    |> async.each _, compress-pkg, ->
      it |> cb _, files

module.exports = Package

#
# Pure functions helpers
#

create-dir = ->
  it |> mk

output-file = (file, dir) ->
  "#{file}.nar" |> path.join dir, _

get-filename = (pkg = {}) ->
  name = pkg.name or 'unnamed'
  name += "-#{pkg.version}" if pkg.version
  name

apply-pkg-options = (options, pkg) ->
  pkg.archive |> extend options, _

read-pkg-file = ->
  it |> read

discover-pkg = (dir = process.cwd!) ->
  findup 'package.json', cwd: dir

apply-options = (options) ->
  options = (defaults |> clone) |> extend _, options
  if options.path
    options <<< path: options.path |> resolve-pkg-path
  else
    options <<< path: process.cwd!
  options

resolve-pkg-path = ->
  if it |> is-file
    it |> path.dirname |> set-path
  else
    it

get-ignored-files = (dir) ->
  patterns = []
  ignore-files
    .map -> it |> path.join "#{dir}", _
    .filter -> it |> exists
    .filter ->
      not (((it.index-of '.gitignore') isnt -1) and @length > 1)
    .for-each ->
      patterns = ((it |> read).split EOL) ++ patterns
  patterns

get-module-path = ->
  it |> path.join 'node_modules', _

match-dependencies = (options, pkg) ->
  { dependencies, dev-dependencies, peer-dependencies } = options
  deps = {}
  deps <<< run: matchdep.filter '*', pkg if dependencies
  deps <<< dev: matchdep.filter-dev '*', pkg if dev-dependencies
  deps <<< peer: matchdep.filter-peer '*', pkg if peer-dependencies
  deps
