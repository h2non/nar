require! {
  hu
  fs
  path
  async
  crypto
  matchdep
  './pack'
  './extract'
  rm: rimraf.sync
  mk: mkdirp.sync
  'os-shim'.tmpdir
  findup: 'findup-sync'
  '../package.json'.version
}
{ read, checksum } = require './helper'

const pkgfile = 'package.json'
const attr = 'archive'
const pkg-dir = 'node_modules'

module.exports = class Nar

  @create = (options, cb) ->
    nar = new Nar options
    nar.create cb
    nar

  @extract = (options, cb) ->
    nar = new Nar
    nar.extract options, cb
    nar

  @run = (options, cb) ->
    Nar.extract options, ->
      pkg = pkg

  @VERSION = version

  defaults:
    base: null
    pkg-path: null
    binary: no
    dependencies: yes
    dev-dependencies: no
    peer-dependencies: yes

  (options) ->
    @options = (@defaults |> hu.clone) |> hu.extend _, options
    @options <<< base: process.cwd! unless @options.base
    @pkg = {}
    @set-tmp-dir!

  create: ->
    @pkg-path = @options.pkg-path or path.join @options.base, pkgfile
    @discover!
    @load-config!
    @set-filename!
    @set-output!
    @compress it

  load-config: ->
    if @exists!
      try
        @apply-config!
      catch
        throw new Error "Error while parsing package.json: #{e.message} - #{@pkg-path}"

  apply-config: ->
    @pkg = @pkg-path |> read
    options = @pkg[attr]
    options |> hu.extend @options, _ if (options |> hu.is-object)

  discover: ->
    unless @exists!
      @pkg-path = findup pkgfile, cwd: @options.base
      @load-config!

  exists: ->
    (it or @pkg-path) and ((it or @pkg-path) |> fs.exists-sync)

  name: ->
    @pkg.name or 'unnamed'

  set-filename: ->
    @file = @name!
    @file += "-#{@pkg.version}" if @pkg.version

  set-tmp-dir: ->
    @tmp-dir = "nar-#{@pkg.name or 'pkg'}-#{random!}" |> path.join tmpdir!, _
    @tmp-dir |> fs.mkdir-sync

  set-output: ->
    @output = "#{@file}.nar" |> path.join @options.base, _

  match-deps: ->
    { dependencies, dev-dependencies, peer-dependencies } = @options
    deps = {}
    deps <<< dep: matchdep.filter '*', @pkg if dependencies
    deps <<< dev: matchdep.filter-dev '*', @pkg if dev-dependencies
    deps <<< peer: matchdep.filter-peer '*', @pkg if peer-dependencies
    deps

  clean: ->
    try
      rm @tmp-dir
      rm @file if @file

  compress: (cb) ->
    config =
      name: @name!
      time: new Date!get-time!
      info:
        platform: process.platform
        arch: process.arch
        version: process.version
      files: []
      manifest: @pkg

    deps = (done) ~>
      @compress-deps config, ->
        done!

    pkg = (done) ~>
      @compress-pkg ->
        it |> config.files.push
        done!

    all = (done) ~>
      config |> @compress-all _, done

    async.series [ deps, pkg, all ], ~>
      @clean!
      cb!

  write-config: (config, cb) ->
    file = @tmp-dir |> path.join _, '.nar.json'
    data = config |> JSON.stringify _, null, 2
    fs.writeFile file, data, (err) ->
      throw err if err
      cb!

  compress-all: (config, cb) ->
    options =
      name: @file
      dest: @options.base
      patterns: [ '*.tar', '.nar.json' ]
      src: @tmp-dir
      ext: 'nar'
      gzip: yes

    pack-all = (done) ->
      pack options, (err) ->
        throw err if err
        done!

    write-config = (done) ~>
      config |> @write-config _, done

    exec = ->
      async.series [ write-config, pack-all ], -> cb!

    add-binary = ~>
      copy process.exec-path, @tmp-dir, ~>
        (path.basename it) |> options.patterns.push
        info =
          archive: 'node'
          dest: '.node/bin'
          type: 'binary'

        checksum it, (err, hash) ->
          info <<< checksum: hash
          info |> config.files.push
          exec!

    if @options.binary
      add-binary!
    else
      exec!

  compress-pkg: (cb) ->
    dest = @tmp-dir
    { base } = @options

    options =
      name: @name!
      dest: dest
      patterns: [ '**', '.*', '!node_modules/**' ]
      src: @pkg-path |> path.dirname

    pkg-info =
      archive: "#{@name!}.tar"
      dest: '.'
      type: 'package'

    pack options, (err, pkg) ->
      throw err if err
      checksum pkg.path, (err, hash) ->
        pkg-info <<< checksum: hash
        cb pkg-info

  compress-deps: (config, cb) ->
    dest = @tmp-dir
    { base } = @options

    find-pkg = ->
      it.map ->
        name: it
        dest: dest
        src: findup (it |> get-pkg-path), cwd: base

    is-valid = ->
      it and it.length

    do-compress = (it, done) ->
      set-pkg = (pkg, done) ->
        pkg-info =
          archive: pkg.archive
          dest: path.join pkg-dir, pkg.name
          type: 'dependency'

        checksum pkg.path, (err, hash) ->
          pkg-info <<< checksum: hash
          done null, pkg-info

      async.map it, pack, (err, results) ->
        done err if err
        async.map results, set-pkg, (err, results) ->
          throw err if err
          config <<< files: config.files.concat results
          done!

    ((@match-deps! |> hu.vals)
      .map find-pkg
      .filter is-valid)
      |> async.each _, do-compress, ->
        throw it if it
        cb!

  extract: (options = {}, cb) ->
    { archive, dest } = options if options
    archive ||= findup '*.nar'
    archive = archive[0] if archive |> hu.is-array
    throw new Error 'Cannot find nar archive' unless archive

    @output = dest ||= process.cwd!
    tmp = @tmp-dir

    mk dest unless @exists dest

    extract { archive, dest: tmp, gzip: yes }, ->
      nar = "#{tmp}/.nar.json" |> read
      copy "#{tmp}/.nar.json", dest, ->
        extract-files nar.files, cb

    #clean = ~> @clean!
    on-err = (cb) -> ->
      cb!
      #clean!
      throw it if it

    extract-files = (files, cb) ->
      async.each files, ((file, done) ->
        archive = path.join tmp, file.archive
        checksum archive, (err, hash) ->
          if hash is file.checksum
            cwd = path.join dest, file.dest
            mk cwd
            if file.type is 'binary'
              copy archive, cwd, -> done!
            else
              extract { archive, dest: cwd }, on-err done
          else
            throw new Error "Checksum verification was failed for archive '#{file.archive}'"
        ), on-err cb

copy = (file, dest, cb) ->
  filename = file |> path.basename
  dest = filename |> path.join dest, _
  (fs.create-read-stream file)
    .pipe(fs.create-write-stream dest)
    .on('error', -> throw it)
    .on('close', -> cb dest)

get-pkg-path = ->
  it |> path.join pkg-dir, _

random = ->
  new Date!get-time! + (Math.floor Math.random! * 10000)
