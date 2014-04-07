require! {
  path
  '../list'
  program: commander
}
{ echo, exit, exists, is-dir, is-file } = require '../utils'

program
  .command 'list [archive]'
  .description '\n  List archive files'
  .usage '[archive] [options]'
  .option '-d, --debug', 'Enable debugging mode for tasks that support it'
  .option '--no-color', 'Disable colored output'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar list
        $ nar list app.nar
    \t
    '''
  .action -> list ...

list = (archive, options) ->
  { debug, force, verbose, output } = options

  opts =
    dest: output

  if archive
    unless archive |> exists
      "Error: the given path do not exists" |> exit 1
    if archive |> is-file
      archive = archive |> path.dirname
    else
      unless archive |> is-dir
        "Error: path must be a directory" |> exit 1
    opts <<< base: archive

  try
    "Extracting files..." |> echo
    archive = nar.run opts, ->
      "Extracted in: #{archive.output}" |> echo
      exit 0
  catch
    "Error: cannot extract the archive: #{e.message} \n" |> echo
    e.stack |> echo if debug
    exit 1
