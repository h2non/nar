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

program.command 'version' .action (-> version |> echo)
  .description '\n  Output the version information'

program.on '--help', help = ->
  echo '''
    Usage examples:

      $ nar create [path]
      $ nar run [archive]
      $ nar extract [archive] -o [directory]

    Command specific help:

      $ nar <command> --help
  \t
  '''

<[ create extract ]>for-each -> "./commands/#{it}" |> require
