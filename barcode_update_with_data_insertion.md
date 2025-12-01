# Barcode Update with Data Insertion Tasks

## 1. Backend: Enhanced Barcode & Search Support

### 1.1. Update Item & Barcode Models
- Ensure `Item` model supports multiple barcodes (already exists: `Barcode` model).
- Ensure `Serial` model is correctly linked for phone IMEIs (already exists).
- **Task:** Verify `ItemController` allows creating items with an initial barcode from the `code` field.

### 1.2. CSV Import Endpoint
- Create a new endpoint `POST /api/inventory/import` to handle CSV file uploads.
- **Logic:**
  - Parse CSV rows (`Code`, `Description`, `Quantity`, `Amount`).
  - Check if `Item` exists by `Code` (Barcode) or `Description` (Name).
    - **If Exists:** Update stock (create new Batch).
    - **If New:** Create `Item` + `Barcode` + Initial `Batch`.
  - **Fields Mapping:**
    - `Code` -> `Barcode.barcode`
    - `Description` -> `Item.name`
    - `Quantity` -> `Batch.totalQuantity` & `Item.stockQuantity` (increment)
    - `Amount` -> `Item.sellingPrice` (Update if changed? Or set for new)
    - `Batch.unitCost` -> Derive or default (maybe use `Amount` as cost if this is a supplier invoice? User said "price of the item", usually selling price. Let's assume selling price for Item, default cost 0 for now).
- **Support:** Handle transaction to ensure atomicity.

### 1.3. Universal Search Endpoint (Sales)
- Create or Update `ItemController.search` to search by:
  - Item Name (partial)
  - Barcode (exact)
  - Serial/IMEI (exact) -> Resolves to the specific Item.
- **Response:** Should indicate if the match was by IMEI (specific serial found) or generic Item (barcode/name).

## 2. Frontend: CSV Import Feature

### 2.1. File Upload UI
- Add an "Import Inventory" button in the Inventory Screen.
- Implement a file picker for `.csv` files.
- Show a preview of parsed data (optional but recommended) or just a confirmation dialog.

### 2.2. Import Logic
- Read CSV file content.
- Send to `POST /api/inventory/import`.
- Show progress/success/error messages.
- Refresh Inventory list upon success.

## 3. Frontend: Sales Page Barcode Integration

### 3.1. Barcode Scanner / Input Field
- Add a text input field "Scan Barcode / IMEI" at the top of the Sales/Cart page.
- Listen for "Enter" key (scanners usually send Enter).

### 3.2. Add to Cart Logic
- **On Submit:** Call the Search Endpoint.
- **Scenario A: Found by Barcode/Name**
  - Add Item to Cart (Quantity 1).
  - If already in cart, increment quantity.
- **Scenario B: Found by IMEI (Phone/Serialized)**
  - Add Item to Cart.
  - **Link Serial:** Store the specific Serial/IMEI with the cart item to mark it as "Selected" so it can be marked "Sold" upon checkout.
  - Prevent adding the same IMEI twice.
- **Scenario C: Not Found**
  - Show error "Item not found".
  - Optionally offer to "Quick Create" if it's a new item (maybe out of scope for now).

### 3.3. UI Adjustments
- Keep "Add Item" button (manual selection).
- Ensure Cart displays the specific IMEI if one was scanned.
