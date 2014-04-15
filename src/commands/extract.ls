require! {
  path
  '../nar'
  program: commander
}
{ echo, exit, exists, is-file, add-extension } = require '../utils'

program
  .command 'extract <archive>'
  .description '\n  Extract archive'
  .usage '[archive] [options]'
  .option '-o, --output <path>', 'Output directory. Default to current directory'
  .option '-d, --debug', 'Enable debugging mode for tasks that support it'
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
  { debug, output } = options

  opts =
    path: archive |> add-extension
    dest: output

  on-start = -> "Extracting files..." |> echo

  on-error = (err, code) ->
    err.message |> echo if err
    err.stack |> echo if debug and err.stack
    ((code or 1) |> exit)!

  on-entry = ->
    "Extract [".green + "#{it.size} KB".cyan + "] #{it.path}".green |> echo

  on-end = ->
    "Extracted sucessfully in: #{it.dest}" |> echo
    exit 0

  extract = ->
    "The given path is not a file" |> exit 1 unless opts.path |> is-file

    archive = nar.extract opts
      .on 'error', on-error
      .on 'end', on-end

    if debug
      archive.on 'start', on-start
      archive.on 'entry', on-entry

  try
    extract!
  catch
    "Cannot extract the archive: #{e.message}" |> on-error
