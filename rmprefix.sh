#! /usr/bin/bash
#Brown.LiuZan@copyright
#Version:1.0
#Date:20190727
#Description: Remove specified prefix from all files in given directory.


#Imports.
source color.sh
source path.sh


#Global parameters.
#LZDEBUG=false
LZDEBUG=true


function Usage() {
    local vMsg="Usage: rmprefix.sh <Prefix> [DirName]"
    print_bold_green "${vMsg}"
    vMsg="    DirName defaults to current directory."
    print_bold_green "${vMsg}"
    exit 1
}

#Main logic.
if [[ $# -lt 1 || $# -gt 2 ]]; then
    Usage
elif [[ $# -eq 1 ]]; then
    DIR=`pwd`
else
    DIR=$2
fi
PREFIX=$1
if [[ ! -d ${DIR} ]]; then
    print_bold_red "Directory not found: ${DIR}"
    exit 1
fi

gFileList=`GetFileList ${DIR}`
echo "file number: ${#gFileList[@]}"
for i in ${gFileList[@]}; do
    if [[ $i =~ ^${PREFIX}.+ ]]; then
	echo $i
        mv $i ${i/#${PREFIX}}
    fi
done

