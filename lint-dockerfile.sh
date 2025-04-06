#!/bin/bash

set -e

DOCKERFILE="${1:-Dockerfile}"

# Check if the Dockerfile exists
if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ Error: File '$DOCKERFILE' does not exist."
  exit 1
fi

echo "✅ Running hadolint via Docker on '$DOCKERFILE'..."

docker run --rm -i hadolint/hadolint < "$DOCKERFILE"

