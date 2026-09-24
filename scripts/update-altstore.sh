#!/usr/bin/env bash
set -euo pipefail

# Regenerate altstore/apps.json from the GitLab release that
# sync-from-github.sh just created, then commit it back to main through the
# SSH deploy key remote. Only versioned tags produce AltStore entries; the
# rolling "nightly" tag is skipped.

RELEASE_TAG="${RELEASE_TAG:-}"
if [ -z "$RELEASE_TAG" ] || [ "$RELEASE_TAG" = "nightly" ]; then
  echo "No versioned release tag, skipping AltStore source update"
  exit 0
fi

PROJECT_DIR="${CI_PROJECT_DIR:-$PWD}"
cd "$PROJECT_DIR"

PKG_BASE="${CI_API_V4_URL:-https://gitlab.com/api/v4}/projects/${CI_PROJECT_ID}/packages/generic/release-assets/${RELEASE_TAG}"
IPA_NAME="koulur-ios-arm64-unsigned.ipa"

IPA_SIZE=$(curl -fsSLI "${PKG_BASE}/${IPA_NAME}" | tr -d '\r' | awk 'tolower($1)=="content-length:"{print $2}' | tail -n1)
if [ -z "$IPA_SIZE" ]; then
  echo "Could not determine ipa size from the package registry" >&2
  exit 1
fi

VERSION="${RELEASE_TAG#v}"
RELEASE_DATE=$(date -u +%Y-%m-%d)
ICON_URL="https://gitlab.com/${CI_PROJECT_PATH}/-/raw/main/assets/icon-1024.png"
SOURCE_URL="https://httpanimations.gitlab.io/koulur/altstore/apps.json"

mkdir -p altstore
cat > altstore/apps.json <<EOF
{
  "name": "Koulur",
  "identifier": "com.koulur.source",
  "sourceURL": "${SOURCE_URL}",
  "apps": [
    {
      "name": "koulur",
      "bundleIdentifier": "com.koulur.koulur",
      "developerName": "HttpAnimations",
      "subtitle": "Colour palette generator",
      "localizedDescription": "Generate harmonious five-colour palettes, lock the shades you like and copy hex codes with a tap.",
      "iconURL": "${ICON_URL}",
      "tintedIconURL": "${ICON_URL}",
      "category": "utilities",
      "versions": [
        {
          "version": "${VERSION}",
          "date": "${RELEASE_DATE}",
          "downloadURL": "${PKG_BASE}/${IPA_NAME}",
          "size": ${IPA_SIZE},
          "minOSVersion": "13.0"
        }
      ],
      "appPermissions": {},
      "news": [
        {
          "identifier": "release-${VERSION}",
          "title": "koulur ${VERSION}",
          "caption": "Latest release",
          "date": "${RELEASE_DATE}",
          "notify": false
        }
      ]
    }
  ]
}
EOF

git config user.name "GitLab CI"
git config user.email "ci@gitlab.com"
git remote add gitlab-ssh "git@gitlab.com:${CI_PROJECT_PATH}.git" 2>/dev/null || true
git fetch gitlab-ssh main
git checkout -B main FETCH_HEAD

git add altstore/apps.json
if git diff --cached --quiet; then
  echo "AltStore source already up to date"
  exit 0
fi

git commit -m "chore: 更新 AltStore 源"
git push -o ci.skip gitlab-ssh main:main
echo "AltStore source updated for $RELEASE_TAG"
