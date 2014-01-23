# nar

> **N**ode.js application **AR**chive. Package and ship node applications like a boss

> **work in progress!**

## About

Easily package and ship node.js applications in a self-contained gzipped archive

**work in progress!**

## Configuration

nar specific build configuration should be defined as meta-data
in the `package.json` manifest file of your application

```
{
  "name": "my-cool-package",
  "version": "1.0.0",
  "nar": {
    "binary": true,
    "dependencies": true,
    "devDependencies": false,
    "peerDependencies": false,
    "commands": {
      "pre-run": "npm install",
      "run": "node app"
    }
  }
}
```

### Options

The following options should be declared in a package called `package`

#### binary
Type: `boolean`
Default: `false`
Alias: `includeBinary`

This options allows to you include include the node.js binary in the generated build archive.
This is usually useful when you want to deploy a fully self-contained application in a sandboxed deployment environment

**Note**: Node binary is OS-specific. Be aware about using this option if you want to deploy in multiple platforms

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

## Command-line interface

### create

### update

### exec

### extract

## Programmatic API

`to do`

## License

Copyright (c) 2014 Tomas Aparicio

Released under the MIT license
