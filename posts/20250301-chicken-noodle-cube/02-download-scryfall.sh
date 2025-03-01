#!/bin/bash

# download from scryfall
scryfall_url="https://api.scryfall.com/cards/named?fuzzy="
csv="cubecobra/cards.csv"

mkdir -p scryfall
ids=$(duckdb cube.duckdb -list "select distinct replace(name, ' ', '') as name from cards where maybeboard_ind=FALSE" | tail -n +2)

IFS=$'\n'
for id in $ids; do
    
    url=${scryfall_url}"${id}"
    echo $url
    curl "${scryfall_url}${id}" -o ./scryfall/${id}.json
done
