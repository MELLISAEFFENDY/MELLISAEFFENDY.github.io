#!/bin/bash

# Simple Git Update Script
echo "🚀 Updating repository..."

# Add all changes
git add .

# Commit with timestamp
git commit -m "Update auto_fishing_comparison.lua - $(date '+%Y-%m-%d %H:%M:%S')"

# Push to main branch
git push origin main

echo "✅ Repository updated successfully!"
