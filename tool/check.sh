#!/usr/bin/env bash
# Contrôle local complet avant un commit.
set -euo pipefail
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test
echo "Contrôles OK."
