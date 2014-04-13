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
  .option '--no-table', 'Disable table format output'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar list app.nar
        $ nar list app.nar --no-table
    \t
    '''
  .action -> list ...

list = (archive, options) ->
  { debug, gzip, table } = options
  table-list = new Table head: [ 'Filename', 'Path', 'Size', 'Type' ]

  opts =
    file: archive
    gzip: gzip

  on-error = ->
    new Error "Error while reading the archive: #{it.message}".red |> echo
    it.stack |> echo if debug
    exit 1

  on-entry = ->
    if table
      it |> map-entry |> table-list.push
    else
      it.path |> path.basename |> echo

  on-end = ->
    table-list.to-string! |> echo if table
    exit 0

  unless archive |> exists
    "Error: the given path do not exists" |> exit 1
  unless archive |> is-file
    "Error: archive path must be a file" |> exit 1

  try
    nar.list opts
      .on 'error', on-error
      .on 'entry', on-entry
      .on 'end', on-end
  catch
    e |> on-error

map-entry = ->
  [ (it.path |> path.basename _, '.tar'), it.path, it.size + ' KB', it.type ] if it
