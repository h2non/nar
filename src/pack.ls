require! {
  hu
  fs
  path
  zlib
  archiver
  'os-shim'.tmpdir
}

# See: http://zlib.net/manual.html#Constants
const zlib-options =
  level: 1

module.exports = pack =

  (options, cb) ->
    { name, src, dest, gzip, patterns, ext } = options
    src ||= process.cwd!
    dest ||= tmpdir!
    ext ||= 'tar'
    patterns ||= [ '**' ]

    tar = archiver 'tar', zlib-options
    file = name |> get-name _, ext
    dest-path = path.join dest, file

    stream = fs.create-write-stream dest-path
    stream.on 'close', ->
      cb null,
        name: name
        archive: file
        path: dest-path

    if gzip
      tar.pipe zlib.create-gzip! .pipe stream
    else
      tar.pipe stream

    tar.on 'error', -> on-err cb, it
    tar.bulk [{ expand: true, cwd: src, src: patterns, dest: '.' }]
    tar.finalize!

get-name = (name, ext) ->
  "#{name}." + ext

on-err = (cb, err) ->
  cb err
  throw err
