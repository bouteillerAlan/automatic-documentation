#!/bin/bash

# todo
# remove text after ( in the function name >> echo $var | sed "s/(.*//"
# set returns in code but not the params; for the param set the name of the params
# italic the types

# init var
fileName=''
subLine=''
lines=()

# utility function for exit if file doesn't exist
exitNoFile () {
  echo -e "\e[1;31mFolder doesn't exist\e[0m" && exit
}

setFile () {
  # $1 param is the title

  # the title line is the ending line so put all the thing in order
  title=$(echo "${1}" | sed "s/(.*//")
  {
    # ---
    # echo "${IFS}${separationLine}"
    # function()
    echo "${title}"
  } >> "${finalFilename}".md

  linesWithNoDesc=()
  # param & returns
  for line in "${lines[@]}"
  do
    # trim the line
    modLine=$(echo "${line}" | sed "s/^[ \t]*//;s/[ \t]*$//")
    # if the line start by @ this is not the description
    if [[ "${modLine}" == "@"* ]] ; then
      # this is not the description
      # replace he @ by ```
      modLine="${line//\@/\`}"
      # replace { by ```  surrounding the type
      modLine="${modLine//\{/\` }"
      # remove } surrounding the type
      modLine="${modLine//\}/}"
      # remove * @
      modLine="${modLine//\*\@/}"
      linesWithNoDesc+=("${modLine}")
    else
      # this is the description
      # put the description
      echo "${modLine}${IFS}" >> "${finalFilename}".md
    fi

  done

  # subTitle
  echo "${subLine}" >> "${finalFilename}".md
  for line in "${linesWithNoDesc[@]}"
  do
    # put the line
    echo "${line}${IFS}" >> "${finalFilename}".md
  done

  # ---
  echo "${separationLine}" >> "${finalFilename}".md

  # and delete the array
  unset lines
  unset linesWithNoDesc
}

core () {
  echo -e "\e[1;34m▶️ Run core function\e[0m"
  # go to folder or exit
  cd "$pathRead" || exitNoFile

  # timestamp for the file name
  timestamp=$(date +%d%m%y-%H%M%S)
  # final filename
  finalFilename=generated_documentation-"${timestamp}"
  # set the date
  echo "> generated @ ${timestamp}" > "${finalFilename}".md

  # search jsdoc comment and stock it
  grep -zroP '(?m)/\*\*$\n?|^\h+\*\h.*$\n?|^\h+\*/$\n?|(?<=\*/\n)(?:\h+@.*\n)*\K.+\n?' * > tmp"${timestamp}".txt

  # set style
  old_IFS=$IFS
  IFS=$'\n'
  for line in $(cat tmp"${timestamp}".txt)
  do

    ### stock file name
    fileNameCheck=$(echo "${line}" | grep -o '^.*[.][a-z]*[:||-]')
    fileNameCheck=${fileNameCheck//[:||-]/}
    # if the file name is equal to the precedent make nothing
    # else stock it
    if [ "$fileNameCheck" ] && [ "$fileName" != "$fileNameCheck" ] ; then
      echo "# ${fileNameCheck}" >> "${finalFilename}".md
      fileName=$fileNameCheck
    fi

    ### clean
    # line without the file-name:
    line=$(echo "$line" | grep -oP '(?:.+\.\w+:\s*)\K.+')

    ### markdown it
    # if last character is { this is the last line
    if [ "${line: -1}" = "{" ] ; then
      title="## ${line::-1}${IFS}"
      setFile "${title}"
    elif [ "${line}" = "/**" ] ; then
      subLine=("### Attributes${IFS}")
    elif [ "${line}" = "*/" ] ; then
      separationLine=("---${IFS}")
    else
      # delete the first *
      lines+=("${line/\*/}")
    fi

  done

  IFS=$old_IFS

  # remove temporary file and exit
  rm tmp"${timestamp}".txt

  echo -e "\e[1;34m🖖️ Done\e[0m"
  exit
}

# answer the input file/folder & the output file
answer () {
  # answer a path
  echo -e "\e[1;34mWhere do you want to run the script? A folder is ok not a file.\e[0m"
  read -rp "📂 > " pathRead
  echo -e "\e[1;34mWhere do you want the doc to be saved?\e[0m"
  read -rp "📑 > " pathWrite

  while true
  do
    echo -e "\e[1;34mYou have chosen \"$pathRead\" for read and \"$pathWrite\" for write; this is ok ?\e[0m"
    read -rp "💬 [y][n] > " response

    case $response in
     [yY]* ) echo -e "\e[1;32m🛩️ Okay, ran script.\e[0m"
             core;;
     [nN]* ) answer;;
     * )     echo -e "\e[1;31mJust enter Y or N, please.\e[0m";;
    esac
  done
}

answer
