#!/usr/bin/env bash
# ==============================================================================
# Script : harden-ubuntu.sh
# Objet  : Durcissement (Hardening) automatisé d'Ubuntu Server 24.04 LTS
#          et déploiement du portail Intranet d'entreprise (Nginx)
# Auteur : dosantossasse-hue
# ==============================================================================

set -e

echo "=================================================================="
echo "  DURCISSEMENT & CONFIGURATION D'UBUNTU SERVER (SecOps)           "
echo "=================================================================="

if [ "$EUID" -ne 0 ]; then
  echo "[!] Veuillez lancer ce script avec sudo : sudo ./harden-ubuntu.sh"
  exit 1
fi

echo "[1/5] Mise à jour des paquets système..."
apt-get update -y && apt-get upgrade -y

echo "[2/5] Installation des services de sécurité (UFW, Fail2ban) et Nginx..."
apt-get install -y ufw fail2ban nginx openssh-server curl

echo "[3/5] Durcissement de la configuration SSH (/etc/ssh/sshd_config)..."
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' /etc/ssh/sshd_config
systemctl restart ssh

echo "[4/5] Configuration du pare-feu UFW et activation de Fail2ban..."
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 'Nginx HTTP'
ufw --force enable

systemctl enable --now fail2ban

echo "[5/5] Déploiement du portail Intranet d'entreprise (Nginx)..."
cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Intranet Entreprise — corp.local</title>
    <style>
        body { font-family: Segoe UI, Arial, sans-serif; background: #0f172a; color: #f8fafc; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .card { background: #1e293b; padding: 2.5rem; border-radius: 12px; box-shadow: 0 10px 25px rgba(0,0,0,0.4); max-width: 600px; text-align: center; border: 1px solid #334155; }
        h1 { color: #38bdf8; margin-bottom: 0.5rem; }
        .badge { display: inline-block; background: #22c55e; color: #052e16; font-weight: bold; padding: 0.35rem 0.8rem; border-radius: 999px; font-size: 0.85rem; margin-top: 1rem; }
        p { color: #cbd5e1; line-height: 1.6; }
    </style>
</head>
<body>
    <div class="card">
        <h1>🏢 Portail Intranet — CORP.LOCAL</h1>
        <p>Serveur Linux <strong>srv-ubuntu-01</strong> (Ubuntu Server 24.04 LTS)</p>
        <p>Résolution DNS assurée par le Contrôleur de Domaine Active Directory <strong>SRV-DC01</strong>.</p>
        <span class="badge">✔ Pare-feu UFW & Fail2ban Actifs</span>
    </div>
</body>
</html>
EOF

systemctl enable --now nginx

echo ""
echo "=================================================================="
echo "  TERMINE ! État actuel du pare-feu UFW :"
echo "=================================================================="
ufw status verbose
