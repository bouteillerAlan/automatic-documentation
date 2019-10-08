#!/bin/bash
#####################################
## nldr
# allows to find a comment in each file for a project and auto generate the documentation
# for the moment the format is "\\ comment", before the function, on one line or multi line
# markdown is fully functionnal, just use it in the comment line (// ## title lvl2)
## example a
# 1 // this function make something great (great:string)
# 2 async function(great: string) {
# 3 ... some code
## example b
# 1 // this function make something great (great:string)
# 2 // other line of comment
# 3 async function(great: string) {
# 4 ... some code
#####################################

# go to src or exit
cd "$(pwd)"/src || exit

# remove content
: > generated_documentation.md

# search comment and stock it
grep -ri -A1 "// " * > tmp.md

# set style
old_IFS=$IFS
IFS=$'\n'
fileName=''
for line in $(cat tmp.md)
do

  ### stock file name
  fileNameCheck=$(echo "${line}" | grep -o '^.*[.][a-z]*[:||-]')
  fileNameCheck=${fileNameCheck//[:||-]/}
  # if the file name is egal to the precedent make nothing
  # else stock it
  if [ "$fileNameCheck" ] && [ "$fileName" != "$fileNameCheck" ] ; then
    echo "# ${fileNameCheck}" >> generated_documentation.md
    fileName=$fileNameCheck
  fi

  ### clean
  # remove command log and replace by nothing
  line=${line//*.ts[:||-][' '][' '][' '][' ']/}
  # remove tab comment
  line=${line//[' ']['// ']/}
  # remove comment slash
  line=${line//'// '/}

  ### markdown it
  # suppress last { on line function (the line after the last // ) (in example a is line 2, in example b is line 3)
  if [ "${line: -1}" = "{" ] ; then
    newLine=" \`\`\` ${IFS}${line::-1}${IFS} \`\`\` "
  else
    newLine="${line}"
  fi
  # suppress bad log line
  if [ "${newLine}" = "--" ] ; then
    newLine=''
  fi
  echo "${newLine}${IFS}" >> generated_documentation.md
done
IFS=$old_IFS

# remove temporary file and exit
rm tmp.md
exit
