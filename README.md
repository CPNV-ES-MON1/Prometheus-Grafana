# Installation SRV

## Prérequis

- Docker
- Docker-compose
- Git

Clone du projet

```bash
git clone https://github.com/CPNV-ES-MON1/Prometheus-Grafana.git
```

Exécuter la commande, pour l’installation et le lancement du docker 

```bash
sudo docker-compose -f Prometheus-Grafana/Debian/Docker_Compose/docker-compose.yml up -d
```

# Installation Client

## Windows

### Installation Windows Exporter

- Vous pouvez trouver la liste des downloads pour docker exporter sur le page suivant :
    
    [https://github.com/prometheus-community/windows_exporter/releases](https://github.com/prometheus-community/windows_exporter/releases)
    
- Pour ce teste on a utilisé windows_exporter-0.30.6-amd64.msi
- Lancer l’installeur afin de commencer l’installation
- Maintenant il faut lancer PowerShell en tant qu’administrateur et taper la commande suivante :

```powershell
Start-Service windows_exporter
```

- Maintenant vous pouvez tester si Windows exporter fonctionne correctement en allant sur ce site :

```powershell
<votre-adresse-IP>:9182/metrics 
```

- S’il y a des logs des métriques qui s’affichent, ca veut dire que Windows exporter fonctionne comme il faut.

### Prometheus

- Maintenant il faut que prometheus récupère les informations qui sont envoyés par windows exporter, alors on doit ajouter des lignes dans notre fichier yaml :

```yaml
  global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []
      scheme: http
      timeout: 10s
      api_version: v2

scrape_configs:
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
          - localhost:9090

  - job_name: 'Mon1-Windows'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['192.168.28.213:9182']
```

- Pour tester si votre yaml est correcte, vous pouvez aller sur le site suivant :

```yaml
<adresse_ip_du_serveur>:<port>/targets
```

- Si vous voyez votre job windows en UP, ca veut dire qu’il fonctionne correctement :

![image](https://github.com/user-attachments/assets/62066e78-c85e-42dd-8baa-737c55c7ff31)

## Linux

### Prérequis

- Docker

### Installation et run du docker node exporter

```bash
sudo docker run -d \
  --restart=always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host
```

### Configuration du `prometheus.yml` sur le SRV

- **Info**
    
    
    | Clé | Description |
    | --- | --- |
    | `job_name` | Nom de la tâche de scraping visible dans l'interface web Prometheus. |
    | `honor_timestamps` | Respecte les timestamps fournis par la cible (utile pour certaines sources). |
    | `scrape_interval` | Fréquence à laquelle Prometheus interroge la cible. |
    | `scrape_timeout` | Temps maximum avant de considérer un timeout. |
    | `metrics_path` | Chemin pour récupérer les métriques (généralement `/metrics`). |
    | `scheme` | Protocole (`http` ou `https`). |
    | `targets` | Liste des hôtes et ports exposant des métriques. |

Ajout de `Client_linux` sur `Prometheus-Grafana/Debian/Config/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: []
      scheme: http
      timeout: 10s
      api_version: v2

scrape_configs:
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
          - localhost:9090

  - job_name: 'Client_linux'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['192.168.28.213:9100']
```

```bash
sudo docker-compose -f Prometheus-Grafana/Debian/Docker_Compose/docker-compose.yml restart prometheus
```

Vérification de l’ajout du client

![image 2](https://github.com/user-attachments/assets/9929e7e6-5469-41cc-a23f-6c6ba060cebb)
