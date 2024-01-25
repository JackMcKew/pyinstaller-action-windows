#!/bin/bash

# Fail on errors.
set -e

SRCDIR=$1

DIRS=$2

# DIRS will receive a list of directories to be processed in
# the form of a string, e.g. "dir1 dir2/subdir2 file1.txt dir3/file3.txt"
# those can be separated by comas or newlines.
# the output need to be in the format: "--add-data $SRCDIR/$dir1/:dir1/"
# so that pyinstaller can process it correctly.
# the output will be in the form of a string, e.g.
# "--add-data /src/dir1/:dir1/ --add-data /src/dir2/subdir2/:dir2/subdir2/ --add-data /src/file1.txt:file1.txt"

# A string de saída
OUTPUT=""

# Verifica se DIRS está vazio ou não fornecido
if [ ! -z "$DIRS" ]; then

    # Processa cada diretório na string DIRS
    for dir in $DIRS; do
        # Adiciona o diretório formatado à string de saída
        OUTPUT+="--add-data $SRCDIR/$dir:$dir "
    done
    # Remove o espaço extra no final da string de saída
    OUTPUT=${OUTPUT::-1}
fi


# Imprime a string de saída
echo $OUTPUT