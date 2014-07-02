require! {
  '../nar'
  progress
  program: commander
}
{ echo, exit, is-url, create-bar, on-download, on-error, on-progress, update-bar } = require './common'

program
  .command 'get <url>'
  .description '\n  Download archive from HTTP server'
  .usage '<url> [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-f, --filename <name>', 'Downloaded filename. Default taken from URL path name'
  .option '-u, --user <user>', 'HTTP autenticantion user'
  .option '-p, --password <password>', 'HTTP user password'
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
  bar = create-bar!

  opts = {
    url,
    dest: output
    strict-SSL: strict-ssl
    options.filename,
    options.timeout,
    options.proxy
  }
  opts.auth = { options.user, options.password } if options.user

  echo "Invalid URL. Cannot download the archive" |> exit 1 unless url |> is-url

  on-end = ->
    bar.total |> (bar |> update-bar)
    "\nDownloaded in: #{it}" |> echo

  download = ->
    nar.get opts
      .on 'download', on-download
      .on 'progress', (bar |> on-progress)
      .on 'error', (debug |> on-error)
      .on 'end', on-end

  try
    download!
  catch
    "Cannot download the archive: #{e.message}" |> on-error debug
