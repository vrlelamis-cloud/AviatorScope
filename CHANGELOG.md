# Changelog

## 3.0.0 — 2026-10-15
### Ajouté
- Projet Flutter complet : Dashboard, Historique, Prédictions & Estimations,
  Importation OCR, Provably Fair (hash), Paramètres.
- Moteur statistique testé (Wilson 95 %, séries, comparaison de fenêtres).
- Import/export CSV documenté, SQLite local avec journal des imports et corrections.
- Workflow GitHub Actions et script de génération du squelette Android.
- Documentation : README, AUDIT, ARCHITECTURE, TESTING, USER_GUIDE.

### Corrigé après audit
- Titre/barre manquants pendant le chargement de l'historique.
- Ripple invisible sur les cartes de l'historique.
- Chaîne fragile dans l'écran d'import.
