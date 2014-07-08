require! {
  fs
  fw
  path
  './unpack'
  events.EventEmitter
  findup: 'findup-sync'
}
{ symlink-sync, chmod-sync, readdir-sync } = fs
{ join, dirname, normalize, sep, relative } = path
{ next, copy, is-file, is-dir, tmpdir, rm, mk, read, write, clone, add-extension, is-executable, executable-msg, is-win, is-string, is-object, win-binary-script } = require './utils'

module.exports = extract = (options = {}) ->
  { path, dest, tmpdir } = options = options |> apply
  emitter = new EventEmitter
  errored = no

  clean = -> try rm tmpdir

  clean-error = ->
    clean!
    try rm dest if dest isnt process.cwd!

  on-end = ->
    clean!
    options |> emitter.emit 'end', _ unless errored

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-msg = (msg) ->
    msg |> emitter.emit 'message', _ if msg

  on-error = (err) ->
    clean-error!
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  extractor = (options, type) -> (done) ->
    { path, dest } = options
    return new Error 'The given path is not a file' |> on-error unless path |> is-file
    return path |> executable-msg |> on-error if path |> is-executable

    create-link = (name, path) ->
      bin-path = path |> join dest, _
      if bin-path |> is-file
        if root = findup 'package.json', cwd: (bin-path |> dirname)
          bin-dir = root |> dirname |> join _, '../../../', 'bin'
          bin-file = bin-dir |> join _, name
          mk bin-dir unless bin-dir |> is-dir

          if is-win
            bin-path |> win-binary-script |> write "#{bin-file}.cmd", _
          else
            bin-path |> symlink-sync _, bin-file

    process-global-binaries = (pkg) ->
      { bin } = pkg
      if bin |> is-string
        bin |> create-link pkg.name, _
      else if bin |> is-object
        for own name, path of bin when path
        then path |> create-link name, _

    extract-end = ->
      if type is 'global-dependency'
        pkg = (dest |> join _, 'package.json') |> read
        pkg |> process-global-binaries if pkg
      done!

    do ->
      dest |> mk unless dest |> is-dir
      (options |> unpack)
        .on 'error', on-error
        .on 'entry', on-entry
        .on 'end', extract-end

  extractor-fn = ->
    options =
      gzip: no
      path: it.archive |> join tmpdir, _
      dest: it.dest |> join dest, _ |> normalize-path
      checksum: it.checksum
    options |> extractor _, it.type

  copy-bin-fn = (options) -> (done) ->
    origin = options.archive |> join tmpdir, _
    target = options.dest |> join dest, _ |> normalize-path
    mk target unless target |> is-dir
    origin |> copy _, target, done

  create-symlinks = (files) -> (done) ->
    { links } = files
    base = dest |> join _, 'node_modules', '.bin'
    cwd = process.cwd!

    base |> mk
    base |> process.chdir
    for own name, link of links
      when (link |> is-file) and not (name |> is-file)
      then link |> symlink-sync _, name
    cwd |> process.chdir
    done!

  get-extract-files = (nar) ->
    tasks = []
    links = null
    nar.files.for-each ->
      emitter.emit 'archive', it if it.type isnt 'binaries'
      if it.type is 'binary'
        it |> copy-bin-fn |> tasks.push
      else if it.type is 'binaries'
        links := it
      else
        it |> extractor-fn |> tasks.push
    links |> create-symlinks |> tasks.push if links
    tasks

  extract-archives = (done) ->
    nar = '.nar.json' |> join tmpdir, _ |> read
    nar |> emitter.emit 'info', _
    (nar |> get-extract-files) |> fw.series _, done

  copy-nar-json = (done) ->
    origin = '.nar.json' |> join tmpdir, _
    copy origin, dest, (err) ->
      return err |> on-error if err
      done!

  set-execution-perms = ->
    deps-bin-dir = dest |> join _, 'node_modules', '.bin'
    bin-dir = 'bin' |> join dest, _
    [ bin-dir, deps-bin-dir ]
      .filter (|> is-dir)
      .for-each (dir) ->
        (dir |> readdir-sync).for-each ->
          try (it |> join dir, _) |> chmod-sync _, '775'

  extract-nar = do ->
    config = options |> clone
    config <<< dest: tmpdir
    config |> extractor

  extract-tasks = ->
    fw.series [ extract-nar, extract-archives, copy-nar-json ], (err) ->
      return err |> on-error if err
      set-execution-perms!
      on-end!

  do-extract = -> next ->
    mk-dirs dest, tmpdir
    dest |> emitter.emit 'start', _
    extract-tasks!

  try
    do-extract!
  catch
    e |> on-error
  emitter

apply = (options) ->
  {
    gzip: yes
    tmpdir: tmpdir!
    options.dest or process.cwd!
    path: options.path |> add-extension
  }

mk-dirs = (dest, tmpdir) ->
  mk dest unless dest |> is-dir
  mk tmpdir unless tmpdir |> is-dir

normalize-path = (path) ->
  path.replace new RegExp('\\\\', 'g'), '/' if path
