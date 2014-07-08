require! {
  '../nar'
  program: commander
}
{ echo, create-bar, on-entry, on-archive, on-download, on-error, on-progress, update-bar, on-download-end, archive-name } = require './common'

program
  .command 'run <archive>'
  .description '\n  Run archive files'
  .usage '<archive> [options]'
  .option '-o, --output <path>', 'Output directory'
  .option '-d, --debug', 'Enable debud mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose  mode. Will output stdout and stderr'
  .option '-as, --args-start <args>', 'Aditional arguments to pass to start command'
  .option '-ap, --args-prestart <args>', 'Aditional arguments to pass to prestart command'
  .option '-as, --args-stop <args>', 'Aditional arguments to pass to stop command'
  .option '-ax, --args-poststop <args>', 'Aditional arguments to pass to poststop command'
  .option '-u, --user <user>', 'HTTP autenticantion user'
  .option '-p, --password <password>', 'HTTP user password'
  .option '--proxy <url>', 'Proxy server URL to use'
  .option '--timeout <number>', 'HTTP request timeout'
  .option '--strict-ssl', 'Enable strict SSL'
  .option '--no-clean', 'Disable app directory clean after exit'
  .option '--no-hooks', 'Disable command hooks'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar run app.nar
        $ nar run app.nar -o some/dir
        $ nar run app.nar --args-start '--node ${PATH}'
        $ nar run app.nar --debug --no-hooks
        $ nar run http://my.server.net/my-app-0.1.0.nar
    \t
    '''
  .action -> run ...

run = (archive, options) ->
  { debug, verbose, output, strict-ssl, args-start, args-prestart, args-stop, args-poststop } = options
  bar = create-bar!

  opts = {
    path: archive
    dest: output
    strictSSL: strict-ssl
    options.clean, options.hooks
    options.proxy, options.timeout
    args:
      start: args-start
      prestart: args-prestart
      stop: args-stop
      poststop: args-poststop
  }
  opts <<< auth: { options.user, options.password } if options.user

  on-extract = -> "Extracting files..." |> echo

  on-start = -> "Running application..." |> echo

  on-end = -> "Finished" |> echo

  on-command = (cmd, hook) ->
    "Run [".green + hook.cyan + "]: #{cmd}".green |> echo

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
      .on 'download', on-download
      .on 'downloadEnd', (bar |> on-download-end)
      .on 'progress', (bar |> on-progress)
      .on 'extract', on-extract
      .on 'info', on-info
      .on 'start', on-start
      .on 'error', (debug |> on-error)
      .on 'end', on-end
      .on 'command', on-command
      .on 'stderr', on-stderr
      .on 'exit', on-exit
      .on 'stdout', on-stdout
    if debug or verbose
      archive.on 'entry', ('Extract' |> on-entry) if verbose
    else
      archive.on 'archive', (debug |> on-archive _, verbose)

  try
    run!
  catch
    e |> on-error debug

format-eol = ->
  it.replace /\n(\s+)?$/, '' .replace /\n/g, '\n> ' if it
