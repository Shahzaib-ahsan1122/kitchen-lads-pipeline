import pandas as pd
from rapidfuzz import process, fuzz

# Master menu with Canonical Name & Category mapping
MASTER_MENU = {
    "Lamb Donner Wrap": {"category": "Kebabs", "synonyms": ["Lrg Lamb Donner Wrap", "WRAP-LD-LRG", "Lamb Donner - Large"]},
    "Chicken Tikka Rice Box": {"category": "Rice Boxes", "synonyms": ["Chicken Tikka Box", "Chix Tikka Box (Large)", "ricebox1"]},
    "Peri-Peri Wings (6pcs)": {"category": "Grill & Sides", "synonyms": ["6 x Peri Wings", "Peri Wings 6pc"]},
    "Margherita Pizza (12\")": {"category": "Pizzas", "synonyms": ["12 Inch Margherita", "PIZ-MARG-12"]}
}

master_choices = []
choice_lookup = {}

for canonical, info in MASTER_MENU.items():
    master_choices.append(canonical)
    choice_lookup[canonical] = (canonical, info["category"])
    for syn in info["synonyms"]:
        master_choices.append(syn)
        choice_lookup[syn] = (canonical, info["category"])

raw_platform_items = [
    "Lrg Lamb Donner Wrap",
    "Lamb Donner - Large",
    "WRAP-LD-LRG",
    "Chicken Tikka Box",
    "Chix Tikka Box (Large)",
    "6 x Peri Wings",
    "12 Inch Margherita",
    "ricebox1"
]

results = []
for raw in raw_platform_items:
    match, score, _ = process.extractOne(raw, master_choices, scorer=fuzz.WRatio)
    canonical, category = choice_lookup[match] if score >= 70 else (f"UNMAPPED: {raw}", "Uncategorized")
    
    results.append({
        "raw_item_name": raw,
        "canonical_item_name": canonical,
        "category": category,
        "match_confidence_score": round(score, 2),
        "status": "AUTO_MAPPED" if score >= 70 else "NEEDS_REVIEW"
    })

df = pd.DataFrame(results)
df.to_csv("data/seeds/menu_mapping.csv", index=False)
print("Updated mapping saved with categories!")