require! {
  './unpack'
  events.EventEmitter
}
{ once, next , is-file } = require './utils'

module.exports = extract = (options = {}) ->
  { path } = options |> apply
  errored = no
  emitter = new EventEmitter

  on-end = -> emitter.emit 'end' unless errored
  on-entry = (entry) -> entry.props |> emitter.emit 'entry', _ if entry
  on-error = once (err) ->
    errored := yes
    err |> emitter.emit 'error', _

  do-extract = -> next ->
    return (new Error 'Path do not exists or is invalid' |> on-error) unless path |> is-file
    extractor = options |> extract-archive _
    if checksum
      extractor |> calculate-checksum checksum, path, _
    else
      extractor!

  do-extract!
  emitter

apply = (options) ->
  {
    options.dest or process.cwd!
    options.gzip or no
    options.path or null
    options.checksum or null
  }
