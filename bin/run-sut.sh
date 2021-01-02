#!/bin/sh

set -e

# run-sut.sh: Script to run system unit tests.

rc="0"

server="10.30.50.2"
[ -n "$1" ] && server="$1"

# The following tests query the server to verify that it is running and syncing with its pool servers.

echo "INFO: Beginning tests for server $server."

# Expect an error getting a nonexistant file.
if [ -z "$(tftp -4 $server -c get /nonexistantfile)" ]; then
  echo "ERROR: Getting non-existant file did not fail."
  rc="1"
fi

# Expect an error getting another nonexistant file.
rm -f /var/tftpboot/sample.txt
if [ -z "$(tftp -4 $server -c get /sample.txt)" ]; then
  echo "ERROR: Getting another non-existant file did not fail."
  rc="1"
fi

# Place a sample file into the shared data volume
cat >/var/tftpboot/sample.txt <<-__EOF__
	This is some text data.
	This is more text data.
	Finally, the last line of data!
	__EOF__

# Expect No error getting the file we just place on the shared data volume.
if [ -n "$(tftp -4 $server -c get /sample.txt)" ]; then
  echo "ERROR: Getting existing file failed."
  rc="1"
fi

# Files should be identical.
touch sample.txt
if ! diff /var/tftpboot/sample.txt sample.txt ; then
  echo "ERROR: Contents of retrieved file do not match expected contents."
  rc="1"
fi

if [ "$rc" != "0" ]; then
  echo "ERROR: Some or all tests failed!"
else
  echo "INFO: All tests passed!"
fi

exit $rc

