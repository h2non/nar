require! {
  fw
  path
  './unpack'
  fs.symlink-sync
  events.EventEmitter
  findup: 'findup-sync'
}
{ join, dirname, normalize } = path
{ next, copy, is-file, is-dir, tmpdir, rm, mk, read, write, clone, add-extension, is-win, is-string, is-object } = require './utils'

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
    return new Error 'Invalid archive path' |> on-error unless path |> is-file

    create-link = (name, path) ->
      bin-path = path |> join dest, _
      if bin-path |> is-file
        if root = findup 'package.json', cwd: (bin-path |> dirname)
          bin-dir = (root |> dirname) |> join _, '../../../bin'
          bin-file = bin-dir |> join _, name
          mk bin-dir unless bin-dir |> is-dir

          if is-win
            bin-path |> win-bin-script |> write "#{bin-file}.cmd", _
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

    do-extract = ->
      mk dest unless dest |> is-dir
      (options |> unpack)
        .on 'error', on-error
        .on 'entry', on-entry
        .on 'end', extract-end

    try
      do-extract!
    catch
      e |> on-error

  extractor-fn = ->
    options =
      gzip: no
      path: it.archive |> join tmpdir, _
      dest: it.dest |> join dest, _
      checksum: it.checksum

    options |> extractor _, it.type

  copy-bin-fn = (options) -> (done) ->
    origin = options.archive |> join tmpdir, _
    target = options.dest |> join dest, _
    mk target unless target |> is-dir
    copy origin, target, done

  get-extract-files = (nar) ->
    tasks = []
    nar.files.for-each ->
      if it.type is 'binary'
        it |> copy-bin-fn |> tasks.push
      else
        it |> extractor-fn |> tasks.push
    tasks

  extract-archives = (done) ->
    nar = '.nar.json' |> join tmpdir, _ |> read
    nar |> emitter.emit 'info', _
    fw.series (nar |> get-extract-files), done

  copy-nar-json = (done) ->
    origin = '.nar.json' |> join tmpdir, _
    copy origin, dest, (err) ->
      return err |> on-error if err
      done!

  extract-nar = do ->
    config = options |> clone
    config <<< dest: tmpdir
    config |> extractor

  extract-tasks = ->
    fw.series [ extract-nar, extract-archives, copy-nar-json ], (err) ->
      return err |> on-error if err
      on-end!

  do-extract = -> next ->
    mk-dirs dest, tmpdir
    dest |> emitter.emit 'start', _

    try
      extract-tasks!
    catch
      e |> on-error

  do-extract!
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

win-bin-script = (path) ->
  path = path |> normalize
  """
  @ECHO OFF
  @IF EXIST "%~dp0\\node.exe" (
    "%~dp0\\node.exe" "#{path}" %*
  ) ELSE (
    node "#{path}" %*
  )
  """
