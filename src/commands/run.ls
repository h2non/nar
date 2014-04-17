require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, archive-name } = require '../utils'

program
  .command 'run <archive>'
  .description '\n  Run archive files'
  .usage '[archive] [options]'
  .option '-o, --output <path>', 'Output directory'
  .option '-d, --debug', 'Enable debud mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose  mode. Will output stdout and stderr'
  .option '-as, --args-start <args>', 'Aditional arguments to pass to start command'
  .option '-ap, --args-prestart <args>', 'Aditional arguments to pass to prestart command'
  .option '-as, --args-stop <args>', 'Aditional arguments to pass to stop command'
  .option '-ax, --args-poststop <args>', 'Aditional arguments to pass to poststop command'
  .option '--no-clean', 'Disable app directory clean after exit'
  .option '--no-hooks', 'Disable command hooks'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar run app.nar
        $ nar run app.nar -o some/dir
        $ nar run app.nar --args-start '--node ${PATH}'
        $ nar run app.nar --debug --no-hooks
    \t
    '''
  .action -> run ...

run = (archive, options) ->
  { debug, verbose, output, clean, hooks, args-start, args-prestart, args-stop, args-poststop } = options

  opts =
    path: archive
    dest: output
    clean: clean
    hooks: hooks
    args:
      start: args-start
      prestart: args-prestart
      stop: args-stop
      poststop: args-poststop

  on-extract = -> "Extracting files..." |> echo

  on-start = -> "Starting app..." |> echo

  on-end = -> "Finished" |> echo

  on-error = (err, code) ->
    err.message |> echo if err
    err.stack |> echo if debug and err.stack
    ((code or 1) |> exit)!

  on-command = (cmd, hook) ->
    "Run [".green + hook.cyan + "]: #{cmd}".green |> echo

  on-entry = ->
    "Extract [".green + "#{it.size} KB".cyan + "] #{it.path}".green |> echo

  on-info = ->
    "Running #{it |> archive-name}" |> echo

  on-stdout = (out) ->
    "> #{out |> format-eol}".green |> echo

  on-stderr = (out) ->
    "> #{out |> format-eol}".red |> echo

  on-exit = (code, hook) ->
    "End [".green + hook.cyan + "]: exited with code #{code}".green |> echo

  run = ->
    archive = nar.run opts
      .on 'extract', on-extract
      .on 'info', on-info
      .on 'start', on-start
      .on 'error', on-error
      .on 'end', on-end

    if debug or verbose
      archive.on 'command', on-command
      archive.on 'exit', on-exit
      archive.on 'stdout', on-stdout
      archive.on 'stderr', on-stderr
    if verbose
      archive.on 'entry', on-entry

  try
    run!
  catch
    e |> on-error

format-eol = ->
  it.replace /\n(\s+)?$/, '' .replace /\n/g, '\n> ' if it
