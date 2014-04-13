require! {
  async
  './unpack'
  path.join
  events.EventEmitter
}
{ next, copy, is-file, is-dir, tmpdir, rm, mk, read, clone } = require './utils'

module.exports = extract = (options = {}) ->
  { path, dest, tmpdir } = options = options |> apply
  errored = no
  emitter = new EventEmitter

  clean = ->
    try rm tmpdir

  on-end = ->
    clean!
    options |> emitter.emit 'end', _ unless errored

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-msg = (msg) ->
    msg |> emitter.emit 'message', _ if msg

  on-error = (err) ->
    clean!
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  extractor = (options) -> (done) ->
    { path, dest } = options
    return new Error 'Path do not exists or is invalid' |> on-error unless path |> is-file

    mk dest unless dest |> is-dir
    try
      (options |> unpack)
        .on 'error', on-error
        .on 'entry', on-entry
        .on 'end', done
    catch
      e |> on-error

  extract-nar = do ->
    config = options |> clone
    config <<< dest: tmpdir
    config |> extractor

  extractor-fn = ->
    options =
      gzip: no
      path: it.archive |> join tmpdir, _
      dest: it.dest |> join dest, _
      checksum: it.checksum
    options |> extractor

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
    "Extracting #{nar.name} #{nar.manifest.version}" |> on-msg
    async.series (nar |> get-extract-files), done

  copy-nar-json = (done) ->
    origin = '.nar.json' |> join tmpdir, _
    copy origin, dest, (err) ->
      return err |> on-error if err
      done!

  do-extract = -> next ->
    mk-dirs dest, tmpdir
    try
      async.series [ extract-nar, extract-archives, copy-nar-json ], (err) ->
        return err |> on-error if err
        on-end!
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

add-extension = ->
  it += '.nar' unless /.nar$/.test it if it
  it

mk-dirs = (dest, tmpdir) ->
  mk dest unless dest |> is-dir
  mk tmpdir unless tmpdir |> is-dir
