require! {
  path
  '../nar'
  Table: 'cli-table'
  program: commander
}
{ echo, exit, exists, is-file, to-kb, archive-name } = require '../utils'

program
  .command 'list <archive>'
  .description '\n  List archive files'
  .usage '[archive] [options]'
  .option '-d, --debug', 'Enable debud mode. More information will be shown'
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
  { debug, table } = options
  table-list = new Table head: [ 'Name', 'Destination', 'Size', 'Type' ]

  opts = path: archive

  on-error = ->
    "Error: #{it.message or it}".red |> echo if it
    it.stack |> echo if debug and it.stack
    exit 1

  on-info = ->
    "Package: #{it |> archive-name}" |> echo

  on-entry = ->
    if table
      it |> map-entry |> table-list.push
    else
      (it.archive |> path.join it.dest, _) + " (#{(it.size |> to-kb)} KB)".cyan |> echo

  on-end = ->
    table-list.to-string! |> echo if table
    exit 0

  list = ->
    nar.list opts
      .on 'error', on-error
      .on 'info', on-info
      .on 'entry', on-entry
      .on 'end', on-end

  try
    list!
  catch
    e |> on-error

map-entry = ->
  [ (it.archive |> path.basename _, '.tar'), it.dest, (it.size |> to-kb) + ' KB', it.type ] if it
