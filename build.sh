#!/usr/bin/env sh
set -eu

REPO_OWNER="clash-verge-rev"
REPO_NAME="clash-verge-rev"
MAX_RELEASES="${MAX_RELEASES:-30}"
INCLUDE_PRERELEASE="${INCLUDE_PRERELEASE:-0}"
IMAGE="${IMAGE:-clash-verge-rev}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
PUSH="${PUSH:-0}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing command: $1" >&2; exit 1; }
}

need_cmd curl
need_cmd sed
need_cmd awk
need_cmd docker

fetch_tags_atom() {
  curl -fsSL "https://github.com/${REPO_OWNER}/${REPO_NAME}/releases.atom" \
    | sed -n 's#.*<title>\(.*\)</title>.*#\1#p' \
    | awk 'NR>1{print}' \
    | awk '!seen[$0]++' \
    | (if [ "$INCLUDE_PRERELEASE" = "1" ]; then cat; else awk '$0 !~ /-/' ; fi) \
    | head -n "$MAX_RELEASES"
}

echo "Fetching versions from GitHub releases.atom..." >&2
TAGS=$(fetch_tags_atom || true)

if [ -z "$TAGS" ]; then
  echo "Failed to fetch tags. Check network connectivity." >&2
  exit 1
fi

i=1
printf '%s\n' "$TAGS" | while IFS= read -r t; do
  printf '%2d) %s\n' "$i" "$t"
  i=$((i+1))
done

COUNT=$(printf '%s\n' "$TAGS" | wc -l | awk '{print $1}')

printf "Select a version number (1-%s, press Enter for 1): " "$COUNT"
read -r CHOICE || true

if [ -z "${CHOICE:-}" ]; then
  CHOICE=1
fi

case "$CHOICE" in
  *[!0-9]*|'')
    echo "Invalid selection: $CHOICE" >&2
    exit 1
    ;;
esac

if [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "$COUNT" ]; then
  echo "Selection out of range: $CHOICE" >&2
  exit 1
fi

TAG=$(printf '%s\n' "$TAGS" | sed -n "${CHOICE}p")
VERSION="$TAG"
case "$VERSION" in
  v*) VERSION=$(printf '%s' "$VERSION" | sed 's/^v//') ;;
esac

IMAGE_TAG="${IMAGE}:${VERSION}"

# buildx multi-platform can't be loaded locally; require PUSH=1
case "$PLATFORMS" in
  *,*)
    if [ "$PUSH" != "1" ]; then
      echo "Multiple platforms specified ($PLATFORMS) but PUSH!=1. Set PUSH=1 to push multi-platform images." >&2
      exit 1
    fi
    ;;
esac

set -x
if [ "$PUSH" = "1" ]; then
  docker buildx build \
    --file Dockerfile \
    --build-arg "VERSION=$VERSION" \
    --platform "$PLATFORMS" \
    --tag "$IMAGE_TAG" \
    --push \
    .
else
  docker buildx build \
    --file Dockerfile \
    --build-arg "VERSION=$VERSION" \
    --platform "$PLATFORMS" \
    --tag "$IMAGE_TAG" \
    --load \
    .
fi

echo "Build completed: $IMAGE_TAG"
