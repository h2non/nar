require! {
  path
  '../nar'
  program: commander
}
{ echo, on-entry, on-error, on-archive } = require './common'

program
  .command 'extract <archive>'
  .description '\n  Extract archive'
  .usage '<archive> [options]'
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

  on-end = -> "Extracted in: #{it.dest}" |> echo

  extract = ->
    archive = nar.extract opts
      .on 'start', on-start
      .on 'error', (debug |> on-error)
      .on 'end', on-end

    if debug or verbose
      archive.on 'entry', ('Extract' |> on-entry)
    else
      archive.on 'archive', (debug |> on-archive _, verbose)
  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error debug
