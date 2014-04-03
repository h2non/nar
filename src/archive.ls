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
{ read, random, tmpdir, clone, extend, is-object, is-file, mk, now, stringify, vals, exists, checksum, lines } = require './utils'


const nar-file = '.nar.json'
const ext = 'nar'
const ignore-files = [ '.gitignore' '.npmignore' '.buildignore' '.narignore' ]
const defaults =
  path: null
  binary: no
  dependencies: yes
  dev-dependencies: no
  peer-dependencies: yes

class Archive extends EventEmitter

  (options, cb) ->
    @pkg = {}
    @options = options |> apply-options
    @pkg-path = @options.path
    @set-values!

  set-values: ->
    @pkg = @pkg-path |> read-pkg-file if @pkg-path
    @options = @pkg |> apply-pkg-options @options, _ if @pkg
    @tmpdir = tmpdir @pkg.name

    @name = @pkg.name or 'unnamed'
    @file = get-filename @pkg
    @output = @file |> output-file _, @options.dest
    @dependencies = @options |> match-dependencies _, @pkg

  clean: ->
    try
      rm @tmpdir
      rm @file if @file

  compress: (cb) ->
    nar-config = @name |> nar-manifest _, @pkg

    deps = (done) ~>
      config =
        dest: @tmpdir
        base: @options.dest
        dependencies: @dependencies

      compress-dependencies config, ->
        nar-config.files = nar-config.files ++ it
        done!

    pkg = (done) ~>
      config =
        dest: @tmpdir
        base: @options.dest
        name: @name

      compress-pkg config, ->
        it |> nar-config.files.push
        done!

    all = (done) ~>
      nar-config |> @compress-all _, done

    do-compression = (done) ->
      async.series [ deps, pkg, all ], done

    try
      @tmpdir |> mk
      do-compression ~>
        @clean!
        @emit 'end', @output
    catch
      @clean!
      @emit 'error', e

  compress-all: (config, cb) ->
    options =
      name: @file
      dest: @options.dest
      patterns: [ '*.tar', nar-file ]
      src: @tmpdir
      ext: 'nar'
      gzip: yes

    pack-all = (done) ->
      pack options, (err) ->
        throw err if err
        done!

    save-config = (done) ~>
      config |> write-config _, @tmpdir, done

    exec = ->
      async.series [ save-config, pack-all ], -> cb!

    add-binary = ~>
      copy process.exec-path, @tmpdir, ~>
        (path.basename it) |> options.patterns.push
        info =
          archive: 'node'
          dest: '.node/bin'
          type: 'binary'

        checksum it, (err, hash) ->
          info <<< checksum: hash
          info |> config.files.push
          exec!

    if @options.binary
      config <<< binary: yes
      add-binary!
    else
      exec!

write-config = (config, tmpdir, cb) ->
  file = tmpdir |> path.join _, nar-file
  data = config |> stringify
  fs.writeFile file, data, (err) ->
    throw err if err
    cb!

nar-manifest = (name, pkg) ->
  { platform, arch, version } = process
  name: name
  time: now!
  binary: no
  info: {
    platform
    arch
    version
  }
  manifest: pkg
  files: []

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
    checksum pkg.path, (err, hash) ->
      pkg-info <<< checksum: hash
      cb pkg-info

compress-dependencies = (options, cb) ->
  { dest, base, dependencies } = options
  files = []

  add-bin-directory = ->
    bin-dir = path.join base, ('.bin' |> get-module-path)
    if exists bin-dir
      {
        name: '.bin'
        dest: '.bin' |> get-module-path
        src: bin-dir
      } |> it.push

  find-pkg = ->
    it.map ->
      name: it
      dest: dest
      src: findup (it |> get-module-path), cwd: base
    it |> add-bin-directory

  create-pkg = (pkg, done) ->
    pkg-info =
      archive: pkg.archive
      dest: pkg.name |> get-module-path
      type: 'dependency'

    checksum pkg.path, (err, hash) ->
      pkg-info <<< checksum: hash
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

exports = module.exports = Archive

#
# Pure functions helpers
#

is-valid = ->
  it and it.length

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
    pkg-path = options.path |> resolve-pkg-path
  else
    pkg-path = process.cwd!
  options <<< path: pkg-path |> discover-pkg
  unless options.dest
    options <<< dest: process.cwd!
  options

resolve-pkg-path = ->
  if it |> is-file
    it |> path.dirname |> resolve-pkg-path
  else
    it

get-ignored-files = (dir) ->
  patterns = []
  files = ignore-files
    .map -> it |> path.join "#{dir}", _
    .filter -> it |> exists
  files.splice 1 if files.length > 1
  if files.length
    patterns =
      ((files[0] |> read) |> lines)
        .filter -> it
        .map (.trim!)
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
