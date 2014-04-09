require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}
{ once, next }:_ = require './utils'

module.exports = unpack =

  (options = {}) ->
    { path, checksum } = options |> apply
    errored = no
    emitter = new EventEmitter

    on-end = -> next -> emitter.emit 'end' unless errored
    on-entry = (entry) -> next -> entry.props |> emitter.emit 'entry', _ if entry
    on-error = once (err) ->
      errored := yes
      next -> err |> emitter.emit 'error', _

    do-extract = ->
      extractor = options |> extract-archive _
      if checksum
        extractor |> calculate-checksum checksum, path, _
      else
        extractor!

    extract-archive = (options) -> ->
      { dest, gzip } = options
      dest = process.cwd! unless dest
      stream = fs.create-read-stream path
      stream.on 'error', on-error
      if gzip
        stream |> extract-gzip _, dest
      else
        stream |> extract-normal _, dest

    extract-gzip = (stream, dest) ->
      gzstream = stream.pipe create-gunzip!
      gzstream.on 'error', on-error
      gzstream |> extract-normal _, dest

    extract-normal = (stream, dest) ->
      extract = tar.Extract path: dest
      extract.on 'entry', on-entry
      tstream = stream.pipe extract
      tstream.on 'error', on-error
      tstream.on 'end', on-end

    calculate-checksum = (hash, file, cb) ->
      file |> _.checksum _, (err, nhash) ->
        return (err |> on-error) if err
        if hash is nhash
          cb!
        else
          new Error "checksum verification failed: #{nhash}" |> on-error

    do-extract!
    emitter

apply = (options) ->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.path or null
    options.checksum or null
  }
