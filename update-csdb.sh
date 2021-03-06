#! /usr/bin/bash
#Brown@copyright
#Version: 1.0
#Date: 20180614
#Description: Used to create/update and install the cscope database of a special kind of source files under specified diretory.


#Imports
source color.sh


#Global parameters.
#LZDEBUG=false
LZDEBUG=true


#Main logic.
if [[ -z "${LZHOME}" ]]; then
    print_blinking_red "LZHOME undefined."
    exit 1
fi

echo "===>Try to make sure tag directory to exist."
TagsDir=${LZHOME}/CscopeAndCtags
if [[ ! -d ${TagsDir} ]]; then
    mkdir ${TagsDir}
fi
if [[ ! -d ${TagsDir} ]]; then
    echo "${TagBuldDir} doesn't exist and failed to create it." 1>&2
    exit 1
fi
if ${LZDEBUG}; then
    echo "TagsDir=${TagsDir}"
fi
echo -e "===>Done\n"

#Usage check and argument handle
echo "===>Try to check/parse arguments and collect source files."
usage ()
{
    echo -e "Usage:\n\tupdate-csdb.sh <c|b|p> SrcDir" 1>&2
    echo -e "Note:\n\tc\tC and C++ source files\n\tb\tbash scripts\n\tp\tPython scripts" 1>&2
    echo -e "\tRootDir\tthe root directory to create/update cscope dababse" 1>&2
    exit 1
}
if [[ ${#@} -ne 2 ]]; then
    usage
else
    if [[ ! -d $2 ]]; then
        echo -e "$2: invalid source file  directory." 1>&2
        usage
    fi
    if [[ -n $(whereis readlink) ]]; then
        SrcDir=$(readlink -f $2)
    elif [[ -n $(whereis readpath) ]]; then
        SrcDir=$(readpath -f $2)
    else
        echo -e "Only support CentOS and Ubuntu family OSes.\n" 1>&2
        exit 1
    fi
    if ${LZDEBUG}; then
        echo "SrcDir=${SrcDir}"
    fi
    BaseName=$(basename ${SrcDir}).$1
    SrcFiles=${BaseName}.csf
    if [[ -f ${TagsDir}/${SrcFiles} ]]; then
        mv ${TagsDir}/${SrcFiles} ${TagsDir}/${SrcFiles}.bak
    fi
    case $1 in
    'c')
        CtagLangId=C,C++
        echo "Try to create C/C++ source file list for updating cscope database of $2"
        $(find ${SrcDir} -regextype posix-extended \
            -regex '.*\.(h|hpp|c|cc|cpp|cxx)' \
            -type f > ${TagsDir}/${SrcFiles});;
    'b')
        CtagLangId=Sh
        echo "Try to create C/C++ source file list for updating cscope database of $2"
        $(find ${SrcDir} -name '*.sh' -type f > ${TagsDir}/${SrcFiles});;
    'p')
        CtagLangId=Python
        echo "Try to create C/C++ source file list for updating cscope database of $2"
        $(find ${SrcDir} -name '*.py' -type f > ${TagsDir}/${SrcFiles});;
    'm')
        CtagLangId=Make
        echo "Try to create make source file list for updating cscope database of $2"
        $(find ${SrcDir} -regextype posix-extended -regex 'GNUmakefile|makefile|Makefile' -type f \
        > ${TagsDir}/${SrcFiles});;
    *)
        usage;;
    esac
    if [[ -f ${TagsDir}/${SrcFiles} ]]; then
        if [[ -f ${TagsDir}/${SrcFiles}.bak ]]; then
            rm -f ${TagsDir}/${SrcFiles}.bak
        fi
        ls -lh ${TagsDir}/${SrcFiles}
    else
        echo -e "Failed to create/update a source file list for cscope.\n" 1>&2
        exit 1
    fi
fi
echo -e "===>Done\n"

#Generate cscope database file.
echo "===>Try to generate/update cscope database file."
cd ${TagsDir}
if ${LZDEBUG}; then
    echo "CWD=`pwd`"
fi
if [[ -f cscope.out || -f cscope.in.out || -f cscope.po.out ]]; then
    rm -f cscope*.out
fi
if [[ -f ${TagsDir}/${BaseName}.cscope.out ]]; then
    mv ${TagsDir}/${BaseName}.cscope.out ${TagsDir}/${BaseName}.cscope.out.bak
fi
if [[ -f ${TagsDir}/${BaseName}.cscope.in.out ]]; then
    mv ${TagsDir}/${BaseName}.cscope.in.out ${TagsDir}/${BaseName}.cscope.in.out.bak
fi
if [[ -f ${TagsDir}/${BaseName}.cscope.po.out ]]; then
    mv ${TagsDir}/${BaseName}.cscope.po.out ${TagsDir}/${BaseName}.cscope.po.out.bak
fi
cscope -bqk -i ${TagsDir}/${SrcFiles}
if [[ -f cscope.out && -f cscope.in.out && -f cscope.po.out ]]; then
    mv cscope.out ${TagsDir}/${BaseName}.cscope.out
    mv cscope.in.out ${TagsDir}/${BaseName}.cscope.in.out
    mv cscope.po.out ${TagsDir}/${BaseName}.cscope.po.out
    if [[ -f ${TagsDir}/${BaseName}.cscope.out &&
          -f ${TagsDir}/${BaseName}.cscope.in.out &&
          -f ${TagsDir}/${BaseName}.cscope.po.out ]]; then
        rm -f ${TagsDir}/${BaseName}.cscope.out.bak
        rm -f ${TagsDir}/${BaseName}.cscope.in.out.bak
        rm -f ${TagsDir}/${BaseName}.cscope.po.out.bak
        ls -lh ${TagsDir}/${BaseName}.cscope*.out
    fi
    if [[ -f ${TagsDir}/${BaseName}.cscope.out.bak ]]; then
        rm -f ${TagsDir}/${BaseName}.cscopei*.out
        mv ${TagsDir}/${BaseName}.cscope.out.bak ${TagsDir}/${BaseName}.cscope.out
        mv ${TagsDir}/${BaseName}.cscope.in.out.bak ${TagsDir}/${BaseName}.cscope.in.out
        mv ${TagsDir}/${BaseName}.cscope.po.out.bak ${TagsDir}/${BaseName}.cscope.po.out
        echo -e "Failed to generate/udpate cscope database file.\n"
        exit 1
    fi
else
    if [[ -f ${TagsDir}/${BaseName}.cscope.out.bak ]]; then
        mv ${TagsDir}/${BaseName}.cscope.out.bak ${TagsDir}/${BaseName}.cscope.out
        mv ${TagsDir}/${BaseName}.cscope.in.out.bak ${TagsDir}/${BaseName}.cscope.in.out
        mv ${TagsDir}/${BaseName}.cscope.po.out.bak ${TagsDir}/${BaseName}.cscope.po.out
    fi
    echo -e "Failed to generate/update cscope database file.\n"
    exit 1
fi
cd -
echo -e "===>Done.\n"

#Install this cscope database file.
echo -e "===>Try to install the cscope database file."
LocalVimRc="${HOME}/.vimrc"
if ${LZDEBUG}; then
    echo "The local vimrc file is ${LocalVimRc}"
fi
CsDbAppendMark='" Repeat above if clause for more database files.'
cscope_section_insert()
{
    if [[ ${#@} -ne 1 ]]; then
        echo "Usage: cscope_section_insert CsDbAbsPathname" 1>&2
        exit 1
    fi
    echo >> ${LocalVimRc}
    echo -e "if has(\"cscope\") && filereadable(\"/usr/bin/cscope\")" >> ${LocalVimRc}
    echo -e "\tset csprg=/usr/bin/cscope" >> ${LocalVimRc}
    echo -e "\tset csto=0" >> ${LocalVimRc}
    echo -e "\tset cst" >> ${LocalVimRc}
    echo -e "\tset nocsverb" >> ${LocalVimRc}
    echo -e "\tif filereadable(\"$1\")" >> ${LocalVimRc}
    echo -e "\t\t\" MUST NOT quoting database file." >> ${LocalVimRc}
    echo -e "\t\tcs add $1" >> ${LocalVimRc}
    echo -e "\tendif" >> ${LocalVimRc}
    echo -e "\t${CsDbAppendMark}" >> ${LocalVimRc}
    echo -e "\tset csverb\n" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev csa cs add" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev csf cs find" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev csk cs kill" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev csr cs reset" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev css cs show" >> ${LocalVimRc}
    echo -e "\tcnoreabbrev csh cs help\n" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>s :cs find s <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>g :cs find g <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>c :cs find c <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>t :cs find t <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>e :cs find e <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>f :cs find f <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>i :cs find i <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-\\>d :cs find d <C-R>=expand(\"<cword>\")<CR><CR>\n" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>s :scs find s <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>g :scs find g <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>c :scs find c <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>t :scs find t <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>e :scs find e <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>f :scs find f <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>i :scs find i <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@>d :scs find d <C-R>=expand(\"<cword>\")<CR><CR>\n" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>s :vert scs find s <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>g :vert scs find g <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>c :vert scs find c <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>t :vert scs find t <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>e :vert scs find e <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>f :vert scs find f <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>i :vert scs find i <C-R>=expand(\"<cfile>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-@><C-@>d :vert scs find d <C-R>=expand(\"<cword>\")<CR><CR>" >> ${LocalVimRc}
    echo -e "\tnmap <C-H> <C-W><C-H>" >> ${LocalVimRc}
    echo -e "\tnmap <C-L> <C-W><C-L>" >> ${LocalVimRc}
    echo -e "\tnmap <C-J> <C-W><C-J>" >> ${LocalVimRc}
    echo -e "\tnmap <C-K> <C-W><C-K>" >> ${LocalVimRc}
    echo -e "endif" >> ${LocalVimRc}
}
cscope_section_mark()
{
    echo -n `cat ${LocalVimRc} | grep 'cscope' | grep '/usr/bin/cscope'`
}
cscope_section_csdb_mark()
{
    if [[ ${#@} -ne 1 ]]; then
        echo "Usage: cscope_section_csdb_mark CsDbAbsPathname" 1>&2
        exit 1
    fi
    echo -n `cat ${LocalVimRc} | grep -E '\bcs[[:blank:]]+add[[:blank:]]+' | grep "$1"`
}
cscope_section_csdb_insert()
{
    if [[ ${#@} -ne 1 ]]; then
        echo "Usage: cscope_section_csdb_insert CsDbAbsPathname" 1>&2
        exit 1
    fi
    if ${LZDEBUG}; then
        echo "cscope_section_csdb_mark $1= $(cscope_section_csdb_mark $1)"
    fi
    if [[ -n $(cscope_section_csdb_mark $1) ]]; then
        echo "The given cscope database file already registered in ${LocalVimRc}."
        exit 0
    fi
    TempRc=${LocalVimRc}.tmp
    while IFS= read -r line; do
        if [[ ${line} =~ ${CsDbAppendMark} ]]; then
            echo -e "\tif filereadable(\"$1\")" >> ${TempRc}
            echo -e "\t\t\" MUST NOT quoting database file." >> ${TempRc}
            echo -e "\t\tcs add $1" >> ${TempRc}
            echo -e "\tendif" >> ${TempRc}
        fi
        echo "${line}" >> ${TempRc}
    done < ${LocalVimRc}

    rm -f ${LocalVimRc}
    mv ${TempRc} ${LocalVimRc}
}
if ${LZDEBUG}; then
    echo "cscope_section_mark = $(cscope_section_mark)"
fi
if [[ -z $(cscope_section_mark) ]]; then
    echo "Insert a new cscope section in ${LocalVimRc}."
    cscope_section_insert "${TagsDir}/${BaseName}.cscope.out"
elif [[ -z $(cscope_section_csdb_mark "${TagsDir}/${BaseName}.cscope.out") ]]; then
    echo "Insert a new cscope database into cscope section in ${LocalVimRc}."
    cscope_section_csdb_insert "${TagsDir}/${BaseName}.cscope.out"
else
    echo "The target cscope database already registered in ${LocalVimRc}."
fi
echo -e "===>Done\n"
