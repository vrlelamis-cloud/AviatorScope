# AviatorScope

**ANALYSE • STATISTIQUES • ESTIMATIONS**

Application Android (Flutter) d'analyse statistique des multiplicateurs observés
au jeu Aviator. Elle décrit un historique que **vous** fournissez ; elle ne
connaît pas et ne peut pas prédire le prochain résultat.

> Les résultats précédents ne garantissent jamais le résultat futur.
> Aucun taux de confiance ni aucune prédiction n'est fabriqué.

## Fonctionnalités

- **Dashboard** : nombre de manches, moyenne, parts sous 1,50x / sous 2x / à partir
  de 5x / à partir de 10x, dernier multiplicateur, graphique interactif
  (20/50/100 derniers, valeurs au toucher, période, échelle logarithmique).
- **Historique** : ajout, modification, suppression (avec confirmation),
  recherche, tri, filtre par période, détection de doublons possibles, import /
  export CSV, journal des corrections.
- **Importation** : capture d'écran → OCR local (Google ML Kit) → extraction des
  seuls nombres suivis de « x » → correction manuelle → écran de confirmation.
- **Prédictions & Estimations** : fréquences observées par catégorie avec
  intervalle de Wilson à 95 %, comparaison des fenêtres 50/100/500, analyse des
  séries, qualité des données, bloc « ESTIMATION STATISTIQUE ».
- **Provably Fair** : contrôle de hachage (SHA-256 / SHA-512) d'une manche
  terminée. Le multiplicateur n'est **jamais** déclaré vérifié :
  « Vérification incomplète : formule exacte non confirmée. »
- **Paramètres** : export, suppression de toutes les données, limites
  statistiques, version.

Aucune connexion à BetPawa : pas de scraping, pas de cookies, pas d'identifiants.
L'application fonctionne uniquement avec des données importées volontairement.

## Documentation

- `docs/AUDIT.md` — rapport d'audit et conformité au cahier des charges
- `docs/ARCHITECTURE.md` — couches, flux, base de données, extension
- `docs/TESTING.md` — plan de test et checklist sur appareil
- `docs/USER_GUIDE.md` — guide d'utilisation
- `CHANGELOG.md`

## Architecture

```
lib/
  main.dart
  app/            app.dart, router.dart (go_router), app_shell.dart, theme.dart
  core/           constants, utils (formatage, parsing), widgets communs
  shared/         models, data (SQLite), services (CSV), providers (Riverpod)
  features/
    dashboard/ history/ predictions/ screenshot_import/
    statistics/ fairness/ settings/        (domain/ + presentation/ [+ data/])
test/             tests unitaires et widget
tool/             bootstrap_android.sh
.github/workflows/android-build.yml
```

La logique métier (`features/*/domain`, `shared/services`) est indépendante des
widgets et testée unitairement. `PredictionStatisticsService` est déterministe.

Ordre chronologique : l'historique est ordonné par ordre d'insertion. Une
capture est enregistrée du plus ancien au plus récent (vous indiquez l'ordre de
lecture sur l'écran d'import). Aucune date ni numéro de manche n'est inventé.

## Prérequis

- Flutter stable (≥ 3.27) et Dart ≥ 3.6
- JDK 17, Android SDK

## Installation et exécution locale

```bash
git clone <votre-depot> aviatorscope && cd aviatorscope
bash tool/bootstrap_android.sh   # génère android/ avec votre version de Flutter
flutter pub get
flutter run
```

`android/` est généré par `flutter create` (script ci-dessus) pour rester
compatible avec la version de Flutter installée. Une fois généré, vous pouvez le
commiter.

## Tests

```bash
dart format .
flutter analyze
flutter test
# ou, en une commande :
bash tool/check.sh
```

## Compilation Android

```bash
flutter build apk --debug      # build/app/outputs/flutter-apk/app-debug.apk
```

Pour une version release, créez un keystore **hors du dépôt**, référencez-le dans
`android/key.properties` (ignoré par git) et configurez `signingConfigs` dans
`android/app/build.gradle`. Ne commitez jamais de clé privée ni de mot de passe.

## GitHub Actions

Le workflow `.github/workflows/android-build.yml` se lance sur push vers `main`,
sur pull request et manuellement (`workflow_dispatch`). Étapes : Flutter stable →
squelette Android → `flutter pub get` → contrôle de formatage (non bloquant au
début) → `flutter analyze --no-fatal-infos` → `flutter test` (bloquant) →
`flutter build apk --debug` → publication de l'artifact.

### Télécharger l'APK

1. Onglet **Actions** du dépôt → ouvrir l'exécution réussie.
2. Section **Artifacts** → télécharger **`AviatorScope-Android-APK`** (zip).
3. Décompresser, copier `app-debug.apk` sur le téléphone et l'installer
   (autoriser les sources inconnues si Android le demande).

## Format CSV

```
id,multiplier,observed_at,source,round_id,validated,corrected
```

| Colonne | Obligatoire | Détail |
|---|---|---|
| `multiplier` | oui | `1.25`, `1,25`, `1.25x` acceptés |
| `observed_at` | non | ISO 8601, ex. `2026-10-14T18:30:00` |
| `source`, `round_id` | non | texte libre |
| `validated`, `corrected` | non | `true/false`, `1/0`, `oui/non` |
| `id` | non | ignoré à l'import |

Séparateurs `,` ou `;`. Lignes de la plus ancienne à la plus récente (triées par
date si toutes les lignes en ont une). L'import affiche un résumé, signale les
lignes incorrectes, ignore les doublons identifiables et n'écrase jamais
l'existant.

## Confidentialité

Pas de compte, pas de serveur : tout est stocké localement (SQLite). L'OCR est
exécuté sur l'appareil. L'export CSV et la suppression totale sont disponibles
dans les paramètres.

## Limites statistiques

- Les pourcentages sont des **fréquences observées**, pas des probabilités du
  prochain tour.
- L'intervalle de Wilson suppose des manches indépendantes et de même loi,
  hypothèse que l'historique seul ne permet pas de vérifier.
- Un écart entre fenêtres ou une longue série n'est jamais un signal prédictif.
- Aucune probabilité théorique officielle n'est intégrée (« Probabilité
  théorique non configurée. »).
- Les seuils « valeur très élevée » (> 1000x) et la borne basse de 1,00x sont des
  heuristiques de validation de l'application, pas des règles du jeu.

## Dépannage

- **`flutter pub get` échoue** : relancer après `flutter upgrade`, ou ajuster les
  versions de `pubspec.yaml` à votre Flutter.
- **Échec Gradle / Kotlin** : régénérer `android/` (supprimer le dossier puis
  relancer `tool/bootstrap_android.sh`).
- **OCR vide ou erroné** : utiliser une capture nette, recadrée sur la barre
  d'historique ; corriger les valeurs signalées « ambiguës ».
- **Export CSV annulé** : le sélecteur de fichiers Android doit être confirmé.
- **Caractères accentués illisibles dans Excel** : l'export inclut un BOM UTF-8.
