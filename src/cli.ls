require! {
  path
  colors
  './nar'
  program: commander
}
{ echo } = require './utils'

module.exports <<< parse: -> it |> program.parse

program
  .version nar.VERSION

program.command 'help' .action (-> help |> echo)
  .description '\n  Output the usage information'

program.on '--help', help = ->
  echo '''
    Usage examples:

      $ nar create
      $ nar run app.nar
      $ nar extract app.nar -o some/dir
      $ nar list app.nar

    Command specific help:

      $ nar <command> --help
  \t
  '''

<[ create extract run list ]>for-each -> "./commands/#{it}" |> require
