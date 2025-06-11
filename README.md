# Installation AWS

# Installation SRV

## Prérequis

<aside>
💡

- Docker  `v.20.10.24`
- Docker-compose `v.1.29.2`
- Git `v.2.39.5`
</aside>

## Téléchargement du projet

Clone du projet

```bash
git clone https://github.com/CPNV-ES-MON1/Prometheus-Grafana.git
```

## Configuration du projet

**Gestion des notification**

Ajout de l’URL du `webhooks` dans le fichier `Debian/Config/alert/n-contact_point.yml` pour les notifications sur discord

**Modification des adresses IP clients**

Une fois que vous avez récupérer le projet depuis GitHub, il faut remplacer les adresses IP clients par les adresses qui correspondent à votre infrastructure actuel :

```powershell
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
      - targets: ['AdresseIPDuClientLinux:9100']

  - job_name: 'Mon1-Windows'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['<AdresseIPDuClientWindows>:9182']
```

**Installation du exporter client**

Pour recevoir les métriques du SRV il nous faut installer l’exporter linux.
A savoir, à l’installation linux il y a déjà un exporter prometheus mais il nous donne uniquement les infos de prometheus et non les infos comme la consommation CPU.

```bash
sudo docker run -d \
  --restart=always \
  --net="host" \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host
```

## Configuration du proxy

Pour configurer le proxy aller dans `/Prometheus-Grafana/Debian/Config/revers_proxy/default.conf`

Remplacer le port 7025 par celui sur le quelle vous écouter

```powershell
server {
    listen       7025;
    listen  [::]:7025;
    server_name  localhost;
```

Remplacer l’adresse IP dans l’URL proxy_pass par l’adresse qui est actuellement utilisé par Zammad

```powershell
 location /zammad/ {
        proxy_pass http://<AdresseIPDuZammad>:8081/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
```

Il faut faire la même chose pour Grafana

```powershell
    location /grafana/ {
        proxy_pass http://<AdresseIPDuGrafana>:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Prefix /grafana;
```

## Lancement du projet

Exécuter la commande, pour l’installation et le lancement du docker 

```bash
sudo docker-compose -f Prometheus-Grafana/Debian/Docker_Compose/docker-compose.yml up -d
```

## Zammad

```powershell
git clone https://github.com/zammad/zammad-docker-compose.git
```

Se déplacer dans le dépôt et démarrer le conteneur

Dans le docker compose modifier la valeur de la variable : NGINX_EXPOSE_PORT par 8081

Démarrer le docker-compose

```powershell
Sudo docker-compose up -d
```

Sur la page web de Zammad configurer un utilisateur par défaut

Crée un utilisateur pour la création de ticket via grafana et lui attribuer les rôles suivants

![image](https://github.com/user-attachments/assets/ca6d9b11-8936-496d-b323-c004711bb0ef)

Et attribuer lui les permission de groupe suivante:

![image 1](https://github.com/user-attachments/assets/ebec72fa-aa37-48f4-bf5e-e640d8667270)

### Vérification

Pour vérifier que la connexion à l’API fonctionne aller dans paramètre —> API  et faite un curl de la commande fournie avec vos identifiant.

![image 2](https://github.com/user-attachments/assets/01832271-b84c-4a2c-aea8-bb115ce31356)

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

- Maintenant il faut que prometheus récupère les informations qui sont envoyés par Windows exporter, alors il faut rajouter un ‘job’ dans le fichier prometheus.yml qui contient l’adresse du client windows :

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
      - targets: ['<AdresseDuClientWindows>:9182']
```

- Pour tester si votre yaml est correcte, vous pouvez aller sur le site suivant :

```yaml
<adresse_ip_du_serveur>:<port>/targets
```

- Si vous voyez votre job Windows en UP, ca veut dire qu’il fonctionne correctement :

![image 3](https://github.com/user-attachments/assets/094d7f05-f0cd-4ad8-8053-41091cd1135d)

## Linux

### Prérequis

<aside>
💡

- Docker `v.20.10.2`
- Docker-Compose `v.1.29.2`
- Git `v.2.39.5`
</aside>

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

### Installation de l’exporter MySQL

Crée le docker-compose :

```powershell
version: "3.8"

networks:
  monitoring:
    name: monitoring

services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: demo
      MYSQL_USER: demo
      MYSQL_PASSWORD: demopass
    ports:
      - "3306:3306"
    networks:
      - monitoring
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-prootpass"]
      interval: 10s
      timeout: 5s
      retries: 3

  mysqld-exporter:
    image: prom/mysqld-exporter
    container_name: mysqld-exporter
    command:
      - "--config.my-cnf=/etc/mysql_exporter/.my.cnf"
    volumes:
      - ./.my.cnf:/etc/mysql_exporter/.my.cnf:ro
    ports:
      - "9104:9104"
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - monitoring
```

Crée le fichier `.my.cnf`

```powershell
[client]
user=demo
password=demopass
host=mysql
port=3306
```

Démarrer le docker compose

```bash
sudo docker-compose up -d
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
  - job_name: 'Client_linux'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['<AdresseIPDuClientLinux>:9100']
```

Ajout de `Client_linux_mysql` sur le `Prometheus-Grafana/Debian/Config/prometheus.yml`

```yaml

  - job_name: 'Client_linux_mysql'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['<AdresseIPDuClientLinuxMySQL>:9104']
```

Redémarrage de prometheus

```bash
sudo docker-compose -f Prometheus-Grafana/Debian/Docker_Compose/docker-compose.yml restart prometheus
```

Vérification de l’ajout des clients, prometheus/targets :

![image 4](https://github.com/user-attachments/assets/285aa6fb-6247-4592-acbc-5ad88a7cf86b)
