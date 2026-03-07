#!/usr/bin/env bash
BASE_URL="https://sime.educaciontuc.gov.ar/Vacantes"

if [[ "$#" != 1 || ! -d $1 ]]; then 
    echo Uso: $(basename "${BASH_SOURCE[0]}") directorio
    exit 1
fi

basedir="$1"

find "./$basedir" -name "*.errout" -type f | while read -r error_file; do
    context=$(basename "$(dirname "$error_file")")
    json_file="${error_file%.errout}"
    #vacante_id=$(basename "$json_file" .json)
    vacante_id=$(basename "$error_file" .json.errout)
    
    printf "Reintentando %s \t" $(dirname $error_file)/$vacante_id
    if [[ "$error_file" == *"padrones"* ]]; then
        endpoint="ObtenerPadrones"
    else
        endpoint="ObtenerDetalleVacante"
    fi

    rm -f "$error_file" "$json_file"
    if curl -f --no-progress-meter "$BASE_URL/$endpoint/$vacante_id" -o "$json_file" 2> "$error_file"; then
        rm -f "$error_file"
        printf "EXITO\n"
    else
        printf "FALLÓ (Log: %s)\n" "$(basename "$error_file")"
    fi
done
