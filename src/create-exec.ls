require! {
  fs
  fw
  path
  './pack'
  './utils'
  './unpack'
  './create'
  './download'
  'array-unique'
  'resolve-tree'
  ncp: { ncp }
  child_process: { exec }
  events: { EventEmitter }
  path: { dirname, join, basename, relative }
}

{ rm, mk, is-win, tmpdir, copy-binary, rename, exists, once, is-file, extend, handle-exit, arch, discover-pkg, resolve-pkg-path } = utils

const script = __dirname |> join _, '..', 'scripts/run.sh'
const supported-platforms = <[ linux darwin sunos ]>
const supported-archs = <[ x86 x64 armv7l ]>

const supported-versions = [
  /^0.(8|9|10|11|12).[0-9]+$/,
  /^[0-9].[0-9].[0-9]+$/
]

const copy-opts =
  stopOnErr: no
  clobber: yes

module.exports = (options) ->
  emitter = new EventEmitter
  options = options |> apply
  dest = options.dest or process.cwd!
  tmp-path = tmpdir!
  tmp-download = null
  options.dest = tmp-path
  node-binary = null

  clean = ->
    emitter.emit 'message', 'Cleaning temporary directories'
    try
      tmp-path |> rm
      tmp-download |> rm if tmp-download

  on-error = once (err) ->
    clean!
    err |> emitter.emit 'error', _

  on-download-error = (err) ->
    err |> on-error

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  on-end = ->
    clean!
    it |> emitter.emit 'end', _

  on-create-end = (nar-path) ->
    nar-path |> create-executable

  on-progress = (status) ->
    status |> emitter.emit 'progress', _

  on-download = ->
    'download' |> emitter.emit

  on-download-end = ->
    it |> emitter.emit 'downloadEnd', _

  get-binary-type = ->
    { os, arch } = options
    "#{os}-#{arch}"

  create-executable = (nar) ->
    nar-file = nar |> basename _, '.nar'
    nar-path = (dest |> join _, nar-file) + '.run'
    nar-output = (dest |> join _, nar-file) + "-#{get-binary-type!}.nar"

    clean-exec = ->
      nar-path |> rm
      clean!

    copy-node-binary = (done) ->
      bin-dir = tmp-path |> join _, 'bin'
      bin-dir |> mk
      (node-binary or process.exec-path)
      |> copy-binary _, bin-dir, done

    copy-directory = (dest) -> (dir, next) ->
      name = (dir |> basename)
      orig = name |> join dest, _
      pkg-dest = name |> join dest, _

      fs.exists orig, (exists) ->
        return next! if exists
        fs.exists pkg-dest, (exists) ->
          return next! if exists
          dir |> ncp _, pkg-dest, copy-opts, next

    copy-nar-pkg = (done) ->
      nar-dest = tmp-path |> join _, 'nar'
      nar-path = __dirname |> join _, '..'
      nar-manifest = require(nar-path |> join _, 'package.json')

      do-copy = (paths, done) ->
        # Copy nar directory recursively
        nar-path |> ncp _, nar-dest, copy-opts, (err) ->
          return err |> done if err
          # Copy shared dependencies recursively
          deps-dest = nar-dest |> join _, 'node_modules'
          # Run copy in parallel
          fw.each paths, (deps-dest |> copy-directory), done

      resolve-tree.manifest nar-manifest, basedir: nar-path, (err, tree) ->
        return cb err if err

        # Filter by top level dependencies
        paths = tree |> resolve-tree.flattenMap _, 'root' |> array-unique

        # Copy root level dependencies
        root-paths = paths.filter -> (join options.base, 'node_modules', basename(it)) is it

        # Copy parent dependencies in case that nar is a nested dependency
        parent-paths = paths
          .filter -> (it |> root-paths.index-of) is -1
          .filter -> (new RegExp "^#{nar-path}" .test it) is no
          .map -> (it |> relative (join options.base, 'node_modules'), _).split '/' .shift!
          .map -> join options.base, 'node_modules', it
          .filter -> (it |> root-paths.index-of) is -1
          |> array-unique

        (root-paths ++ parent-paths) |> do-copy _, done

    create-tarball = (done) ->
      const config =
        name: nar |> basename _, '.nar'
        dest: dest
        patterns: [ '**' ]
        src: tmp-path
        ext: 'run'
        gzip: yes

      (config |> pack)
        .on 'error', done
        .on 'entry', on-entry
        .on 'end', -> done!

    create-binary = (done) ->
      cmd = if is-win then 'type' else 'cat'
      exec "#{cmd} \"#{script}\" \"#{nar-path}\" > \"#{nar-output}\"", done

    generate = ->
      'generate' |> emitter.emit
      fw.parallel [ copy-node-binary, copy-nar-pkg ], (err) ->
        return new Error 'cannot copy files to temporal directory: ' + err |> on-error if err
        fw.series [ create-tarball, create-binary ], (err) ->
          return new Error "cannot create the executable due to error: #{err.messsage or err}" |> on-error if err
          clean-exec!
          emitter.emit 'end', nar-output

    extract-binary = (options) ->
      options <<< gzip: yes
      (options |> unpack)
        .on 'error', on-error
        .on 'end', ->
          node-binary := options.dest |> join _, options.name, 'bin', 'node'
          generate!

    get-download-url = (engine) ->
      engine = if engine is 'node' then 'nodejs' else engine
      "https://#{engine}.org/dist"

    download-binary = ->
      { node, io } = options
      engine = if io then 'iojs' else 'node'
      version = io or node

      name = "#{engine}-#{version}-#{get-binary-type!}"
      url = "#{engine |> get-download-url}/#{version}/#{name}.tar.gz"
      dest = tmp-download := tmpdir!

      ({ url, dest, options.proxy } |> download)
        .on 'download', on-download
        .on 'progress', on-progress
        .on 'error', on-download-error
        .on 'end', ->
          it |> on-download-end
          { path: it, dest, name } |> extract-binary

    unless options |> same-node-binary
      download-binary!
    else
      generate!

  if is-win and options.os is 'win32'
    return new Error 'Windows do not support nar executables. Use --os <linux|darwin|sunos>' |> on-error

  mk tmp-path
  clean |> handle-exit

  (options |> create)
    .on 'error', on-error
    .on 'entry', on-entry
    .on 'end', on-create-end
    .on 'start', -> 'start' |> emitter.emit
    .on 'archive', -> 'archive' |> emitter.emit _, it

  emitter

apply = (options) ->
  options |> set-os
  options |> set-arch
  options |> set-node
  options <<< executable: yes

  if options.path
    pkg-path = options.path |> resolve-pkg-path
  else
    pkg-path = process.cwd!

  options <<< path: pkg-path |> discover-pkg

  if /\.json$/i.test pkg-path
    options <<< base: pkg-path |> dirname
  else
    options <<< base: pkg-path

  options

find-index = (arr, item) ->
  arr.index-of(item) isnt -1

match-version = (version) ->
  (supported-versions.filter -> it.test version).length isnt 0

same-node-binary = (options) ->
  { os, arch, node, io } = options
  node = io if io
  os is process.platform and arch is process.arch and node is process.version

set-os = (options) ->
  { os } = options
  if os
    if (supported-platforms |> find-index _, os)
      options <<< os: os
    else
      throw new Error "Invalid OS platform '#{os}'. Only #{supported-platforms.join ', '} are supported"
  else
    options <<< os: process.platform

set-arch = (options) ->
  { arch } = options
  if arch
    if (supported-archs |> find-index _, arch)
      options <<< arch: arch
    else
      throw new Error "Invalid architecture '#{arch}'. Only x86, x64 and armv7l are supported"
  else
    options <<< arch: process.arch

set-node = (options) ->
  { node, io } = options
  if node
    if node is 'latest'
      options <<< node: 'latest'
    else if (node |> match-version)
      options <<< node: "v#{node}"
    else
      throw new Error "Invalid node version '#{node}'"
  else if io
    if io is 'latest'
      options <<< io: 'latest'
    else if (io |> match-version)
      options <<< io: "v#{io}"
    else
      throw new Error "Invalid io.js version '#{io}'"
  else
    options <<< node: process.version
