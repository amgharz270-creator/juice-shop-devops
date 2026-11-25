# Infrastructure et déploiement : Podman, Kubernetes (kind) et Terraform

**Membre 2** — Projet DevSecOps sur OWASP Juice Shop
**Branche Git :** `zineb-amghar`

## 1. Objectif

Construire l'image de Juice Shop avec **Podman**, la déployer dans un cluster **Kubernetes local (kind)** et automatiser ce déploiement avec **Terraform**. Les autres membres (Trivy, ZAP, Postman, Jenkins) réutilisent ce travail.

## 2. Environnement

| Élément | Détail |
|---|---|
| Système | Windows 11 Pro, 8 Go de RAM |
| Conteneurs | Podman (machine en mode **rootful**) |
| Cluster local | kind (nom du cluster : `juice`, nœud `juice-control-plane`) |
| Orchestration | kubectl, manifests YAML dans `k8s/` |
| Infrastructure as Code | Terraform v1.17.2, provider `hashicorp/kubernetes` v2.38.0 |

## 3. Structure des fichiers

```
juice-shop-devops/
├── k8s/
│   ├── 00-namespace.yaml
│   ├── 10-deployment.yaml
│   └── 20-service.yaml
├── terraform-kind/        # notre code Terraform (kind)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── .terraform.lock.hcl
├── terraform/             # code officiel OWASP (AWS), non utilisé, voir section 8
└── docs/                  # captures d'écran et README
```

Les fichiers `k8s/` sont numérotés pour que `kubectl apply -f k8s/` les applique dans le bon ordre (le namespace doit exister avant le deployment).

## 4. Podman

```powershell
# Test avec l'image publique
podman run -d --name juice -p 3000:3000 docker.io/bkimminich/juice-shop

# Construction de l'image depuis le code source
podman build -t localhost/juice-shop:latest .

# Test de l'image construite
podman run -d --name juice-local -p 3001:3000 localhost/juice-shop:latest
```

- L'application répond sur `http://localhost:3000` puis `http://localhost:3001`.
- Le Dockerfile officiel utilise un build multi-étapes et un utilisateur non-root (`USER 65532`).
- Les avertissements `BUILD_DATE` et `VCS_REF` manquants sont sans conséquence (simples métadonnées).

Captures : `01` à `05` dans `docs/`.

## 5. Cluster Kubernetes avec kind

```powershell
podman machine set --rootful
$env:KIND_EXPERIMENTAL_PROVIDER="podman"
kind create cluster --name juice
kubectl get nodes
```

Résultat attendu : `juice-control-plane   Ready   control-plane`.

kind ne voit pas les images de Podman, il faut donc les charger dans le cluster :

```powershell
podman save localhost/juice-shop:latest -o juice-shop.tar
kind load image-archive juice-shop.tar --name juice
```

Le fichier `juice-shop.tar` est dans le `.gitignore` (trop volumineux, ne pas le versionner).

Captures : `06-kind-cluster-ready.png`, `07-kind-load-image.png`.

## 6. Déploiement avec les manifests Kubernetes

```powershell
kubectl apply -f k8s/
kubectl get pods -n juice-shop
kubectl port-forward -n juice-shop svc/juice-shop 8080:80
```

Résultat : pod `juice-shop-...` en `1/1 Running`, application accessible sur `http://localhost:8080`.

Points importants du deployment :
- `imagePullPolicy: Never` : on utilise l'image chargée localement dans kind.
- `resources` (requests et limits) : mémoire limitée à 512 Mi à cause des 8 Go de RAM.
- `readinessProbe` et `livenessProbe` sur `/` port 3000.
- `securityContext` : `runAsNonRoot: true`, `runAsUser: 65532`, `allowPrivilegeEscalation: false`.

Captures : `08-kubectl-get-pods.png`, `09-app-k8s-localhost-8080.png`.

## 7. Automatisation avec Terraform

Le dossier `terraform-kind/` crée les mêmes ressources que `k8s/` (namespace, deployment, service) avec le provider `kubernetes`, en ciblant le contexte `kind-juice`.

```powershell
cd terraform-kind
terraform init
terraform fmt
terraform validate
terraform plan       # Plan: 3 to add, 0 to change, 0 to destroy
terraform apply
terraform destroy    # supprime les 3 ressources
terraform apply      # recréation pour valider le cycle complet
```

Avant le premier `terraform apply`, les ressources créées avec `kubectl` doivent être supprimées (`kubectl delete -f k8s/`), sinon Terraform les trouve déjà existantes.

Fichiers à ne **pas** versionner : `.terraform/`, `*.tfstate`, `*.tfstate.backup`.
Fichier à versionner : `.terraform.lock.hcl`.

Captures : `10-terraform-init.png`, `11-terraform-plan.png`, `12-terraform-apply.png`, `13-terraform-destroy.png`.

## 8. Remarque sur le dossier `terraform/`

Le dépôt contient aussi un dossier `terraform/` (fichiers `main.tf`, `networking.tf`, `variables.tf`, `outputs.tf`). Il provient du **dépôt officiel OWASP Juice Shop** (historique Git : « Add Terraform infrastructure setup and Misplaced IaC Files challenge »).

- Il décrit un déploiement **AWS** (ECS Fargate, ECR, EFS, load balancer).
- Il est **volontairement vulnérable** : c'est un challenge de Juice Shop.
- Nous ne l'avons ni écrit, ni modifié, ni exécuté (il créerait des ressources payantes sur AWS).
- Il est utile comme exemple de mauvaises configurations IaC à détecter avec `trivy config terraform/` (Membre 4) et Gitleaks (Membre 1).

## 9. Problèmes rencontrés et solutions

| Problème | Cause | Solution |
|---|---|---|
| `minikube start --driver=podman` échoue (timeout de 360 s, conteneur `minikube` introuvable) | Driver Podman expérimental sous Windows, mode rootless | `podman machine set --rootful`, puis changement d'outil |
| Mémoire saturée (83 % utilisée sur 8 Go) | minikube réserve ~3 Go | Passage à **kind**, plus léger (~1 Go) |
| `podman save` : `image not known` | Le passage en mode rootful a changé le stockage des images | Reconstruction de l'image avec `podman build` |
| `kubectl apply -f k8s/` : `namespace not found` | Ordre alphabétique (deployment avant namespace) | Fichiers renommés `00-`, `10-`, `20-` |
| `kubectl` : connexion refusée sur `127.0.0.1` | Conteneur du cluster arrêté après redémarrage du PC | `podman machine start` puis `podman start juice-control-plane` |

## 10. Intégration dans la pipeline Jenkins (Membre 5)

Commandes à utiliser dans les étapes de la pipeline :

```powershell
podman build -t localhost/juice-shop:latest .
podman save localhost/juice-shop:latest -o juice-shop.tar
kind load image-archive juice-shop.tar --name juice
terraform -chdir=terraform-kind init
terraform -chdir=terraform-kind apply -auto-approve
```

`-chdir` évite de changer de dossier et `-auto-approve` supprime la confirmation interactive, nécessaire en automatisation.

## 11. Informations pour les autres membres

- **Trivy (Membre 4)** : image `localhost/juice-shop:latest` ; configuration avec `trivy config k8s/` et `trivy config terraform-kind/`.
- **ZAP et Postman (Membre 3)** : lancer `kubectl port-forward -n juice-shop svc/juice-shop 8080:80` (terminal à laisser ouvert), puis cibler `http://localhost:8080`.
- **Prometheus (Membre 4)** : Juice Shop expose ses métriques sur `/metrics`.
