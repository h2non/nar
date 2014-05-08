require! {
  path
  '../nar'
  progress
  program: commander
}
{ echo, exit, is-file, to-kb, log-error } = require '../utils'

program
  .command 'get <url>'
  .description '\n  Download archive from HTTP server'
  .usage '[url] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-f, --filename <name>', 'Downloaded filename. Default taken from URL path name'
  .option '--user <user>', 'HTTP autenticantion user'
  .option '--password <password>', 'HTTP user password'
  .option '--proxy <url>', 'Proxy server URL to use'
  .option '--timeout <number>', 'HTTP request timeout'
  .option '--strict-ssl', 'Enable strict SSL'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
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

get = (url, options) ->
  { debug, output, strict-ssl } = options
  bar = null

  opts = {
    url,
    dest: output
    strict-SSL: strict-ssl
    options.filename,
    options.timeout, options.proxy
  }

  if options.user
    "password option is required" |> on-error unless options.password
    opts.auth = { options.user, options.password }

  update-bar = (value) ->
    bar.curr = value
    bar.render!

  on-error = (err, code) ->
    err |> log-error _, debug |> echo
    ((code or 1) |> exit)!

  on-entry = ->
    "Extract [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or ''}".green |> echo

  on-download = ->
    "Downloading archive..." |> echo

  on-progress = (state) ->
    unless bar
      bar := new progress '[:bar] :percent :etas', { state.total, width: 30 }
      bar.start = new Date!
    else
      state.received |> update-bar

  on-end = ->
    bar.total |> update-bar if bar
    "\nDownloaded in: #{it}" |> echo

  extract = ->
    nar.get opts
      .on 'download', on-download
      .on 'progress', on-progress
      .on 'error', on-error
      .on 'end', on-end

  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error
