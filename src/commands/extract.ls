require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, to-kb, log-error } = require '../utils'

program
  .command 'extract <archive>'
  .description '\n  Extract archive'
  .usage '[archive] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-d, --debug', 'Enable debug mode. More information will be shown'
  .option '-v, --verbose', 'Enable verbose mode. A lot of information will be shown'
  .on '--help', ->
    echo '''
      Usage examples:

        $ nar extract
        $ nar extract app.nar
        $ nar extract app.nar -o some/dir
        $ nar extract app.nar --debug
    \t
    '''
  .action -> extract ...

extract = (archive, options) ->
  { debug, verbose, output } = options

  opts =
    path: archive
    dest: output

  on-start = -> "Reading archive..." |> echo

  on-error = (err, code) ->
    err |> log-error _, debug |> echo
    ((code or 1) |> exit)!

  on-entry = ->
    "Extract [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or ''}".green |> echo

  on-archive = ->
    "Extracting [#{it.type.cyan}] #{it.name or ''}" |> echo unless debug and verbose

  on-end = ->
    "Extracted in: #{it.dest}" |> echo
    exit 0

  extract = ->
    archive = nar.extract opts
      .on 'start', on-start
      .on 'archive', on-archive
      .on 'error', on-error
      .on 'end', on-end
    archive.on 'entry', on-entry if debug or verbose

  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error
