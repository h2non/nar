require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-dir, is-file, is-string, to-kb, archive-name } = require '../utils'

program
  .command 'create [path]'
  .description '\n  Create a nar archive'
  .usage '[path] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-f, --file <name>', 'Define the archive file name'
  .option '-r, --dependencies', 'Include dependencies'
  .option '-x, --dev-dependencies', 'Include development dependencies'
  .option '-p, --peer-dependencies', 'Include peer dependencies'
  .option '-g, --global-dependencies <names>', 'Include global dependencies, comma separated'
  .option '-i, --patterns <patterns>', 'Glob patterns to use for files include/exclude, comma separated'
  .option '-b, --binary', 'Include node binary'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar create
        $ nar create some/dir --debug
        $ nar create path/to/package.json -o some/dir
        $ nar create --verbose
        $ nar create --global-dependencies 'npm,grunt' --patterns '!.tmp,src/**'
    \t
    '''
  .action -> create ...

create = (pkgpath, options) ->
  { debug, verbose, output, file } = options

  opts = { dest: output, file }
  options |> apply _, opts

  if pkgpath
    unless pkgpath |> exists
      "Error: path do not exists" |> exit 1
    if pkgpath |> is-file
      pkgpath = pkgpath |> path.dirname
    unless pkgpath |> is-dir
      "Error: path must be a directory" |> exit 1
    opts <<< path: pkgpath

  on-error = (err, code) ->
    "Error: #{err.message or err}".red |> echo if err
    err.stack |> echo if debug and err.stack
    ((code or 1) |> exit)!

  on-start = ->
    "Creating archive: #{it |> archive-name}" |> echo

  on-entry = ->
    "Add [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.name}".green |> echo

  on-end = (output) ->
    "Created in: #{output}" |> echo
    exit 0

  create = ->
    archive = nar.create opts
      .on 'start', on-start
      .on 'error', on-error
      .on 'end', on-end
    archive.on 'entry', on-entry if debug or verbose

  try
    create!
  catch
    e |> on-error

normalize = (type, value) ->
  if type is 'globalDependencies' or type is 'patterns'
    value.split ',' .map (.trim!)
  else
    value

apply = (args, opts) ->
  <[dependencies devDependencies peerDependencies globalDependencies patterns binary]>
    .filter -> args[it] is yes or (args[it] |> is-string)
    .for-each -> opts <<< (it): args[it] |> normalize it, _
  opts
