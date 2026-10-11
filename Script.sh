#!/usr/bin/env bash
# Installation de la base du projet "Veille IA & Cybermenaces"
# Cible : Debian 12, 2 Go de RAM. Usage : bash install-veille.sh
set -euo pipefail

echo "=== 1. Test de la connexion sortante ==="
FAIL=0
for URL in https://github.com https://discord.com https://www.cert.ssi.gouv.fr https://get.docker.com; do
  if curl -sS -I -m 10 "$URL" >/dev/null 2>&1; then
    echo "OK     $URL"
  else
    echo "ECHEC  $URL"
    FAIL=1
  fi
done
if [ "$FAIL" -eq 1 ]; then
  echo "Un ou plusieurs sites sont injoignables (proxy ou filtrage probable)."
  echo "Arret du script : regle d'abord l'acces reseau."
  exit 1
fi

echo "=== 2. Mise a jour du systeme ==="
sudo apt update
sudo apt upgrade -y
sudo apt install -y curl git ca-certificates

echo "=== 3. Swap de 1 Go (si absent) ==="
if ! swapon --show | grep -q '/swapfile'; then
  sudo fallocate -l 1G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
else
  echo "Swap deja present."
fi

echo "=== 4. Installation de Docker ==="
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sudo sh
fi
sudo systemctl enable --now docker

echo "=== 5. Lancement de n8n ==="
sudo docker volume create n8n_data >/dev/null
if sudo docker ps -a --format '{{.Names}}' | grep -qx n8n; then
  echo "Le conteneur n8n existe deja."
else
  sudo docker run -d --name n8n --restart unless-stopped \
    -p 5678:5678 \
    -e GENERIC_TIMEZONE=Europe/Paris -e TZ=Europe/Paris \
    -v n8n_data:/home/node/.n8n \
    docker.n8n.io/n8nio/n8n
fi

echo "=== 6. Verification ==="
sleep 5
sudo docker ps --filter name=n8n
IP=$(hostname -I | awk '{print $1}')
echo
echo "Termine. Ouvre n8n sur : http://${IP}:5678"
echo "Cree ton compte administrateur avec un vrai mot de passe."
