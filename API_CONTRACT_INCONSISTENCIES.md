# API Contract Inconsistencies: Snake_case vs CamelCase

## Overview

This document outlines the inconsistencies between frontend (Flutter/Dart) and backend (Node.js/TypeScript) API contracts, specifically regarding field naming conventions. The frontend consistently sends snake_case field names in JSON payloads, while the backend expects snake_case but maps them to camelCase for database operations.

## Key Findings

### 1. Frontend Uses Snake_case in API Requests

All service classes in the mobile app send JSON data using snake_case field names, regardless of the Dart model field names.

### 2. Backend Expects Snake_case but Maps to CamelCase

Backend controllers destructure snake_case fields from request bodies and map them to camelCase for database operations using Prisma.

### 3. Field Name Mismatches

Several fields have different names between frontend models, API payloads, and database schema.

---

## Detailed Analysis by Service

### Customer Service (`mobile/lib/shared/services/customer_service.dart`)

**Frontend Model Fields (camelCase):**

- `companyName`
- `phoneNumber`
- `taxNumber`
- `locationLink`

**API Request Payload (snake_case):**

```json
{
  "company_name": "Company Name",
  "phone_number": "+1234567890",
  "tax_number": "123456789",
  "location_link": "https://maps.google.com/..."
}
```

**Backend Controller Mapping:**

```typescript
const {
  company_name: companyName,
  phone_number: phoneNumber,
  tax_number: taxNumber,
  location_link: locationLink,
} = req.body;
```

**Database Schema (camelCase):**

- `companyName`
- `phoneNumber`
- `taxNumber`
- `locationLink`

✅ **Status: Consistent**

---

### Repair Service (`mobile/lib/shared/services/repair_service.dart`)

**Frontend Model Fields (camelCase):**

- `deviceType` (but database uses `deviceBrand`)
- `deviceModel`
- `deviceSerial` (but database uses `deviceImei`)

**API Request Payload (snake_case):**

```json
{
  "customer_id": 1,
  "device_type": "iPhone",
  "device_model": "12 Pro",
  "device_serial": "123456789",
  "problem_description": "Screen broken",
  "estimated_cost": 100.0,
  "warranty_provided": true,
  "warranty_days": 30
}
```

**Backend Controller Mapping:**

```typescript
const {
  customer_id: customerId,
  device_type: deviceBrand, // Maps to deviceBrand (correct)
  device_model: deviceModel, // Maps to deviceModel (correct)
  deviceImei: deviceImei, // Expects deviceImei, but frontend sends device_serial
} = req.body;
```

**Database Schema (camelCase):**

- `deviceBrand` (not `deviceType`)
- `deviceModel`
- `deviceImei` (not `deviceSerial`)

❌ **Issues:**

1. Frontend sends `device_serial`, backend expects `deviceImei`
2. Frontend model uses `deviceType`, database uses `deviceBrand`
3. Frontend model uses `deviceSerial`, database uses `deviceImei`

---

### Sale Service (`mobile/lib/shared/services/sale_service.dart`)

**API Request Payload (snake_case):**

```json
{
  "customer_id": 1,
  "discount_type": "percentage",
  "discount_value": 10.0,
  "tax_rate": 8.0
}
```

**Backend Controller Mapping:**

```typescript
const {
  customer_id: customerId,
  discount_type: discountType,
  discount_value: discountValue,
  tax_rate: taxRate,
} = req.body;
```

**Database Schema (camelCase):**

- `customerId`
- `discountType`
- `discountValue`
- `taxRate`

✅ **Status: Consistent**

---

### Item Service (`mobile/lib/shared/services/item_service.dart`)

**API Request Payload (snake_case):**

```json
{
  "category_id": 1,
  "batch_id": 2,
  "low_stock": true,
  "item_id": 3
}
```

**Backend Controller Mapping:**

```typescript
const {
  category_id: categoryId,
  batch_id: batchId,
  low_stock: lowStock,
  item_id: itemId,
} = req.body;
```

**Database Schema (camelCase):**

- `categoryId`
- `batchId`
- `lowStock`
- `itemId`

✅ **Status: Consistent**

---

## Critical Issues Requiring Fixes

### 1. Repair Device Fields Mismatch

**Problem:** Frontend sends `device_serial`, backend expects `deviceImei`
**Impact:** Repair creation fails silently or creates incomplete records
**Solution:** Either:

- Change frontend to send `deviceImei` instead of `device_serial`
- Update backend to accept `device_serial` and map to `deviceImei`

### 2. Repair Device Type vs Brand Naming

**Problem:** Frontend model uses `deviceType`, database uses `deviceBrand`
**Impact:** Semantic confusion in code
**Solution:** Either:

- Rename database field to `deviceType`
- Update frontend model to use `deviceBrand`

### 3. Repair Device Serial vs IMEI Naming

**Problem:** Frontend model uses `deviceSerial`, database uses `deviceImei`
**Impact:** Semantic confusion in code
**Solution:** Either:

- Rename database field to `deviceSerial`
- Update frontend model to use `deviceImei`

---

## Recommended Solutions

### Option 1: Standardize on Frontend (Preferred)

Update frontend to match backend expectations:

1. **Change repair service to send correct field names:**

   ```dart
   // In createRepair method
   'deviceImei': deviceSerial,  // Instead of 'device_serial'
   ```

2. **Update frontend model field names:**
   ```dart
   // In Repair model
   String deviceBrand;  // Instead of deviceType
   String deviceImei;   // Instead of deviceSerial
   ```

### Option 2: Standardize on Backend

Update backend to accept frontend field names:

1. **Change repair controller mapping:**

   ```typescript
   const {
     device_type: deviceBrand,
     device_model: deviceModel,
     device_serial: deviceImei, // Accept device_serial
   } = req.body;
   ```

2. **Update database schema:**
   ```prisma
   deviceType   String  // Instead of deviceBrand
   deviceSerial String? // Instead of deviceImei
   ```

### Option 3: Add API Transformation Layer

Create middleware to transform field names between frontend and backend formats.

---

## Current Debugging Status

- ✅ Customer search functionality fixed with case-insensitive matching
- ✅ Debug logging added to track API requests/responses
- ✅ Customer creation issues identified (tax_number field handling)
- ❌ Repair creation likely failing due to field name mismatches
- ❌ Sale and item operations may have similar issues

---

## Next Steps

1. **Immediate Fix:** Update repair service to send `deviceImei` instead of `device_serial`
2. **Model Alignment:** Decide on deviceType vs deviceBrand and deviceSerial vs deviceImei
3. **Testing:** Verify all CRUD operations work after fixes
4. **Documentation:** Update API documentation to reflect correct field names</content>
   <parameter name="filePath">/Users/elalitareq/Documents/projects/repair_shop/API_CONTRACT_INCONSISTENCIES.md
