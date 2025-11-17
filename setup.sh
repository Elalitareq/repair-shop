#!/bin/bash

# Repair Shop Management System - Development Setup Script

echo "🚀 Setting up Repair Shop Management System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "README.md" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

echo "📱 Setting up Flutter Mobile App..."
cd mobile

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter first."
    echo "Visit: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Install Flutter dependencies
print_status "Installing Flutter dependencies..."
flutter pub get

# Check Flutter setup
print_status "Checking Flutter setup..."
flutter doctor

cd ..

echo ""
echo "🖥️  Setting up Go Backend..."
cd server

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go first."
    echo "Visit: https://golang.org/download/"
    exit 1
fi

# Initialize Go module and install dependencies
print_status "Installing Go dependencies..."
go mod tidy

# Create necessary directories
mkdir -p database uploads

print_status "Creating environment file..."
if [ ! -f ".env" ]; then
    cp .env.example .env 2>/dev/null || echo "No .env.example found, using existing .env"
fi

cd ..

echo ""
print_status "Setup completed successfully!"
echo ""
echo "🎯 Next steps:"
echo "1. Backend: cd server && go run main.go"
echo "2. Frontend: cd mobile && flutter run"
echo ""
echo "📖 Documentation:"
echo "- Consolidated project tasks: project_tasks.md"
echo "- More docs archived under docs-archive/"
echo ""
echo "🌐 Default URLs:"
echo "- Backend API: http://localhost:8080"
echo "- Health Check: http://localhost:8080/health"
echo ""
print_warning "Make sure to update the JWT_SECRET in server/.env for production!"