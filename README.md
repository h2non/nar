# nar [![Build Status](https://secure.travis-ci.org/h2non/nar.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.png)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.png)][npm]

> Bundle and package self-contained node.js applications that are ready-to-ship-and-run

> **Spoiler! Work in progress!**

<table>
<tr>
<td><b>Version</b></td><td>beta</td>
</tr>
</table>

## About

**nar** is a simple utility for creating and running self-contained node.js applications

## Features

- Simple command-line interface
- Provides a easy-to-use programmatic API
- Tarball with gzip compression/decompression
- Built-in package extraction
- Built-in support app execution
- Application pre/post run hooks
- Automatic package discovery
- Full configurable from package.json
- Allow to bundle dependencies by type
- Allow to bundle node binary for platform-specific runtime environments
- Native checksum file integrity verification

## Installation

It's recommended you install it as global package
```bash
$ npm install -g nar
```

If you need to use the API, you should install it as package dependency
```bash
$ npm install nar --save
```

## Configuration

It supports specific archive build configuration that can be defined as meta-data
in the `package.json` of your application

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "archive": {
    "binary": true,
    "dependencies": true,
    "devDependencies": false,
    "peerDependencies": true
  }
}
```

### Config options

The following options can be declared in your application `package.json` as
properties members in the `archive` object

#### dependencies
Type: `boolean`
Default: `true`

#### devDependencies
Type: `boolean`
Default: `false`

#### peerDependencies
Type: `boolean`
Default: `true`

#### binary
Type: `boolean`
Default: `false`

Include the node.js binary in the generated archive.
This is usually useful when you want to deploy a obsessively fully self-contained application
in a sandboxed deployment or runtime environment

**Note**: node binary is OS and platform specific.
Take that into account if you are going to deploy the archive in multiple platforms

### Run hooks

`nar` supports application pre/post execution hooks, that are also supported by `npm`.

You should define it the `package.json` in the `scripts` properties

Supported hooks:
- `prestart`
- `start`
- `stop`

Configuration example:
```json
{
  "name": "app",
  "version": "1.0.0",
  "scripts": {
    "prestart": "rm -rf dir",
    "start": "node app --env ${ENV}",
    "stop" "rm -rf cache"
  }
}
```

#### Notes about hooks

##### Environment variables in hook commands

You can consum environment variables from hook comands using the `${VARNAME}` notation

##### Passing arguments to hook commands

You can pass arguments to hooks commands from nar CLI

```
$ nar run app.nar --start-args "--env ${ENV} --debug"
```

## Command-line interface

```
Usage: nar [options] [command]

Commands:

  help
    Output the usage information
  create [options] [path]
    Create new aplication archive
  extract [options] [archive]
    Extract archive files
  list [options] [archive]
    List archive files

Options:

  -h, --help     output usage information
  -V, --version  output the version number

Usage examples:

  $ nar create [path]
  $ nar run [archive]
  $ nar extract [archive] -o [directory]
  $ nar list [archive]

Command specific help:

  $ nar <command> --help
```

### create

Create a new archive from an existent application

```
Usage: create [path] [options]

Options:

  -h, --help     output usage information
  -o, --output   Output directory
  -f, --force    Forces archive creation passing warnings or errors
  -d, --debug    Enable debugging mode for tasks that support it
  -v, --verbose  Verbose mode. A lot of information will be showed
  --no-color     Disable colored output

Usage examples:

  $ nar create
  $ nar create some/path
  $ nar create path/to/package.json -o some-dir
  $ nar create --debug --verbose --no-color
```

### extract

Extract archive files into directory

```
Usage: extract [archive] [options]

Options:

  -h, --help     output usage information
  -o, --output   Output directory
  -f, --force    Forces archive creation passing warnings or errors
  -d, --debug    Enable debugging mode for tasks that support it
  -v, --verbose  Verbose mode. A lot of information will be showed
  --no-color     Disable colored output

Usage examples:

  $ nar extract
  $ nar extract app.nar
  $ nar extract app.nar -o some-dir
  $ nar extract app.nar --debug --verbose --no-color
```

### run

### list


## Programmatic API

```js
var nar = require('nar')

var options = {
  dest: 'path/to/pkg'
  binary: true,
  dependencies: true,
  devDependencies: true
}

try {
  nar.create(options, function (err, nar) {
    console.log('Archive created successfully in:', nar.output)
  })
} catch (e) {
  console.error('Cannot create the archive:', e.message)
}
```

### nar.create(options, cb)

### nar.extract(options, cb)

### nar.run(options, cb)

### nar.list(options, cb)

### nar.VERSION

### Options

- **dependencies** `boolean` Add package dependencies
- **devDependencies** `boolean` Add package development dependencies
- **peerDependencies** `boolean` Add package development dependencies
- **binary** `boolean` Add node binary (warning! binary is platform specific)
- **commands** `array` Command to execute in different app stages

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
