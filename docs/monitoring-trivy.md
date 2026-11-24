# Scan Trivy de Juice Shop

## Commande utilisée
podman run --rm -v trivy-cache:/root/.cache/ docker.io/aquasec/trivy image --severity HIGH,CRITICAL docker.io/bkimminich/juice-shop:latest

## Résultats
- 33 vulnérabilités HIGH/CRITICAL au total (26 HIGH, 7 CRITICAL)
- Debian 13.7 : 2 HIGH, 0 CRITICAL (paquet libssl3t64, OpenSSL)
- Node.js : 28 failles (21 HIGH, 7 CRITICAL)
- 3 autres cibles : 1 HIGH chacune

## Paquets CRITICAL (Node.js)
| Paquet | Version installée | Version corrigée | Problème |
|---|---|---|---|
| crypto-js | 3.3.0 | 4.2.0 | PBKDF2 trop faible (CVE-2023-46233) |
| jsonwebtoken | 0.1.0 / 0.4.0 | 4.2.2 | Contournement de vérification JWT (CVE-2015-9235) |
| lodash | 2.4.2 | 4.17.12 | Prototype pollution (CVE-2019-10744) |
| marsdb | 0.6.11 | aucune | Injection de commandes |
| tar | 6.2.1 | 7.5.19 | Déni de service (CVE-2026-59873) |

## Autres paquets HIGH identifiés
- express-jwt 0.1.3 (correctif : 6.0.0) : contournement d'autorisation
- base64url 0.0.6 (correctif : 3.0.0) : lecture hors limites
- libssl3t64 : déni de service OpenSSL, aucun correctif disponible

## Analyse
L'image système Debian est presque propre (2 failles), tandis que les
dépendances Node.js concentrent l'essentiel du risque, dont les 7 CRITICAL.
La majorité des paquets CRITICAL ont une version corrigée : une mise à jour
réduirait fortement le risque. marsdb n'a aucun correctif et doit être remplacé.
Ces résultats sont attendus : Juice Shop est volontairement vulnérable.

## Recommandation pour la pipeline
Le Security Gate pourrait bloquer le déploiement si le nombre de CRITICAL
augmente par rapport à cette référence (7).

## Captures
(à ajouter)