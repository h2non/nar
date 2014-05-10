require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-file, to-kb } = require '../utils'

program
  .command 'get <url>'
  .description '\n  Download remote archive'
  .usage '[url] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '--user <user>', 'HTTP autenticantion user'
  .option '--password <password>', 'HTTP user password'
  .option '--proxy <url>', 'URL proxy to use'
  .option '--timeout <number>', 'HTTP request timeout'
  .option '--strict-ssl', 'Enable strict SSL'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar get
        $ nar get app.nar
        $ nar get app.nar -o some/dir
        $ nar get app.nar --debug
        $ nar get http://server.net/app-0.1.0.nar
    \t
    '''
  .action -> get ...

get = (archive, options) ->
  { debug, verbose, output, user, password, proxy } = options

  opts =
    path: archive |> add-extension
    dest: output

  on-start = -> "Reading archive..." |> echo

  on-error = (err, code) ->
    "Error: #{err.message or err}".red |> echo if err
    err.stack |> echo if debug and err.stack
    ((code or 1) |> exit)!

  on-entry = ->
    "Extract [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or ''}".green |> echo

  on-archive = ->
    "Extracting [#{it.type.cyan}] #{it.name or ''}" |> echo unless debug and verbose

  on-end = ->
    "Extracted in: #{it.dest}" |> echo
    exit 0

  extract = ->
    installer = nar.install opts
      .on 'start', on-start
      .on 'archive', on-archive
      .on 'error', on-error
      .on 'end', on-end

    installer.on 'entry', on-entry if debug or verbose

  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error
