#!/bin/sh

export PATH="$(pwd)/node_modules/.bin:${PATH}"

if [ -d "$(pwd)/.node/lib/node" ]; then
  export NODE_PATH="$(pwd)/.node/lib/node"
fi

if [ -f "$(pwd)/.node/bin/node" ]; then
  export PATH="$(pwd)/.node/bin:${PATH}"
  chmod +x "$(pwd)/.node/bin/node"
  "$(pwd)/.node/bin/node" "$@"
else
  node "$@"
fi
