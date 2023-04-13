#!/bin/bash
REMOTE=${1:-root@example.com}

# backup book and sync from remote

ssh -t "mkdir -p /src/fava"

echo "sync local file to remote"
rsync -av \
  --exclude="node_modules" \
  --exclude=".git" \
  --exclude=".DS_Store" \
  . \
  $REMOTE:/src/fava

ssh -t $REMOTE "bash /src/fava/.scripts/start.sh"

