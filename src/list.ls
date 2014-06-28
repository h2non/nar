require! {
  fs
  tar
  zlib.create-gunzip
  events.EventEmitter
}
{ next, is-file, add-extension, is-executable, executable-msg } = require './utils'

module.exports = list = (options) ->
  { path, gzip } = options |> apply
  emitter = new EventEmitter
  ended = no
  error = no
  files = []

  on-error = (err) ->
    error := err
    err |> emitter.emit 'error', _

  on-end = ->
    ended := yes
    files |> emitter.emit 'end', _

  on-entry = (entry) ->
    entry |> files.push
    entry |> emitter.emit 'entry', _

  on-listener = (name, fn) ->
    switch name
    | 'error' => error |> fn if error
    | 'end' => files |> fn if ended

  parse = -> next ->
    nar = null
    entries = {}

    return new Error 'The given path is not a file' |> on-error unless path |> is-file
    return path |> executable-msg |> on-error if path |> is-executable

    entry-reader = (entry) ->
      data = ''
      if /\.nar\.json$/.test entry.path
        entry.on 'data', -> data += it.to-string!
        entry.on 'end', -> nar := data |> JSON.parse
      else
        entries <<< (entry.path): entry

    emit-entries = ->
      nar |> emitter.emit 'info', _
      nar.files.for-each (file) ->
        {
          file.archive
          file.type
          file.dest
          size: entries[file.archive].size
          props: entries[file.archive].props
        } |> on-entry

    parse = tar.Parse!
    parse.on 'error', on-error
    parse.on 'entry', entry-reader
    parse.on 'end', ->
      return new Error 'Invalid nar file' |> on-error unless nar
      emit-entries!
      on-end!

    stream = path |> fs.create-read-stream
    stream.on 'error', on-error
    stream = stream.pipe create-gunzip! if gzip
    stream.pipe parse

  emitter.on 'newListener', on-listener

  parse!
  emitter

apply = (options) ->
  { gzip: yes, path: options.path |> add-extension }
