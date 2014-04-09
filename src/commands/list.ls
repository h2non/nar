require! {
  path
  '../nar'
  Table: 'cli-table'
  program: commander
}
{ echo, exit, exists, is-file } = require '../utils'

program
  .command 'list [archive]'
  .description '\n  List archive files'
  .usage '[archive] [options]'
  .option '-d, --debug', 'Enable debugging mode'
  .option '-x, --no-gzip', 'Process archive without gzip compression'
  .option '--no-color', 'Disable colored output'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar list app.nar
        $ nar list app.nar --verbose
    \t
    '''
  .action -> list ...

list = (archive, options) ->
  { debug, verbose, gzip } = options
  table = new Table head: [ 'Filename', 'Path', 'Size', 'Type' ]

  opts =
    file: archive
    gzip: gzip

  error = ->
    "Error while reading the archive: #{it.message}" |> echo
    it.stack |> echo if debug
    exit 1

  unless archive |> exists
    "Error: the given path do not exists" |> exit 1
  unless archive |> is-file
    "Error: archive path must be a file" |> exit 1

  try
    nar.list opts
      .on 'error', error
      .on 'entry', -> it |> map-entry |> table.push
      .on 'end', ->
        table.to-string! |> echo
        exit 0
  catch
    e |> error

map-entry = ->
  [ (it.path |> path.basename), it.path, it.size + ' KB', it.type ] if it
