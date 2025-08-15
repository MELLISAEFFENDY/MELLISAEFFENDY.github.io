#!/usr/bin/env python3
"""
GitHub Auto-Update Script (Python Version)

A comprehensive script for automatically updating GitHub repositories
Features:
• Auto-detect file changes with detailed analysis
• Smart commit message generation
• Error handling and recovery
• Backup system with compression
• Lua file validation
• Rich console output with colors
• Cross-platform compatibility

Developer: MELLISAEFFENDY
Version: 1.0
"""

import os
import sys
import subprocess
import datetime
import json
import shutil
import tarfile
import argparse
from pathlib import Path
from typing import Optional, List, Dict

# Color constants for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    BOLD = '\033[1m'
    NC = '\033[0m'  # No Color

class GitHubUpdater:
    def __init__(self):
        self.repo_path = "/workspaces/MELLISAEFFENDY.github.io"
        self.github_username = "MELLISAEFFENDY"
        self.repo_name = "MELLISAEFFENDY.github.io"
        self.branch = "main"
        self.backup_dir = "/tmp/github_backup"
        
    def print_color(self, color: str, message: str):
        """Print colored message to console"""
        print(f"{color}{message}{Colors.NC}")
        
    def print_header(self):
        """Print script header"""
        print()
        self.print_color(Colors.CYAN, "═" * 64)
        self.print_color(Colors.WHITE, "           🚀 GitHub Auto-Update Script v1.0 (Python)")
        self.print_color(Colors.CYAN, "═" * 64)
        print()
        
    def run_command(self, cmd: List[str], capture_output: bool = True) -> subprocess.CompletedProcess:
        """Run shell command and return result"""
        try:
            result = subprocess.run(
                cmd, 
                capture_output=capture_output, 
                text=True, 
                cwd=self.repo_path
            )
            return result
        except subprocess.SubprocessError as e:
            self.print_color(Colors.RED, f"❌ Command failed: {' '.join(cmd)}")
            self.print_color(Colors.RED, f"Error: {e}")
            sys.exit(1)
            
    def check_git_repo(self):
        """Check if current directory is a git repository"""
        if not os.path.exists(os.path.join(self.repo_path, ".git")):
            self.print_color(Colors.RED, "❌ Error: Not a git repository!")
            self.print_color(Colors.YELLOW, f"💡 Run: git init && git remote add origin https://github.com/{self.github_username}/{self.repo_name}.git")
            sys.exit(1)
            
    def check_git_config(self):
        """Check and setup git configuration"""
        name_result = self.run_command(["git", "config", "user.name"])
        email_result = self.run_command(["git", "config", "user.email"])
        
        if not name_result.stdout.strip() or not email_result.stdout.strip():
            self.print_color(Colors.YELLOW, "⚠️  Git configuration missing. Setting up...")
            self.run_command(["git", "config", "user.name", self.github_username])
            self.run_command(["git", "config", "user.email", f"{self.github_username}@users.noreply.github.com"])
            self.print_color(Colors.GREEN, "✅ Git configuration set!")
            
    def create_backup(self):
        """Create backup of current repository state"""
        self.print_color(Colors.BLUE, "📦 Creating backup...")
        
        os.makedirs(self.backup_dir, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = os.path.join(self.backup_dir, f"backup_{timestamp}.tar.gz")
        
        try:
            with tarfile.open(backup_file, "w:gz") as tar:
                for root, dirs, files in os.walk(self.repo_path):
                    # Exclude .git and node_modules
                    dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', '__pycache__']]
                    
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, self.repo_path)
                        tar.add(file_path, arcname=arcname)
                        
            self.print_color(Colors.GREEN, f"✅ Backup created: {backup_file}")
            return backup_file
            
        except Exception as e:
            self.print_color(Colors.YELLOW, f"⚠️  Backup creation failed: {e}")
            return None
            
    def check_changes(self) -> bool:
        """Check if there are any changes to commit"""
        result = self.run_command(["git", "status", "--porcelain"])
        return bool(result.stdout.strip())
        
    def get_file_changes(self) -> Dict[str, List[str]]:
        """Get detailed information about file changes"""
        changes = {
            "modified": [],
            "new": [],
            "deleted": [],
            "renamed": []
        }
        
        # Get modified files
        result = self.run_command(["git", "diff", "--name-only"])
        changes["modified"] = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        # Get new files
        result = self.run_command(["git", "ls-files", "--others", "--exclude-standard"])
        changes["new"] = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        # Get deleted files
        result = self.run_command(["git", "diff", "--name-only", "--diff-filter=D"])
        changes["deleted"] = result.stdout.strip().split('\n') if result.stdout.strip() else []
        
        # Get renamed files
        result = self.run_command(["git", "diff", "--name-status", "--diff-filter=R"])
        if result.stdout.strip():
            renamed_lines = result.stdout.strip().split('\n')
            changes["renamed"] = [line.split('\t')[1:] for line in renamed_lines]
        
        return changes
        
    def show_changes(self):
        """Display file changes in a formatted way"""
        changes = self.get_file_changes()
        
        self.print_color(Colors.BLUE, "📊 File Changes Detected:")
        print()
        
        if changes["modified"]:
            self.print_color(Colors.YELLOW, "📝 Modified Files:")
            for file in changes["modified"]:
                if file:  # Skip empty strings
                    print(f"   • {file}")
            print()
            
        if changes["new"]:
            self.print_color(Colors.GREEN, "📄 New Files:")
            for file in changes["new"]:
                if file:  # Skip empty strings
                    print(f"   • {file}")
            print()
            
        if changes["deleted"]:
            self.print_color(Colors.RED, "🗑️  Deleted Files:")
            for file in changes["deleted"]:
                if file:  # Skip empty strings
                    print(f"   • {file}")
            print()
            
        if changes["renamed"]:
            self.print_color(Colors.PURPLE, "🔄 Renamed Files:")
            for old_file, new_file in changes["renamed"]:
                print(f"   • {old_file} → {new_file}")
            print()
            
    def generate_commit_message(self, custom_message: Optional[str] = None) -> str:
        """Generate smart commit message based on changes"""
        if custom_message:
            return custom_message
            
        changes = self.get_file_changes()
        
        modified_count = len([f for f in changes["modified"] if f])
        new_count = len([f for f in changes["new"] if f])
        deleted_count = len([f for f in changes["deleted"] if f])
        renamed_count = len(changes["renamed"])
        
        message_parts = []
        
        if new_count > 0:
            message_parts.append(f"+{new_count} new")
        if modified_count > 0:
            message_parts.append(f"~{modified_count} modified")
        if deleted_count > 0:
            message_parts.append(f"-{deleted_count} deleted")
        if renamed_count > 0:
            message_parts.append(f"→{renamed_count} renamed")
            
        if not message_parts:
            message = "🔄 Auto-update: Minor changes"
        else:
            message = f"🔄 Auto-update: {', '.join(message_parts)} files"
            
        # Add timestamp
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        message += f" [{timestamp}]"
        
        return message
        
    def validate_lua_files(self) -> bool:
        """Validate Lua file syntax"""
        self.print_color(Colors.BLUE, "🔍 Validating Lua files...")
        
        lua_files = []
        for root, _, files in os.walk(self.repo_path):
            for file in files:
                if file.endswith('.lua'):
                    lua_files.append(os.path.join(root, file))
                    
        if not lua_files:
            self.print_color(Colors.YELLOW, "⚠️  No Lua files found")
            return True
            
        # Check if luac is available
        try:
            subprocess.run(["luac", "-v"], capture_output=True, check=True)
        except (subprocess.SubprocessError, FileNotFoundError):
            self.print_color(Colors.YELLOW, "⚠️  luac not found, skipping syntax validation")
            return True
            
        validation_failed = False
        
        for lua_file in lua_files:
            try:
                result = subprocess.run(
                    ["luac", "-p", lua_file], 
                    capture_output=True, 
                    text=True
                )
                
                if result.returncode == 0:
                    self.print_color(Colors.GREEN, f"✅ {os.path.relpath(lua_file, self.repo_path)} - OK")
                else:
                    self.print_color(Colors.RED, f"❌ Lua syntax error in: {os.path.relpath(lua_file, self.repo_path)}")
                    if result.stderr:
                        print(f"   Error: {result.stderr.strip()}")
                    validation_failed = True
                    
            except Exception as e:
                self.print_color(Colors.RED, f"❌ Error validating {lua_file}: {e}")
                validation_failed = True
                
        return not validation_failed
        
    def commit_changes(self, commit_message: str):
        """Stage and commit changes"""
        self.print_color(Colors.BLUE, "📝 Staging changes...")
        result = self.run_command(["git", "add", "."])
        
        if result.returncode != 0:
            self.print_color(Colors.RED, "❌ Failed to stage changes!")
            sys.exit(1)
            
        self.print_color(Colors.BLUE, "💾 Committing changes...")
        result = self.run_command(["git", "commit", "-m", commit_message])
        
        if result.returncode != 0:
            self.print_color(Colors.RED, "❌ Failed to commit changes!")
            sys.exit(1)
            
        self.print_color(Colors.GREEN, "✅ Changes committed successfully!")
        
    def push_to_github(self, force_push: bool = False):
        """Push changes to GitHub"""
        self.print_color(Colors.BLUE, "🚀 Pushing to GitHub...")
        
        cmd = ["git", "push"]
        if force_push:
            cmd.append("--force")
        cmd.extend(["origin", self.branch])
        
        result = self.run_command(cmd)
        
        if result.returncode != 0:
            self.print_color(Colors.RED, "❌ Failed to push to GitHub!")
            if not force_push:
                self.print_color(Colors.YELLOW, "💡 Try running with --force flag if needed")
            sys.exit(1)
            
        self.print_color(Colors.GREEN, "✅ Successfully pushed to GitHub!")
        
    def show_github_info(self):
        """Display GitHub repository information"""
        self.print_color(Colors.PURPLE, "🌐 GitHub Information:")
        print(f"   Repository: https://github.com/{self.github_username}/{self.repo_name}")
        print(f"   Raw Files: https://raw.githubusercontent.com/{self.github_username}/{self.repo_name}/{self.branch}/")
        print()
        self.print_color(Colors.CYAN, "📄 Important Raw URLs:")
        print(f"   UILibrary.lua: https://raw.githubusercontent.com/{self.github_username}/{self.repo_name}/{self.branch}/UILibrary.lua")
        print(f"   Upgrade.lua: https://raw.githubusercontent.com/{self.github_username}/{self.repo_name}/{self.branch}/Upgrade.lua")
        
    def update_repository(self, args):
        """Main update process"""
        self.print_header()
        
        # Change to repository directory
        if not os.path.exists(self.repo_path):
            self.print_color(Colors.RED, f"❌ Cannot access repository path: {self.repo_path}")
            sys.exit(1)
            
        # Check git repository
        self.check_git_repo()
        self.check_git_config()
        
        # Check for changes
        if not self.check_changes():
            self.print_color(Colors.GREEN, "🎉 Repository is up to date!")
            return
            
        # Show changes
        self.show_changes()
        
        # If show only, exit here
        if args.show:
            self.print_color(Colors.BLUE, "📊 Changes shown. Use without --show to commit.")
            return
            
        # Create backup if requested
        if args.backup:
            self.create_backup()
            
        # Validate Lua files if requested
        if args.validate:
            if not self.validate_lua_files():
                self.print_color(Colors.RED, "❌ Lua validation failed! Please fix syntax errors.")
                sys.exit(1)
                
        # Generate commit message
        commit_message = self.generate_commit_message(args.message)
        self.print_color(Colors.BLUE, f"📝 Commit message: {commit_message}")
        
        # Commit changes
        self.commit_changes(commit_message)
        
        # Push to GitHub
        self.push_to_github(args.force)
        
        # Show GitHub information
        self.show_github_info()
        
        self.print_color(Colors.GREEN, "🎉 Update completed successfully!")
        print()

def main():
    parser = argparse.ArgumentParser(
        description="GitHub Auto-Update Script",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python github_update.py                           # Auto-update with generated message
  python github_update.py "Fixed bug in fishing"   # Custom commit message
  python github_update.py --force                  # Force push
  python github_update.py --validate "New UI"      # Validate and commit
        """
    )
    
    parser.add_argument("message", nargs="?", help="Custom commit message")
    parser.add_argument("-f", "--force", action="store_true", help="Force push to GitHub")
    parser.add_argument("-b", "--backup", action="store_true", help="Create backup before update")
    parser.add_argument("-v", "--validate", action="store_true", help="Validate Lua files before commit")
    parser.add_argument("-s", "--show", action="store_true", help="Show changes without committing")
    
    args = parser.parse_args()
    
    updater = GitHubUpdater()
    updater.update_repository(args)

if __name__ == "__main__":
    main()
