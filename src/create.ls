require! {
  fs
  fw
  path
  './pack'
  './utils'
  requireg.resolve
  events.EventEmitter
}
{ dirname, basename, join, normalize } = path
{
  read, rm, tmpdir, clone, extend, copy-binary, keys, archive-name,
  is-object, is-file, is-dir, is-link, is-string, mk, stringify,
  vals, exists, checksum, lines, next, is-array, now,
  replace-env-vars, discover-pkg, handle-exit, once, is-win
} = utils

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
  ignore-files: yes

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

  on-error = once (err) ->
    clean-error!
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  on-end = ->
    clean!
    output |> emitter.emit 'end', _ unless errored

  do-create = -> next ->
    clean-error |> handle-exit
    nar-config = name |> nar-manifest _, pkg
    nar-config |> emitter.emit 'start', _
    nar-config |> emitter.emit 'info', _

    deps = (done) ->
      tmp-path |> compress-dependencies _, base-dir, (err, files) ->
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
      tmp-path |> mk
      [ deps, base-pkg, all ] |> fw.series _, done

    on-compress = (err) ->
      return err |> on-error if err
      on-end!

    on-compress |> do-compression

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
      [ save-config, pack-all ] |> fw.series _, cb

    add-binary = ->
      { binary-path } = options
      return new Error "Binary path do not exists: #{binary-path}" |> on-error unless binary-path |> is-file

      pkg-info =
        name: 'node'
        archive: 'node'
        dest: '.node/bin'
        type: 'binary'

      pkg-info |> emitter.emit 'archive', _

      copy-binary binary-path, tmp-path, (err, file) ->
        return new Error "Error while copying the node binary: #{err}" |> on-error if err
        file |> basename |> config.patterns.push
        { name: pkg-info.archive, pkg-info.type, size: '10485760', source-path: binary-path } |> on-entry

        checksum file, (err, hash) ->
          pkg-info <<< checksum: hash
          pkg-info |> nar-config.files.push
          exec!

    if options.binary
      nar-config <<< binary: yes
      add-binary!
    else
      exec!

  compress-pkg = (config, cb) ->
    { dest, base, name, patterns } = config = config |> clone
    config.patterns = patterns.concat (base |> include-files-patterns _, options.ignore-files)
    config <<< src: base

    pkg-info =
      name: name
      archive: "#{name}.tar"
      dest: '.'
      type: 'package'

    pkg-info |> emitter.emit 'archive', _

    on-pack-end = (pkg) ->
      checksum pkg.path, (err, hash) ->
        pkg-info <<< checksum: hash
        cb pkg-info

    pack config
      .on 'error', -> throw it
      .on 'entry', on-entry
      .on 'end', on-pack-end

  compress-dependencies = (dest, base, cb) ->
    files = []
    globals = []

    add-bin-directory = ->
      bin-dir = join base, ('.bin' |> get-module-path)
      if bin-dir |> is-dir
        links = {}
        (bin-dir |> fs.readdir-sync)
          .filter -> not((/^\./).test it)
          .filter -> it isnt 'Thumbs.db'
          .for-each (file) ->
            if is-win
              # beta implementation for Windows binaries: pending parse batch code
              links <<< (file): (file |> join (bin-dir |> join _, '..', file, 'bin', file), _)
            else
              link-path = file |> join bin-dir, _
              links <<< (file): link-path |> fs.readlink-sync if link-path |> is-link
        {
          name: '_modules-bindir'
          src: bin-dir
          dest, links
        } |> it.push

    get-pkg-path = (name) ->
      path = name |> get-module-path |> join base, _
      unless path |> join _, 'package.json' |> is-file
        throw new Error "Missing required dependency in node_modules: #{name}\nRun: npm install"
      path

    find-pkg = ->
      it.map ->
        name: it
        dest: dest
        src: it |> get-pkg-path

    calculate-checksum = (pkg-path, pkg-info, done) ->
      pkg-path |> checksum _, (err, hash) ->
        throw new Error "Error while calculating checksum for package #{pkg-info.name}" if err
        pkg-info <<< checksum: hash
        pkg-info <<< dest: pkg-info.dest
        pkg-info |> done null, _

    define-pkg-info = (pkg, done) ->
      pkg-info = name: pkg.name
      pkg-info <<< archive: pkg.file if pkg.file

      if pkg.name is '_modules-bindir'
        pkg-info <<< type: 'binaries'
        pkg-info <<< { pkg.links }
        pkg-info |> files.push
        pkg-info |> done null, _
      else
        if (pkg.name |> globals.index-of) isnt -1
          pkg-info <<< dest: ".node/lib/node/#{pkg.name}"
          pkg-info <<< type: 'global-dependency'
        else
          pkg-info <<< dest: pkg.name |> get-module-path
          pkg-info <<< type: 'dependency'

        pkg-info |> emitter.emit 'archive', _
        pkg.path |> calculate-checksum _, pkg-info, (err, pkg-info) ->
          pkg-info |> files.push
          done ...

    do-pack = (options, done) ->
      if options.name is '_modules-bindir'
        options |> done null, _
      else
        (options |> pack)
          .on 'error', done
          .on 'entry', on-entry
          .on 'end', -> done null, it

    compress-dep-pkgs = (pkgs, done) ->
      fw.map pkgs, do-pack, (err, results) ->
        return err |> done if err
        fw.map results, define-pkg-info, done

    find-global = (name) ->
      module = name |> resolve
      throw new Error "Cannot find global dependency: #{name}" unless module

      if json-path = (module |> dirname) |> discover-pkg
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
      list |> fw.each _, compress-dep-pkgs, (|> cb _, files)
    else
      cb!

  try
    do-create!
  catch
    e |> on-error
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
  info: { platform, arch, version }
  manifest: pkg
  files: []

include-files-patterns = (dir, ignore) ->
  patterns = [ '**' ] ++ ignored-files
  patterns = patterns ++ (dir |> get-ignored-files) if ignore
  patterns

get-ignored-files = (dir) ->
  patterns = []
  files = ignore-files.map (|> join dir, _) .filter (|> exists)
  files = files.slice -1 if files.length > 1
  if files.length
    ignored = ((files[0] |> read) |> lines)
    if ignored |> is-array
      patterns = ignored
        .filter (-> it)
        .map -> if (it |> join dir, _) |> is-dir then "#{it}/**" else it
        .map -> "!#{it.trim!}"
  patterns = patterns ++ ignore-files.map -> "!#{it}"
  patterns

is-valid = -> it and it.length

output-file = (file, dir) ->
  "#{file}.nar" |> join dir, _

get-filename = (options, pkg = {}) ->
  { file, binary } = options
  if file
    name = file.replace /\.[a-z0-9]$/i, ''
  else
    name = pkg.name or 'unnamed'
    name += "-#{pkg.version}" if pkg.version

  name += "-#{process.platform}-#{process.arch}" if binary
  name

apply-pkg-options = (options, pkg) ->
  pkg.archive |> extend options, _

apply = (options) ->
  options = (defaults |> clone) |> extend _, options
  options.patterns ||= []

  if options.path
    pkg-path = options.path |> resolve-pkg-path
  else
    pkg-path = process.cwd!

  options <<< binary-path: options |> get-binary-path
  options <<< path: pkg-path |> discover-pkg
  options <<< dest: process.cwd! unless options.dest
  options

resolve-pkg-path = ->
  if it |> is-file
    it |> dirname |> resolve-pkg-path
  else
    it

get-binary-path = (options) ->
  binary = options.binary-path
  binary = process.env.NAR_BINARY if process.env.NAR_BINARY
  binary |> normalize |> replace-env-vars

get-module-path = ->
  it = '.bin' if it is '_modules-bindir'
  it |> join 'node_modules', _

match-dependencies = (options, pkg) ->
  { dependencies, dev-dependencies, peer-dependencies, global-dependencies } = options
  deps = {}
  deps <<< run: pkg.dependencies |> keys if dependencies
  deps <<< dev: pkg.dev-dependencies |> keys if dev-dependencies
  deps <<< peer: pkg.peer-dependencies |> keys if peer-dependencies
  deps <<< global: global-dependencies if global-dependencies |> is-array
  deps
