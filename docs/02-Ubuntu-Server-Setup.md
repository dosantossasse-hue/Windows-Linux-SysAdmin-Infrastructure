# Guide de Déploiement — Ubuntu Server 24.04 LTS (`srv-ubuntu-01`)

Ce document détaille la configuration et la sécurisation du serveur Linux **`srv-ubuntu-01`** (`192.168.100.20`) intégré au réseau d'entreprise `corp.local`.

---

## 1. Configuration Réseau Statique (`Netplan`)
Édition du fichier `/etc/netplan/50-cloud-init.yaml` (ou `/etc/netplan/00-installer-config.yaml`) pour fixer l'adresse IP et utiliser le contrôleur de domaine Windows Server (`192.168.100.10`) comme serveur DNS :

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.100.20/24
      routes:
        - to: default
          via: 192.168.100.1
      nameservers:
        addresses:
          - 192.168.100.10
          - 8.8.8.8
        search:
          - corp.local
```

Application de la configuration :
```bash
sudo netplan apply
```

---

## 2. Sécurisation Automatisée & Déploiement Intranet
Exécution du script de durcissement présent dans [`scripts/harden-ubuntu.sh`](../scripts/harden-ubuntu.sh) ou via les commandes suivantes :

```bash
# Mise à jour et installation des paquets essentiels
sudo apt update && sudo apt upgrade -y
sudo apt install -y ufw fail2ban nginx openssh-server

# Configuration du pare-feu UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx HTTP'
sudo ufw --force enable

# Vérification de l'état de sécurité
sudo ufw status verbose
sudo systemctl status nginx
```

- **Captures associées** :
  - `docs/screenshots/07-ubuntu-security.png` (Terminal Ubuntu avec `sudo ufw status verbose`)
  - `docs/screenshots/08-intranet-working.png` (Accès à `http://intranet.corp.local` depuis le PC Windows 10/11)
