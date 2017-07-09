# decryptPdfs
Removes encryption from PDF bank statements generated by some banks and
credit unions.

The encryption targetted for removal serves no practical purpose other
than to show the integrity of the original file.

As such it can prevent copying of the file content and file indexing.

# Usage:
decryptPdfs.bash [directoryName] [directoryName] ..

Description:
Tries to decrypt all PDF files located in list of directoryNames
If no directory name is given, it searches current directory for
any encrypted PDF files.

Requires:
qpdf
  install by:
    Ubuntu:   apt-get install qpdf
    openSuSE: zypper  install qpdf
