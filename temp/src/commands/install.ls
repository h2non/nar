require! {
  '../nar'
  program: commander
}
{ echo, extend, create-bar, on-extract, on-download, on-start, on-error, on-progress, on-entry, update-bar, on-download-end } = require './common'

program
  .command 'install <archive>'
  .description '\n  Install archive'
  .usage '<archive> [options]'
  .option '-o, --output <path>', 'Install directory. Default to node_modules'
  .option '-f, --filename <name>', 'Downloaded filename. Default taken from URL path name'
  .option '-u, --user <user>', 'HTTP autenticantion user'
  .option '-p, --password <password>', 'HTTP user password'
  .option '--proxy <url>', 'Proxy server URL to use'
  .option '--timeout <number>', 'HTTP request timeout'
  .option '--strict-ssl', 'Enable strict SSL'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .option '-s, --save', 'Save as runtime dependency in package.json'
  .option '-sd, --save-dev', 'Save as development dependency in package.json'
  .option '-sp, --save-peer', 'Save as peer dependency in package.json'
  .option '-g, --global', 'Install as global dependency'
  .option '--clean', 'Remove downloaded file after install'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar install app.nar --save
        $ nar install app.nar -o some/dir
        $ nar install app.nar --debug
        $ nar install http://server.net/app-0.1.0.nar
    \t
    '''
  .action -> install ...

install = (archive, options) ->
  { debug, verbose, output, strict-ssl } = options
  bar = create-bar!

  opts = options |> extend _, {
    path: archive
    dest: output
    strict-SSL: strict-ssl
  }
  opts.auth = { options.user, options.password } if options.user

  on-start = -> "Installing archive..." |> echo

  on-end = -> "Installed in: #{it.dest}" |> echo

  extract = ->
    installer = nar.install opts
      .on 'start', on-start
      .on 'progress', (bar |> on-progress)
      .on 'download', on-download
      .on 'error', (debug |> on-error)
      .on 'downloadEnd', (bar |> on-download-end)
      .on 'end', on-end
    installer.on 'entry', ('Extract' |> on-entry) if debug or verbose

  try
    extract!
  catch
    "Cannot install the archive: #{e.message}" |> on-error debug
