#/bin/bash

output=$1
log=nar-debug.log

die() {
  echo "Error: $*"
  exit 1
}

if [ -z `which tar` ]; then
  die 'tar is not found or $PATH available'
fi

if [ -z $output ]; then
  output=`pwd`
else
  if [ -f $output ]; then
    die 'output path cannot be a file'
  fi
fi

[[ ! -d $output ]] && mkdir $output

echo 'Extracting...'

skip=`awk '/^__END__/ { print NR + 1; exit 0; }' $0`
tail -n +$skip $0 | tar -xz -C $output

exit $?

__END__
