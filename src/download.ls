require! {
  fs
  request
  path.join
  events.EventEmitter
}
{ next, is-win, is-array } = require './utils'

module.exports = download = (options) ->
  { url, dest, filename, auth } = options = options |> apply
  emitter = new EventEmitter

  do-download = -> next ->
    stream = fs.create-write-stream fs.join dest, filename
    request url .pipe stream

    stream.on 'close', ->
    stream.on 'error', ->

  do-download!
  emitter

apply = (options) ->
  {
    options.url
    options.auth
    options.filename or 'archive.nar'
    dest: options.dest or 'node_modules' # to do: resolve package.json directory
  }
