require! {
  async
  './extract'
  path.join
  child_process.spawn
  events.EventEmitter
}
{ next, tmpdir, read, has, rm, delimiter, is-win } = require './utils'

const hooks-keys = [ 'prestart' 'start' 'stop' 'poststop' ]

module.exports = run = (options) ->
  { path, hooks, args, dest, clean } = options = options |> apply
  emitter = new EventEmitter

  clean-dir = -> try rm dest if clean

  on-error = (err, code, cmd) ->
    clean-dir!
    err |> emitter.emit 'error', _, code, cmd

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  hooks-fn = (options, nar) ->
    buf = []
    for own hook, cmd of (nar |> get-hooks)
      when hooks or (not hooks and hook is 'start')
      then
        if args and (hook |> has args, _) and args[hook]
          cmd += " " + if args[hook] |> Array.is-array then args[hook].join ' ' else args[hook]
        cmd |> exec emitter, _, options.dest, hook |> buf.push
    buf

  app-runner = (options) ->
    { dest } = options

    nar = dest |> read-nar-json
    nar |> emitter.emit 'info', _

    if nar.binary
      dest |> extend-path
      unless nar |> is-binary-valid
        return new Error 'Unsupported binary platform or processor' |> on-error

    dest |> set-environment
    async.series (nar |> hooks-fn options, _), (err) ->
      return err |> on-error if err
      clean-dir!
      options |> emitter.emit 'end', _, nar

  do-extract = -> next ->
    'extract' |> emitter.emit
    (options |> extract)
      .on 'error', on-error
      .on 'entry', on-entry
      .on 'end', app-runner

  do-extract!
  emitter

apply = (options) ->
  {
    gzip: yes
    options.path
    dest: options.dest or tmpdir!
    clean: if options.clean? then options.clean else yes
    hooks: if options.hooks? then options.hooks else yes
    args: options.args or {}
  }

read-nar-json = (dest) ->
  '.nar.json' |> join dest, _ |> read

get-hooks = (nar) ->
  scripts = nar.manifest.scripts
  hooks = {}
  hooks-keys.for-each -> hooks <<< (it): scripts[it] if it |> has scripts, _
  hooks

is-binary-valid = (nar) ->
  { platform, arch } = nar.info
  platform is process.platform and arch is process.arch

exec = (emitter, command, cwd, hook) -> (done) ->
  { cmd, args } = command |> get-command-script |> parse-command
  (cmd-str = "#{cmd} #{args.join ' '}") |> emitter.emit 'command', _, hook
  cmd-str |> emitter.emit if hook is 'start'

  child = spawn cmd, args, { cwd, process.env }
  child.stdout.on 'data', -> it.to-string! |> emitter.emit 'stdout', _
  child.stderr.on 'data', -> it.to-string! |> emitter.emit 'stderr', _
  child.on 'error', (|> done)
  child.on 'exit', (code) ->
    if code isnt 0
      new Error "Command failed with exit code: #{code}" |> done _, code, cmd-str
    else
      code |> emitter.emit 'exit', _, hook
      done!

get-command-script = (cmd) ->
  if cmd is 'node' or /^node /.test cmd
    script = join __dirname, '../scripts', if is-win then 'node.bat' else 'node.sh'
    script = "/usr/bin/env bash #{script}" unless is-win
    cmd = "#{script} " + cmd.replace /^node/, ''
  cmd

parse-command = (cmd) ->
  [ cmd, ...args ] = (cmd |> replace-env-vars |> clean-spaces).split ' '
  { cmd, args }

replace-env-vars = (str) ->
  str.replace /\$\{(\w+)\}/ig, (_, name) -> process.env[name] or ''

clean-spaces = -> it.replace /\s+/g, ' '

set-environment = (dest) ->
  process.env.NODE_PATH = ('.node' |> join dest, _)
  process.env.NODE_NAR = '1'

extend-path = (dest) ->
  process.env.PATH = ('.node/bin' |> join dest, _) + "#{delimiter}#{process.env.PATH}"
