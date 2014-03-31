require! {
  fs
  tar
  zlib
}

module.exports = extract =

  (options, cb) ->
    { archive, dest, gzip } = options
    dest ||= process.cwd!
    stream = fs.create-read-stream archive
    stream.on 'error', -> on-err cb, it

    if gzip
      extract-gzip stream, dest, cb
    else
      extract-normal stream, dest, cb

extract-gzip = (stream, dest, cb) ->
  gzstream = stream.pipe zlib.create-gunzip!
  gzstream.on 'error', -> on-err cb, it
  gzstream |> extract-normal _, dest, cb

extract-normal = (stream, dest, cb) ->
  tstream = stream.pipe tar.Extract path: dest
  tstream.on 'error', -> on-err cb, it
  tstream.on 'end', -> cb!

on-err = (cb, err) ->
  cb err
  throw err
