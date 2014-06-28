#!/usr/bin/env node

var exec = require('child_process').exec
var file = 'nar-0.2.5.nar'
var runScript = __dirname + '/scripts/run.sh'

exec('cat ' + runScript + ' ' + file + ' > nar-0.2.5.run',
  function (error, stdout, stderr) {
    console.log('stdout: ' + stdout)
    console.log('stderr: ' + stderr)
    if (error !== null) {
      console.log('exec error: ' + error)
    }
})
