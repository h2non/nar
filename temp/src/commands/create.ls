require! {
  '../nar'
  program: commander
}
{ echo, exit, on-entry, on-error, create-bar, on-progress, update-bar, on-download-end } = require './common'
{ exists, is-dir, is-file, is-string } = require '../utils'

const options = [
  'dependencies'
  'devDependencies'
  'peerDependencies'
  'globalDependencies'
  'patterns'
  'binary'
  'binaryPath'
  'os'
  'arch'
  'node'
  'proxy'
]

program
  .command 'create [path]'
  .description '\n  Create a nar archive'
  .usage '<path> [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-f, --file <name>', 'Define the archive file name'
  .option '-r, --dependencies', 'Include dependencies'
  .option '-x, --dev-dependencies', 'Include development dependencies'
  .option '-p, --peer-dependencies', 'Include peer dependencies'
  .option '-g, --global-dependencies <names>', 'Include global dependencies, comma separated'
  .option '-n, --omit-dependencies', 'Create archive without embed any type of dependencies'
  .option '-i, --patterns <patterns>', 'Glob patterns to use for files include/exclude, comma separated'
  .option '-b, --binary', 'Include node binary'
  .option '-e, --executable', 'Create nar as self executable binary'
  .option '-l, --binary-path <path>', 'Custom node binary to embed into the archive'
  .option '-s, --os <name>', 'Node.js OS binary platform to embed. Default to current OS'
  .option '-a, --arch <name>', 'Node.js OS binary architecture to embed. Default to ' + process.arch
  .option '-q, --node <name>', 'Node.js version to embed. Default to ' + process.version
  .option '--proxy <url>', 'Proxy server URL to use to download binaries'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar create
        $ nar create some/dir --debug
        $ nar create path/to/package.json -o some/dir
        $ nar create --verbose --binary
        $ nar create --global-dependencies 'npm,grunt' --patterns '!.tmp,src/**'
    \t
    '''
  .action -> create ...

create = (pkgpath, options) ->
  { debug, verbose, output, file, executable } = options
  bar = create-bar!

  opts = { dest: output, file }
  options |> apply _, opts
  opts.binary = yes if opts.binary-path

  if options.omit-dependencies
    opts <<< dependencies: no
    opts <<< dev-dependencies: no
    opts <<< peer-dependencies: no

  if pkgpath
    unless pkgpath |> exists
      'Error: path do not exists' |> exit 1
    if pkgpath |> is-file
      pkgpath = pkgpath |> path.dirname
    unless pkgpath |> is-dir
      'Error: path must be a directory' |> exit 1
    opts <<< path: pkgpath

  on-start = ->
    'Creating archive...' |> echo

  on-download = ->
    'Downloading node binary...' |> echo

  on-archive = ->
    "Add [#{it.type.cyan}] #{it.name or ''}" |> echo unless debug and verbose

  on-generate = ->
    'Generating executable...' |> echo

  on-end = (output) ->
    "Created in: #{output}" |> echo

  create = ->
    archive = nar[executable |> get-mode] opts
      .on 'start', on-start
      .on 'error', (debug |> on-error)
      .on 'download', on-download
      .on 'downloadEnd', (bar |> on-download-end)
      .on 'progress', (bar |> on-progress)
      .on 'generate', on-generate
      .on 'end', on-end

    if debug or verbose
      archive.on 'entry', ('Add' |> on-entry)
    else
      archive.on 'archive', on-archive

  try
    create!
  catch
    e |> on-error debug

normalize = (type, value) ->
  if type is 'globalDependencies' or type is 'patterns'
    value.split ',' .map (.trim!)
  else
    value

apply = (args, opts) ->
  options
    .filter -> args[it] is yes or (args[it] |> is-string)
    .for-each -> opts <<< (it): args[it] |> normalize it, _

get-mode = (exec) ->
  if exec
    'createExec'
  else
    'create'
