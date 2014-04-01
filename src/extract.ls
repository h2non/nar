require! {
  fs
  tar
  zlib
}

module.exports = extract =

  (options, cb) ->
    { archive, dest, gzip } = options |> apply

    stream = fs.create-read-stream archive
    stream.on 'error', cb

    if gzip
      stream |> extract-gzip _, dest, cb
    else
      stream |> extract-normal _, dest, cb

extract-gzip = (stream, dest, cb) ->
  gzstream = stream.pipe zlib.create-gunzip!
  gzstream.on 'error', cb
  gzstream |> extract-normal _, dest, cb

extract-normal = (stream, dest, cb) ->
  tstream = stream.pipe tar.Extract path: dest
  tstream.on 'error', cb
  tstream.on 'end', cb

apply = (options = {})->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.archive or null
  }
