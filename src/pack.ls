require! {
  fs
  path
  archiver
  'os-shim'.tmpdir
  zlib.create-gzip
  events.EventEmitter
}
{ checksum, once, exists, next, is-dir } = require './utils'

# See: http://zlib.net/manual.html#Constants
const zlib-options = level: 1

module.exports = pack =

  (options = {}) ->
    { name, src, dest, patterns, ext } = options = options |> apply
    emitter = new EventEmitter
    errored = no

    on-end = (data) -> data |> emitter.emit 'end', _ unless errored
    on-entry = (entry) -> entry.props |> emitter.emit 'entry', _ if entry
    on-error = once (err) ->
      errored := yes
      err |> emitter.emit 'error', _

    do-pack = -> next ->
      return new Error 'source path do not exists' |> on-error unless src |> exists
      return new Error 'destination path is not a directory' |> on-error unless dest |> is-dir

      file = "#{name}.#{ext}"
      file-path = file |> path.join dest, _
      data = { name, file, path: file-path }

      cb = file-path |> calculate-checksum _, data
      (file-path
        |> create-stream _, cb)
        |> create-tar _, options, cb

    create-stream = (file, cb) ->
      fs.create-write-stream file
        .on 'error', on-error
        .on 'close', cb

    create-tar = (stream, options) ->
      { src, gzip, patterns } = options
      tar = archiver 'tar', zlib-options
      tar.on 'entry', on-entry
      tar.on 'error', on-error
      tar.bulk [{ expand: yes, cwd: src, src: patterns, dest: '.' }]

      if gzip
        stream |> (create-gzip! |> tar.pipe).pipe
      else
        stream |> tar.pipe

      tar.finalize!

    calculate-checksum = (file, data) -> ->
      file |> checksum _, (err, hash) ->
        return (err |> on-error) if err
        data <<< checksum: hash
        data |> on-end

    do-pack!
    emitter

apply = (options) ->
  {
    options.src or process.cwd!
    options.dest or tmpdir!
    options.ext or 'tar'
    options.patterns or [ '**', '.*' ]
    options.name or 'unnamed'
    options.gzip or no
  }
