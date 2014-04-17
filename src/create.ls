require! {
  fs
  path
  async
  './pack'
  requireg.resolve
  events.EventEmitter
  findup: 'findup-sync'
}
{
  read, rm, tmpdir, clone, extend, copy, keys,
  is-object, is-file, is-dir, is-string, mk, stringify,
  vals, exists, checksum, lines, next, is-array, now
} = require './utils'

const nar-file = '.nar.json'
const ext = 'nar'
const ignored-files = [ '!node_modules/**' ]
const ignore-files = [ '.gitignore' '.npmignore' '.buildignore' '.narignore' ]

const defaults =
  path: null
  binary: no
  dependencies: yes
  dev-dependencies: no
  peer-dependencies: yes
  global-dependencies: null
  patterns: null

module.exports = create = (options) ->
  errored = no
  emitter = new EventEmitter
  options = options |> apply
  pkg-path = options.path

  pkg = pkg-path |> read if pkg-path
  options = pkg |> apply-pkg-options options, _ if pkg
  throw new Error 'Cannot find package.json' unless pkg

  name = pkg.name or 'unnamed'
  tmp-path = tmpdir name
  options <<< base: base-dir = pkg-path |> path.dirname

  file = if options.file then options.file else get-filename pkg
  output = file |> output-file _, options.dest

  clean = ->
    emitter.emit 'message', 'Cleaning temporary directories'
    try rm tmp-path

  on-error = (err) ->
    clean!
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  do-create = -> next ->
    nar-config = name |> nar-manifest _, pkg
    nar-config |> emitter.emit 'start', _
    nar-config |> emitter.emit 'info', _

    deps = (done) ->
      compress-dependencies tmp-path, base-dir, (err, files) ->
        return err |> on-error if err
        nar-config.files = nar-config.files ++ files
        done!

    base-pkg = (done) ->
      config =
        dest: tmp-path
        base: base-dir
        name: name
        patterns: options.patterns

      compress-pkg config, ->
        it |> nar-config.files.push
        done!

    all = (done) ->
      nar-config |> compress-all _, done

    do-compression = (done) ->
      async.series [ deps, base-pkg, all ], done

    on-compress = (err) ->
      return err |> on-error if err
      clean!
      output |> emitter.emit 'end', _

    try
      tmp-path |> mk
      on-compress |> do-compression
    catch
      e |> on-error

  compress-all = (nar-config, cb) ->
    config =
      name: file
      dest: options.dest
      patterns: [ '*.tar', nar-file ]
      src: tmp-path
      ext: 'nar'
      gzip: yes

    pack-all = (done) ->
      pack config
        .on 'error', done
        .on 'entry', on-entry
        .on 'end', -> done!

    save-config = (done) ->
      nar-config |> write-config _, tmp-path, done

    exec = ->
      async.series [ save-config, pack-all ], cb

    add-binary = ->
      info =
        archive: 'node'
        dest: '.node/bin'
        type: 'binary'

      copy process.exec-path, tmp-path, (err, file) ->
        return new Error "Error while copying the node binary: #{err}" |> on-error if err
        file |> path.basename |> config.patterns.push
        { name: info.archive, info.type, size: '10485760' } |> on-entry

        checksum file, (err, hash) ->
          info <<< checksum: hash
          info |> nar-config.files.push
          exec!

    if options.binary
      nar-config <<< binary: yes
      add-binary!
    else
      exec!

  compress-pkg = (options, cb) ->
    { dest, base, name, patterns } = options = options |> clone
    options.patterns = patterns.concat (base |> include-files-patterns)
    options <<< src: base

    pkg-info =
      archive: "#{name}.tar"
      dest: '.'
      type: 'package'

    on-pack-end = (pkg) ->
      checksum pkg.path, (err, hash) ->
        pkg-info <<< checksum: hash
        cb pkg-info

    pack options
      .on 'error', -> throw it
      .on 'entry', on-entry
      .on 'end', on-pack-end

  compress-dependencies = (dest, base, cb) ->
    files = []
    globals = []

    add-bin-directory = ->
      bin-dir = path.join base, ('.bin' |> get-module-path)
      {
        name: 'modules-bin-dir'
        dest: dest
        src: bin-dir
      } |> it.push if bin-dir |> is-dir

    find-pkg = ->
      it.map ->
        name: it
        dest: dest
        src: findup (it |> get-module-path), cwd: base

    calculate-checksum = (pkg-path, pkg-info, done) ->
      checksum pkg-path, (err, hash) ->
        throw new Error "Error while calculating checksum for package #{pkg-info.name}" if err
        pkg-info <<< checksum: hash
        pkg-info |> files.push
        done null, pkg-info

    define-pkg-info = (pkg, done) ->
      pkg-info = archive: pkg.file

      if (pkg.name |> globals.index-of) isnt -1
        pkg-info <<< dest: ".node/lib/node/#{pkg.name}"
        pkg-info <<< type: 'global-dependency'
      else
        pkg-info <<< dest: pkg.name |> get-module-path
        pkg-info <<< type: 'dependency'

      pkg.path |> calculate-checksum _, pkg-info, done

    do-pack = (options, done) ->
      (options |> pack)
        .on 'error', done
        .on 'entry', on-entry
        .on 'end', -> done null, it

    compress-pkg = (pkg, done) ->
      async.map pkg, do-pack, (err, results) ->
        return err |> done if err
        async.map results, define-pkg-info, done

    find-global = (name) ->
      module = name |> resolve
      throw new Error "Cannot find global dependency: #{name}" unless module

      json-path = discover-pkg (module |> path.dirname)
      if json-path
        pkg = json-path |> read
        if pkg
          pkg.name |> globals.push
          src = json-path |> path.dirname
          return { pkg.name, dest, src }

    process-global = (globals) ->
      (globals |> vals)
        .filter is-valid
        .map find-global

    process-deps = (deps) ->
      deps = (deps |> vals)
        .filter is-valid
        .map find-pkg
        .filter is-valid
      deps[0] |> add-bin-directory if deps.length
      deps

    dependencies-list = ->
      { run, dev, peer, global } = (options |> match-dependencies _, pkg)
      list = { run, dev, peer } |> process-deps
      list = list ++ [ (global |> process-global) ] if global
      list

    list = dependencies-list!
    list |> async.each _, compress-pkg, (|> cb _, files)

  do-create!
  emitter

write-config = (config, tmpdir, cb) ->
  file = tmpdir |> path.join _, nar-file
  data = config |> stringify
  fs.write-file file, data, cb

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

include-files-patterns = ->
  ignored-files ++ [ '**' ] ++ ignore-files ++ (it |> get-ignored-files)

is-valid = -> it and it.length

output-file = (file, dir) ->
  "#{file}.nar" |> path.join dir, _

get-filename = (pkg = {}) ->
  name = pkg.name or 'unnamed'
  name += "-#{pkg.version}" if pkg.version
  name

apply-pkg-options = (options, pkg) ->
  pkg.archive |> extend options, _

discover-pkg = (dir = process.cwd!) ->
  findup 'package.json', cwd: dir

apply = (options) ->
  options = (defaults |> clone) |> extend _, options
  options.patterns ||= []

  if options.path
    pkg-path = options.path |> resolve-pkg-path
  else
    pkg-path = process.cwd!

  options <<< path: pkg-path |> discover-pkg
  options <<< dest: process.cwd! unless options.dest
  options

resolve-pkg-path = ->
  if it |> is-file
    it |> path.dirname |> resolve-pkg-path
  else
    it

get-ignored-files = (dir) ->
  patterns = []
  files = ignore-files.map (|> path.join "#{dir}", _) .filter (|> exists)
  files = files.slice -1 if files.length > 1
  if files.length
    ignored = ((files[0] |> read) |> lines)
    patterns = ignored.filter (-> it) .map (-> "!#{it.trim!}") if ignored
  patterns

get-module-path = ->
  it = '.bin' if it is 'modules-bin-dir'
  it |> path.join 'node_modules', _

match-dependencies = (options, pkg) ->
  { dependencies, dev-dependencies, peer-dependencies, global-dependencies } = options
  deps = {}
  deps <<< run: pkg.dependencies |> keys if dependencies
  deps <<< dev: pkg.dev-dependencies |> keys if dev-dependencies
  deps <<< peer: pkg.peer-dependencies |> keys if peer-dependencies
  deps <<< global: global-dependencies if global-dependencies |> is-array
  deps
