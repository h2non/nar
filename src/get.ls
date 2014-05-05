require! {
  path
  events.EventEmitter
  progress: 'request-progress'
}
{ next } = require './utils'

module.exports = get = (options) ->

