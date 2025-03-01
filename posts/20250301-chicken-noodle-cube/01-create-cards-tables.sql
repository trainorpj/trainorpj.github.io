create or replace table cards as 
    select
        name as name
        , cmc as cmc
        , type as card_type
        , color as color
        , set as set
        , "Collector Number" as collector_number
        , rarity as rarity
        , "Color Category" as color_category
        , status as status
        -- ,finish as finish
        , maybeboard as maybeboard_ind
        -- ,"image URL" as image_url
        -- ,"image Back URL" as image_back_url
        , notes as notes 
        -- ,"MTGO ID" as mtgo_id
    from read_csv_auto('cubecobra/cards.csv');

create or replace view spells as
    select *
    from cards
    where 1=1 
        -- removes lands
        and cmc > 0;

create or replace view lands as
    select *
    from cards 
    where 1=1 and cmc=0;