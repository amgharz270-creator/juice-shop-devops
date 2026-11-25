# Prometheus : collecte des métriques de Juice Shop

## Rôle de Prometheus
Prometheus est un outil de supervision qui collecte des métriques.
Toutes les 15 secondes, il interroge la page `/metrics` de Juice Shop
et stocke les valeurs (mémoire, requêtes, temps de réponse...).
Ces données seront ensuite affichées dans Grafana.

## Configuration (`monitoring/prometheus.yml`)
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: juice-shop
    metrics_path: /metrics
    static_configs:
      - targets: ['juice:3000']
```

- `scrape_interval: 15s` : une collecte toutes les 15 secondes
- `job_name` : nom du groupe de cibles surveillées
- `metrics_path` : page où Juice Shop expose ses métriques
- `targets` : nom du conteneur et port (`juice:3000`)

## Commandes utilisées
```powershell
podman network create monitoring
podman run -d --name juice --network monitoring -p 3000:3000 docker.io/bkimminich/juice-shop
podman run -d --name prometheus --network monitoring -p 9090:9090 -v ${PWD}/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro docker.io/prom/prometheus
```
Les deux conteneurs sont sur le même réseau `monitoring`, ce qui permet
à Prometheus d'atteindre Juice Shop avec le nom `juice`.

## Vérification
Dans l'interface (http://localhost:9090, menu Status > Target health),
la cible `juice-shop` est à l'état **UP** (1/1 up), avec un temps de
réponse d'environ 19 ms.

![Page Targets de Prometheus](captures/prometheus-targets.png)

## Conclusion
Prometheus collecte correctement les métriques de Juice Shop.
La prochaine étape est de les visualiser dans Grafana.