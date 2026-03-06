#!/usr/bin/env bash

if [[ "$#" != 1 || ! -d $1 ]]; then 
    echo Uso: $(basename "${BASH_SOURCE[0]}") directorio
    exit 1
fi

basedir="$1"

find "$basedir" -name "*.json" -type f | while read -r file; do
    printf "."
    if jq . "$file" > "$file.tmp" 2> error.log; then
        mv "$file.tmp" "$file"
    else
        echo "FALLO en: $file" >> check-and-prettify.log
        cat error.log >> check-and-prettify.log
        rm -f "$file.tmp"
    fi
done
printf "\nFinalizado %s\n" "$(date)"
