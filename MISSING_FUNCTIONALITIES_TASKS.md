# Missing Functionalities Tasks

This document outlines the missing functionalities in the repair shop management project, based on the backend and frontend analysis. Tasks are organized by category and prioritized for implementation.

## Backend Missing Functionalities

### High Priority

- [x] **Implement BarcodeController**

  - Create controller for barcode generation and scanning
  - Add endpoints for generating barcodes for items/serials
  - Implement barcode scanning API for inventory lookup

- [x] **Add Batch-Aware Stock Accounting**
  - Implement cost tracking per batch (unitCost, totalCost)
  - Add profit margin calculations
  - Update stock reduction to use FIFO/LIFO batch accounting

### Medium Priority

- [~] **Add Unit Tests**

  - Added Jest + ts-jest test setup and initial unit tests for `SerialController` and `ItemController`.
  - Next: add tests for `Batch`, `Repair`, `Sale` controllers, and integration tests for endpoints.
  - (Partial) Set up mocking strategy for Prisma; integration tests and test DB still pending.

- [~] **Create API Documentation**
- Integrated basic Swagger UI at `/docs` using `swagger-jsdoc` and `swagger-ui-express`.
- Next: add JSDoc comments to route handlers and augment descriptions/examples.
- Add API versioning and deprecation notes as subsequent tasks.

### Low Priority

- [~] **Implement Database Migrations and Seeding**

  - Migration scripts via Prisma exist (`prisma:migrate`) and `prisma:seed` is implemented.
  - Next: Add CI-oriented migration checks, and backup/restore tooling.
  - - Address plugin warnings: We attempted to add `file_picker_<platform>` packages, but these aren't published; instead either use `file_selector` for cross-platform selection or ask `file_picker` maintainers to add inline implementations.

- [~] **Implement Database Migrations and Seeding**
- Add proper migration scripts
- Create seed data for development/testing
- Implement database backup/restore functionality (done in backend + mobile UI; refine and add integration tests)

## Frontend Missing Functionalities

### High Priority

- [x] **Implement Sales UI**

  - Create sales creation/editing screens
  - Add payment processing interface
  - Implement sales history and details views

- [x] **Add Barcode Scanning Functionality**
  - Integrate camera for barcode scanning
  - Add barcode generation for items
  - Implement real-time inventory lookup via barcode

### Medium Priority

- [ ] **Create Reports and Analytics UI**

  - Build sales reports dashboard
  - Add inventory reports (low stock, value, etc.)
  - Implement profit/loss analytics

- [ ] **Implement Advanced Search and Filtering**

  - Add global search across items, customers, sales
  - Implement filters for inventory (by category, condition, etc.)
  - Add sorting and pagination for large datasets

- [ ] **Add User Authentication UI**
  - Create login/register screens
  - Implement session management
  - Add user profile management

### Low Priority

- [ ] **Implement Settings Screen**

  - Add app configuration options
  - Implement theme switching
  - Add data sync preferences

- [ ] **Add Notifications**

  - Implement push notifications for low stock alerts
  - Add in-app notifications for sales/repairs
  - Create notification settings

- [ ] **Implement Offline Support**

  - Add offline data caching
  - Implement sync when online
  - Handle conflict resolution

- [ ] **Add Testing**
  - Write widget tests for UI components
  - Add integration tests for user flows
  - Implement automated testing pipeline

## Backend Features Not Yet in Frontend

### High Priority

- [x] **Surface Serial Management**

  - Create UI for viewing/managing IMEI/serial numbers
  - Add serial assignment to items
  - Implement serial search and tracking

- [x] **Implement Customer Management UI**

  - Build customer list and detail screens
  - Add customer creation/editing
  - Integrate customers with sales and repairs

- [x] **Add Repair Management Interface**
  - Create repair tracking screens
  - Add repair status updates
  - Implement repair history and details

### Medium Priority

- [x] **Add Batch Management UI**

  - Create batch viewing and editing screens
  - Add batch cost tracking display
  - Implement batch-wise inventory reports

- [ ] **Implement Stock Adjustment UI**
  - Add manual stock adjustment screens
  - Implement stock usage logging
  - Add stock history tracking

### Low Priority

- [ ] **Add Category/Condition/Quality Management**
  - Create admin screens for managing categories
  - Add condition and quality settings
  - Implement bulk category updates

## Recently Completed Features

### CRUD Operations Implementation

- [x] **Batch CRUD Operations**

  - Added update and delete methods to BatchController
  - Implemented batch editing UI with form validation
  - Added batch deletion with business logic checks
  - Updated batch list with edit/delete actions

- [x] **Item CRUD Operations**

  - Enhanced ItemController update method
  - Modified item form to support both create and edit modes
  - Added proper form field population for editing
  - Updated routing for item editing

- [x] **Serial CRUD Operations**
  - Added update method to SerialController
  - Implemented serial editing capabilities
  - Added proper validation for IMEI uniqueness

### Integration Improvements

- [x] **Frontend-Backend Linkage**

  - Verified all CRUD operations work end-to-end
  - Added proper error handling and user feedback
  - Implemented data refresh after operations
  - Added loading states and validation

- [x] **Repair Management Interface Implementation**

  - Comprehensive repair list page with search and advanced filtering (status, priority)
  - Detailed repair view with complete repair information and status tracking
  - Full repair creation and editing forms with customer selection and device details
  - Status update functionality and repair workflow management
  - Integration with customer management and proper navigation routing

- **Dependencies**: Ensure backend APIs are stable before implementing frontend features
- **Testing**: Add tests for each new feature as it's implemented
- **UI/UX**: Follow Flutter material design guidelines for consistency
- **Performance**: Implement lazy loading and caching for large datasets
- **Security**: Add proper validation and error handling for all new features

## Next Steps

1. Prioritize BarcodeController and Sales UI for immediate implementation
2. Review and update this task list as features are completed
3. Coordinate backend and frontend development to avoid conflicts
