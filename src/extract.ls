require! {
  fs
  tar
  zlib.create-gunzip
}
{ checksum, once } = require './utils'

module.exports = extract =

  (options = {}, cb) ->
    { path, checksum } = options |> apply
    cb = (cb |> once)

    return (new Error 'path option is required' |> cb) unless path

    extractor = options |> extract-archive _, cb
    if checksum
      extractor |> calculate-checksum checksum, path, _
    else
      extractor!

extract-archive = (options, cb) -> ->
  { path, dest, gzip } = options
  return cb it if it

  stream = fs.create-read-stream path
  stream.on 'error', cb
  if gzip
    stream |> extract-gzip _, dest, cb
  else
    stream |> extract-normal _, dest, cb

extract-gzip = (stream, dest, cb) ->
  gzstream = stream.pipe create-gunzip!
  gzstream.on 'error', cb
  gzstream |> extract-normal _, dest, cb

extract-normal = (stream, dest, cb) ->
  tstream = stream.pipe tar.Extract path: dest
  tstream.on 'error', cb
  tstream.on 'end', cb

calculate-checksum = (hash, file, cb) ->
  file |> checksum _, (err, nhash) ->
    return cb err if err
    if hash is nhash
      cb!
    else
      new Error "checksum verification failed: #{nhash}" |> cb

apply = (options) ->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.path or null
    options.checksum or null
  }
