require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}
{ next } = require './utils'

module.exports = list =

  (options) ->
    { file, gzip } = options
    emitter = new EventEmitter
    ended = no
    error = no
    files = []

    on-error = (err) ->
      error := err
      next -> err |> emitter.emit 'error', _

    on-end = ->
      ended := yes
      next -> files |> emitter.emit 'end', _

    on-entry = (entry) -> next ->
      if entry
        entry := { entry.type, entry.path, entry.size, entry.props }
        entry |> files.push
        entry |> emitter.emit 'entry', _

    on-listener = (name, fn) ->
      switch name
        case 'error' then fn error if error
        case 'end' then fn files if ended

    parse = ->
      parse = tar.Parse!
      parse.on 'error', on-error
      parse.on 'entry', on-entry
      parse.on 'end', on-end

      stream = file |> fs.create-read-stream
      stream.on 'error', on-error
      stream = stream.pipe create-gunzip! if gzip
      stream.pipe parse

    emitter.on 'newListener', on-listener

    process.next-tick parse
    emitter
