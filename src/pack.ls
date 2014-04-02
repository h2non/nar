require! {
  fs
  path
  archiver
  'os-shim'.tmpdir
  zlib.create-gzip
}
{ checksum, once, exists } = require './helper'

# See: http://zlib.net/manual.html#Constants
const zlib-options =
  level: 1

module.exports = pack =

  (options = {}, cb) ->
    { name, src, dest, patterns, ext } = options = options |> apply

    file = "#{name}.#{ext}"
    file-path = file |> path.join dest, _

    return new Error 'source path do not exists' |> cb unless src |> exists
    return new Error 'destination path do not exists' |> cb unless dest |> exists

    data =
      name: name
      archive: file
      path: file-path

    cb = (cb |> calculate-checksum file-path, data, _) |> once

    (file-path
      |> create-stream _, cb)
      |> create-tar _, options, cb

create-stream = (file, cb) ->
  fs.create-write-stream file
    .on 'error', cb
    .on 'close', cb

create-tar = (stream, options, cb) ->
  { src, gzip, patterns } = options

  tar = archiver 'tar', zlib-options
  tar.on 'error', cb
  tar.bulk [{ expand: yes, cwd: src, src: patterns, dest: '.' }]

  if gzip
    (create-gzip! |> tar.pipe).pipe stream
  else
    stream |> tar.pipe

  tar.finalize!

calculate-checksum = (file, data, cb) -> ->
  return cb it if it
  file |> checksum _, (err, hash) ->
    data <<< checksum: hash
    data |> cb err, _

apply = (options) ->
  {
    options.src or process.cwd!
    options.dest or tmpdir!
    options.ext or 'tar'
    options.patterns or [ '**', '.*' ]
    options.name or 'unnamed'
    options.gzip or no
  }
