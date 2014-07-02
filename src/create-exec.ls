require! {
  fw
  path
  ncp.ncp
  './pack'
  './create'
  child_process.exec
  events.EventEmitter
}
{ dirname, join, basename } = path
{ rm, mk, is-win, tmpdir, copy, exists, once, extend, handle-exit, get-platform, arch } = require './utils'

const script = __dirname |> join _, '..', 'scripts/run.sh'
const download-url = 'http://nodejs.org/dist'
const supported-platforms = <[ linux darwin sunos ]>
const supported-archs = <[ x86 x64 ]>
const supported-versions = [ /^0.8/, /^0.10/ ]

module.exports = (options) ->
  emitter = new EventEmitter
  options = options |> apply
  dest = options.dest or process.cwd!
  tmp-path = tmpdir!
  options.dest = tmp-path

  clean = ->
    emitter.emit 'message', 'Cleaning temporary directories'
    try rm tmp-path

  on-error = once (err) ->
    clean!
    err |> emitter.emit 'error', _

  on-entry = ->
    it |> emitter.emit 'entry', _ if it

  on-end = ->
    clean!
    it |> emitter.emit 'end', _

  on-create-end = (nar-path) ->
    nar-path |> create-executable

  create-executable = (nar) ->
    nar-file = nar |> basename _, '.nar'
    nar-path = (dest |> join _, nar-file) + '.run'
    nar-output = (dest |> join _, nar-file) + "-#{get-platform!}-#{arch}.nar"

    clean-exec = ->
      nar-path |> rm
      clean!

    copy-binary = (done) ->
      bin-dir = tmp-path |> join _, 'bin'
      mk bin-dir
      copy process.execPath, bin-dir, done

    copy-nar-pkg = (done) ->
      dest = tmp-path |> join _, 'nar'
      nar-path = __dirname |> join _, '..'
      ncp nar-path, dest, done

    create-tarball = (done) ->
      const config =
        name: nar |> basename _, '.nar'
        dest: dest
        patterns: [ '**' ]
        src: tmp-path
        ext: 'run'
        gzip: yes

      pack config
        .on 'error', done
        .on 'entry', on-entry
        .on 'end', (file) -> done!

    create-binary = (done) ->
      exec "cat #{script} #{nar-path} > #{nar-output}", done

    fw.parallel [ copy-binary, copy-nar-pkg ], (err) ->
      return new Error 'cannot copy files to temporal directory' |> on-error if err
      fw.series [ create-tarball, create-binary ], (err) ->
        return new Error 'cannot create the executable' |> on-error if err
        clean-exec!
        emitter.emit 'end', nar-output

  return new Error 'Windows platform cannot create nar executables' |> on-error if is-win

  mk tmp-path
  clean |> handle-exit

  (options |> create)
    .on 'error', on-error
    .on 'entry', on-entry
    .on 'end', on-create-end
    .on 'start', -> 'start' |> emitter.emit
    .on 'archive', -> 'archive' |> emitter.emit _, it

  emitter

apply = (options) ->
  options |> set-os
  options |> set-arch
  options |> set-node
  options

find-index = (arr, item) ->
  arr.index-of(os) isnt -1

match-version = (version) ->
  (supported-versions.filter -> it.test version).length isnt 0

set-os = (options) ->
  { os } = options
  if os
    if (supported-platforms |> find-index _, os)
      options <<< os: os
    else
      throw new Error "Invalid OS platform '#{os}'. Only #{supported-platforms.join ', '} are supported"
  else
    options <<< os: process.platform

set-arch = (options) ->
  { arch } = options
  if arch
    if (supported-archs |> find-index _, arch)
      options <<< arch: arch
    else
      throw new Error "Invalid architecture '#{arch}'. Only x86 or x64 are supported"
  else
    options <<< arch: process.arch

set-node = (options) ->
  { node } = options
  if node
    if node is 'latest'
      options <<< node: 'latest'
    else if (node |> match-version)
      options <<< node: "v#{node}"
    else
      throw new Error "Invalid node version '#{node}'"
  else
    options <<< node: process.version
