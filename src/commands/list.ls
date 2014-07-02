require! {
  path
  '../nar'
  Table: 'cli-table'
  program: commander
}
{ join, basename } = path
{ echo, on-error, to-kb, archive-name } = require './common'

program
  .command 'list <archive>'
  .description '\n  List archive files'
  .usage '<archive> [options]'
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

  on-info = ->
    "Package: #{it |> archive-name}" |> echo

  on-entry = ->
    if table
      it |> map-entry |> table-list.push
    else
      (it.archive |> join it.dest, _) + " (#{(it.size |> to-kb)} KB)".cyan |> echo

  on-end = ->
    table-list.to-string! |> echo if table

  list = ->
    nar.list opts
      .on 'error', (debug |> on-error)
      .on 'info', on-info
      .on 'entry', on-entry
      .on 'end', on-end

  try
    list!
  catch
    e |> on-error debug

map-entry = ->
  [ (it.archive |> basename _, '.tar'), it.dest, (it.size |> to-kb) + ' KB', it.type ] if it
