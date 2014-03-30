# nar [![Build Status](https://secure.travis-ci.org/h2non/nar.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.png)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.png)][npm]

> node.js application archive. Bundle, package self-contained applications ready-to-ship

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

## Command-line interface

```
$ nar --help

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

Create a nar archive from an existent application

### run

Run an application

### extract

Extend sources from a nar archive

## Configuration

nar specific build configuration should be defined as meta-data
in the `package.json` manifest file of your application

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

### Ignore files

You can explicit omit files defining them in the `.buildignore` file

### Options

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

#### globalPackages
Type: `string|array`
Default: `undefined`

Bundle globally installed packages in the generated archive.
Useful for npm, grunt-cli, bower...

Include the node.js binary in the generated archive.
This is usually useful when you want to deploy a obsessively fully self-contained application
in a sandboxed deployment or runtime environment

**Note**: the binary is OS-specific. Be aware about using this option if you want to deploy in multiple platforms

#### deployPath
Type: `string`
Default: `undefined`

## Programmatic API

### Nar(options)

### Nar.create(options)

#### compress(callback)

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
