require! { progress }
{ echo, log-error, exit, to-kb, is-url, extend, archive-name, to-kb } = require '../utils'

module.exports = _ = {

  echo, exit, to-kb
  is-url, extend
  archive-name

  create-bar: ->
    new progress '[:bar] :percent :etas', { total: 1, width: 30 }

  update-bar: (bar) -> (value) ->
    bar.curr = value
    try bar.render!

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

  on-entry: (action) -> ->
    "#{action} [".green + "#{it.size |> to-kb} KB".cyan + "] #{it.path or it.name or ''}".green |> echo

  on-archive: (debug, verbose) -> ->
    "Extract [#{it.type.cyan}] #{it.name or ''}" |> echo unless debug and verbose

  on-error: (debug) -> (err, code) ->
    err |> log-error _, debug |> echo
    ((code or 1) |> exit)!

  on-extract: ->
    "Extract [#{it.type.cyan}] #{it.name or ''}" |> echo

  on-download-end: (bar) -> ->
    bar.total |> (bar |> _.update-bar) |> echo

}
