# Scan Trivy de Juice Shop

## Commande utilisée
podman run --rm -v trivy-cache:/root/.cache/ docker.io/aquasec/trivy image --severity HIGH,CRITICAL docker.io/bkimminich/juice-shop:latest

## Résultats
- 30 vulnérabilités HIGH/CRITICAL au total (23 HIGH, 7 CRITICAL)
- Debian 13.7 : 2 HIGH, 0 CRITICAL
- Node.js : 21 HIGH, 7 CRITICAL
- Package identifié parmi les vulnérabilités CRITICAL : crypto-js
- Autres packages identifiés : express-jwt, libssl3t64

## Analyse
L'image Juice Shop contient des vulnérabilités dans ses dépendances
système et applicatives.

Les vulnérabilités CRITICAL identifiées concernent notamment crypto-js.
Les vulnérabilités HIGH incluent express-jwt et libssl3t64.

Une mise à jour des dépendances vers les versions corrigées,
lorsqu'elles sont disponibles, permettrait de réduire le risque
## Recommandation pour la pipeline
Le Security Gate pourrait bloquer le déploiement si le nombre de CRITICAL
augmente par rapport à cette référence (7).

## Captures
(à ajouter)