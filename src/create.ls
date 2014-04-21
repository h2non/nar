require! {
  fs
  fw
  './pack'
  requireg.resolve
  events.EventEmitter
  findup: 'findup-sync'
}
{
  read, rm, tmpdir, clone, extend, copy, keys, archive-name,
  is-object, is-file, is-dir, is-string, mk, stringify,
  vals, exists, checksum, lines, next, is-array, now
} = require './utils'
{ dirname, basename, join, normalize } = require 'path'

const nar-file = '.nar.json'
const ext = 'nar'
const ignored-files = [ '!node_modules/**' ]
const ignore-files = [ '.gitignore' '.npmignore' '.buildignore' '.narignore' ]

const defaults =
  path: null
  binary: no
  binary-path: process.exec-path
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
  options <<< base: base-dir = pkg-path |> dirname

  file = options |> get-filename _, pkg
  output = file |> output-file _, options.dest

  clean = ->
    emitter.emit 'message', 'Cleaning temporary directories'
    try rm tmp-path

  clean-error = ->
    clean!
    try rm output

  on-error = (err) ->
    clean-error!
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  on-end = ->
    clean!
    output |> emitter.emit 'end', _ unless errored

  do-create = -> next ->
    nar-config = name |> nar-manifest _, pkg
    nar-config |> emitter.emit 'start', _
    nar-config |> emitter.emit 'info', _

    deps = (done) ->
      compress-dependencies tmp-path, base-dir, (err, files) ->
        return err |> on-error if err
        nar-config.files = nar-config.files ++ files if files
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
      fw.series [ deps, base-pkg, all ], done

    on-compress = (err) ->
      return err |> on-error if err
      on-end!

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
      fw.series [ save-config, pack-all ], cb

    add-binary = ->
      { binary-path } = options
      return  new Error "Binary path do not exists: #{binary-path}" |> on-error unless binary-path |> is-file
      info =
        archive: 'node'
        dest: '.node/bin'
        type: 'binary'

      copy binary-path, tmp-path, (err, file) ->
        return new Error "Error while copying the node binary: #{err}" |> on-error if err
        file |> basename |> config.patterns.push
        { name: info.archive, info.type, size: '10485760', source-path: binary-path } |> on-entry

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
      bin-dir = join base, ('.bin' |> get-module-path)
      {
        name: 'modules-bin-dir'
        dest: dest
        src: bin-dir
      } |> it.push if bin-dir |> is-dir

    get-pkg-path = (name) ->
      path = name |> get-module-path |> join base, _
      unless path |> join _, 'package.json' |> is-file
        throw new Error "Missing dependency in node_modules: #{name}"
      path

    find-pkg = ->
      it.map ->
        name: it
        dest: dest
        src: it |> get-pkg-path

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
      fw.map pkg, do-pack, (err, results) ->
        return err |> done if err
        fw.map results, define-pkg-info, done

    find-global = (name) ->
      module = name |> resolve
      throw new Error "Cannot find global dependency: #{name}" unless module

      if json-path = discover-pkg (module |> dirname)
        if pkg = json-path |> read
          pkg.name |> globals.push
          src = json-path |> dirname
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
    if list.length
      list |> fw.each _, compress-pkg, (|> cb _, files)
    else
      cb!

  do-create!
  emitter

write-config = (config, tmpdir, cb) ->
  file = tmpdir |> join _, nar-file
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
  [ '**' ] ++ ignored-files ++ (it |> get-ignored-files)

get-ignored-files = (dir) ->
  patterns = []
  files = ignore-files.map (|> join "#{dir}", _) .filter (|> exists)
  files = files.slice -1 if files.length > 1
  if files.length
    ignored = ((files[0] |> read) |> lines)
    patterns = ignored.filter (-> it) .map (-> "!#{it.trim!}") if ignored
  patterns = patterns ++ ignore-files.map -> "!#{it}"
  patterns

is-valid = -> it and it.length

output-file = (file, dir) ->
  "#{file}.nar" |> join dir, _

get-filename = (options, pkg = {}) ->
  if options.file
    name = options.file.replace /\.[a-z0-9]$/i, ''
  else
    name = pkg.name or 'unnamed'
    name += "-#{pkg.version}" if pkg.version

  name += "-#{process.platform}-#{process.arch}" if options.binary
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
  options <<< binary-path: options.binary-path |> normalize
  options

resolve-pkg-path = ->
  if it |> is-file
    it |> dirname |> resolve-pkg-path
  else
    it

get-module-path = ->
  it = '.bin' if it is 'modules-bin-dir'
  it |> join 'node_modules', _

match-dependencies = (options, pkg) ->
  { dependencies, dev-dependencies, peer-dependencies, global-dependencies } = options
  deps = {}
  deps <<< run: pkg.dependencies |> keys if dependencies
  deps <<< dev: pkg.dev-dependencies |> keys if dev-dependencies
  deps <<< peer: pkg.peer-dependencies |> keys if peer-dependencies
  deps <<< global: global-dependencies if global-dependencies |> is-array
  deps
