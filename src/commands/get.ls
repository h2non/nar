require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, is-file, to-kb, log-error } = require '../utils'

program
  .command 'get <url>'
  .description '\n  Download archive from HTTP server'
  .usage '[url] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '--user <user>', 'HTTP autenticantion user'
  .option '--password <password>', 'HTTP user password'
  .option '--proxy <url>', 'Proxy server URL to use'
  .option '--timeout <number>', 'HTTP request timeout'
  .option '--strict-ssl', 'Enable strict SSL'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar get http://server.net/app.nar
        $ nar get http://server.net/app.nar --user john --password pa$s
        $ nar get http://server.net/app.nar --proxy http://proxy:3128
        $ nar get http://server.net/app.nar --strict-ssl --timeout 60000
    \t
    '''
  .action -> get ...

get = (archive, options) ->
  { debug, verbose, output, strict-ssl } = options

  opts = {
    path: archive
    dest: output
    strict-SSL: strict-ssl
    options.timeout, options.user,
    options.password, options.proxy
  }

  on-start = -> "Reading archive..." |> echo

  on-error = (err, code) ->
    err |> log-error _, debug |> echo
    ((code or 1) |> exit)!

  on-entry = ->
    "Extract [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or ''}".green |> echo

  on-archive = ->
    "Extracting [#{it.type.cyan}] #{it.name or ''}" |> echo unless debug and verbose

  on-end = ->
    "Extracted in: #{it.dest}" |> echo
    exit 0

  extract = ->
    installer = nar.get opts
      .on 'start', on-start
      .on 'archive', on-archive
      .on 'error', on-error
      .on 'end', on-end
    installer.on 'entry', on-entry if debug or verbose

  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error
