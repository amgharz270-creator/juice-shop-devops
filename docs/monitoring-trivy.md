# Scan Trivy de Juice Shop

## Commande utilisée
podman run --rm -v trivy-cache:/root/.cache/ docker.io/aquasec/trivy image --severity HIGH,CRITICAL docker.io/bkimminich/juice-shop:latest

## Résultats
- 33 vulnérabilités HIGH/CRITICAL au total (26 HIGH, 7 CRITICAL)
- 5 cibles analysées
- Une cible concentre 28 failles, dont les 7 CRITICAL
- Paquets les plus touchés : (à compléter)

## Analyse
Juice Shop est une application volontairement vulnérable : ces résultats sont attendus.
La majorité des failles vient des dépendances applicatives.
Une mise à jour des paquets ayant une "Fixed Version" réduirait le risque.

## Recommandation pour la pipeline
Le Security Gate pourrait bloquer le déploiement si le nombre de CRITICAL
augmente par rapport à cette référence (7).

## Captures
(à ajouter)