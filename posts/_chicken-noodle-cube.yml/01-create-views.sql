create or replace table scryfall as
    select
        name
        , id
        , type_line
        , oracle_text
        , power
        , toughness
        , list_transform(
            str_split(trim(both '[]' from cast(keywords as text)), ','),
            kw->lower(kw)
        ) as keywords
        , cast(prices->'$.usd' as float) as price_usd

    from read_json('scryfall/*.json')
;

create or replace table cards as 
    select 
        cards.*
        , scryfall.* exclude(scryfall.name)
    from cards 
    left join scryfall using(name);