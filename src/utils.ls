require! {
  fs
  hu
  path
  crypto
  os: 'os-shim'
  rm: rimraf.sync
  mk: mkdirp.sync
}
{ env, platform, exit } = process

module.exports = _ = {

  path, platform, hu.extend, hu.vals,
  hu.clone, hu.is-object, mk, rm, os.EOL

  echo: -> console.log ...

  env: -> env[it] or null

  now: -> new Date!get-time!

  exists: -> it and (it |> fs.exists-sync)

  stringify: ->
    it |> JSON.stringify _, null, 2 if it

  tmpdir: (name = 'pkg') ->
    "nar-#{name}-#{_.random!}" |> path.join os.tmpdir!, _

  is-dir: ->
    (it |> _.exists) and (it |> fs.lstat-sync).is-directory!

  is-file: ->
    (it |> _.exists) and (it |> fs.lstat-sync).is-file!

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
      data = (it |> fs.read-file-sync).to-string!
      if it |> /.json$/.test
        data |> JSON.parse
      else
        data
    else
      null

  once: (cb) ->
    error = no
    ->
      cb ... unless error
      error := yes if it

  checksum: (file, cb) ->
    hash = crypto.create-hash 'sha1'
    (file |> fs.create-read-stream)
      .on('data', -> it |> hash.update)
      .on('end', -> hash.digest 'hex' |> cb null, _)
      .on('error', -> it |> cb)

  copy: (file, dest, cb) ->
    filename = file |> path.basename
    dest = filename |> path.join dest, _
    (fs.create-read-stream file)
      .pipe(fs.create-write-stream dest)
      .on('error', -> throw it)
      .on('close', -> cb dest)

}
