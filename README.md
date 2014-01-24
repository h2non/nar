# nar

> **N**ode.js application **AR**chive. Package and ship node applications easily

> **work in progress!**

## Why

If you are a lucky guy, you probably do not need to use `nar`, in other cases,

Easily package and ship node.js applications in a self-contained gzipped archive

## Installation

```
$ npm install -g nar
```

## Command-line interface

### create

### exec

### extract

### deploy

## Configuration

nar specific build configuration should be defined as meta-data
in the `package.json` manifest file of your application

```
{
  "name": "my-cool-package",
  "version": "1.0.0",
  "nar": {
    "binary": true,
    "deployPath": "${HOME}/apps/my-cool-package",
    "dependencies": true,
    "devDependencies": false,
    "peerDependencies": true,
    "commands": {
      "pre-run": "npm install",
      "run": "node ./app"
    }
  }
}
```

### Options

The following options can be declared in your application package.json as
properties members of the `nar` or `package` first-level property

#### dependencies
Type: `boolean`
Default: `true`
Alias: `includeDependencies`

#### devDependencies
Type: `boolean`
Default: `false`
Alias: `includeDevDependencies`

#### peerDependencies
Type: `boolean`
Default: `false`
Alias: `includePeerDependencies`

#### binary
Type: `boolean`
Default: `false`
Alias: `includeBinary`

#### globalPackages
Type: `string|array`
Default: `undefined`
Alias: `includeGlobalPackages`

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

`to do`

## License

Copyright (c) 2014 Tomas Aparicio

Released under the MIT license
