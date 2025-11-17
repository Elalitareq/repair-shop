# Proposed GitHub Issues (Draft)

These are the issues that can be created automatically via `scripts/create_github_issues.sh` or manually via GitHub.

1. Items: Implement Items CRUD + IMEI validation

   - Implement backend endpoints (GET/POST/PUT/DELETE /items)
   - Add IMEI uniqueness and validation
   - Wire to Flutter ItemService
   - Add tests

2. Items: Image upload & management  (milestone: Images - #6)

   - Add multipart upload endpoint
   - Add image processing (thumbnail/preserve exif)
   - Mobile upload integration

3. Repairs: Implement repairs CRUD + state workflow (milestone: Repairs - #2)

   - Create repair CRUD endpoints
   - Add workflow states and transitions
   - Add images upload endpoint

4. Sales: Improve payment processing & receipts (milestone: Sales - #3)

   - Multi-method payments
   - Support partial payments & refunds
   - Receipt generation (PDF)

5. Sync: Implement offline-first sync with conflict resolution (milestone: Sync - #4)

   - Design architecture for incremental sync
   - Implement conflict resolution strategy
   - Add sync status logging

6. Stock: Stock movement history + low-stock optimizations (milestone: Items - #1)

   - Movement log API
   - DB-side optimization for low stock queries

7. Mobile: Connect Flutter providers to TypeScript API (milestone: Mobile - #5)

   - Replace mock data with real endpoints
   - Implement image upload and progress handling

8. Images: Cloud image storage + compression pipeline (milestone: Images - #6)

   - Configure S3-compatible storage
   - Add compression and deduplication

9. Security: Replace default credentials and harden backend (milestone: Security - #7)

   - Change seeded admin password
   - Add rate limiting and token revocation

10. Testing: Add unit/integration tests + CI (milestone: Testing - #8)

- Add Jest and integration tests for backend
- Add GitHub Actions or other CI for lint/test/build

---

If you want these created now, run:

```bash
export GITHUB_TOKEN="your_token_here"
./scripts/create_github_issues.sh Elalitareq/repair-shop
```

Or, if you prefer the GitHub CLI, install gh and run:

```bash
# create issues with gh
gh issue create --repo Elalitareq/repair-shop --title "Items: Implement Items CRUD + IMEI validation" --body "..."
```
