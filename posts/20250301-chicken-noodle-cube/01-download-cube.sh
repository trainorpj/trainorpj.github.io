#!/bin/bash

db="cube.duckdb"

# download from cubecobra
cards_url="https://cubecobra.com/cube/download/csv/2d0fde97-e28c-4ba4-84fc-f271016e9578?primary=Color%20Category&secondary=Types-Multicolor&tertiary=Mana%20Value&quaternary=Alphabetical&showother=false"
csv="cubecobra/cards.csv"

echo "downloading csv from ${cards_url}"
curl -s -o "${csv}" "${cards_url}"

echo "loading into duckdb"
rm -f $db
duckdb $db < 01-create-cards-tables.sql