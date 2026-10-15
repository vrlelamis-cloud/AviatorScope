#!/usr/bin/env bash
# Génère le squelette Android (Gradle, MainActivity, icônes) avec la version de
# Flutter installée, sans toucher à lib/, test/ ni pubspec.yaml.
# Utilisé par le workflow GitHub Actions et utilisable en local.
set -euo pipefail

if [ -f android/settings.gradle ] || [ -f android/settings.gradle.kts ]; then
  echo "android/ existe déjà : rien à générer."
  exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

flutter create --platforms=android --org com.aviatorscope \
  --project-name aviatorscope --empty "$tmp/aviatorscope"

cp -R "$tmp/aviatorscope/android" ./android

manifest="android/app/src/main/AndroidManifest.xml"
sed -i.bak 's/android:label="[^"]*"/android:label="AviatorScope"/' "$manifest"
rm -f "${manifest}.bak"

echo "Squelette Android généré (nom d'application : AviatorScope)."
