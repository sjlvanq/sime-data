#!/usr/bin/env bash

if [[ "$#" != 1 || ! -d $1 ]]; then 
    echo Uso: $(basename "${BASH_SOURCE[0]}") directorio
    exit 1
fi

basedir="$1"

function process_file() {
    local file="$1"
    local tmp_err=$(mktemp) #Evita colisiones
    printf "."
    if jq . "$file" > "$file.tmp" 2> "$tmp_err"; then
        mv "$file.tmp" "$file"
    else 
        {
            echo "FALLO en: $file"
            cat "$tmp_err"
        } >> check-and-prettify.log
        rm -f "$file.tmp"
    fi
    rm -f "$tmp_err"
}
export -f process_file

echo "Procesando archivos JSON en '$basedir'..."
find "$basedir" -name "*.json" -type f -print0 | \
        xargs -0 -I {} -P $(nproc) bash -c 'process_file "$@"' _ {}

printf "\nFinalizado %s\n" "$(date)"
