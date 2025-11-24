# Repair Shop Management System - TypeScript Backend

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn

### Installation

````bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Generate Prisma client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate

# Seed database with initial data
## Development & Testing

- Run the API locally in dev mode:

```bash
npm run dev
````

// Tests removed from this project; use scripts and tools appropriate to your workflow.

- Swagger UI is available at /docs when the server is running: http://localhost:8080/docs

## Backup & Restore

- **Download a backup** (admin):

  GET /api/backups/download

  This endpoint returns the raw SQLite DB file as an attachment. Requires an admin user (`role: admin`).

- **Restore a backup** (admin):

  POST /api/backups/restore

  Accepts a multipart form upload with `file` pointing to a `.db` or `.sqlite` file.
  The server will disconnect Prisma, replace the configured database file, reconnect and try a no-op query to validate the restore.

  Example using curl:

```bash
curl -H "Authorization: Bearer <token>" -X POST -F "file=@repair_shop_backup.db" http://localhost:8080/api/backups/restore
```

Note: Restoring a backup will overwrite your current database. Only use in development or with confirmed backups.

npm run prisma:seed

# Start development server

npm run dev

````

### Production Build

```bash
# Build TypeScript
npm run build

# Start production server
npm start
````

## 📋 API Endpoints

### Authentication

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/refresh` - Refresh JWT token

### Categories

- `GET /api/categories` - Get all categories
- `GET /api/categories/:id` - Get category by ID
- `POST /api/categories` - Create category
- `PUT /api/categories/:id` - Update category
- `DELETE /api/categories/:id` - Delete category

### Customers

- `GET /api/customers` - Get all customers
- `GET /api/customers/search?q=term` - Search customers
- `GET /api/customers/:id` - Get customer by ID
- `POST /api/customers` - Create customer
- `PUT /api/customers/:id` - Update customer
- `DELETE /api/customers/:id` - Delete customer

### Items

- `GET /api/items` - Get all items
- `GET /api/items/search?q=term` - Search items
- `GET /api/items/low-stock` - Get low stock items
- `GET /api/items/:id` - Get item by ID
- `POST /api/items` - Create item
- `PUT /api/items/:id` - Update item
- `DELETE /api/items/:id` - Delete item
- `PUT /api/items/:id/stock` - Adjust stock

### Repairs

- `GET /api/repairs` - Get all repairs
- `GET /api/repairs/:id` - Get repair by ID
- `POST /api/repairs` - Create repair
- `PUT /api/repairs/:id` - Update repair
- `DELETE /api/repairs/:id` - Delete repair
- `PUT /api/repairs/:id/state` - Update repair state

### Sales

- `GET /api/sales` - Get all sales
- `GET /api/sales/:id` - Get sale by ID
- `POST /api/sales` - Create sale
- `PUT /api/sales/:id` - Update sale
- `DELETE /api/sales/:id` - Delete sale
- `PUT /api/sales/:id/status` - Update sale status
- `GET /api/sales/reports/daily` - Daily sales report
- `GET /api/sales/reports/monthly` - Monthly sales report

### Reference Data

- `GET /api/reference/conditions` - Get all conditions
- `GET /api/reference/qualities` - Get all qualities
- `GET /api/reference/issue-types` - Get all issue types
- `GET /api/reference/repair-states` - Get all repair states
- `GET /api/reference/payment-methods` - Get all payment methods

## 🔐 Default Credentials

**Username:** admin  
**Password:** admin123

## 🗄️ Database

This server uses SQLite with Prisma ORM. The database file is created at `./database/repair_shop.db`.

### Prisma Commands

```bash
# Open Prisma Studio (GUI for database)
npm run prisma:studio

# Create a new migration
npx prisma migrate dev --name migration_name

# Reset database
npx prisma migrate reset
```

## 🛠️ Technology Stack

- **Runtime:** Node.js
- **Framework:** Express.js
- **Language:** TypeScript
- **ORM:** Prisma
- **Database:** SQLite
- **Authentication:** JWT
- **Validation:** express-validator
- **Logging:** Winston

## 📁 Project Structure

```
server-ts/
├── prisma/
│   ├── schema.prisma    # Database schema
│   └── seed.ts          # Seed data
├── src/
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Auth, error handling
│   ├── routes/          # API routes
│   ├── utils/           # Utilities
│   └── index.ts         # App entry point
├── .env.example         # Environment template
├── package.json
└── tsconfig.json
```

## 🔧 Environment Variables

See `.env.example` for all available configuration options.

## 📝 License

ISC
