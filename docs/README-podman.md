\# Podman - Juice Shop



\## Commandes utilisées

podman run -d --name juice -p 3000:3000 docker.io/bkimminich/juice-shop

podman build -t juice-shop:latest .

podman run -d --name juice-local -p 3001:3000 localhost/juice-shop:latest



\## Résultat

\- Build réussi, image: localhost/juice-shop:latest

\- App accessible sur http://localhost:3001

