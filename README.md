# nar [![Build Status](https://secure.travis-ci.org/h2non/nar.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.png)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.png)][npm]

<table>
<tr>
<td><b>Stage</b></td><td>beta</td>
</tr>
</table>

## About

**nar** is a simple application packager utility for [node.js](http://nodejs.org)

With nar you can easily create self-contained node.js applications
that are ready-to-ship-and-run

It provides built-in support for creating, extracting and running applications
easily through a featured [command-line interface](#command-line-interface)
and asynchronous event-based [programmatic API](#programmatic-api)

## Features

<img align="right" height="165" src="http://nodejs.org/images/platform-icon-generic.png" />

- Simple command-line interface
- Easy-to-use asynchronous programmatic API
- Fully configurable from package.json
- Tarball with gzip compression/decompression
- Built-in support for archive extraction
- Built-in support for application execution
- Supports application pre/post run hooks (from [npm scripts][npm-scripts])
- Allow to bundle dependencies by type
- Allow to bundle global dependencies
- Allow to bundle node binary for platform-specific isolated runtime environments
- Transparent checksum file integrity verification
- Platform agnostic

## Installation

It's recommended you install nar as global package
```bash
$ npm install -g nar
```

If you need to use the API, you should install it as package dependency
```bash
$ npm install nar --save
```

## Basic usage

Create new archive
```bash
$ nar create
```

Extract files
```bash
$ nar extract app.nar
```

Or directly run the application
```bash
$ nar run app.nar
```

## Configuration

Example `package.json` with full configuration
```json
{
  "name": "my-package",
  "version": "1.0.0",
  "archive": {
    "binary": true,
    "dependencies": true,
    "devDependencies": false,
    "globalDependencies": ["npm", "grunt"],
    "patterns": ["**", "!temp/**"]
  },
  "scripts": {
    "start": "node app --env ${ENV}"
  },
  "dependencies": {
    "some": "~0.1.0"
  }
}
```

### Options

The following options can be declared in your application `package.json` as
properties members of the `archive` object

Dependencies will be matched from `package.json`

#### dependencies
Type: `boolean`
Default: `true`

Include package dependencies in the nar archive

#### devDependencies
Type: `boolean`
Default: `false`

Include development dependencies in the nar archive

#### peerDependencies
Type: `boolean`
Default: `true`

Include peer dependencies in the nar archive

#### globalDependencies
Type: `array`
Default: `null`

Include global dependencies in the nar archive.
It should define an array strings with packages names

nar will resolve globally installed packages (via [requireg][requireg])
and will bundle them into the archive

Global dependencies will be placed in `.node/lib/node` on archive extraction and them will be
available via `require` and `PATH` environment variable (for binary files)

#### binary
Type: `boolean`
Default: `false`

Include the node binary in the nar archive.
This is useful when you want to deploy a fully self-contained application
like a sandboxed runtime environment

The included node binary will be the same as the used when your
create the archive (taken from `process.execPath`)

**Note**: as you already know, the node binary is OS and platform specific.
Take that into account if you are going to deploy the archive in multiple platforms

#### patterns
Type: `array`
Default: `['**']`

[Glob][glob] patterns for matching files to include or exclude in the archive
OS level specific hidden files such as `.DS_Store` or `Thumbs.db` will be ignored by default

Aditionally, nar will ignore matched patterns defined in [ignore-like files](#ignoring-files)

### Stage hooks

`nar` supports application pre/post execution hooks, that are also supported by `npm`

You should define them from `package.json` in the `scripts` member (see [npm scripts][npm-scripts])

Supported hooks (by execution order):

- `prestart`
- `start`
- `stop`
- `poststop`

Configuration example:

```json
{
  "name": "app",
  "version": "1.0.0",
  "scripts": {
    "prestart": "mkdir -p temp/logs",
    "start": "node app --env ${ENV}",
    "stop" "rm -rf cache"
  }
}
```

#### Aditional useful features

##### Environment variables in hook commands

You can consum environment variables from hook comands using the `${VARNAME}` notation

##### Nar-specific execution environment

nar will expose the `NODE_NAR` environment variable in the hooks execution contexts and node application

You can make any environment runtime checks if your application needs a different behavior
dependending of the runtime environment

##### Ignoring files

nar will find ignore-like files in order to load
and match patterns of files to discard

Supported files (by priority):

- `.narignore`
- `.buildignore`
- `.npmignore`
- `.gitignore`

## Command-line interface

```bash
Usage: nar [options] [command]

Commands:

  help
    Output usage information
  create [options] [path]
    Create a nar archive
  extract [options] <archive>
    Extract archive
  run [options] <archive>
    Run archive files
  list [options] <archive>
    List archive files

Options:

  -h, --help     output usage information
  -V, --version  output the version number

Usage examples:

  $ nar create
  $ nar run app.nar
  $ nar extract app.nar -o some/dir
  $ nar list app.nar

Command specific help:

  $ nar <command> --help
```

### create

Create a new archive from an existent application

```bash
$ nar create
$ nar create some/path --debug
$ nar create path/to/package.json -o some/dir
$ nar create --dev-dependencies --global-dependencies 'npm,grunt'
$ nar create --debug --verbose
```

### extract

Extract archive files into directory

```bash
$ nar extract
$ nar extract app.nar
$ nar extract app.nar -o some-dir
$ nar extract app.nar --debug
```

### run

Run nar archive application

```bash
$ nar run app.nar
$ nar run app.nar --no-hooks
$ nar run app.nar --no-clean --debug
$ nar run app.nar --verbose
$ nar run app.nar --args-start '--env ${ENV}'
$ nar run app.nar --args-stop '--path ${PATH}'
```

### list

List files from a nar archive

```bash
$ nar list app.nar
$ nar list app.nar --no-table
```

## Programmatic API

nar provides a full featured programmatic API designed to
be easily consumed from other node applications

The API is fully asynchronous event-based, for a better approach

```js
var nar = require('nar')

var options = {
  path: 'my/package.json', // defaults to current directory
  dest: 'build/',
  archive: {
    binary: true,
    dependencies: true,
    devDependencies: true
  }
}

try {
  nar.create(options)
    .on('error', function (err) {
      throw err
    })
    .on('info', function (nar) {
      console.log(nar.name)
    })
    .on('end', function (path) {
      console.log('Archive created in: ' + path)
    })
} catch (e) {
  console.error('Cannot create the archive:', e.message)
}
```

### nar.create(options)
Fired events: `end, error, entry, message, info, start`

Create new archive from a given package.json

##### Options

- **path** `string` Path to package.json or application directory. Required
- **dest** `string` Extract destination path. Default to random temporal directory
- **patterns** `array` List of glob patterns for matching included/excluded files
- **archive** `object` Creation archive options. By default taken from `package.json`

### nar.extract(options)
Fired events: `end, error, entry, message, info, start`

Extract archive files into a output directory

##### Options

- **path** `string` Path to nar archive. Required
- **dest** `string` Extract destination path. Default to random temporal directory
- **tmpdir** `string` Temporal directory to use. Default to random temporal directory

### nar.run(options)
Fired events: `end, error, entry, command, info, start, stdout, stderr, exit`

Read, extract and run an application. It will read [command scripts][npm-scripts] hooks in `package.json`

##### Options

- **path** `string` Path to nar archive. Required
- **dest** `string` Extract destination path. Defaults to random temporal directory
- **args** `object` Aditional argument to pass to hooks. Keys must have the same hook name
- **hooks** `boolean` Enable/disable run command hooks. Defaults to `true`
- **clean** `boolean` Clean app directory on exit. Defaults to `true`

### nar.list(options)
Options: `path`

Fired events: `end, error, entry`

Read and parse a given .nar archive, emitting the `entry` event for each existent file

##### Options

- **path** `string` Path to nar archive. Required

### nar.VERSION
Type: `string`

### Events

Complete list of available events for subscription

- **end** (`[result]`) Task was completed successfully
- **error** `(error)` Some error happens and task cannot be completed
- **entry** `(entry)` On read/write file, usually fired from file streams
- **message** `(message)` General information status message, useful for debugging purposes
- **command** `(command)` Hook command to execute when run an application
- **info** `(config)` Expose the nar archive config
- **start** `(command)` On application start hook command
- **stdout** `(string)` Command execution stdout entry. Emits on every chunk of data
- **stderr** `(string)` Command execution stderr entry. Emits on every chunk of data
- **exit** `(code, hook)` When a hook command process ends

## Contributing

Wanna help? Cool! It will be really apreciated :)

`nar` is completely written in LiveScript language.
Take a look to the language [documentation][livescript] if you are new with it.
and follow the LiveScript language conventions defined in the [coding style guide][coding-style]

You must add new test cases for any new feature or refactor you do,
always following the same design/code patterns that already exist

### Development

Only [node.js](http://nodejs.org) is required for development

Clone/fork this repository
```
$ git clone https://github.com/h2non/nar.git && cd nar
```

Install dependencies
```
$ npm install
```

Compile code
```
$ make compile
```

Run tests
```
$ make test
```

Publish a new version
```
$ make publish
```

## License

Copyright (c) 2014 Tomas Aparicio

Released under the MIT license

[livescript]: http://livescript.net
[coding-style]: https://github.com/gkz/LiveScript-style-guide
[travis]: http://travis-ci.org/h2non/nar
[gemnasium]: https://gemnasium.com/h2non/nar
[npm]: http://npmjs.org/package/nar
[npm-scripts]: https://www.npmjs.org/doc/misc/npm-scripts.html
[glob]: https://github.com/isaacs/node-glob
[requireg]: https://github.com/h2non/requireg
