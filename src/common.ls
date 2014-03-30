require! {
  path
  _: 'hu'
}

{ env, platform, exit } = process

module.exports = class common

  @_ = _

  @path = path

  @is-win32 = platform is 'win32'

  @is-darwin = platform is 'darwin'

  @is-linux = platform is 'linux'

  @echo = -> console.log ...

  @env = (key) -> env[key] or null

  @user-home = ~> (env[(if @is-win32 then 'USERPROFILE' else 'HOME')] or '') |> path.normalize

  @exit = (code) ~>
    if code is 0 or not code
      code |> exit
    # if exit code is not 0, return a partial function
    (message) ~>
      if message?
        message = message.red if String::red?
        message |> @echo
      code |> exit
