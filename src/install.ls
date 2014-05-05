require! {
  path.join
  './extract'
  './download'
  events.EventEmitter
}
{ next, is-win, is-array, replace-env-vars, is-file, is-url, clone, extend } = require './utils'

const defaults =
  gzip: yes
  dest: 'node_modules'
  clean: yes

module.exports = install = (options) ->
  { path, dest, clean } = options = options |> apply
  emitter = new EventEmitter

  clean-dir = -> try rm dest if clean

  on-error = (err, code, cmd) ->
    clean-dir!
    err |> emitter.emit 'error', _, code, cmd

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-archive = (archive) ->
    archive |> emitter.emit 'archive', _ if archive

  on-progress = (status) ->
    status |> emitter.emit 'progress', _

  on-download = ->
    'download' |> emitter.emit

  on-end = (output) ->
    clean-dir!
    output |> emitter.emit 'end', _, options

  extractor = (path) ->
    options <<< { path }
    extract options
      .on 'error', on-error
      .on 'entry', on-entry
      .on 'end', on-end

  downloader = ->
    download options
      .on 'download', on-download
      .on 'progress', on-progress
      .on 'error', on-error
      .on 'end', (|> extractor)

  do-install = ->
    if path |> is-url
      downloader!
    else
      path |> extractor

  do-install!
  emitter

apply = (options) ->
  (options |> extend (defaults |> clone) _)
