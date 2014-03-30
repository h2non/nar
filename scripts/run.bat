@ECHO OFF

PATH="%~dp0\node_modules\.bin:%PATH%"

@IF EXIST "%~dp0\.node\bin\node.exe" (
  "%~dp0\.node\bin\node.exe" %*
) ELSE (
  node %*
)
