require! {
  path.join
  './extract'
  events.EventEmitter
}
{ next, is-win, is-array, replace-env-vars } = require './utils'

module.exports = install = (options) ->
  { path, hooks, args, dest, clean } = options = options |> apply
  emitter = new EventEmitter

  clean-dir = -> try rm dest if clean

  on-error = (err, code, cmd) ->
    clean-dir!
    err |> emitter.emit 'error', _, code,  cmd

  on-entry = (entry) ->
    entry |> emitter.emit 'entry', _ if entry

  on-archive = (archive) ->
    archive |> emitter.emit 'archive', _ if archive

  on-end = (options, nar) ->
    clean-dir!
    options |> emitter.emit 'end', _, nar

  do-install = ->

  do-install!
  emitter

apply = (options) ->
  {
    gzip: yes
    options.path
    dest: options.dest or 'node_modules'
    clean: if options.clean? then options.clean else yes
    hooks: if options.hooks? then options.hooks else yes
    args: options.args or {}
  }
