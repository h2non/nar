#!/bin/bash
##nar##

output="`pwd`/.nar"
command=$1

die() {
  echo "Error: $*"
  exit 1
}

if [ -z `which tar` ]; then
  die 'tar binary not found or is not present in PATH'
fi

if [ -f $output ]; then
  die 'output path cannot be a file'
fi

[[ ! -d $output ]] && mkdir $output

echo 'Extracting...'

if [ -d $output ]; then
  rm -rf $output
fi
mkdir $output

skip=`awk '/^__END__/ { print NR + 1; exit 0; }' $0`
tail -n +$skip $0 | tar -xz -C $output
if [ $? != 0 ]; then
  die "cannot extract the files"
fi

export PATH="${output}/bin:$PATH"
nar_file=`cd .nar && ls *.nar | head -n 1`
chmod +x ${output}/bin/node

if [[ $command == 'exec' || -z $command ]]; then
  if [[ $command == 'exec' ]]; then 
    shift 1
  fi
  if [ $# -eq 0 ]; then 
    ${output}/bin/node ${output}/nar/bin/nar start ${output}/${nar_file}
  else
    ${output}/bin/node ${output}/nar/bin/nar start --args-start="$*" ${output}/${nar_file}
  fi
else
  ${output}/bin/node ${output}/nar/bin/nar $* ${output}/${nar_file}
fi

exit $?

__END__
