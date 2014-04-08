require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}

module.exports = list =

  (options) ->
    { file, gzip } = options
    emitter = new EventEmitter
    ended = no
    error = no
    files = []

    on-error = ->
      error := it
      emitter.emit 'error', it

    on-end = ->
      ended := yes
      emitter.emit 'end', files

    on-entry = ->
      if it
        it.props |> files.push
        emitter.emit 'entry', it.props

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
