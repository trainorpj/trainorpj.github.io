

echo "loaded card count:"
duckdb $db "select count(*) num_cards from cards"

