import duckdb
import pandas as pd
import numpy as np
import os
import faiss
from tqdm import tqdm
from sentence_transformers import SentenceTransformer
import json
from pathlib import Path

DATA_PATH = Path("/Users/pj/Documents/trainorpj.github.io/.data/")
PARQUET_PATH = DATA_PATH / "oracle-cards-20250425090226.parquet"
INDEX_PATH = DATA_PATH / "mtg_faiss.index"
ID_MAP_PATH = DATA_PATH / "id_map.json"
EMBEDDINGS_PATH = DATA_PATH / "embeddings.npy"

# Step 1: Load filtered cards with DuckDB
def load_cards_from_parquet():
    con = duckdb.connect()
    df = con.execute(f"""
        SELECT id, name, type_line, mana_cost, oracle_text
        FROM read_parquet('{PARQUET_PATH}')
        WHERE 1=1
            and oracle_text IS NOT NULL
            and layout='normal'
    """).df()
    con.close()
    return df

#
def create_embedding_texts(df):
    return [
        "|".join([row[key] for key in ['name','type_line', 'mana_cost', 'oracle_text']])
        for _, row in df.iterrows()
    ]

def embed_texts(texts, model_name="all-MiniLM-L6-v2", batch_size=64):
    if os.path.exists(EMBEDDINGS_PATH):
        print("✅ Embeddings already cached.")
        return np.load(EMBEDDINGS_PATH)

    print("🧠 Embedding texts...")
    model = SentenceTransformer(model_name)
    embeddings = []
    for i in tqdm(range(0, len(texts), batch_size), desc="Embedding"):
        batch = texts[i:i+batch_size]
        emb = model.encode(batch, show_progress_bar=False)
        embeddings.append(emb)
    result = np.vstack(embeddings)
    np.save(EMBEDDINGS_PATH, result)
    print("✅ Saved embeddings to disk.")
    return result

def build_faiss_index(embeddings, ids_df):
    if os.path.exists(INDEX_PATH) and os.path.exists(ID_MAP_PATH):
        print("✅ FAISS index and ID map already cached.")
        return

    print("📦 Building FAISS index...")
    index = faiss.IndexFlatL2(embeddings.shape[1])
    index.add(embeddings)
    faiss.write_index(index, str(INDEX_PATH))

    with open(ID_MAP_PATH, "w") as f:
        json.dump(ids_df.to_dict("records"), f)
    print("✅ Saved FAISS index and ID map.")

def search_by_text(query_text, model, index, ids_df, top_k=5):
    query_emb = model.encode([query_text])
    D, I = index.search(query_emb, top_k)
    for idx, dist in zip(I[0], D[0]):
        row = ids_df.iloc[idx]
        print(f"{row['name']} | {row['type_line']} | {row['mana_cost']} | {row['oracle_text']} | Score: {dist:.2f}")

# --- Run it all ---
if __name__ == "__main__":
    
    df = load_cards_from_parquet()
    texts = create_embedding_texts(df)
    embeddings = embed_texts(texts)
    build_faiss_index(embeddings, df)

