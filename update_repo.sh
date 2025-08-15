#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# AUTO UPDATE SCRIPT FOR MELLISAEFFENDY.github.io
# ═══════════════════════════════════════════════════════════════

echo "🚀 Starting repository update process..."
echo "📁 Repository: MELLISAEFFENDY.github.io"
echo "📅 Date: $(date)"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "auto_fishing_comparison.lua" ]; then
    print_error "auto_fishing_comparison.lua not found!"
    print_error "Please run this script from the repository root directory."
    exit 1
fi

print_success "Found auto_fishing_comparison.lua ✓"

# Check git status
print_status "Checking git status..."
git status --porcelain

# Check if there are any changes
if [ -z "$(git status --porcelain)" ]; then
    print_warning "No changes detected. Repository is already up to date."
    echo ""
    echo "📊 Current repository status:"
    git log --oneline -5
    exit 0
fi

# Show what files will be updated
print_status "Files to be updated:"
git status --short

echo ""
read -p "🤔 Do you want to continue with the update? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Update cancelled by user."
    exit 0
fi

# Add all changes
print_status "Adding changes to staging area..."
git add .

if [ $? -eq 0 ]; then
    print_success "Files staged successfully ✓"
else
    print_error "Failed to stage files!"
    exit 1
fi

# Get commit message
echo ""
echo "💬 Enter commit message (or press Enter for default):"
read -r commit_message

if [ -z "$commit_message" ]; then
    commit_message="🎣 Update BOT FISH IT V1 - Android-compatible fishing script with modern table UI and dual AFK systems"
fi

# Commit changes
print_status "Committing changes..."
git commit -m "$commit_message"

if [ $? -eq 0 ]; then
    print_success "Changes committed successfully ✓"
else
    print_error "Failed to commit changes!"
    exit 1
fi

# Push to remote repository
print_status "Pushing to remote repository..."
git push origin main

if [ $? -eq 0 ]; then
    print_success "Repository updated successfully! 🎉"
else
    print_error "Failed to push to remote repository!"
    print_warning "You may need to pull first if there are remote changes."
    echo ""
    echo "🔧 Try running:"
    echo "   git pull origin main"
    echo "   git push origin main"
    exit 1
fi

# Show final status
echo ""
echo "════════════════════════════════════════════════════════════"
print_success "UPDATE COMPLETED SUCCESSFULLY!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "📊 Latest commits:"
git log --oneline -3

echo ""
echo "🌐 Your script is now available at:"
echo "   https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/auto_fishing_comparison.lua"
echo ""
echo "🎮 To use in Roblox:"
echo '   loadstring(game:HttpGet("https://raw.githubusercontent.com/MELLISAEFFENDY/MELLISAEFFENDY.github.io/main/auto_fishing_comparison.lua"))()'
echo ""
print_success "All done! Happy fishing! 🎣"
