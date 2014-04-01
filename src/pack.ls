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
    { name, src, dest, gzip, patterns, ext } = options |> apply
    error = null

    tar = archiver 'tar', zlib-options
    file = "#{name}.#{ext}"
    dest-path = file |> path.join dest, _

    values =
      name: name
      archive: file
      path: dest-path

    stream = fs.create-write-stream dest-path
    stream.on 'close', -> cb error, values

    if gzip
      tar.pipe zlib.create-gzip! .pipe stream
    else
      tar.pipe stream

    tar.on 'error', ->
      error := it
      cb it

    tar.bulk [{ expand: yes, cwd: src, src: patterns, dest: '.' }]
    tar.finalize!

apply = (options = {}) ->
  src: options.src or process.cwd!
  dest: options.dest or tmpdir!
  ext: options.ext or 'tar'
  patterns: options.patterns or [ '**', '.*' ]
  name: options.name or 'unnamed'
  gzip: options.gzip or no
