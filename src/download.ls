require! {
  fs
  path
  request
  events.EventEmitter
  '../package.json'.version
  progress: 'request-progress'
}
{ join, dirname } = path
{ next, is-win, is-array, once, platform, arch, mk, rm, exists, clone, extend, discover-pkg } = require './utils'

module.exports = download = (options) ->
  { url, dest, filename, auth } = options = options |> apply
  emitter = new EventEmitter
  errored = no
  output = dest |> join _, filename

  # to do: support proxy, discover from env variable or file
  create-dest = ->
    mk dest unless dest |> exists

  clean = ->
    try rm output

  on-error = once (err, code) ->
    errored := yes
    err |> emitter.emit 'error', _, code if err

  on-end = once ->
    output |> emitter.emit 'end', _ unless errored

  on-progress = ->
    it |> emitter.emit 'progress', _

  handler = (err, res, data) ->
    if err
      err |> on-error
    else if res.status-code >= 400
      new Error "Invalid status code: #{res.status-code}"
        |> on-error _, res.status-code
    else unless data
      new Error 'Empty response' |> on-error

  do-download = -> next ->
    create-dest!
    stream = output |> fs.create-write-stream
    http = request options, handler
    http.on 'error', on-error

    progress http, { delay: 500 }
      .on 'progress', on-progress
      .pipe stream

    stream.on 'close', on-end
    stream.on 'error', on-error

  do-download!
  emitter

default-dest = ->
  dest = discover-pkg!
  if dest
    dest |> dirname
  else
    '.'

apply = (options) ->
  options = {
    options.url
    options.auth or null
    options.filename or 'archive.nar'
    options.dest or default-dest!
    options.timeout or 10000
    options.strict-SSL or no
    headers: 'User-Agent': "node nar #{version} (#{platform}-#{arch})"
  }
