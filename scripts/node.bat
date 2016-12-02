@ECHO OFF

SETLOCAL ENABLEDELAYEDEXPANSION
PATH="%~dp0\node_modules\.bin:%PATH%"

@IF EXIST "%~dp0\.node\lib\node" (
  NODE_PATH="%~dp0\.node\lib\node"
)
ENDLOCAL

SETLOCAL ENABLEDELAYEDEXPANSION
@IF EXIST "%~dp0\.node\bin\node.exe" (
  echo Using embedded node.exe
  PATH="%~dp0\.node\bin:%PATH%"
  "%~dp0\.node\bin\node.exe" %*
) ELSE (
  echo Using system node
  node %*
)
ENDLOCAL
