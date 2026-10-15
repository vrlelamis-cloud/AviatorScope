# Guide d'utilisation

AviatorScope **décrit** les multiplicateurs que vous avez enregistrés. Il ne
connaît pas le prochain résultat et ne peut pas le prédire.

## Premiers pas
1. **Historique** → *Ajouter* : saisissez un multiplicateur (`2,35`). Date et
   numéro de manche sont facultatifs : laissez-les vides si vous ne les
   connaissez pas.
2. Ou **Importation** → choisissez une capture d'écran de l'historique du jeu.
   Indiquez l'ordre de lecture (récent d'abord / ancien d'abord), corrigez les
   lectures signalées, puis confirmez.
3. Ou **Historique** → menu ⋮ → *Importer un CSV*.

## Lire les écrans
- **Dashboard** : chiffres clés et graphique des derniers résultats.
  L'échelle logarithmique rend lisibles les grandes valeurs.
- **Prédictions & Estimations** : fréquences observées par catégorie, avec
  intervalle de confiance à 95 %. C'est une description du passé, pas une
  promesse pour la prochaine manche.
- **Comparaison des fenêtres** : « ≈ » = écart compatible avec le hasard
  d'échantillonnage ; « ≠ » = écart plus marqué. Aucun des deux n'est un signal.
- **Séries** : observations passées. Une valeur absente depuis longtemps n'est
  jamais « due ».

## Vos données
Elles restent sur votre téléphone. Paramètres → exporter en CSV, ou tout
supprimer (définitif : exportez avant).

## Vérification Provably Fair
Outil de contrôle d'une manche terminée : compare un hash calculé localement au
hash affiché. Il ne prédit rien et ne confirme jamais le multiplicateur.
