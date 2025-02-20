#!/bin/bash

# download from scryfall
scryfall_url="https://api.scryfall.com/cards/named?fuzzy="
db="cube.duckdb"

mkdir -p scryfall
ids=$(duckdb "$db" -list "select replace(name, ' ', '-') from cards" | tail -n +2)

for id in $ids; do
    curl "${scryfall_url}${id}" -o ./scryfall/${id}.json
done
