require! {
  './run'
  './list'
  './create'
  './extract'
  './install'
  '../package.json'.version
}

exports = module.exports = {
  VERSION: version
  create, extract, run, list, install
}
