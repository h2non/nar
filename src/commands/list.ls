require! {
  path
  '../nar'
  Table: 'cli-table'
  program: commander
}
{ echo, exit, exists, is-file, add-extension } = require '../utils'

program
  .command 'list <archive>'
  .description '\n  List archive files'
  .usage '[archive] [options]'
  .option '-d, --debug', 'Enable debugging mode'
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
  table-list = new Table head: [ 'File', 'Destination', 'Size', 'Type' ]

  opts = path: archive |> add-extension

  on-error = ->
    it.message.red |> echo if it.message
    it.stack |> echo if debug
    exit 1

  on-info = ->
    "Package: #{it.name} #{it.manifest.version or ''}" |> echo

  on-entry = ->
    if table
      it |> map-entry |> table-list.push
    else
      (it.archive |> path.join it.dest, _) + " (#{it.size} KB)".cyan |> echo

  on-end = ->
    table-list.to-string! |> echo if table
    exit 0

  unless opts.path |> is-file
    "The given path is not a file" |> exit 1

  try
    nar.list opts
      .on 'error', on-error
      .on 'info', on-info
      .on 'entry', on-entry
      .on 'end', on-end
  catch
    e |> on-error

map-entry = ->
  [ (it.archive |> path.basename _, '.tar'), it.dest, it.size + ' KB', it.type ] if it
