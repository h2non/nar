
# nar [![Build Status](https://api.travis-ci.org/h2non/nar.svg?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.svg)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.svg)][npm] [![Stories in Ready](https://badge.waffle.io/h2non/nar.png?label=ready&title=Ready)](https://waffle.io/h2non/nar)

**nar** is a simple application packager utility for [node.js](http://nodejs.org)
that **creates fully self-contained applications**
that are **ready-to-ship-and-run**

It provides built-in support for creating, extracting, installing and running node
applications easily from a simple [configuration](#configuration) through
a featured [command-line interface](#command-line-interface)
and full asynchronous event-based [programmatic API](#programmatic-api)

It could be an great solution for distributing, running and testing
private node.js applications that are outside of the `npm` ecosystem

Questions? Read the [FAQs](#faq) or [open](https://github.com/h2non/nar/issues/new) an issue

## Features

<img align="right" height="165" src="http://nodejs.org/images/platform-icon-generic.png" />

- Simple and featured command-line interface
- Easy-to-use asynchronous programmatic API
- Fully configurable from package.json
- Tarball with gzip compression/decompression
- Built-in support for archive extraction
- Built-in support for application execution
- Built-in support for installating archives (like npm does)
- Supports downloading and running archives from remote servers
- Supports application pre/post run hooks (like [npm scripts][npm-scripts])
- Supports installing archives from local and remote servers (like npm does)
- Allow to embed dependencies by type
- Allow to embed global dependencies
- Allow to embed node binary for isolated runtime environments
- Allow to create archives like executables binary-like containers (embedded node)
- Integrable in your development workflow through [Grunt][grunt-plugin] or [Gulp][gulp-plugin]
- Transparent file checksum integrity verification

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

Or directly run it
```bash
$ nar run app.nar
```

Install (default to `node_modules`)
```bash
$ nar install http://server.net/app-0.1.0.nar --save
```

### Executables

`nar` also provides support for creating **executables binary-like** archives which
has `node` binary embedded, and therefore, is not required
to have node.js already installed in the target OS

This is a useful feature when you need to deploy or test
node applications in new or isolated servers

Create new executable binary `nar` archive
```bash
$ nar create --executable
> Creates: myapp-0.1.0-linux-x64.nar
```

Then you can run it as simple as:
```bash
$ chmod +x myapp-0.1.0-linux-x64.nar
$ ./myapp-0.1.0-linux-x64.nar start --args-start='--port 8080'
```

If you need to pass custom arguments to your application, instead
of use the `--args-start` flag to pass custom arguments,
you could use the `exec` command directly
```bash
$ ./myapp-0.1.0-linux-x64.tar exec --port 8080 --env dev --debug
```

You can also embed a custom node binary per platform, processor architecture and version
```bash
$ nar create --executable --os darwin --arch x64 --node 0.11.9
```

Supported platforms are:
- `linux` (x86, x64)
- `darwin` (x86, x64)
- `sunos` (x86, x64)

Suported node version are:
- `0.8.x`
- `0.9.x`
- `0.10.x`
- `0.11.x`

## Configuration

Example `package.json` with full configuration
```json
{
  "name": "my-package",
  "version": "1.0.0",
  "archive": {
    "dependencies": true,
    "devDependencies": false,
    "globalDependencies": ["npm", "grunt-cli", "bower"],
    "patterns": ["**", "!test/**"]
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

Following options can be declared in your application `package.json` as
properties members of the `archive` object

Packages dependencies names will be taken from `package.json`

#### dependencies
Type: `boolean`
Default: `true`

Include runtime dependencies in the archive

#### devDependencies
Type: `boolean`
Default: `false`

Include development dependencies in the archive

#### peerDependencies
Type: `boolean`
Default: `true`

Include peer dependencies in the archive

#### globalDependencies
Type: `array`
Default: `null`

Include global dependencies in the archive.
It should define an array of strings with packages names

nar will resolve globally installed packages (via [requireg][requireg])
and will add them to the archive

Global dependencies will be placed in `.node/lib/node` on archive extraction and them will be
available via `require` and `PATH` environment variable (for binary files)

#### binary
Type: `boolean`
Default: `false`

Include the node binary in the nar archive.
This is useful when you want to deploy a fully self-contained application
which works in a sandboxed runtime environment

The included node binary will be, by default, the same as the used when your
create the archive (taken from `process.execPath`)

Hooks scripts that requires node will use the self-contained binary inside the archive.
It will be also accessible via `PATH` environment variable
if you want to call it from hook scripts

**Note**: as you already know, the node binary is OS and platform specific.
Take that into account if you are going to deploy the archive in multiple platforms

#### binaryPath
Type: `string`
Default: `process.execPath`

Custom `node` binary path to add into the archive

You must define the `binary` option as `true` in order to apply this.
You can use interpolated environment variables expressions in
this option, like `${HOME}/binaries/node`

Aditionally, you can also define the `binaryPath` value from the `NAR_BINARY`
environment variable

#### ignoreFiles
Type: `boolean`
Default: `true`

Enable/disable [ignore-like files](#ignoring-files) processing in order to load
files patterns to discard from the archive

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
  install [options] <archive>
    Install archive
  get [options] <url>
    Download archive from HTTP server

Options:

  -h, --help     output usage information
  -V, --version  output the version number

Usage examples:

  $ nar create
  $ nar run app.nar
  $ nar extract app.nar -o some/dir
  $ nar list app.nar
  $ nar install app.nar --save
  $ nar get http://server.net/app.nar

Command specific help:

  $ nar <command> --help
```

### create
Alias: `c`

Create a new archive from an existent application

```bash
$ nar create
$ nar create some/path --debug
$ nar create path/to/package.json -o some/dir
$ nar create --dev-dependencies --global-dependencies 'npm,grunt'
$ nar create --omit-dependencies
$ nar create --verbose
$ nar create --executable
```

### extract
Alias: `e`

Extract archive files into directory

```bash
$ nar extract
$ nar extract app.nar
$ nar extract app.nar -o some-dir
$ nar extract app.nar --debug
```

### run
Alias: `x` `start`

Run nar archive application

```bash
$ nar run app.nar
$ nar run app.nar --no-hooks
$ nar run app.nar --no-clean --debug
$ nar run app.nar --verbose
$ nar run app.nar --args-start '--env ${ENV}'
$ nar run app.nar --args-stop '--path ${PATH}'
$ nar run http://server.net/app.nar
```

### install
Alias: `i`

Install nar archive as dependency (defaults to `node_modules`)

```bash
$ nar install app.nar --save
$ nar install app.nar -o some/dir --save-dev
$ nar install app.nar --debug
$ nar install http://server.net/app-0.1.0.nar
$ nar install -g http://server.net/app-0.1.0.nar
```

### get
Alias: `g`

Download a remote archive

```bash
$ nar get http://server.net/app.nar
$ nar get http://server.net/app.nar --user john --password pa$s
$ nar get http://server.net/app.nar --proxy http://proxy:3128
$ nar get http://server.net/app.nar --strict-ssl --timeout 60000
```

### list
Alias: `l`

List files from archive

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
  path: 'my/package.json', // defaults to ./package.json
  dest: 'build/', // defaults to current directory
  binary: true,
  dependencies: true,
  devDependencies: true,
  globalDependencies: ['npm', 'grunt']
}

try {
  nar.create(options)
    .on('error', function (err) {
      throw err
    })
    .on('info', function (nar) {
      console.log(nar.name)
    })
    .on('entry', function (file) {
      console.log('Adding file:', file.name)
    })
    .on('end', function (path) {
      console.log('Archive created in:', path)
    })
} catch (e) {
  console.error('Cannot create the archive:', e.message)
}
```

### nar.create(options)
Fired events: `end, error, entry, archive, message, info, start`

Create new archive from a given package.json

##### Options

You can pass any configuration [options](#options) and the following options:

- **path** `string` Path to package.json or application directory. Required
- **dest** `string` Extract destination path. Default to random temporal directory
- **file** `string` Archive file name. Default to package name + version, taken from `package.json`
- **patterns** `array` List of glob patterns for matching files to include or exclude

### nar.createExec(options)

Same as `nar.create()`, but this generate an executable binary-like archive

Aditional executable options are:

- **os** `string` Node.js OS binary platform to embed. Detault to current OS
- **arch** `string` Node.js OS binary architecture to embed. Default to current OS
- **node** `string` Node.js version to embed. Default to current node runtime version

### nar.extract(options)
Fired events: `end, error, entry, archive, message, info, start`

Extract archive files into a output directory

##### Options

- **path** `string` Path to nar archive. Required
- **dest** `string` Extract destination path. Default to random temporal directory
- **tmpdir** `string` Temporal directory to use. Default to random temporal directory

### nar.run(options)
Fired events: `end, error, entry, archive, command, info, start, stdout, stderr, exit`

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

### nar.install(options)
Fired events: `end, download, downloadEnd, error, entry, start, progress`

Install archive as dependency in `node_modules` directory.
It can aditionally download the archive from remote server

##### Options

- **path** `string` Path to nar archive. Required if `url` is empty
- **url** `string` URL to download the archive. Required if `path` is empty
- **filename** `string` Downloaded filename. Defaults taken from URI path
- **dest** `string` Install destination path. Defaults to random `node_modules`
- **clean** `boolean` Clean downloaded archive after install. Defaults to `true`
- **proxy** `string` Proxy server URL. Default taken from environment variable `http_proxy`
- **auth** `object` user and password for HTTP basic authentication
- **timeout** `number` HTTP request timeout in ms. Defaults to `10000`
- **headers** `object` Define aditional HTTP request headers
- **strictSSL** `boolean` Performs HTTP request with valid SSL servers. Defaults to `false`
- **save** `boolean` Save installed package as runtime dependency in `package.json`. Default to `false`
- **saveDev** `boolean` Save installed package as development dependency in `package.json`. Default to `false`
- **savePeer** `boolean` Save installed package as peer dependency in `package.json`. Default to `false`
- **global** `boolean` Install package as global dependency. Default to `false`

### nar.get(options)
Alias: `download`

Fired events: `end, error, download, progress`

Download archive from remote server.
It supports basic HTTP authentication and proxy

##### Options

- **path** `string` Path to nar archive. Required if `url` is empty
- **url** `string` URL to download the archive. Required if `path` is empty
- **dest** `string` Install destination path. Defaults to random `node_modules`
- **filename** `string` Downloaded filename. Defaults taken from URI path
- **clean** `boolean` Clean downloaded archive after install. Defaults to `true`
- **proxy** `string` Proxy server URL. Default taken from environment variable `http_proxy`
- **auth** `object` user and password for HTTP basic authentication
- **timeout** `number` HTTP request timeout in ms. Defaults to `10000`
- **strictSSL** `boolean` Performs HTTP request with valid SSL servers. Defaults to `false`

### nar.VERSION
Type: `string`

### Events

Complete list of available events for subscription

- **end** `([result])` Task was completed successfully
- **error** `(error)` Some error happens and task cannot be completed
- **entry** `(entry)` On read/write file, usually fired from file streams
- **archive** `(archive)` Emit the archive that is being processed
- **message** `(message)` General information status message, useful for debugging purposes
- **download** `()` Starts a download process
- **command** `(command)` Hook command to execute when run an application
- **info** `(config)` Expose the nar archive config
- **start** `(command)` On application start hook command
- **stdout** `(string)` Command execution stdout entry. Emits on every chunk of data
- **stderr** `(string)` Command execution stderr entry. Emits on every chunk of data
- **exit** `(code, hook)` When a hook command process ends

## FAQ

##### Which kind of archive is nar?

nar archives are just a tarball containers with gzip compression.
It's equivalent to a file with `tar.gz` extension, so you can extract
it with `tar`, `7zip` or file compression tools ans inspect the archive contents

Example using `tar`
```bash
$ tar xvfz app-0.1.0.nar
```

##### Is required to have installed node or nar in order to work with nar archives?

No. From version `0.3.0` you can create executable binary-like applications containers
and there is no more required to have previously installed `node` or `nar` in order
to run, install or extract an application

You must create a executable nar archive
```bash
$ nar create --executable
```

Then you could simply run it like this:
```bash
$ ./app-0.1.0.nar [run|extract|install] [options]
```

If you don't create your archive with this option, you must to have `nar`
(and consequently node) installed in the target computer

##### nar executables runs in Windows?

No. nar executables only can run in any UNIX-like OS

Is not planned to support it due to technical limitations in Windows OS

##### Which binary is used in nar executables?

The node binary that is begin used when the `nar` archive is created

To be exactly, the binary that
[process.execPath](http://nodejs.org/api/process.html#process_process_execpath) points to

That means, if you create an executable archive in OSX and then deploy it into a GNU/Linux server, it will fail.
At the moment, you must create the archive in the same OS as you want to use it

It was created a [feature request](https://github.com/h2non/nar/issues/88) about add support to configure the embebbed binary to use

##### When will be used embedbed node binary in the archive?

Yes.
If you use the `run` command, if the archive was created with the node binary embedded,
your application will run with the self-contained binary

##### Which MIME type is recommened to serve nar files?

One of the following types will be valid:

- `application/x-gzip`
- `aplication/x-compress`
- `application/x-compressed`
- `application/octet-stream`

##### Can I download archives which requires server authentication?

Of course. You could use both methods:

Passing credentials via optional flags:
```
$ nar get https://server.net/archive.nar --user john --password p@s$
```

Or using the `HTTP_USER` and `HTTP_PASSWORD` environment variables
```
$ HTTP_USER=john HTTP_PASSWORD=p@s$ nar get https://server.net/archive.nar
```

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

[MIT](http://opensource.org/licenses/MIT) © Tomas Aparicio

[livescript]: http://livescript.net
[coding-style]: https://github.com/gkz/LiveScript-style-guide
[travis]: http://travis-ci.org/h2non/nar
[gemnasium]: https://gemnasium.com/h2non/nar
[npm]: http://npmjs.org/package/nar
[npm-scripts]: https://www.npmjs.org/doc/misc/npm-scripts.html
[glob]: https://github.com/isaacs/node-glob
[requireg]: https://github.com/h2non/requireg
[grunt-plugin]: https://github.com/h2non/grunt-nar
[gulp-plugin]: https://github.com/h2non/gulp-nar
