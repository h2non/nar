require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-dir, is-file } = require '../utils'

program
  .command 'extract [archive]'
  .description '\n  Extract archive files'
  .usage '[archive] [options]'
  .option '-o, --output', 'Output directory'
  .option '-f, --force', 'Forces archive creation passing warnings or errors'
  .option '-d, --debug', 'Enable debugging mode for tasks that support it'
  .option '-v, --verbose', 'Verbose mode. A lot of information will be showed'
  .option '-x, --no-gzip', 'Process archive without gzip compression'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar extract
        $ nar extract app.nar
        $ nar extract app.nar -o some-dir
        $ nar extract app.nar --debug --verbose
    \t
    '''
  .action -> create ...

create = (archive, options) ->
  { debug, force, verbose, output } = options

  opts = dest: output

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
    archive = nar.extract opts, ->
      "Extracted in: #{archive.output}" |> echo
      exit 0
  catch
    "Error: cannot extract the archive: #{e.message} \n" |> echo
    e.stack |> echo if debug
    exit 1
