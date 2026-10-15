# Plan de test

## 1. Automatique (CI)

`flutter analyze --no-fatal-infos` → `flutter test` → `flutter build apk --debug`.
Un échec des tests interrompt le workflow.

## 2. Checklist manuelle sur appareil

Cocher après installation de l'APK.

**Démarrage**
- [ ] L'application s'ouvre sur le Dashboard vide avec les deux boutons d'action.
- [ ] Les 5 onglets s'affichent et conservent leur état (ex. recherche conservée).

**Historique**
- [ ] Ajout d'un résultat `2,35` (virgule) puis `2.35` (point) acceptés.
- [ ] `0,5` et `abc` refusés avec message clair.
- [ ] Modification : badge « corrigé » + entrée dans le journal (détails).
- [ ] Suppression : confirmation demandée.
- [ ] Recherche « 1,2 » et tri croissant/décroissant.
- [ ] Deux résultats avec le même numéro de manche → « doublon possible ».

**CSV**
- [ ] Export, puis import du même fichier : doublons non réimportés si manche/date présentes.
- [ ] Fichier avec lignes incorrectes : résumé listant les numéros de ligne.
- [ ] Ouverture de l'export dans un tableur : accents corrects.

**OCR**
- [ ] Capture nette : valeurs détectées, ordre « récent d'abord » à vérifier.
- [ ] Capture floue : avertissement « trop flou » ou « aucun multiplicateur ».
- [ ] Valeur `125x` : marquée ambiguë ; correction manuelle possible.
- [ ] Rien n'est enregistré sans la boîte de confirmation.
- [ ] Réimporter la même capture : avertissement de doublons.

**Prédictions**
- [ ] Changement d'échantillon (50/100/200/500/Tout) met à jour tous les blocs.
- [ ] Moins de manches que demandé : message « Seulement N manches disponibles ».
- [ ] Texte « Ces valeurs décrivent l'historique sélectionné… » visible.
- [ ] Aucun chiffre affiché sans données.

**Provably Fair**
- [ ] SHA-256 de `abc` = `ba7816bf…15ad` : « Hash concordant ».
- [ ] Un caractère modifié : « Vérification échouée » avec position.
- [ ] Hash trop court : « Erreur de saisie ».
- [ ] Message « Vérification incomplète : formule exacte non confirmée. » toujours présent.

**Paramètres / confidentialité**
- [ ] « Tout supprimer » : confirmation, puis Dashboard vide.
- [ ] Mode avion : toutes les fonctions marchent (OCR inclus).

**Affichage**
- [ ] Petit écran (≈ 360 dp) : aucun débordement de texte.
- [ ] Tablette / paysage : rail de navigation, contenu centré.
- [ ] Taille de police système agrandie : lisible.
- [ ] « Réduire les animations » activé : pas d'animation de chargement.
