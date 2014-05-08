require! {
  './run'
  './list'
  './create'
  './extract'
  './install'
  './download'
  '../package.json'.version
}

exports = module.exports = {
  VERSION: version
  create, extract, run,
  list, install, download
  get: download
}
