#!/bin/bash
# This script scands I/O commands to the virtual device in order to test the server's logic

# Make sure to clean all files left on the block device in case of logic failure
trap "rm /mnt/ramdisk_test/testfile* 2>/dev/null; exit" SIGINT SIGTERM

# Parameter number 1 is the number of iterations
if [ $# -gt 0 ]; then
	NUMBER_OF_ITERATIONS=$1
fi

# This function creates temp files on our mount point
function makeTempFiles
{
	mktemp -p /mnt/ramdisk_test testfile.XXXXXXXX &
}

# Make sure that files will be created simulataneously,
# if parameter was given it will run the given number
if [[ $NUMBER_OF_ITERATIONS =~ ^[0-9]+$ ]]; then
	for index in $(seq 1 $NUMBER_OF_ITERATIONS); do
		makeTempFiles &
	done
else
	while true; do
		makeTempFiles &
	done
fi
