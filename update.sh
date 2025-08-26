#!/bin/bash

# Update fork with upstream changes
# This script fetches the latest changes from upstream and merges them into the current branch

set -e

UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
ORIGIN_REMOTE="origin"

echo "🔄 Updating fork with upstream changes..."

# Check if upstream remote exists
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    echo "❌ Upstream remote '${UPSTREAM_REMOTE}' not found."
    echo "Add it with: git remote add upstream https://github.com/vicinaehq/vicinae.git"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: ${CURRENT_BRANCH}"

# Fetch latest changes from upstream
echo "⬇️  Fetching latest changes from upstream..."
git fetch ${UPSTREAM_REMOTE}

# Check if there are new commits in upstream
NEW_COMMITS=$(git log --oneline ${CURRENT_BRANCH}..${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH} | wc -l)

if [ "${NEW_COMMITS}" -eq 0 ]; then
    echo "✅ Already up to date with upstream!"
    exit 0
fi

echo "📦 Found ${NEW_COMMITS} new commit(s) in upstream"

# Show what commits will be merged
echo "📋 New commits:"
git log --oneline --graph ${CURRENT_BRANCH}..${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}

# Confirm before merging
read -p "🤔 Merge these changes? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted"
    exit 0
fi

# Merge upstream changes
echo "🔄 Merging upstream changes..."
git merge ${UPSTREAM_REMOTE}/${UPSTREAM_BRANCH}

# Push to origin
read -p "📤 Push merged changes to your fork? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⬆️  Pushing to ${ORIGIN_REMOTE}..."
    git push ${ORIGIN_REMOTE} ${CURRENT_BRANCH}
    echo "✅ Fork updated successfully!"
else
    echo "⚠️  Changes merged locally but not pushed to fork"
fi