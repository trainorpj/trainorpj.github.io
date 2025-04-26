create table cards as (
    SELECT 
        id
        , name
        , type_line
        , mana_cost
        , oracle_text
    FROM read_parquet('.data/oracle-cards-20250425090226.parquet')
    WHERE 1=1
        and oracle_text IS NOT NULL
        and layout='normal'
);

card_embeddings (
    id text,
    name text,
    embedding list<double>
);