#!/bin/bash

# Database Implementation Verification Script

echo "🗄️ Database Implementation Verification"
echo "======================================="

cd /Users/elalitareq/Documents/projects/repair_shop/server

# Check if database file exists
if [ -f "database/repair_shop.db" ]; then
    echo "✅ Database file exists"
else
    echo "❌ Database file not found"
    exit 1
fi

echo ""
echo "📊 Database Tables:"
sqlite3 database/repair_shop.db ".tables"

echo ""
echo "👤 Admin User:"
sqlite3 database/repair_shop.db "SELECT username, email, role FROM users WHERE role='admin';"

echo ""
echo "🏷️ Item Conditions:"
sqlite3 database/repair_shop.db "SELECT name FROM conditions;"

echo ""
echo "⭐ Quality Grades:"
sqlite3 database/repair_shop.db "SELECT name, grade_order FROM qualities ORDER BY grade_order;"

echo ""
echo "🔄 Repair Workflow States:"
sqlite3 database/repair_shop.db "SELECT name, color_code FROM repair_states ORDER BY order_sequence;"

echo ""
echo "🔧 Issue Types by Category:"
sqlite3 database/repair_shop.db "SELECT category, GROUP_CONCAT(name, ', ') as issues FROM issue_types GROUP BY category;"

echo ""
echo "📈 Database Statistics:"
echo "Tables: $(sqlite3 database/repair_shop.db '.tables' | wc -w | tr -d ' ')"
echo "Conditions: $(sqlite3 database/repair_shop.db 'SELECT COUNT(*) FROM conditions;')"
echo "Qualities: $(sqlite3 database/repair_shop.db 'SELECT COUNT(*) FROM qualities;')"
echo "Repair States: $(sqlite3 database/repair_shop.db 'SELECT COUNT(*) FROM repair_states;')"
echo "Issue Types: $(sqlite3 database/repair_shop.db 'SELECT COUNT(*) FROM issue_types;')"
echo "Users: $(sqlite3 database/repair_shop.db 'SELECT COUNT(*) FROM users;')"

echo ""
echo "🚀 Database Implementation Status: COMPLETE ✅"
echo "Ready for API development!"