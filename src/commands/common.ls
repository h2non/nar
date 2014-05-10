require! { progress }
{ echo, log-error, exit, to-kb, is-url, extend, archive-name } = require '../utils'

module.exports = _ =

  echo: echo
  exit: exit
  is-url: is-url
  extend: extend
  archive-name: archive-name

  create-bar: ->
    new progress '[:bar] :percent :etas', { total: 1, width: 30 }

  update-bar: (bar) -> (value) ->
    bar.curr = value
    bar.render!

  on-download: ->
    'Downloading archive...' |> echo

  on-start: ->
    "Reading archive..." |> echo

  on-progress: (bar) -> (state) ->
    if bar.total is 1
      bar <<< { state.total }
      bar <<< start: new Date!
    else
      state.received |> _.update-bar bar

  on-entry: ->
    "Extract [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or ''}".green |> echo

  on-error: (debug) -> (err, code) ->
    err |> log-error _, debug |> echo
    ((code or 1) |> exit)!

  on-extract: ->
    "Extracting [#{it.type.cyan}] #{it.name or ''}" |> echo

  on-download-end: (bar) -> ->
    bar.total |> (bar |> _.update-bar) |> echo
