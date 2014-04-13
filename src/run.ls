require! {
  async
  './extract'
  path.join
  child_process.spawn
  events.EventEmitter
}
{ next, copy, tmpdir, read, has, delimiter } = require './utils'

const hooks-keys = [ 'prestart' 'start' 'stop' 'poststop' ]

module.exports = run = (options) ->
  { path, hooks, args } = options
  emitter = new EventEmitter

  on-error = (err) ->
    err |> emitter.emit 'error', _

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-msg = (msg) ->
    msg |> emitter.emit 'message', _ if msg

  on-end = ->
    emitter.emit 'end'

  run-app = (options) ->
    nar = '.nar.json' |> join options.dest, _ |> read
    hooks = nar |> get-hooks

    process.env.NODE_NAR = '1'
    if nar.binary
      return new Error 'Unsupported binary platform or processor architecture'
        |> on-error unless nar |> check-platform
      process.env.PATH = ('.node/bin' |> join options.dest, _) + "#{delimiter}#{process.env.PATH}"

    hooks-fn = []
    for own hook, cmd of hooks then
      cmd += " #{args[hook]}" if args and (hook |> has args, _)
      exec emitter, cmd, options.dest |> hooks-fn.push

    if hooks-fn.length
      async.series hooks-fn, (err) ->
        return err |> on-error if err
        on-end!

  do-extract = -> next ->
    'Extracting archive...' |> on-msg
    (options |> extract)
      .on 'error', on-error
      .on 'entry', on-entry
      .on 'end', run-app

  do-extract!
  emitter

get-hooks = (nar) ->
  scripts = nar.manifest.scripts
  hooks = {}
  hooks-keys.for-each ->
    hooks <<< (it): scripts[it] if it |> has scripts, _
  hooks

check-platform = (nar) ->
  { platform, arch } = nar.info
  platform is process.platform and arch is process.arch

exec = (emitter, command, cwd) -> (done) ->
  { cmd, args } = command |> parse-command
  cmd = spawn cmd, args, { cwd: cwd, env: process.env }
  "Running command: #{command}" |> emitter.emit 'message', _

  cmd.stdout.on 'data', -> it.to-string! |> emitter.emit 'stdout', _
  cmd.stderr.on 'data', -> it.to-string! |> emitter.emit 'stderr', _
  cmd.on 'error', (|> done)
  cmd.on 'exit', (code) ->
    if code isnt 0
      new Error "Hook command failed with exit code: #{code}" |> done
    else
      done!

parse-command = (cmd) ->
  [ cmd, ...args ] = (cmd |> replace-env-vars |> clean-spaces).split ' '
  { cmd, args }

replace-env-vars = (str) ->
  str.replace /\$\{(\w+)\}/ig, (_, name) -> process.env[name] or ''

clean-spaces = -> it.replace /\s+/g, ' '
