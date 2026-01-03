import csv
import os

def fix_row(row):
    # row is a dict from DictReader
    
    # 1. Clean whitespace
    for k, v in row.items():
        if v:
            row[k] = v.strip()
            
    desc = row.get('Description', '')
    brand = row.get('Brand', '')
    model = row.get('Model', '')
    category = row.get('Category', '')
    
    # 2. MOXOM Logic
    if 'MOXOM' in desc.upper():
        if not brand or brand.lower() == 'china':
            brand = 'MOXOM'
            
        if not model:
            # Try to extract model from description e.g., "MOXOM MX-VS138" -> "MX-VS138"
            parts = desc.split()
            for part in parts:
                if 'MX-' in part:
                    model = part
                    break
        
        # specific fix for "MX-VS" -> holder
        if 'MX-VS' in desc and not category:
            category = 'holder'

    # 3. Green Lion Logic
    # Example Brand: "green lion cable" -> "Green Lion"
    if 'green lion' in brand.lower():
        brand = 'Green Lion'
        
    if brand == 'Green Lion' and not model:
        # Use description as model, removing "GL " prefix if present
        if desc.startswith('GL '):
            model = desc[3:].strip()
        else:
            model = desc

    # 4. General Logic
    if not model and desc:
        # Fallback: if model is still empty, use description
        model = desc

    # Apply updates
    row['Brand'] = brand
    row['Model'] = model
    row['Category'] = category
    
    return row

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    input_file = os.path.join(base_dir, 'accs.csv price.csv 2.csv ppp.csv 3.csv final.csv')
    output_file = os.path.join(base_dir, 'accs_fixed.csv')
    
    if not os.path.exists(input_file):
        print(f"File not found: {input_file}")
        return

    print(f"Processing {input_file}...")
    
    fixed_rows = []
    fieldnames = []
    
    with open(input_file, 'r', encoding='utf-8') as f:
        # Handle potential BOM (Byte Order Mark) or weird encoding chars if any, but utf-8 usually fine
        # DictReader to handle columns by name
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        
        for row in reader:
            fixed_row = fix_row(row)
            fixed_rows.append(fixed_row)
            
    if not fixed_rows:
        print("No rows found.")
        return

    print(f"Writing {len(fixed_rows)} rows to {output_file}...")
    with open(output_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(fixed_rows)
        
    print("Done.")

if __name__ == '__main__':
    main()
