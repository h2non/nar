require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}
{ once }:_ = require './utils'

module.exports = extract =

  (options = {}) ->
    { path, checksum } = options |> apply
    errored = no
    emitter = new EventEmitter

    on-end = -> emitter.emit 'end' unless errored
    on-entry = -> emitter.emit 'entry', it.props if it
    on-error = once ->
      errored := yes
      emitter.emit 'error', it

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

    return (new Error 'Path option is required' |> on-error) unless path

    do-extract!
    emitter

apply = (options) ->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.path or null
    options.checksum or null
  }
