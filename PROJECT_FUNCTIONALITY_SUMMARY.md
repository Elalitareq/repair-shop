# Project Functionality Summary

Generated: 2025-11-24

This document summarizes implemented functionality (backend and mobile frontend), missing functionality, and features that exist in the backend but are not yet surfaced in the frontend.

**Important:** This summary was created from scanning `server-ts/src/controllers` and `mobile/lib/features` and the Prisma schema. If you want this expanded into a checklist per-file or a finer-grained roadmap (with PR suggestions or code pointers), tell me and I will produce that.

---

**Backend — Implemented**

- Auth

  - `AuthController`:
    - `login` (JWT generation)
    - `register` (create user + token)
    - `refresh` (refresh token)

- Items

  - `ItemController`:
    - `getAll` (pagination, low-stock filter implemented in-app)
    - `search` (search items and match serial IMEIs)
    - `getLowStock`
    - `getById` (includes serials)
    - `create` (accepts camelCase and snake_case, `itemType` handled)
    - `update`
    - `delete` (prevents deletion with transactions)
    - `adjustStock` (creates `StockUsage` entries when reason provided)

- Batches

  - `BatchController`:
    - `getAll` (list with supplier + serials)
    - `getById` (detailed + stock/percentage helpers)
    - `create` (creates batch and returns metadata)
    - `getForItem` (find batches that contain serials for a given item)

- Serials (IMEI) management

  - `SerialController`:
    - `getAll` (filter by `itemId` or `batchId`)
    - `create` (unique IMEI enforcement)
    - `delete`

- Sales

  - `SaleController`:
    - `getAll`, `getById`, `create`, `update`, `delete`
    - `updateStatus` (on confirm, reduces stock)
    - `getDailyReport`, `getMonthlyReport`

- Customers

  - `CustomerController`:
    - `getAll`, `search`, `getById`, `create`, `update`, `delete`

- Repairs

  - `RepairController`:
    - `getAll`, `getById`, `create`, `update`, `delete`, `updateState`

- Reference data & settings

  - `ReferenceController` (likely handles conditions, qualities, payment methods etc.)
  - `CategoryController` (category CRUD)

- Prisma schema updates
  - `Item.itemType` added (`phone` | `other`) with default `other`
  - `Batch.unitCost` & `Batch.totalCost` present and used in controllers
  - `Serial` model added for IMEIs
  - `Barcode` model exists in schema

**Backend — Notes / Implementation details**

- Controllers generally return JSON and use Prisma `include` to return relations.
- Several endpoints accept both camelCase and snake_case bodies for mobile compatibility.
- Serial (IMEI) uniqueness is enforced at the controller level (and by `@unique` in Prisma schema).
- Some controllers use `@ts-ignore` while prisma client types were regenerating in earlier work (now resolved).

---

**Mobile Frontend — Implemented**

- Inventory / Items

  - `InventoryPage` (list items, search, filters, low-stock toggle)
  - `ItemFormPage` (create/edit item)
    - Includes `item_type` selection (`phone` / `other`)
    - Upload item image flow
  - `ItemDetailPage` (view item details & serials)

- Batches

  - `BatchFormPage` (create new batch for an item)
    - Auto-detects item type via `itemDetailProvider` and shows serial UI only for phones
    - Adds serials via `serialService.createSerial` for phone items
    - Validates serial count == quantity for phone items

- Repairs

  - `RepairsPage`, `RepairFormPage`, `RepairDetailPage` (repair lifecycle)

- Customers

  - `CustomersPage` (list/create/edit customers)

- Settings & Reference Data

  - `qualities_settings_page`, `conditions_settings_page`, `categories_settings_page` (CRUD UI for reference data)

- Auth

  - `LoginPage` and auth providers

- Dashboard

  - `DashboardPage` (high level; Reports action currently shows "Reports coming soon")

- Models & Serialization

  - JSON-serializable models for `Item`, `Sale`, `SaleItem`, `Payment`, `PaymentMethod`, etc.
  - Mobile models updated to use snake_case mapping where needed (e.g., `item_type`, `stock_quantity`)

- Services / Providers
  - `item_provider`, `batch_provider`, `serial_service`, `itemDetailProvider`, `batchNotifierProvider` and others used by pages above

**Mobile — Notes / UX details**

- Batch creation for phone items requires adding serial numbers; the UI enforces that serials count matches total quantity for phone items.
- Item creation includes `item_type` dropdown (phones require serials for batches).
- Serial creation requests are made after successfully creating a batch on the server (per `BatchFormPage`).

---

**Missing / Incomplete Backend Functionality**

(These are either missing controllers/endpoints or are partially implemented and need refinement.)

- Barcode endpoints

  - Prisma has `Barcode` model, but there is no `barcode.controller.ts` in `server-ts/src/controllers`. Add a `BarcodeController` with CRUD endpoints (list, create, delete, search by barcode → item) and endpoints to link multiple barcodes to an item.

- Batch-stock accounting improvements

  - `StockUsage` entries currently created with `unitCost: 0` in `adjustStock` TODO comment. Need to implement batch-aware stock deduction (FIFO or LIFO) so `unitCost` is tracked and historic costing is accurate.

- Tests & migrations

  - There are no automated tests verifying serial uniqueness, batch creation flow, and sale stock deductions.
  - Migration scripts and documentation for schema updates are missing (DB pushes are done locally but a migration history + tests would help reproducibility).

- Barcode / scanner deduplication

  - A robust barcode model/controller should support multiple barcodes per item (already in schema), plus endpoints for resolving barcode → item for quick lookup in sales.

- Reporting enhancements

  - Backend provides report endpoints (`getDailyReport`, `getMonthlyReport`) but there may be more desired aggregations (by product, by payment method, by customer).

- API docs
  - No OpenAPI/Swagger description found. Adding autogenerated API docs would help mobile/web teams.

---

**Missing / Incomplete Frontend Functionality**

- Sales UI (major gap)

  - There are models for `Sale`, `SaleItem`, and `Payment`, but the mobile app lacks a full `Sales` flow pages (add sale, select items, scan barcode to add item to sale, choose payments, confirm sale).
  - Payment capture UI and payment method selection page are missing.

- Barcode scanning & barcode UI

  - No barcode scanning integration (camera-based scan) is present in mobile pages.
  - No UI for managing multiple barcodes per item (adding/removing barcodes from an item) even though schema supports it.

- Reports UI

  - Although backend supports daily/monthly reports, the `Dashboard` currently shows "Reports coming soon". There is no dedicated reports page.

- Sync/Offline handling

  - If the app is expected to work offline and sync later, the UI and conflict handling screens are missing. (There are `SyncLog` schema entries but no sync UI.)

- Payments UI

  - List and manage payment methods in-app, and a payment capture flow on sales are missing.

- Tests for mobile
  - Widget/unit tests for critical pages (batch create with serials, item create, inventory list) are missing.

---

**Features Present in Backend but Not Yet Surfaced in Frontend**

- Sales endpoints & reports (backend has `SaleController` and report endpoints; mobile has models only)
- Payment methods endpoints (backend likely exposes reference/payment methods but mobile UI for adding/managing them is incomplete)
- Barcode CRUD/search endpoints (backend: schema exists; frontend: no UI nor scanner integration)
- Sync logs / batch reconciliation endpoints (backend: `SyncLog`; frontend: no sync status UI)

---

**Recommended Next Steps / Priorities**

1. Implement Sales flow in mobile app (high priority):

   - Build `SalesPage`, `SaleFormPage` (select items, optionally scan barcode to add), `PaymentCapture` flow.
   - Reuse existing `Sale`/`SaleItem`/`Payment` models and backend endpoints.

2. Barcode support (scan & manage):

   - Backend: add `BarcodeController` with search endpoint that returns `item` by `barcode`.
   - Mobile: add camera-based barcode scanning (e.g., `mobile_scanner` or `barcode_scan2`), a UI to add barcodes on `ItemFormPage` and to scan in `SaleFormPage`.

3. Batch costing fidelity:

   - Implement batch-aware stock deduction and `unitCost` attribution when deducting stock for sales/stock usage.

4. Reports UI:

   - Create `ReportsPage` on mobile consuming `getDailyReport`/`getMonthlyReport`.

5. Tests & API docs:

   - Add unit & integration tests for backend controllers (serial uniqueness, sale confirmation reduces stock, batch creation). Add widget tests for the mobile batch & item flows.
   - Add API documentation (OpenAPI) to the backend.

6. Minor / cosmetic:
   - Add barcode management UI (add/remove multiple barcodes per item), and syncing/merge UI if offline-first behavior is expected.

---

If you want, I can:

- Create the `BarcodeController` scaffold (backend) and open a PR draft.
- Add `Sales` pages scaffolding in the mobile app and wire them to the backend endpoints.
- Produce a prioritized task list with estimated hours per item.

Tell me which of the above you'd like me to implement next and I'll start.
