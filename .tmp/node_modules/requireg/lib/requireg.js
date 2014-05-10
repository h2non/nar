var fs   = require('fs') 
var path = require('path')
var resolvers = require('./resolvers')

'use strict';

module.exports = requireg

function requireg(module) {
  var moduleExports

  try {
    moduleExports = require(resolve(module))
  } catch (e) {}

  if (moduleExports === undefined) {
    throw new Error("Cannot find global module '"+ module +"'")
  }

  return moduleExports
}

requireg.resolve = resolve

requireg.globalize = function () {
  global.requireg = requireg
}


function resolve(module, dirname) {
  var i, resolver, modulePath

  for (i = 0, l = resolvers.length; i < l; i += 1) {
    resolver = resolvers[i]
    if (modulePath = resolver(module, dirname)) {
      break
    }
  }

  return modulePath
}