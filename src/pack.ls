require! {
  fs
  path
  archiver
  os: { tmpdir }
  zlib: { create-gzip }
  events: { EventEmitter }
  './utils': { checksum, exists, next, is-dir }
}

# See: http://zlib.net/manual.html#Constants
const zlib-options = level: 1

# From: https://github.com/github/gitignore/tree/master/Global
const ignored-files = [
  '!.DS_Store'
  '!Thumbs.db'
  '!ehthumbs.db'
  '!Desktop.ini'
  '!$RECYCLE.BIN/'
  '!.AppleDouble'
  '!.LSOverride'
  '!.Trashes'
  '!.apdisk'
  '!.AppleDB'
  '!.nar'
]

module.exports = pack = (options = {}) ->
  { name, src, dest, patterns, ext } = options = options |> apply
  emitter = new EventEmitter
  errored = no

  on-end = (data) ->
    data |> emitter.emit 'end', _ unless errored

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-error = (err) ->
    err |> emitter.emit 'error', _ unless errored
    errored := yes

  create-stream = (file, cb) ->
    fs.create-write-stream file
      .on 'error', on-error
      .on 'close', cb

  create-tar = (stream, options) ->
    { src, gzip, patterns } = options
    tar = archiver 'tar', zlib-options
    tar.on 'entry', on-entry
    tar.on 'error', on-error

    include = [pattern for pattern in patterns when pattern and pattern[0] is not '!']
    ignore = [pattern.slice(1) for pattern in patterns when pattern and pattern[0] is '!']

    for pattern in include
      tar.glob pattern, { expand: yes, cwd: src, ignore: ignore }, { name: '.' }

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

  do-pack = -> next ->
    return new Error 'source path do not exists' |> on-error unless src |> exists
    return new Error 'destination path is not a directory' |> on-error unless dest |> is-dir

    file = "#{name |> normalize-name}.#{ext}"
    file-path = file |> path.join dest, _
    data = { name, file, path: file-path }

    cb = file-path |> calculate-checksum _, data
    (file-path
    |> create-stream _, cb)
    |> create-tar _, options

  do-pack!
  emitter

normalize-name = (name) ->
  name := name.replace '/', '-' if ~name.indexOf('@')
  name

apply = (options) ->
  {
    options.src or process.cwd!
    options.ext or 'tar'
    options.name or 'unnamed'
    options.dest or (options.name |> tmpdir)
    options.gzip or no
    patterns: (options.patterns or [ '**', '.*' ]) ++ ignored-files
  }
