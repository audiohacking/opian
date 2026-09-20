#!/usr/bin/env bash
set -euo pipefail

# Build a simple macOS .pkg that installs OPIAN AU + VST3 (+ Standalone.app).
# Usage: ./scripts/build-installer-pkg.sh --version v0.2.1

VERSION="${2:-0.2.1}"
if [[ "${1:-}" == "--version" ]]; then
  VERSION="${2:-0.2.1}"
fi
VERSION="${VERSION#v}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARTEFACTS="${ROOT}/build/OPIAN_artefacts/Release"
STAGE="${ROOT}/release-artefacts/pkgroot"
OUT_DIR="${ROOT}/release-artefacts"
PKG="${OUT_DIR}/OPIAN-macOS-Installer.pkg"

if [[ ! -d "${ARTEFACTS}" ]]; then
  echo "Missing ${ARTEFACTS}. Build Release first." >&2
  exit 1
fi

rm -rf "${STAGE}"
mkdir -p \
  "${STAGE}/Library/Audio/Plug-Ins/Components" \
  "${STAGE}/Library/Audio/Plug-Ins/VST3" \
  "${STAGE}/Applications"

if [[ -d "${ARTEFACTS}/AU/OPIAN.component" ]]; then
  cp -R "${ARTEFACTS}/AU/OPIAN.component" "${STAGE}/Library/Audio/Plug-Ins/Components/"
fi
if [[ -d "${ARTEFACTS}/VST3/OPIAN.vst3" ]]; then
  cp -R "${ARTEFACTS}/VST3/OPIAN.vst3" "${STAGE}/Library/Audio/Plug-Ins/VST3/"
fi
if [[ -d "${ARTEFACTS}/Standalone/OPIAN.app" ]]; then
  cp -R "${ARTEFACTS}/Standalone/OPIAN.app" "${STAGE}/Applications/"
fi

mkdir -p "${OUT_DIR}"
pkgbuild \
  --root "${STAGE}" \
  --identifier com.opian.chordbuilder \
  --version "${VERSION}" \
  --install-location / \
  "${PKG}"

echo "Wrote ${PKG}"
