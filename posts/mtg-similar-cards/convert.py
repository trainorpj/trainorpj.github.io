import os
import json
import requests
from pathlib import Path
import pandas as pd

ORACLE_JSON_PATH = "oracle_cards.json"
FILTERED_PARQUET_PATH = "oracle_cards_filtered.parquet"

def filter_and_convert_to_parquet(
    oracle_json_path: Path,
    oracle_parquet_path: Path
):
    print("Loading Oracle JSON...")
    with open(oracle_json_path, encoding="utf-8") as f:
        cards = json.load(f)

    print("Filtering fields...")
    filtered = []
    for card in cards:
        if "oracle_text" in card:
            filtered.append({
                "id": card["id"],
                "name": card["name"],
                "type_line": card.get("type_line"),
                "mana_cost": card.get("mana_cost"),
                "oracle_text": card.get("oracle_text"),
                "colors": card.get("colors"),
                "cmc": card.get("cmc"),
                "set": card.get("set_name"),
                "rarity": card.get("rarity"),
                "layout": card.get("layout")
            })

    print(f"Total filtered cards: {len(filtered)}")

    print("Writing to Parquet...")
    df = pd.DataFrame(filtered)
    df.to_parquet(oracle_parquet_path, index=False)
    print(f"Saved filtered cards to {oracle_parquet_path}")

if __name__ == "__main__":
    data_dir = Path('/Users/pj/Documents/trainorpj.github.io/.data')
    filter_and_convert_to_parquet(
        data_dir / 'oracle-cards-20250425090226.json',
        data_dir / 'oracle-cards-20250425090226.parquet'
    )
