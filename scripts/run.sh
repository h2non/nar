#!/bin/sh

cwd=$(pwd)
basedir=`dirname "$0"`

export PATH="${cwd}/node_modules/.bin:${PATH}"

case `uname` in
    *CYGWIN*) basedir=`cygpath -w "$basedir"`;;
esac

if [ -f "${cwd}/.node/bin/node" ]; then
  chmod +x "${cwd}/.node/bin/node"
  "${cwd}/.node/bin/node" "$@"
else
  node "$@"
fi
