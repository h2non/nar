require! {
  fs
  path
  http
  chai
  rimraf
  mkdirp
  stubby
  request
  'node-static'
  '../../lib/nar'
  child_process.spawn
  '../../package.json'.version
}

node = process.execPath
nar-bin = path.join __dirname, '/../../', 'bin/nar'
cwd = process.cwd!

module.exports =

  fs: fs
  stat-sync: fs.stat-sync
  nar: nar
  cwd: cwd
  node: node
  version: version
  request: request
  expect: chai.expect
  rm: rimraf.sync
  mk: mkdirp.sync
  chdir: process.chdir
  env: process.env
  join: path.join
  spawn: spawn

  createWriteStream: fs.createWriteStream

  read: ->
    data = (it |> fs.read-file-sync).to-string!
    if it |> /.json$/.test
      data |> JSON.parse
    else
      data

  exists: ->
    fs.exists-sync it

  spy: (fn) ->
    call = ->
      unless call.called
        fn ...
        call.called = yes
    call.called = no
    call

  once: (fn) ->
    call = no
    ->
      unless call
        call := yes
        fn ...

  uncaught: ->
    process.remove-listener 'uncaughtException', (process.listeners 'uncaughtException')[0]
    process.add-listener 'uncaughtException', ->

  exec: (type, args, callback) ->
    command = spawn node, [ nar-bin ] ++ args, { process.env }
    if type is 'close'
      command.on type, callback
    else
      data = ''
      command.stdout.on type, -> data += it.to-string!
      command.on 'close', (code) -> data |> callback _, code

  server: (done) ->
    server = new stubby.Stubby
    server.start { data: require "../fixtures/mock.json" }, done
    server

  static-server: (dir, cb) ->
    file = new node-static.Server dir
    server = http.createServer (request, response) ->
      request.addListener 'end', (-> file.serve request, response) .resume!
    server.listen 8883, cb
    server

  is-executable: (file) ->
    ``!!(1 & parseInt(((fs.statSync(file)).mode & parseInt('775', 8)).toString(8)[0]))``
