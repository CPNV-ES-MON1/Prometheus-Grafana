#!/bin/bash

# Demande des valeurs ?? l'utilisateur
read -p "Entrez le nom du job (default_name) : " job_name
read -p "Entrez l'adresse IP (default_ip) : " ip_address

# Chemin du fichier
file="../Config/prometheus.yml"

# Ajout des lignes ?? la fin du fichier avec indentation adapt??e
cat <<EOF >> "$file"

  - job_name: '$job_name'
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['$ip_address']
EOF

echo "Ligne add of end of file: $file."


