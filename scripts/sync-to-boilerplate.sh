#!/bin/bash

# Reverse Boilerplate Synchronization Script (project → boilerplate)
# Supports: --file <filename>, --help

set -e

# --- Option parsing ---
ONLY_FILE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --file)
      ONLY_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [--file <filename>]"
      echo "  --file <filename>   Only sync/merge the specified file or directory to boilerplate."
      echo "  --help, -h          Show this help message."
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Check if boilerplate submodule exists
if [ ! -d "boilerplate" ]; then
    echo -e "${RED}❌ Boilerplate submodule not found!${NC}"
    echo -e "${YELLOW}💡 To add boilerplate as submodule, run:${NC}"
    echo "   git submodule add <boilerplate-repo-url> boilerplate"
    exit 1
fi

echo "🔄 Starting reverse boilerplate synchronization (project → boilerplate)..."

# Output color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Root files sync/merge (project → boilerplate) ---
for file in $(ls -A); do
    if [ -f "$file" ]; then
        # Skip files that should not be synced to boilerplate
        case "$file" in
            node_modules|.next|.git|src|.boilerplate-backup-*|.DS_Store|.env*|pnpm-lock.yaml|tsconfig.tsbuildinfo|next-env.d.ts)
                continue
                ;;
        esac
        
        # --file 옵션 처리
        if [ -n "$ONLY_FILE" ] && [ "$file" != "$ONLY_FILE" ]; then
            continue
        fi
        
        if [ -f "boilerplate/$file" ]; then
            echo -e "${BLUE}📝 $file diff (project → boilerplate):${NC}"
            git diff --no-index "$file" "boilerplate/$file" || true
            read -p "🤔 merge $file to boilerplate? (y/n): " yn
            if [ "$yn" = "y" ]; then
                git merge-file "boilerplate/$file" "boilerplate/$file" "$file"
                echo -e "${GREEN}🔀 $file merged to boilerplate!${NC}"
                echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
            else
                echo -e "${YELLOW}⏭️ $file skipped${NC}"
            fi
        else
            # Always prompt before copying
            read -p "🆕 copy $file to boilerplate? (y/n): " yn
            if [ "$yn" = "y" ]; then
                cp "$file" boilerplate/
                echo -e "${GREEN}🆕 $file copied to boilerplate${NC}"
            else
                echo -e "${YELLOW}⏭️ $file copy skipped${NC}"
            fi
        fi
    fi
done

# --- Directory sync/merge (project → boilerplate) ---
sync_dirs=()
if [ -f "scripts/boilerplate-sync-dirs.txt" ]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    sync_dirs+=("$line")
  done < scripts/boilerplate-sync-dirs.txt
fi

for dir in "${sync_dirs[@]}"; do
  if [ -d "$dir" ]; then
    # --file 옵션 처리 (디렉토리 이름이 정확히 일치할 때만)
    if [ -n "$ONLY_FILE" ] && [ "$dir" != "$ONLY_FILE" ]; then
      continue
    fi
    echo -e "\n${BLUE}🔄 Syncing $dir directory to boilerplate...${NC}"
    mkdir -p "boilerplate/$dir"
    for file in $(ls -A "$dir"); do
      if [ -f "$dir/$file" ]; then
        if [ -f "boilerplate/$dir/$file" ]; then
          echo -e "${BLUE}📝 $dir/$file diff (project → boilerplate):${NC}"
          git diff --no-index "$dir/$file" "boilerplate/$dir/$file" || true
          read -p "🤔 merge $dir/$file to boilerplate? (y/n): " yn
          if [ "$yn" = "y" ]; then
            git merge-file "boilerplate/$dir/$file" "boilerplate/$dir/$file" "$dir/$file"
            echo -e "${GREEN}🔀 $dir/$file merged to boilerplate!${NC}"
            echo -e "${YELLOW}🚧 If there are conflicts, please resolve the conflict markers manually.${NC}"
          else
            echo -e "${YELLOW}⏭️ $dir/$file skipped${NC}"
          fi
        else
          # Always prompt before copying
          read -p "🆕 copy $dir/$file to boilerplate? (y/n): " yn
          if [ "$yn" = "y" ]; then
            cp "$dir/$file" "boilerplate/$dir/"
            echo -e "${GREEN}🆕 $dir/$file copied to boilerplate${NC}"
          else
            echo -e "${YELLOW}⏭️ $dir/$file copy skipped${NC}"
          fi
        fi
      fi
    done
  fi
done

echo -e "\n${GREEN}✅ Reverse boilerplate sync complete!${NC}"
echo -e "${YELLOW}💾 Please commit and push changes in boilerplate submodule:${NC}"
echo -e "${BLUE}💡 Next steps:${NC}"
echo "   1. 🚧 If there are conflicts, resolve them manually in boilerplate/ directory"
echo "   2. 💾 cd boilerplate && git add . && git commit -m 'feat: sync config files from project'"
echo "   3. 🚀 git push (to update boilerplate repository)"
echo "   4. 🔄 cd .. && git submodule update --remote boilerplate (to sync back)"

read -p "💾 Do you want to git add/commit/push the changes in boilerplate now? (y/n): " yn
echo ""
if [ "$yn" = "y" ]; then
  echo -e "${GREEN}▶️ Run the following commands to commit and push your changes in boilerplate:${NC}"
  echo "cd boilerplate"
  echo "git add ."
  echo "git commit -m 'feat: sync config files from project'"
  echo "git push"
  echo "cd .."
else
  echo -e "${YELLOW}⏭️ Skipped git commit/push in boilerplate.${NC}"
fi 