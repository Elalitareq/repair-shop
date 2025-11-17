- Created `ItemFormPage` and `ItemDetailPage` routes and basic UI scaffolding for item creation and details (front-end).
- `ImageService` added to support image uploads; backend endpoints to be implemented in `server-ts`.
# Repair Shop Management — Project Tasks (Consolidated)

This file consolidates all development tasks across the mobile, backend, and sync systems. It replaces the previous task documents (DEVELOPMENT_TASKS.md, api_tasks.md, PROJECT_SPECIFICATION.md, TECHNICAL_ARCHITECTURE.md, SETUP_COMPLETE.md, DATABASE_STATUS.md).

---

## 📌 Current Status (as of 2025-11-17)

- Backend: TypeScript server scaffold completed in `server-ts/` with Prisma/SQLite integration and full feature stubs (Auth, Items, Categories, Customers, Sales, Repairs, Reference Data). The TypeScript backend includes seed data and default admin credentials.
- Old Go backend moved to `server-go-backup/` (archived) to avoid accidental deletions and preserve history.
- Mobile: Flutter app structure with Riverpod, inventory UI, and ItemService migrated to `ApiClient`. Inventory UI supports search/filter and CRUD interactions.
- Database: Prisma models mirror the current schema; local SQLite DB is used for development.

---

## ✅ Completed / Implemented

- Project bootstrapping and environment setup
  - Flutter + Go (backup) + TypeScript server scaffolding
  - Prisma schema with migrations and seed script
  - Flutter: Riverpod + ApiClient integration for services
- Authentication
  - JWT-based auth implemented in both Go and TypeScript (seeded admin user)
- Categories & Reference data
  - APIs and controllers defined
- Sales management & POS flow (TS backend)
  - Sale creation with stock validation and reporting APIs implemented
- Batch/Stock management (TS backend & DB models)
- ItemService in Flutter fully migrated to use `ApiClient` (no UnimplementedError)
- Inventory page UI in Flutter with filters, search, and CRUD scaffolding

---

## ❗ Remaining high-priority tasks (Next 1-2 Sprints)

1. Items Management (Backend)

   - [ ] Fully implement items CRUD API (TypeScript): GET/POST/PUT/DELETE
   - [ ] Add IMEI validation & unique checks on create/update
   - [ ] Implement image upload for items
   - [ ] Complete item search indexing & optimized filters (case-insensitive, brand/model search)
   - [ ] Add stock movement history and audit logging

      - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/1

2. Repair Management

   - [ ] Core repair CRUD endpoints (create, update, assign, track)
   - [ ] Repair workflow & state transitions (kanban board support)
   - [ ] Repair images: multipart upload + image categorization (before/during/after)
   - [ ] Repair analytics & reporting

      - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/3

3. Billing & Sales

   - [ ] Improve sale confirmation workflows (stock reservation, partial payments)
   - [ ] Payment gateway integration (plugin points) + payment reconciliation
   - [ ] Receipt generation (PDF/print support)

      - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/4

4. Synchronization & Offline-first

   - [ ] Design cloud sync with conflict resolution
   - [ ] Implement offline queuing + retry logic
   - [ ] Partial sync optimizations for images and large datasets

      - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/5

5. Mobile Integration & UX

   - [ ] Connect all Flutter providers to TypeScript API endpoints
   - [ ] Implement item images and file uploads on mobile
   - [ ] Add map links & contact integrations for customers
   - [ ] Finalize repair screens and parts usage UI

      - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/7

6. Image & Media Storage

   - [ ] Add cloud image provider – S3-compatible or other
   - [ ] Implement compression & deduplication for mobile uploads

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/8

7. Security & Production Readiness

   - [ ] Replace seeded credentials after first-run
   - [ ] Hardening: rate limit, auth expiry, refresh tokens
   - [ ] Audit logging, RBAC, and permissions

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/9

8. Testing & CI
   - [ ] Unit + integration tests (backend + mobile E2E)
   - [ ] CI pipeline for TypeScript backend (lint, test, build)
   - [ ] Create reproducible production configuration + Docker image

   - GitHub Issue: https://github.com/Elalitareq/repair-shop/issues/10

---

## 🔁 Short-term front-end progress (Nov 17, 2025)

- Implemented `CategoryService` and `ReferenceService` in the Flutter app using `ApiClient` to fetch categories, conditions and qualities from the TypeScript API.
- Updated `categoriesProvider`, `conditionsProvider`, and `qualitiesProvider` to use these services and return remote data.
- Created GitHub issues for the major task areas and assigned them to milestones (see `ISSUES.md`).

### Next front-end tasks

1. Wire category dropdowns and filters in `InventoryPage` to show remote categories.
2. Implement the front-end file upload flow for item images (thumbnail + metadata), plus a `ImageService` to talk to `POST /api/items/:id/images` or `POST /api/images` as implemented on the backend.
3. Add a progress indicator and preview when uploading images; persist image url in `createItem`/`updateItem` calls.
4. Add unit tests for `CategoryService` and `ReferenceService` to validate API responses.

If you’d like me to open a PR with these front-end changes, I can stage the changes and push them for review.

---

## 🔁 Migration Plan & Considerations

- The TypeScript backend is the primary target for future development; the old Go backend is archived under `server-go-backup/` for reference. Re-activate if needed later.
- For large queries (e.g., low-stock across thousands of items), optimize with raw SQL or database-side comparison (`Prisma.raw` or view).
- For search & indexing (items/customers) - consider using SQLite FTS (Full Text Search) or a small indexing service for faster search.

---

## 🛠️ Milestone Checklist (Short-term)

- [ ] 1. Implement Items CRUD API in TypeScript and connect Flutter providers to it
- [ ] 2. Implement image upload endpoints and mobile integration
- [ ] 3. Implement Repair CRUD & state management + UI flows
- [ ] 4. Add DB/migration safeguards (backups, data export) and add a DB test suite
- [ ] 5. Documentation: add Postman collection, README updates, deploy steps

---

## ✨ Developer Notes

- Default admin credentials (development/test only): `admin` / `admin123` (change ASAP in prod)
- Use `server-ts/README.md` for running the TypeScript server locally
- When implementing new endpoints: add tests plus migrations; prefer incremental changes and small PRs.

---

## 📎 Links

- TypeScript backend: `server-ts/`
- Flutter mobile: `mobile/`
- (Archived) Go backend: `server-go-backup/`

---

If you'd like: I can add a task-per-file breakdown (with owners, estimates) or create GitHub issues from this list. What would you prefer next?
