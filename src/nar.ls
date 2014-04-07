require! {
  './run'
  './list'
  './extract'
  './archive'
  '../package.json'.version
}

exports = module.exports =

  VERSION: version

  create: (options, cb) ->
    archive.create ...

  extract: (options, cb) ->
    extract ...

  run: (options, cb) ->
    run ...

  list: (options) ->
    list ...
