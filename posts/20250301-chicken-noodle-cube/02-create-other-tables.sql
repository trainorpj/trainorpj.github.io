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

create or replace view cards_with_info as 
    select 
        cards.*
        , scryfall.* exclude(scryfall.name)
    from cards 
    left join scryfall
        on cards.name = trim(split_part(scryfall.name, '//', 1))
    where 1=1
        and maybeboard_ind=False;

create or replace table keyword_counts as
    with exploded as (
        select id, unnest(keywords) as keyword
        from cards_with_info
        where 1=1
            and maybeboard_ind=False
    )
    , cleaned as (
        select id, nullif(replace(trim(keyword), ' ','_'), '') as keyword
        from exploded
    )
    , counts as (
        pivot cleaned
        on keyword
        using count(*)
        group by id
    )
    select *
    from counts;


create schema if not exists diagnostics;

create or replace view diagnostics.missing_scryfall as
    select *
    from cards_with_info
    where id is NULL;