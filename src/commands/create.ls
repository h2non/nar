require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-dir, is-file } = require '../utils'

program
  .command 'create [path]'
  .description '\n  Create a nar archive'
  .usage '[path] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-f, --force', 'Forces archive creation passing warnings or errors'
  .option '-d, --debug', 'Enable debugging mode for tasks that support it'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar create
        $ nar create some/dir
        $ nar create path/to/package.json -o some-dir
        $ nar create --debug --verbose --no-color
    \t
    '''
  .action -> create ...

create = (pkgpath, options) ->
  { debug, force, verbose, output } = options

  opts = dest: output

  if pkgpath
    unless pkgpath |> exists
      "Error: path do not exists" |> exit 1
    if pkgpath |> is-file
      pkgpath = pkgpath |> path.dirname
    unless pkgpath |> is-dir
      "Error: path must be a directory" |> exit 1
    opts <<< path: pkgpath

  on-error = (err, code) ->
    err.message |> echo if err
    err.stack |> echo if debug and err.stack
    ((code or 1) |> exit)!

  on-start = (nar) ->
    "Creating archive: #{nar.name} #{nar.manifest.version or ''}" |> echo

  on-entry = ->
    "Add [".green + "#{it.size} KB".cyan + "] #{it.name}".green |> echo

  on-end = (output) ->
    "Archive created in: #{output}" |> echo
    exit 0

  try
    archive = nar.create opts
      .on 'start', on-start
      .on 'error', on-error
      .on 'end', on-end

    if debug
      archive.on 'entry', on-entry
  catch
    e |> on-error
