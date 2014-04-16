@ECHO OFF

PATH="%~dp0\node_modules\.bin:%PATH%"

@IF EXIST "%~dp0\.node\lib\node" (
  NODE_PATH="%~dp0\.node\lib\node"
)

@IF EXIST "%~dp0\.node\bin\node.exe" (
  PATH="%~dp0\.node\bin:%PATH%"
  "%~dp0\.node\bin\node.exe" %*
) ELSE (
  node %*
)
