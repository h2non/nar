require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-dir, is-file } = require '../utils'

program
  .command 'create [path]'
  .description '\n  Create new aplication archive'
  .usage '[path] [options]'
  .option '-o, --output', 'Output directory'
  .option '-f, --force', 'Forces archive creation passing warnings or errors'
  .option '-d, --debug', 'Enable debugging mode for tasks that support it'
  .option '-v, --verbose', 'Verbose mode. A lot of information will be showed'
  .option '--no-color', 'Disable colored output'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar create
        $ nar create some/path
        $ nar create path/to/package.json -o some-dir
        $ nar create --debug --verbose --no-color
    \t
    '''
  .action -> create ...

create = (pkgpath, options) ->
  { debug, force, verbose, output } = options

  opts =
    dest: output

  if pkgpath
    unless pkgpath |> exists
      "Error: the given path do not exists" |> exit 1
    if pkgpath |> is-file
      pkgpath = pkgpath |> path.dirname
    else
      unless pkgpath |> is-dir
        "Error: path must be a directory" |> exit 1
    opts <<< base: pkgpath

  try
    "Creating archive..." |> echo
    archive = nar.create opts, ->
      "Archive created in: #{archive.output}" |> echo
      exit 0
  catch
    "Error: cannot create the archive: #{e.message} \n" |> echo
    e.stack |> echo if debug
    exit 1
