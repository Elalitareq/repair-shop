- Created `ItemFormPage` and `ItemDetailPage` routes and basic UI scaffolding for item creation and details (front-end).
- `ImageService` added to support image uploads; backend endpoints to be implemented in `server-ts`.

# Repair Shop Management — Project Tasks (Consolidated)

This file consolidates all development tasks across the mobile, backend, and sync systems. It replaces the previous task documents (DEVELOPMENT_TASKS.md, api_tasks.md, PROJECT_SPECIFICATION.md, TECHNICAL_ARCHITECTURE.md, SETUP_COMPLETE.md, DATABASE_STATUS.md).

---

## 📌 Current Status (as of 2025-11-20)

- **Backend**: TypeScript server (`server-ts/`) with Prisma/SQLite integration
  - Full CRUD APIs for Items, Categories, Customers, Sales, Repairs, Reference Data
  - **NEW**: Serial (IMEI) management endpoints (`/api/serials`) for tracking device serials
  - **NEW**: Batch management endpoints (`/api/batches`) for inventory batch tracking
  - IMEI moved from Item model to separate Serial model (many-to-many: items can have multiple serials)
  - Seed data includes demo serials for testing
- **Mobile**: Flutter app with Riverpod state management
  - Inventory UI with search/filter and full CRUD operations
  - **NEW**: Serial management UI in Item Details (add/delete serials with batch selection)
  - **NEW**: Batch list and creation pages (`/inventory/batches`)
  - ItemService, SerialService, CategoryService, ReferenceService using ApiClient
  - Local SQLite database with serials table and indexes
- **Database**: Prisma schema updated with Serial model; migration script available for legacy IMEI data
- **Auth**: Fixed null-safety issues in mobile AuthResponse parsing

---

## ✅ Completed / Implemented

### Backend Setup (TypeScript Migration)

- ✅ Full TypeScript server implementation with Express + Prisma + SQLite
- ✅ Authentication endpoints (login, register, JWT middleware)
- ✅ Complete CRUD APIs for all entities (Items, Categories, Customers, Sales, Repairs, References)
- ✅ Seed data with demo users, items, categories, repairs, and sales
- ✅ Default admin credentials (email: admin@example.com, password: admin123)

### IMEI to Serial Model Migration

- ✅ **Prisma Schema**: Created Serial model with unique IMEI constraint, itemId, batchId, status fields
- ✅ **Backend Controllers**: SerialController (GET, POST, DELETE /serials) with IMEI uniqueness validation
- ✅ **Backend Routes**: Registered serial.routes.ts and batch.routes.ts in Express app
- ✅ **Item Controller**: Updated search to query serials table for IMEI matches; removed IMEI field from item create/update
- ✅ **Batch Management**: BatchController (GET, POST, GET by item) for inventory batch tracking
- ✅ **Mobile Models**: Created Serial model extending BaseModel; updated Item/ItemBatch models to support serials
- ✅ **Mobile Services**: SerialService with getSerials, createSerial, deleteSerial methods + Riverpod provider
- ✅ **Mobile UI**:
  - Item Details page shows serials in ExpansionTile
  - Add Serial dialog with batch selection dropdown
  - Delete serial per item (icon button)
  - BatchListPage to view all batches
  - BatchFormPage to create new batches
  - Integrated batch navigation into InventoryPage app bar
- ✅ **Local Database**: Updated SQLite schema with serials table, indexes on imei/item_id/batch_id
- ✅ **Migration Script**: Created `migrate-imei-to-serials.ts` helper to move legacy IMEI data from items to serials
- ✅ **Documentation**: Updated README.md with `prisma db push` workflow instructions

### Mobile Setup & Refactoring

- ✅ ItemService migration to ApiClient pattern (all 13+ methods updated)
- ✅ Fixed AuthResponse null-safety issues (login/register token parsing)
- ✅ Inventory UI with search/filter/CRUD operations
- ✅ SerialService, CategoryService, ReferenceService using ApiClient
- ✅ Riverpod providers for items, serials, batches, categories, references

### Sales & POS

- ✅ Sale creation with stock validation implemented (TS backend)
- ✅ Reporting APIs for sales analytics

### Project Infrastructure

- ✅ Flutter + TypeScript server scaffolding
- ✅ Prisma schema with seed script
- ✅ Flutter Riverpod + ApiClient integration
- ✅ Go backend archived to `server-go-backup/`

---

## ❗ Remaining high-priority tasks (Next 1-2 Sprints)

1. **Items Management (Backend)**

   - [x] ~~Fully implement items CRUD API (TypeScript): GET/POST/PUT/DELETE~~ ✅ Complete
   - [x] ~~Add IMEI validation & unique checks on create/update~~ ✅ Moved to Serial model with uniqueness constraint
   - [ ] Implement image upload for items
   - [x] ~~Complete item search indexing & optimized filters (case-insensitive, brand/model search)~~ ✅ Search includes IMEI via serials table
   - [ ] Add stock movement history and audit logging
   - **NEW**: [ ] Run `pnpm prisma db push` to apply Serial model schema changes
   - **NEW**: [ ] Run `pnpm prisma generate` to update Prisma client types
   - **NEW**: [ ] Test serial/batch endpoints (GET/POST/DELETE /serials, /batches)

     - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/1

2. **Mobile App (Flutter)**

   - [x] ~~ItemService API integration~~ ✅ Migrated to ApiClient
   - [x] ~~Serial management UI~~ ✅ Add/delete serials in ItemDetailPage
   - [x] ~~Batch management UI~~ ✅ BatchListPage and BatchFormPage implemented
   - [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate serial.g.dart
   - [ ] Widget tests for serial add/delete flow
   - [ ] Integration tests for batch creation and listing
   - [ ] Add image capture/upload for items

3. **Repair Management**

   - [ ] Core repair CRUD endpoints (create, update, assign, track)
   - [ ] Repair workflow & state transitions (kanban board support)
   - [ ] Repair images: multipart upload + image categorization (before/during/after)
   - [ ] Repair analytics & reporting

     - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/3

4. **Billing & Sales**

   - [ ] Improve sale confirmation workflows (stock reservation, partial payments)
   - [ ] Payment gateway integration (plugin points) + payment reconciliation
   - [ ] Receipt generation (PDF/print support)

     - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/4

5. **Synchronization & Offline-first**

   - [ ] Design cloud sync with conflict resolution
   - [ ] Implement offline queuing + retry logic
   - [ ] Partial sync optimizations for images and large datasets

     - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/5

6. **Mobile Integration & UX**

   - [x] ~~Connect all Flutter providers to TypeScript API endpoints~~ ✅ ItemService, SerialService, CategoryService, ReferenceService using ApiClient
   - [ ] Implement item images and file uploads on mobile
   - [ ] Add map links & contact integrations for customers
   - [ ] Finalize repair screens and parts usage UI

     - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/7

7. **Image & Media Storage**

   - [ ] Add cloud image provider – S3-compatible or other
   - [ ] Implement compression & deduplication for mobile uploads

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/8

8. **Security & Production Readiness**

   - [ ] Replace seeded credentials after first-run
   - [ ] Hardening: rate limit, auth expiry, refresh tokens
   - [ ] Audit logging, RBAC, and permissions

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/9

9. **Testing & CI**

   - [ ] Unit + integration tests (backend + mobile E2E)
   - [ ] CI pipeline for TypeScript backend (lint, test, build)
   - [ ] Create reproducible production configuration + Docker image
   - **NEW**: [ ] Add integration tests for serial/batch endpoints
   - **NEW**: [ ] Add widget tests for serial add/delete flow in mobile
   - **NEW**: [ ] Test migration script (migrate-imei-to-serials.ts) with sample data

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/10

---

## 🔁 Recent Progress (Nov 20, 2025)

### IMEI to Serial Model Migration

- **Why**: Items can have multiple physical devices (each with unique IMEI/serial number), one per batch. Previous model had single IMEI field on Item, limiting inventory tracking.
- **What Changed**:
  - Created `Serial` model (id, imei unique, itemId, batchId, status, timestamps)
  - Updated Prisma schema to add `serials` relation on `Item` and `Batch` models
  - Removed `imei` field from `Item` model
  - Backend: Added SerialController and BatchController with full CRUD endpoints
  - Backend: Updated item search to query serials table for IMEI matches
  - Mobile: Created Serial model/service/provider; added UI to add/delete serials in ItemDetailPage
  - Mobile: Created BatchListPage and BatchFormPage for batch management
  - Added migration helper script (`server-ts/scripts/migrate-imei-to-serials.ts`) to move legacy IMEI data
- **Next Steps**:
  1. Run `pnpm prisma db push` in `server-ts/` to apply schema changes
  2. Run `pnpm prisma generate` to update Prisma client types
  3. Run `flutter pub run build_runner build --delete-conflicting-outputs` in `mobile/` to regenerate serial.g.dart
  4. Test serial/batch endpoints manually or with Postman
  5. (If legacy data exists) Run migration script to move items.imei to serials table

### Front-end Integration (Nov 17, 2025)

- Implemented `CategoryService` and `ReferenceService` in Flutter using `ApiClient` to fetch categories, conditions and qualities from the TypeScript API
- Updated `categoriesProvider`, `conditionsProvider`, and `qualitiesProvider` to use these services and return remote data
- Created GitHub issues for the major task areas and assigned them to milestones (see `ISSUES.md`)

### Next front-end tasks

1. Wire category dropdowns and filters in `InventoryPage` to show remote categories
2. Implement the front-end file upload flow for item images (thumbnail + metadata), plus a `ImageService` to talk to `POST /api/items/:id/images` or `POST /api/images` as implemented on the backend
3. Add a progress indicator and preview when uploading images; persist image url in `createItem`/`updateItem` calls
4. Add unit tests for `CategoryService`, `ReferenceService`, `SerialService` to validate API responses

---

## 🔁 Migration Plan & Considerations

- The TypeScript backend is the primary target for future development; the old Go backend is archived under `server-go-backup/` for reference
- **Database Workflow**: Use `pnpm prisma db push` instead of migrations for development (see README.md for details)
- For large queries (e.g., low-stock across thousands of items), optimize with raw SQL or database-side comparison (`Prisma.raw` or view)
- For search & indexing (items/customers) - consider using SQLite FTS (Full Text Search) or a small indexing service for faster search
- **Serial/IMEI Tracking**: Each physical device now has a unique Serial record; items can have multiple serials across batches

---

## 🛠️ Milestone Checklist (Short-term)

- [x] ~~1. Implement Items CRUD API in TypeScript and connect Flutter providers to it~~ ✅ Complete
- [ ] 2. Implement image upload endpoints and mobile integration
- [ ] 3. Implement Repair CRUD & state management + UI flows
- [ ] 4. Add DB/migration safeguards (backups, data export) and add a DB test suite
- [ ] 5. Documentation: add Postman collection, README updates, deploy steps
- **NEW**: [x] ~~6. Migrate IMEI from Item to Serial model~~ ✅ Complete (pending db push)

---

## ✨ Developer Notes

- Default admin credentials (development/test only): `admin@example.com` / `admin123` (change ASAP in prod)
- Use `server-ts/README.md` for running the TypeScript server locally
- **Important**: After pulling schema changes, run `pnpm prisma db push` then `pnpm prisma generate` in `server-ts/`
- **Mobile**: Run `flutter pub run build_runner build --delete-conflicting-outputs` after model changes
- When implementing new endpoints: add tests plus migrations; prefer incremental changes and small PRs
- Migration helper script available at `server-ts/scripts/migrate-imei-to-serials.ts` for legacy IMEI data

---

## 📎 Links

- TypeScript backend: `server-ts/`
- Flutter mobile: `mobile/`
- (Archived) Go backend: `server-go-backup/`

---

If you'd like: I can add a task-per-file breakdown (with owners, estimates) or create GitHub issues from this list. What would you prefer next?
