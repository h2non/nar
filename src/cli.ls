require! {
  path
  colors
  './nar'
  program: commander
}
{ echo } = require './utils'

const cmd-map =
  e: 'extract'
  c: 'create'
  x: 'run'
  l: 'list'
  i: 'install'
  g: 'get'
  start: 'run'
  build: 'create'
  download: 'get'
  show: 'list'

module.exports <<< parse: -> (it |> map |> program.parse)

program
  .version nar.VERSION

program.command 'help' .action (-> echo! |> help)
  .description '\n  Output usage information'

program.on '--help', help = ->
  echo '''
    Usage examples:

      $ nar create
      $ nar run app.nar
      $ nar extract app.nar -o some/dir
      $ nar list app.nar
      $ nar install app.nar --save
      $ nar get http://server.net/app.nar

    Command specific help:

      $ nar <command> --help
  \t
  '''

<[ create extract run list install get]>for-each -> "./commands/#{it}" |> require

map = (args) ->
  cmd = args[2]
  for own alias, value of cmd-map when alias is cmd then args[2] = value
  args
