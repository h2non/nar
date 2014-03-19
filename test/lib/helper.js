var fs, path, chai, grunt, sinon, mkdirp, rimraf, suppose, spawn, version, node, croak, cwd, homeVar;
fs = require('fs');
path = require('path');
chai = require('chai');
grunt = require('grunt');
sinon = require('sinon');
mkdirp = require('mkdirp');
rimraf = require('rimraf');
suppose = require('suppose');
spawn = require('child_process').spawn;
version = require('../../package.json').version;
node = process.execPath;
croak = path.join(__dirname, '/../../', 'bin/nar');
cwd = process.cwd();
homeVar = process.platform === 'win32' ? 'USERPROFILE' : 'HOME';
module.exports = {
  cwd: cwd,
  node: node,
  version: version,
  croak: croak,
  grunt: grunt,
  sinon: sinon,
  expect: chai.expect,
  should: chai.should,
  assert: chai.assert,
  rm: rimraf.sync,
  mkdirp: mkdirp.sync,
  chdir: process.chdir,
  env: process.env,
  homeVar: homeVar,
  home: process.env[homeVar],
  join: path.join,
  createWriteStream: fs.createWriteStream,
  exists: function(it){
    return fs.existsSync(it);
  },
  read: grunt.file.read,
  exec: function(type, args, callback){
    var command, data;
    command = spawn(node, [croak].concat(args));
    if (type === 'close') {
      return command.on(type, callback);
    } else {
      data = '';
      command.stdout.on(type, function(it){
        return data += it.toString();
      });
      return command.on('close', function(code){
        return callback(data, code);
      });
    }
  },
  suppose: function(args){
    return suppose(node, [croak].concat(args));
  }
};