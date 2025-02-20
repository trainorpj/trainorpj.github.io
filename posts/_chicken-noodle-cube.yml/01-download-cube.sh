#!/bin/bash

db="cube.duckdb"

# download from cubecobra
cards_url="https://cubecobra.com/cube/download/csv/2d0fde97-e28c-4ba4-84fc-f271016e9578?primary=Color%20Category&secondary=Types-Multicolor&tertiary=Mana%20Value&quaternary=Alphabetical&showother=false"
csv="cards.csv"

echo "downloading csv from ${cards_url}"
curl -s -o "${csv}" "${cards_url}"

echo "loading into duckdb"
rm -f $db
duckdb $db <<SQL
create table cards as 
    select
        name
        ,cmc 
        ,type 
        ,color
        ,set
        ,"Collector Number" as collector_number
        ,rarity
        ,"Color Category" as color_category
        ,status
        ,finish
        ,maybeboard
        ,"image URL" as image_url
        ,"image Back URL" as image_back_url
        ,notes
        ,"MTGO ID" as mtgo_id
    from read_csv_auto('$csv')
SQL