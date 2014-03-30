require! {
  colors
  './nar'
  './common'.echo
  program: commander
}

module.exports <<< parse: -> it |> program.parse

program
  .version nar.version

program.command 'help' .action help
  ..description '\n  Output the usage information'

program.command 'version' .action (-> version |> echo)
  ..description '\n  Output the version information'

program.on '--help', help = ->
  echo '''
    Usage examples:

      $ nar create
      $ nar update [file]
      $ nar run
      $ nar extract [directory]

    Command specific help:

      $ nar <command> --help
  .
  '''
