#!/bin/bash
##########################################################################
# Removes encryption from PDF bank statements generated by some banks and
# credit unions.
# The encryption targetted for removal serves no practical purpose other
# than to show the integrity of the original file.
# As such it can prevent copying of the file content and file indexing.
##########################################################################
# Date:    08 September 2016
# Author:  Tomas Kuchta
# License: Creative Commons CC0
#          https://creativecommons.org/publicdomain/zero/1.0/legalcode
##########################################################################
# Usage:
# decryptPdfs.bash [directoryName] [directoryName] ..
#
# Description:
# Tries to decrypt all PDF files located in list of directoryNames
# If no directory name is given, it searches current directory for
# any encrypted PDF files.
#
# Requires:
# qpdf
#   install by:
#     Ubuntu:   apt-get install qpdf
#     openSuSE: zypper  install qpdf
##########################################################################

qpdfExists=$( which qpdf | wc -l )
if (( $qpdfExists == 0 )); then
  echo "ERROR: Missing qpdf package. Please install it."
  exit 1
fi

function isPdf () {
  # prints 1 if file is pdf else 0
  local retVal
  retVal=$( qpdf --check "$1" 2>&1 | awk '/: not a PDF file/ {print 0} /PDF Version: / {print 1}' )
  echo $retVal
}
function isEncrypted () {
  # prints 1 if pdf file is encrypted else 0
  local retStr
  local retVal
  retStr=$( qpdf --show-encryption "$1" | head -n 1 )
  retVal=$( echo $retStr | awk '/File is not encrypted/ {print 0} /R = [0-9]/ { print 1}' )
  echo $retVal
}

if (( $# == 0 )); then
  # Create command finding all pdf files in current directory
  searchCmd="find ./ -type f -name '*.pdf'"
else
  # Create command finding all pdf files in given directory or dir list
  searchCmd="for i in $*; do if [ -d \$i ]; then find \$i -type f -name '*.pdf'; fi done"
fi

fileCount=$( eval $searchCmd | wc -l )
fileCounter=1

eval $searchCmd | while read ln; do
  echo -ne "Scanning file: $fileCounter/$fileCount\r"
  isPdf=$( isPdf "$ln" )
  if (( $isPdf == 1 )); then
    isEncrypted=$( isEncrypted "$ln" )
    #echo "isEncrypted \"$ln\": $isEncrypted"
    if (( $isEncrypted == 1 )); then
      #echo
      echo "INFO: Decrypting file $fileCounter/$fileCount: $ln"
      mv $ln $ln.bak
      qpdf --decrypt $ln.bak $ln
      if [ -f $ln ]; then
        rm $ln.bak
      else
        echo "WARNING: Could not decrypt file $fileCounter/$fileCount: $ln"
        mv $ln.bak $ln
      fi
    fi
  fi
  fileCounter=$(( $fileCounter + 1 ))
done
echo

exit 1

# Notes:
# ------
#  qpdf --decrypt inFile outFile
#  
#  qpdf --check pdfFile
#  #  pdfFile: not a PDF file
#  
#  #  PDF Version: 1.3
#  #  R = 2
#  #  P = -60
#  #  User password = 
#  #  extract for accessibility: not allowed
#  #  extract for any purpose: not allowed
#  #  print low resolution: allowed
#  #  print high resolution: allowed
#  #  modify document assembly: not allowed
#  #  modify forms: not allowed
#  #  modify annotations: not allowed
#  #  modify other: not allowed
#  #  modify anything: not allowed
#  #  File is not linearized
#  #  No syntax or stream encoding errors found; the file may still contain
#  #  errors that qpdf cannot detect
#  
#  qpdf --show-encryption pdfFile
#  #  File is not encrypted
#  
#  #  R = 2
#  #  P = -60
#  #  User password = 
#  #  extract for accessibility: not allowed
#  #  extract for any purpose: not allowed
#  #  print low resolution: allowed
#  #  print high resolution: allowed
#  #  modify document assembly: not allowed
#  #  modify forms: not allowed
#  #  modify annotations: not allowed
#  #  modify other: not allowed
#  #  modify anything: not allowed
