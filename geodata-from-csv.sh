#!/bin/bash
# Purpose: Get GeoData Informations from CSV
# Authors: Kyra / 4lador under Power v2.0
# ---------------------------------------------------------------------------------------- 

# Help
usage="$(basename "$0") [-f] [-a] [-p] [-t] ||[Exemple] -f raw2.csv -a ADRESSE -p CODE_POSTAL -t full"

# CommandLine Options
raw=""
adresse=""
postalcode=""
type="full"

# Temp file configuration
file=./file.csv

# Output files configuration
output=./output.csv
outputLight=./outputlight.csv

while getopts f:a:p:t:h: flag
do
    case "${flag}" in
        f) raw=${OPTARG};;
        a) adresse=${OPTARG};;
        p) postalcode=${OPTARG};;
        t) type=${OPTARG};;
        h) echo $usage && exit -1;;
    esac
done

echo type $type

# Break if missing argument and send help to user
if [[ "$raw" == "" ]] || [[ "$adresse" == "" ]] || [[ "$postalcode" == "" ]] ; then
     echo "Mandatory arguments are missing."
     echo $usage;
     exit 99;
fi

# Remove accents
cat $raw | iconv -f utf8 -t ascii//TRANSLIT//IGNORE > $file

# Generate full file
if [[ "$type" == "full" ]] ; then
    curl -X POST -F data=@$file -F columns=$adresse -F columns=$postalcode https://api-adresse.data.gouv.fr/search/csv/ > $output
fi

# Generate light file
if [[ "$type" == "light" ]] ; then
    curl -X POST -F data=@$file -F columns=$adresse -F columns=$postalcode -F result_columns=latitude -F result_columns=longitude  https://api-adresse.data.gouv.fr/search/csv/ > $outputLight
fi

rm $file
exit 0
