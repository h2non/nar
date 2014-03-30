require! {
  fs
  path
}

{ env, platform, exit } = process

module.exports = _ = {

  path, platform

  echo: -> console.log ...

  env: (key) -> env[key] or null

  exit: (code) ->
    if code is 0 or not code
      code |> exit
    # if exit code is not 0, return a partial function
    (message) ->
      if message?
        message = message.red if String::red?
        message |> _.echo
      code |> exit

  exists: ->
    it and (it |> fs.exists-sync)

  is-dir: ->
    (it |> _.exists) and (it |> fs.lstat-sync).is-directory!

  is-file: ->
    (it |> _.exists) and (it |> fs.lstat-sync).is-file!

}
