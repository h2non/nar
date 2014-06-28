#/bin/bash
##nar##

output="`pwd`/.nar"

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
${output}/bin/node ${output}/nar/bin/nar $* ${output}/${nar_file}

exit $?

__END__
