# Architecture — AviatorScope

## Vue d'ensemble

```
Présentation (widgets, écrans)  →  Providers Riverpod  →  Services / Domaine  →  Données (SQLite, CSV)
```

- **Présentation** : `features/*/presentation`. Aucun calcul métier.
- **Domaine** : `features/*/domain` et `shared/services`. Dart pur, sans Flutter,
  testé unitairement.
- **Données** : `shared/data` (`ResultsRepository` abstrait +
  `SqliteResultsRepository`). Remplaçable par un faux dépôt en test.
- **État** : `shared/providers.dart`. `ResultsNotifier` (AsyncNotifier) charge
  l'historique ; chaque mutation recharge, ce qui recalcule toutes les
  statistiques affichées.

## Flux principaux

**Ajout / import** : écran → `ResultsNotifier.add/importMany` → dépôt (transaction
SQLite, journal d'import) → rechargement → Dashboard et Prédictions recalculés.

**OCR** : image → `OcrService` (ML Kit, local) → `MultiplierExtractor` (regex,
classification ok / ambiguë / suspecte / invalide) → lignes éditables →
avertissements → confirmation → `importMany`.

**Statistiques** : `PredictionStatisticsService` reçoit une liste chronologique de
valeurs valides et retourne des modèles immuables (`CategoryStat`, `RunAnalysis`,
`WindowSnapshot`…).

## Base de données (version 1)

| Table | Rôle |
|---|---|
| `results` | id, multiplier, observed_at, source, round_id, imported_at, validated, manually_corrected |
| `import_logs` | métadonnées de chaque import (source, détectés, enregistrés, ignorés) |
| `corrections` | journal champ par champ des modifications manuelles |

Toute évolution du schéma passe par `openDatabase(version: n, onUpgrade: …)`.

## Navigation

`go_router` : `StatefulShellRoute.indexedStack` (5 branches, état conservé) +
route plein écran `/fairness`.

## Tests

| Fichier | Couvre |
|---|---|
| `prediction_statistics_service_test.dart` | moyenne, médiane, Wilson, séries, fenêtres, cas limites |
| `csv_service_test.dart` | formats, erreurs par ligne, aller-retour |
| `multiplier_extractor_test.dart` | exemples du cahier des charges, ambiguïtés |
| `provably_fair_verifier_test.dart` | vecteur SHA-256 public, erreurs de saisie vs échec |
| `duplicate_detector_test.dart` | doublons, chevauchement |
| `widget_test.dart` | composants d'interface |

## Extension

- **Nouvelle probabilité théorique** : ajouter une `DocumentedProbability`
  (source, formule, hypothèses, explication) dans le registre.
- **Formule Provably Fair officielle** : à n'ajouter qu'avec une source
  confirmée ; sinon le message d'incomplétude reste obligatoire.
