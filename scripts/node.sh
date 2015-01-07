#!/usr/bin/env bash

# make binary dependencies PATH accessible
export PATH="$(pwd)/node_modules/.bin:${PATH}"

# define node lookup global path for modules resolution
# if the nar package has global dependencies embedded
if [ -d "$(pwd)/.node/lib/node" ]; then
  export NODE_PATH="$(pwd)/.node/lib/node"
fi

# expose embedded node binary in path
if [ -f "$(pwd)/.node/bin/node" ]; then
  export PATH="$(pwd)/.node/bin:${PATH}"
  chmod +x "$(pwd)/.node/bin/node"
  "$(pwd)/.node/bin/node" $@
else
  node $@
fi
