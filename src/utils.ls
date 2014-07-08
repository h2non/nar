require! {
  fs
  os
  hu
  path
  crypto
  './status'
  buffer.Buffer
  rm: rimraf.sync
  mk: mkdirp.sync
  findup: 'findup-sync'
}
{ normalize, join, dirname, basename, delimiter, extname } = path
{ env, platform, exit, next-tick, arch } = process

module.exports = _ = {

  path, platform, arch, hu.extend, hu.vals,
  os.EOL, hu.clone, hu.is-object, hu.is-array,
  hu.is-string, mk, rm, delimiter, hu.has

  echo: ->
    if it then console.log ... else console.log ''

  next: next-tick

  env: -> env[it] or null

  now: -> new Date!get-time!

  is-win: platform is 'win32'

  to-kb: -> if it then ((Math.round it / 1024) or 1) else 0

  exists: -> it and (it |> normalize |> fs.exists-sync)

  stringify: ->
    it |> JSON.stringify _, null, 2 if it

  keys: ->
    if it |> hu.is-object then it |> Object.keys else []

  tmpdir: (name = 'pkg') ->
    name = name |> basename _, (name |> extname)
    "nar-#{name}-#{_.random!}" |> join os.tmpdir!, _

  add-extension: ->
    if it and not (it |> _.is-url)
      it += '.nar' unless /.nar$/.test it
    it

  is-dir: ->
    (it |> _.exists) and (it |> normalize |> fs.lstat-sync).is-directory!

  is-link: ->
    (it |> normalize |> fs.lstat-sync).is-symbolic-link!

  is-file: ->
    (it |> _.exists) and ((it |> normalize |> fs.lstat-sync).is-file! or (it |> _.is-link))

  random: ->
    _.now! + (Math.floor Math.random! * 10000)

  lines: ->
    it.split os.EOL if it

  is-url: ->
    it |> /^http[s]?\:/.test

  http-status: (code) ->
    if code
      "#{code} #{status[code] or ''}"
    else
      ''

  replace-env-vars: (str) ->
    /\$\{(\w+)\}/ig |> str.replace _, (_, name) -> process.env[name] or ''

  log-error: (err, debug) ->
    if err
      if debug and err.stack
        err.stack
      else
        "Error: #{err.message or err}".red

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

  discover-pkg: (dir = process.cwd!) ->
    'package.json' |> findup _, cwd: dir

  handle-exit: (cb) ->
    listener = ->
      process.stdin.resume!
      cb!
      listener |> process.remove-listener 'SIGINT', _
    process.on 'SIGINT', listener

  is-executable: (path) ->
    buffer = new Buffer 25
    num = (fs.openSync path, 'r') |> fs.readSync _, buffer, 0, 25, 0
    data = buffer.toString 'utf-8', 0, num
    /^\#\!\/bin\/bash/.test(data) and /\#\#nar\#\#/.test(data)

  executable-msg: (file) ->
    file = file or 'sample.nar' |> basename
    if _.is-win
      """
      the nar file is an executable, you cannot run it in Windows
      """
    else
      """
      the nar file is an executable, you must run it as binary:

        Example:
        $ chmod +x #{file}
        $ ./#{file} exec --port 8080 --verbose

      You could use the exec, start, extract, install or list commands
      For more usage information, see the docs at github.com/h2non/nar
      """

  archive-name: (nar) ->
    name = ''
    if nar
      name += nar.name or 'unnamed'
      name += "-#{version}" if version = nar.manifest.version
      name += "-#{platform}-#{arch}" if nar.binary
    "#{name}.nar"

  checksum: (file, cb) ->
    hash = crypto.create-hash 'sha1'
    (file |> fs.create-read-stream)
      .on 'data', (|> hash.update)
      .on 'end', -> hash.digest 'hex' |> cb null, _
      .on 'error', cb

  rename: (orig, filename, cb) ->
    base = orig |> dirname
    orig |> fs.rename _, (filename |> join base, _), cb

  copy: (file, dest, cb) ->
    filename = file |> basename
    dest = filename |> join dest, _
    (file |> fs.create-read-stream)
      .pipe fs.create-write-stream dest
      .on 'close', -> dest |> cb null, _
      .on 'error', cb

  copy-binary: (file, dest, cb) ->
    file |> _.copy _, dest, (err, output) ->
      return err |> cb if err
      if (name = file |> basename) isnt 'node'
        (output = (output |> dirname) |> join _, name) |> _.rename _, 'node', (err) ->
          return err |> cb if err
          output |> cb null, _
      else
        output |> cb null, _

  win-binary-script: (path) ->
    path = path |> normalize
    """
    @ECHO OFF
    @IF EXIST "%~dp0\\node.exe" (
      "%~dp0\\node.exe" "#{path}" %*
    ) ELSE (
      node "#{path}" %*
    )
    """
}
