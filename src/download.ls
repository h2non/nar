require! {
  fs
  path
  request
  url.parse
  events.EventEmitter
  '../package.json'.version
  progress: 'request-progress'
}
{ join, dirname } = path
{ next, env, is-win, is-array, once, platform, arch, mk, rm, exists, clone, extend, discover-pkg, http-status } = require './utils'

const headers =
  'User-Agent': "node nar #{version} (#{platform}-#{arch})"

module.exports = download = (options) ->
  { url, dest, filename, auth } = options = options |> apply
  emitter = new EventEmitter
  output = dest |> join _, filename
  errored = no

  create-dest = ->
    mk dest unless dest |> exists

  clean = -> try rm output

  on-error = once (err, code) ->
    errored := yes
    clean!
    err |> emitter.emit 'error', _, code if err

  on-download = ->
    'download' |> emitter.emit

  on-end = once ->
    output |> emitter.emit 'end', _ unless errored

  on-progress = ->
    it |> emitter.emit 'progress', _

  handler = (err, res, data) ->
    if err
      err |> on-error
    else if res.status-code >= 400
      new Error "Invalid response code: #{http-status res.status-code}"
        |> on-error _, res.status-code
    else unless data
      new Error 'Empty response' |> on-error

  do-download = -> next ->
    on-download!
    create-dest!

    stream = output |> fs.create-write-stream
    stream.on 'error', on-error

    http = request options, handler
    http.on 'error', on-error

    progress http
      .on 'progress', on-progress
      .pipe stream
      .on 'close', on-end

  try
    do-download!
  catch
    e |> on-error
  emitter

apply = (options) ->
  {
    options.url
    auth: options.auth |> discover-auth
    options.filename or (options.url |> get-filename)
    options.dest or process.cwd!
    options.timeout or 10000
    options.strict-SSL or no
    options.proxy or get-proxy!
    headers: options.headers |> extend (headers |> clone), _
  }

get-filename = (url) ->
  if url
    file = parse url .pathname.split '/' .slice -1 .pop!
    file = 'archive.nar' unless file
  else
    file = 'archive.nar'
  file

get-proxy = ->
  'http_proxy' |> env

discover-auth = (auth) ->
  { user, password } = auth if auth
  user = 'HTTP_USER' |> env unless user
  password = 'HTTP_PASSWORD' |> env unless password
  { user, password } if user and password
