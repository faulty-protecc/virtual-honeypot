#!/bin/bash
# This script scands I/O commands to the virtual device in order to test the server's logic

# Make sure to clean all files left on the block device in case of logic failure
trap "rm /mnt/ramdisk_test/testfile* 2>/dev/null; exit" SIGINT SIGTERM

# This function creates temp files on our mount point
function makeTempFiles
{
	mktemp --dry-run -p /mnt/ramdisk_test testfile.XXXXXXXX &
}

# Make sure that files will be created simulataneously
while true; do
	makeTempFiles &
done
