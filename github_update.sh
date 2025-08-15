#!/bin/bash

#===============================================================================
# GitHub Auto-Update Script
# 
# This script automatically commits and pushes changes to GitHub repository
# Features:
# • Auto-detect file changes
# • Smart commit messages
# • Error handling
# • Backup system
# • Force push option
#
# Developer: MELLISAEFFENDY
# Version: 1.0
#===============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
REPO_PATH="/workspaces/MELLISAEFFENDY.github.io"
GITHUB_USERNAME="MELLISAEFFENDY"
REPO_NAME="MELLISAEFFENDY.github.io"
BRANCH="main"
BACKUP_DIR="/tmp/github_backup"

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print header
print_header() {
    echo ""
    print_color $CYAN "════════════════════════════════════════════════════════════════"
    print_color $WHITE "           🚀 GitHub Auto-Update Script v1.0"
    print_color $CYAN "════════════════════════════════════════════════════════════════"
    echo ""
}

# Function to check if we're in a git repository
check_git_repo() {
    if [ ! -d ".git" ]; then
        print_color $RED "❌ Error: Not a git repository!"
        print_color $YELLOW "💡 Run: git init && git remote add origin https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"
        exit 1
    fi
}

# Function to check git configuration
check_git_config() {
    if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
        print_color $YELLOW "⚠️  Git configuration missing. Setting up..."
        git config user.name "${GITHUB_USERNAME}"
        git config user.email "${GITHUB_USERNAME}@users.noreply.github.com"
        print_color $GREEN "✅ Git configuration set!"
    fi
}

# Function to backup current state
create_backup() {
    print_color $BLUE "📦 Creating backup..."
    mkdir -p "$BACKUP_DIR"
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_file="${BACKUP_DIR}/backup_${timestamp}.tar.gz"
    
    tar -czf "$backup_file" --exclude='.git' --exclude='node_modules' . 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_color $GREEN "✅ Backup created: $backup_file"
    else
        print_color $YELLOW "⚠️  Backup creation failed, continuing anyway..."
    fi
}

# Function to check for changes
check_changes() {
    if [ -z "$(git status --porcelain)" ]; then
        print_color $YELLOW "📝 No changes detected."
        return 1
    fi
    return 0
}

# Function to show file changes
show_changes() {
    print_color $BLUE "📊 File Changes Detected:"
    echo ""
    
    # Show modified files
    modified_files=$(git diff --name-only)
    if [ ! -z "$modified_files" ]; then
        print_color $YELLOW "📝 Modified Files:"
        echo "$modified_files" | while read file; do
            echo "   • $file"
        done
        echo ""
    fi
    
    # Show new files
    new_files=$(git ls-files --others --exclude-standard)
    if [ ! -z "$new_files" ]; then
        print_color $GREEN "📄 New Files:"
        echo "$new_files" | while read file; do
            echo "   • $file"
        done
        echo ""
    fi
    
    # Show deleted files
    deleted_files=$(git diff --name-only --diff-filter=D)
    if [ ! -z "$deleted_files" ]; then
        print_color $RED "🗑️  Deleted Files:"
        echo "$deleted_files" | while read file; do
            echo "   • $file"
        done
        echo ""
    fi
}

# Function to generate smart commit message
generate_commit_message() {
    local custom_message="$1"
    
    if [ ! -z "$custom_message" ]; then
        echo "$custom_message"
        return
    fi
    
    # Auto-generate commit message based on changes
    modified_count=$(git diff --name-only | wc -l)
    new_count=$(git ls-files --others --exclude-standard | wc -l)
    deleted_count=$(git diff --name-only --diff-filter=D | wc -l)
    
    local message="🔄 Auto-update: "
    
    if [ $new_count -gt 0 ]; then
        message="${message}+${new_count} new"
    fi
    
    if [ $modified_count -gt 0 ]; then
        if [ $new_count -gt 0 ]; then
            message="${message}, "
        fi
        message="${message}~${modified_count} modified"
    fi
    
    if [ $deleted_count -gt 0 ]; then
        if [ $new_count -gt 0 ] || [ $modified_count -gt 0 ]; then
            message="${message}, "
        fi
        message="${message}-${deleted_count} deleted"
    fi
    
    message="${message} files"
    
    # Add timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    message="${message} [${timestamp}]"
    
    echo "$message"
}

# Function to commit changes
commit_changes() {
    local commit_message="$1"
    
    print_color $BLUE "📝 Staging changes..."
    git add .
    
    if [ $? -ne 0 ]; then
        print_color $RED "❌ Failed to stage changes!"
        exit 1
    fi
    
    print_color $BLUE "💾 Committing changes..."
    git commit -m "$commit_message"
    
    if [ $? -ne 0 ]; then
        print_color $RED "❌ Failed to commit changes!"
        exit 1
    fi
    
    print_color $GREEN "✅ Changes committed successfully!"
}

# Function to push to GitHub
push_to_github() {
    local force_push="$1"
    
    print_color $BLUE "🚀 Pushing to GitHub..."
    
    if [ "$force_push" = "force" ]; then
        git push --force origin $BRANCH
    else
        git push origin $BRANCH
    fi
    
    if [ $? -ne 0 ]; then
        print_color $RED "❌ Failed to push to GitHub!"
        print_color $YELLOW "💡 Try running with --force flag if needed"
        exit 1
    fi
    
    print_color $GREEN "✅ Successfully pushed to GitHub!"
}

# Function to show GitHub URLs
show_github_info() {
    print_color $PURPLE "🌐 GitHub Information:"
    echo "   Repository: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
    echo "   Raw Files: https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/${BRANCH}/"
    echo ""
    print_color $CYAN "📄 Important Raw URLs:"
    echo "   UILibrary.lua: https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/${BRANCH}/UILibrary.lua"
    echo "   Upgrade.lua: https://raw.githubusercontent.com/${GITHUB_USERNAME}/${REPO_NAME}/${BRANCH}/Upgrade.lua"
}

# Function to validate Lua files
validate_lua_files() {
    print_color $BLUE "🔍 Validating Lua files..."
    
    lua_files=$(find . -name "*.lua" -type f)
    validation_failed=false
    
    for file in $lua_files; do
        if command -v luac >/dev/null 2>&1; then
            if ! luac -p "$file" >/dev/null 2>&1; then
                print_color $RED "❌ Lua syntax error in: $file"
                validation_failed=true
            else
                print_color $GREEN "✅ $file - OK"
            fi
        else
            print_color $YELLOW "⚠️  luac not found, skipping syntax validation"
            break
        fi
    done
    
    if [ "$validation_failed" = true ]; then
        print_color $RED "❌ Lua validation failed! Please fix syntax errors."
        exit 1
    fi
}

# Function to show help
show_help() {
    print_header
    echo "Usage: ./github_update.sh [OPTIONS] [MESSAGE]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -f, --force         Force push to GitHub"
    echo "  -b, --backup        Create backup before update"
    echo "  -v, --validate      Validate Lua files before commit"
    echo "  -s, --show          Show changes without committing"
    echo ""
    echo "Examples:"
    echo "  ./github_update.sh                           # Auto-update with generated message"
    echo "  ./github_update.sh \"Fixed bug in fishing\"   # Custom commit message"
    echo "  ./github_update.sh --force                   # Force push"
    echo "  ./github_update.sh --validate \"New UI\"     # Validate and commit"
    echo ""
}

# Main function
main() {
    # Parse arguments
    force_push=false
    create_backup_flag=false
    validate_flag=false
    show_only=false
    custom_message=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                force_push=true
                shift
                ;;
            -b|--backup)
                create_backup_flag=true
                shift
                ;;
            -v|--validate)
                validate_flag=true
                shift
                ;;
            -s|--show)
                show_only=true
                shift
                ;;
            *)
                custom_message="$1"
                shift
                ;;
        esac
    done
    
    print_header
    
    # Change to repository directory
    cd "$REPO_PATH" || {
        print_color $RED "❌ Cannot access repository path: $REPO_PATH"
        exit 1
    }
    
    # Check git repository
    check_git_repo
    check_git_config
    
    # Check for changes
    if ! check_changes; then
        print_color $GREEN "🎉 Repository is up to date!"
        exit 0
    fi
    
    # Show changes
    show_changes
    
    # If show only, exit here
    if [ "$show_only" = true ]; then
        print_color $BLUE "📊 Changes shown. Use without --show to commit."
        exit 0
    fi
    
    # Create backup if requested
    if [ "$create_backup_flag" = true ]; then
        create_backup
    fi
    
    # Validate Lua files if requested
    if [ "$validate_flag" = true ]; then
        validate_lua_files
    fi
    
    # Generate commit message
    commit_message=$(generate_commit_message "$custom_message")
    print_color $BLUE "📝 Commit message: $commit_message"
    
    # Commit changes
    commit_changes "$commit_message"
    
    # Push to GitHub
    if [ "$force_push" = true ]; then
        push_to_github "force"
    else
        push_to_github
    fi
    
    # Show GitHub information
    show_github_info
    
    print_color $GREEN "🎉 Update completed successfully!"
    echo ""
}

# Run main function with all arguments
main "$@"
