#!/bin/bash

#===============================================================================
# Quick GitHub Update - Simple Interface
# 
# This is a simplified interface for the GitHub auto-update scripts
# Provides easy access to common update scenarios
#
# Developer: MELLISAEFFENDY
# Version: 1.0
#===============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Repository path
REPO_PATH="/workspaces/MELLISAEFFENDY.github.io"

# Function to print colored output
print_color() {
    echo -e "${1}${2}${NC}"
}

# Function to show menu
show_menu() {
    clear
    print_color $CYAN "════════════════════════════════════════════════════════════════"
    print_color $WHITE "                  🚀 Quick GitHub Update Menu"
    print_color $CYAN "════════════════════════════════════════════════════════════════"
    echo ""
    print_color $YELLOW "Choose an option:"
    echo ""
    echo "  1) 📝 Quick Update (Auto-generated message)"
    echo "  2) ✍️  Custom Update (Your commit message)"
    echo "  3) 🔍 Show Changes Only"
    echo "  4) ✅ Validate & Update (Check Lua files)"
    echo "  5) 💪 Force Push Update"
    echo "  6) 📦 Backup & Update"
    echo "  7) 🏗️  Full Update (Backup + Validate + Push)"
    echo "  8) ❌ Exit"
    echo ""
    print_color $BLUE "═══════════════════════════════════════════════════════════════"
}

# Function to handle quick update
quick_update() {
    print_color $GREEN "🚀 Running quick update..."
    cd "$REPO_PATH"
    ./github_update.sh
}

# Function to handle custom update
custom_update() {
    print_color $YELLOW "✍️  Enter your commit message:"
    read -r commit_message
    
    if [ -z "$commit_message" ]; then
        print_color $RED "❌ No message provided. Using auto-generated message."
        quick_update
    else
        print_color $GREEN "🚀 Running update with custom message..."
        cd "$REPO_PATH"
        ./github_update.sh "$commit_message"
    fi
}

# Function to show changes only
show_changes() {
    print_color $BLUE "🔍 Showing repository changes..."
    cd "$REPO_PATH"
    ./github_update.sh --show
}

# Function to validate and update
validate_update() {
    print_color $GREEN "✅ Running validation and update..."
    cd "$REPO_PATH"
    ./github_update.sh --validate
}

# Function to force push
force_update() {
    print_color $YELLOW "⚠️  This will force push to GitHub. Are you sure? (y/N)"
    read -r confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        print_color $GREEN "💪 Running force update..."
        cd "$REPO_PATH"
        ./github_update.sh --force
    else
        print_color $BLUE "Operation cancelled."
    fi
}

# Function to backup and update
backup_update() {
    print_color $GREEN "📦 Running backup and update..."
    cd "$REPO_PATH"
    ./github_update.sh --backup
}

# Function to full update
full_update() {
    print_color $GREEN "🏗️  Running full update (backup + validate + push)..."
    cd "$REPO_PATH"
    ./github_update.sh --backup --validate
}

# Function to wait for user input
wait_for_input() {
    echo ""
    print_color $CYAN "Press Enter to continue..."
    read -r
}

# Main menu loop
main() {
    while true; do
        show_menu
        print_color $WHITE "Enter your choice (1-8): "
        read -r choice
        
        case $choice in
            1)
                quick_update
                wait_for_input
                ;;
            2)
                custom_update
                wait_for_input
                ;;
            3)
                show_changes
                wait_for_input
                ;;
            4)
                validate_update
                wait_for_input
                ;;
            5)
                force_update
                wait_for_input
                ;;
            6)
                backup_update
                wait_for_input
                ;;
            7)
                full_update
                wait_for_input
                ;;
            8)
                print_color $GREEN "👋 Goodbye!"
                exit 0
                ;;
            *)
                print_color $RED "❌ Invalid choice. Please select 1-8."
                sleep 2
                ;;
        esac
    done
}

# Check if we're in the right directory
if [ ! -d "$REPO_PATH" ]; then
    print_color $RED "❌ Repository path not found: $REPO_PATH"
    exit 1
fi

# Check if update scripts exist
if [ ! -f "$REPO_PATH/github_update.sh" ]; then
    print_color $RED "❌ github_update.sh not found in repository"
    exit 1
fi

# Run main menu
main
