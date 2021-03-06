#! /usr/bin/bash
#Brown.LiuZan@copyright
#Version: 1.0
#Date: 2019-13-14
#Description: Counting lines of interested files in given directory.


#Imports.
source color.sh


#Global parameters.
#LZDEBUG=false
LZDEBUG=true


#Main logic.
if ${LZDEBUG}; then
    print_blue "arguments number: $#"
fi

gDirectory=`pwd`
if [[ $# -lt 1 ]]; then
    print_red "Usage: dlc.sh <FilePattern> [Directory]"
    exit -1
fi
gFilePattern=$1
if [[ $# -gt 1 ]]; then
	gDirectory=$2
fi
if [[ ! -d ${gDirectory} ]]; then
    print_red "${gDirectory} not existed."
    print_red "Usage: dlc.sh <FilePattern> [Directory]"
    exit -1
fi

print_blue "Counting lines of files matched by '${gFilePattern}' in '${gDirectory}'"

find ${gDirectory} -name "${gFilePattern}" | xargs wc -l
