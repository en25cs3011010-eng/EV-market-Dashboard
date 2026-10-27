#!/bin/bash
# Usage: bash push_to_github.sh https://github.com/YOUR_USERNAME/YOUR_REPO.git
set -e
[ -z "$1" ] && echo "Pass your repository URL" && exit 1
git init
git add .
git commit -m "EV market Tableau dashboard project"
git branch -M main
git remote add origin "$1" 2>/dev/null || git remote set-url origin "$1"
git push -u origin main
