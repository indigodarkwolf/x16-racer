#!/bin/bash

printusage() {
cat - <<EOF
$0 [-f filename] [-s size-in-megabytes] [-d copy-source-directory] [-v]

Creates, partitions, formats, and optionally copies files from a directory
into a FAT32-partitioned SD card image of a specified size.

Mandatory parameters:
  -f        Filename of SD card image
  -s        Size of the SD card image, in MiB (1024*1024 bytes)

Optional parameters:
  -d        Source directory, from which all files will be copied into
            the SD card image. If omitted, no files will be copied into
            the image, it will be left empty.
  -v        Verbose mode. If omitted, all output from commands in this
            script will be redirected to /dev/null.

To create an empty 64 MiB SD card image:
$0 -f card.img -s 64

To create a 64 MiB file and fill it with the contents of ./build:
$0 -f card.img -s 64 -d ./build

EOF
}

# print usage if we don't have the right number of arguments
if (($# < 4 )); then
    printusage
    exit 0
fi
verbose=false
docopy=false
while getopts "f:s:d:v" opts; do
    case $opts in
        f )  diskimg="$OPTARG"
             ;;
        s )  size="$OPTARG"
             ;;
        d )  input="$OPTARG"
             docopy=true
             ;;
        v )  verbose=true
             ;;
        * )  printusage
             exit 0
             ;;
    esac
done

if [ -z ${diskimg+x} ]; then
    printusage
    exit 0
fi

if [ -z ${size+x} ]; then
    printusage
    exit 0
fi

alignment=1048576
size=$((size *(1<<20)))
size=$(( (size + alignment - 1)/alignment * alignment))

# create the file
printf "Creating ${diskimg} ... "
truncate -s $((size + 2*alignment)) "${diskimg}"
echo "OK"

# partition the file
printf "Partitioning ${diskimg} ... "
if [ ${verbose} = true ] ; then
    echo ""
    echo ',,c;' | /sbin/sfdisk ${diskimg}
else
    echo ',,c;' | /sbin/sfdisk ${diskimg} >& /dev/null
    echo "OK"
fi

# create the filesystem
printf "Formatting ${diskimg} ... "
mformat -F -i ${diskimg}@@$alignment
echo "OK"

# copy files
if [ ${docopy} = true ] ; then
    printf "Copying files to ${diskimg} ... "
    if [ ${verbose} = true ] ; then
        echo ""
        mcopy -D o -i ${diskimg}@@$alignment ${input}/* ::
        mdir -i ${diskimg}@@$alignment
    else
        mcopy -D o -i ${diskimg}@@$alignment ${input}/* :: >& /dev/null
        echo "OK"
    fi
fi
