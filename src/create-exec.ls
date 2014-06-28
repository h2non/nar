require! {
  fw
  path
  ncp.ncp
  './pack'
  './create'
  requireg.resolve
  child_process.exec
  events.EventEmitter
}
{ dirname, join, basename } = path
{ rm, mk, is-win, tmpdir, copy, exists, once, handle-exit } = require './utils'

const script = "#{__dirname}/../scripts/run.sh"

module.exports = (options) ->
  throw new Error 'Windows platform cannot create nar executables' if is-win

  name = null
  dest = options.dest or process.cwd!
  emitter = new EventEmitter
  tmp-path = tmpdir!
  mk tmp-path
  options.dest = tmp-path

  clean = ->
    emitter.emit 'message', 'Cleaning temporary directories'
    try rm tmp-path

  on-error = once (err) ->
    clean!
    err |> emitter.emit 'error', _

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  on-end = ->
    clean!
    it |> emitter.emit 'end', _

  on-create-end = (nar-path) ->
    nar-path |> create-executable

  create-executable = (nar) ->
    nar-file = nar |> basename _, '.nar'
    nar-path = (dest |> join _, nar-file) + '.run'
    nar-output = (dest |> join _, nar-file) + '.nar'

    clean-exec = ->
      nar-path |> rm
      clean!

    copy-binary = (done) ->
      bin-dir = tmp-path |> join _, 'bin'
      mk bin-dir
      copy process.execPath, bin-dir, done

    copy-nar-pkg = (done) ->
      nar-path = resolve 'nar'
      return new Error 'nar package is not installed' |> on-error unless nar-path |> exists
      dest = tmp-path |> join _, 'nar'
      nar-path = ((nar-path |> dirname) |> join _, '..')
      ncp nar-path, dest, done

    create-tarball = (done) ->
      const config =
        name: nar |> basename _, '.nar'
        dest: dest
        patterns: [ '**' ]
        src: tmp-path
        ext: 'run'
        gzip: yes

      pack config
        .on 'error', done
        .on 'entry', on-entry
        .on 'end', (file) -> done!

    create-binary = (done) ->
      exec "cat #{script} #{nar-path} > #{nar-output}", done

    fw.parallel [ copy-binary, copy-nar-pkg ], (err) ->
      return new Error 'cannot copy files to temporal directory' |> on-error if err
      fw.series [ create-tarball, create-binary ], (err) ->
        return new Error 'cannot create the executable' |> on-error if err
        clean-exec!
        emitter.emit 'end', nar-output

  clean |> handle-exit
  (options |> create)
    .on 'error', on-error
    .on 'entry', on-entry
    .on 'end', on-create-end

  emitter
