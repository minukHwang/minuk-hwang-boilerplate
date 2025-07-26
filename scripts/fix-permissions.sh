#!/bin/bash

# Fix file permissions to match boilerplate standards
# This script normalizes file permissions to avoid unnecessary diffs

set -e



echo "🔧 Fixing file permissions..."

# Fix scripts directory permissions
if [ -d "scripts" ]; then
  echo "📁 Fixing scripts directory permissions..."
  find scripts -type f -exec chmod u=rw,go=r {} \;
  find scripts -type d -exec chmod u=rwx,go=rx {} \;
fi

# Fix root config files
echo "📄 Fixing root config file permissions..."
for file in .gitignore commitlint.config.cjs .eslintrc.json .prettierrc .prettierignore .eslintignore tsconfig.json next.config.mjs package.json; do
  if [ -f "$file" ]; then
    chmod u=rw,go=r "$file"
    echo "  ✅ $file"
  fi
done

# Fix other common directories
for dir in .husky .github .vscode; do
  if [ -d "$dir" ]; then
    echo "📁 Fixing $dir directory permissions..."
    find "$dir" -type f -exec chmod u=rw,go=r {} \;
    find "$dir" -type d -exec chmod u=rwx,go=rx {} \;
  fi
done

echo "✅ File permissions fixed!"
echo "💡 Now run the sync script again to check for real differences." 