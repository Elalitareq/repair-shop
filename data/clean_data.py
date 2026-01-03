
import csv
import re
import os
import json

def clean_price(price_str):
    if not price_str:
        return 0.0
    # Remove '$' and extra spaces
    cleaned = price_str.replace('$', '').strip()
    try:
        return float(cleaned)
    except ValueError:
        return 0.0

def extract_imeis(imei_str):
    if not imei_str:
        return []
    parts = re.split(r'\s+', imei_str.strip())
    return [p for p in parts if p]

def process_files(base_dir, output_file):
    all_items = []

    # --- 1. Process Stock Prices (Phones - NEW) ---
    stock_path = os.path.join(base_dir, "PHONE STOCK PRICES.csv")
    if os.path.exists(stock_path):
        print(f"Processing {stock_path}...")
        with open(stock_path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader, None) # Skip header
            for row in reader:
                if not row or all(not cell.strip() for cell in row): continue
                try:
                    brand = row[0].strip()
                    model = row[1].strip()
                    imeis = extract_imeis(row[2])
                    specs = row[3].strip()
                    color = row[4].strip()
                    price = clean_price(row[5])
                    
                    desc_parts = []
                    if specs: desc_parts.append(f"Specs: {specs}")
                    if color: desc_parts.append(f"Color: {color}")
                    description = ", ".join(desc_parts)

                    item_obj = {
                        "name": f"{brand} {model}",
                        "brand": brand,
                        "model": model,
                        "category": "Phone",
                        "description": description,
                        "condition": "New",
                        "quality": "Original",
                        "itemType": "phone",
                        "sellingPrice": price * 1.5,
                        "stockQuantity": 1,
                        "barcode": imeis[0] if imeis else "",
                        "supplier": {
                            "name": "MobileZone",
                            "phone": "70300065",
                        },
                        "batch": {
                            "unitCost": price, # Assuming net price is cost
                            "quantity": 1
                        },
                        "serials": imeis
                    }
                    all_items.append(item_obj)
                except IndexError: continue

    # --- 2. Process Used iPhones (Phones - USED) ---
    used_path = os.path.join(base_dir, "used iphones.csv f.csv 1.csv")
    if os.path.exists(used_path):
        print(f"Processing {used_path}...")
        with open(used_path, 'r', encoding='utf-8') as f:
            reader = csv.reader(f)
            next(reader, None)
            for row in reader:
                if not row or all(not cell.strip() for cell in row): continue
                try:
                    brand = row[0].strip()
                    imeis = extract_imeis(row[1])
                    model = row[2].strip()
                    battery = row[3].strip()
                    storage = row[4].strip()
                    price = clean_price(row[5])
                    
                    desc_parts = []
                    if storage: desc_parts.append(f"Storage: {storage}")
                    if battery: desc_parts.append(f"Battery: {battery}")
                    description = ", ".join(desc_parts)

                    item_obj = {
                        "name": f"{brand} {model}",
                        "brand": brand,
                        "model": model,
                        "category": "Phone",
                        "description": description,
                        "condition": "Used",
                        "quality": "Original",
                        "itemType": "phone",
                        "sellingPrice": price * 1.5,
                        "stockQuantity": 1,
                        "barcode": imeis[0] if imeis else "",
                         "supplier": {
                            "name": "MobileZone",
                            "phone": "70300065",
                        },
                        "batch": {
                            "unitCost": price,
                            "quantity": 1
                        },
                        "serials": imeis
                    }
                    all_items.append(item_obj)
                except IndexError: continue


    # --- Write Final output to JSON ---
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_items, f, indent=2)
    
    print(f"Successfully converted {len(all_items)} items to {output_file}")

if __name__ == "__main__":
    base_dir = "/Users/elalitareq/Documents/projects/repair_shop/data"
    output_file = os.path.join(base_dir, "inventory_import.json")
    process_files(base_dir, output_file)
