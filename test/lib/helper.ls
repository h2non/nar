require! {
  fs
  path
  chai
  rimraf
  mkdirp
  stubby
  request
  child_process.spawn
  '../../lib/nar'
  '../../package.json'.version
}

node = process.execPath
nar-bin = path.join __dirname, '/../../', 'bin/nar'
cwd = process.cwd!

module.exports =

  fs: fs
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

  suppose: (args) ->
    suppose node, [ nar-bin ] ++ args

  server: (done) ->
    server = new stubby.Stubby
    server.start {
      data: require "./mock.json"
    }, done
