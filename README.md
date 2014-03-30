# nar [![Build Status](https://secure.travis-ci.org/h2non/nar.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.png)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.png)][npm]

> node.js application archive. Bundle and package self-contained applications ready-to-ship

> **Spoiler! Work in progress!**

## About

**nar** is a simple utility for creating self-contained node applications
that are ready to ship and deploy

## Features

- Simple command-line interface
- Provides a easy-to-use programmatic API
- Tarball with gzip compression/decompression
- Package extraction and run
- Automatic package discovery
- Full configurable from package.json
- Allow to bundle dependencies by type
- Allow to bundle node binary for platform-specific runtime environments
- Transparent checksum file integrity verification

## Installation

It's recommended you install it as global package
```
$ npm install -g nar
```

If you need to use the API, you should install it as package dependency
```
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
    "peerDependencies": true,
    "commands": {
      "pre-run": [
        "npm install -g grunt"
      ],
      "run": "./app"
    }
  }
}
```

### Config options

The following options can be declared in your application package.json as
properties members of the `nar` or `package` first-level property

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

## Command-line interface

```
  Usage: nar [options] [command]

  Commands:

    help
      Output the usage information
    version
      Output the version information
    create [options] [path]
      Create new aplication archive
    extract [options] [archive]
      Extract archive files

  Options:

    -h, --help     output usage information
    -V, --version  output the version number

  Usage examples:

    $ nar create [path]
    $ nar run [archive]
    $ nar extract [archive] -o [directory]

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

Extract archive files to a given directory

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

## Programmatic API

### Nar(options)

### Nar.create(options, cb)

### Nar.extract(options, cb)

### Options

- **base** `string` Path to package output directory
- **pkgPath** `string` Path to package.json
- **dependencies** `boolean` Add package dependencies
- **devDependencies** `boolean` Add package development dependencies
- **peerDependencies** `boolean` Add package development dependencies
- **binary** `boolean` Add node binary (warning! binary is platform specific)

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
