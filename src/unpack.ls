require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}
{ next }:_ = require './utils'

module.exports = unpack = (options = {}) ->
  { path, checksum } = options |> apply
  errored = no
  emitter = new EventEmitter

  on-end = ->
    emitter.emit 'end' unless errored

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-error = (err) ->
    # fix EOF issue, PR pending: https://github.com/isaacs/node-tar/pull/32
    if err and not /unexpected eof/.test err.message
      err |> emitter.emit 'error', _ unless errored
      errored := yes

  do-extract = -> next ->
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
    stream.pipe extract
      .on 'error', on-error
      .on 'end', on-end

  calculate-checksum = (hash, file, cb) ->
    file |> _.checksum _, (err, nhash) ->
      return (err |> on-error) if err
      if hash is nhash
        cb!
      else
        new Error "Checksum verification failed: #{nhash}" |> on-error

  do-extract!
  emitter

apply = (options) ->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.path or null
    options.checksum or null
  }
