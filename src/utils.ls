require! {
  fs
  hu
  path
  crypto
  os: 'os-shim'
  rm: rimraf.sync
  mk: mkdirp.sync
}
{ normalize, join, basename, delimiter } = path
{ env, platform, exit, next-tick } = process

module.exports = _ = {

  path, platform, hu.extend, hu.vals, hu.has,
  os.EOL, hu.clone, hu.is-object, hu.is-array,
  hu.is-string, mk, rm, delimiter

  echo: -> console.log ...

  next: next-tick

  env: -> env[it] or null

  now: -> new Date!get-time!

  is-win: platform is 'win32'

  to-kb: -> if it then Math.round it / 1024 else 0

  exists: -> it and (it |> normalize |> fs.exists-sync)

  stringify: ->
    it |> JSON.stringify _, null, 2 if it

  keys: ->
    if it |> hu.is-object then it |> Object.keys else []

  tmpdir: (name = 'pkg') ->
    "nar-#{name}-#{_.random!}" |> join os.tmpdir!, _

  add-extension: ->
    it += '.nar' unless /.nar$/.test it if it
    it

  is-dir: ->
    (it |> _.exists) and (it |> normalize |> fs.lstat-sync).is-directory!

  is-file: ->
    (it |> _.exists) and (it |> normalize |> fs.lstat-sync).is-file!

  random: ->
    _.now! + (Math.floor Math.random! * 10000)

  lines: ->
    it.split os.EOL if it

  exit: (code) ->
    code |> exit if code is 0 or not code
    (message) ->
      if message?
        message = message.red if String::red?
        message |> _.echo
      code |> exit

  read: ->
    if it |> _.exists
      data = (it |> normalize |> fs.read-file-sync).to-string!
      if it |> /.json$/.test
        data |> JSON.parse
      else
        data
    else
      null

  write: (path, data) ->
    data |> fs.write-file-sync path, _ if path

  once: (cb) ->
    error = no
    ->
      cb ... unless error
      error := yes if it

  archive-name: (nar) ->
    name = ''
    if nar
      name += nar.name or 'unnamed'
      name += "-#{version}" if version = nar.manifest.version
      name += "-#{process.platform}-#{platform.arch}" if nar.binary
    "#{name}.nar"

  checksum: (file, cb) ->
    hash = crypto.create-hash 'sha1'
    (file |> fs.create-read-stream)
      .on 'data', (|> hash.update)
      .on 'end', -> hash.digest 'hex' |> cb null, _
      .on 'error', cb

  copy: (file, dest, cb) ->
    filename = file |> basename
    dest = filename |> join dest, _
    (file |> fs.create-read-stream)
      .pipe fs.create-write-stream dest
      .on 'close', -> dest |> cb null, _
      .on 'error', cb
}
