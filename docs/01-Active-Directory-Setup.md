# 🟦 Projets Windows Server & Active Directory (Par Ordre Croissant)

Ce guide regroupe les **3 projets progressifs** réalisés sous Windows Server (`SRV-DC01`) et Windows 10/11 Pro (`PC-CLIENT01`), du niveau débutant au niveau avancé.

---

## 🟢 PROJET AD N°1 (Niveau Base) : Créer le Domaine, les Utilisateurs et Connecter un PC

### Étape 1.1 — Préparer le serveur (`SRV-DC01`)
Dans le **Gestionnaire de serveur** $\rightarrow$ **Serveur local** :
1. **Renommer le serveur** : `SRV-DC01`
2. **Fixer l'adresse IPv4** :
   - Adresse IP : `192.168.100.10`
   - Masque : `255.255.255.0`
   - Serveur DNS préféré : `127.0.0.1`
3. 📸 **Capture n°1 à prendre** : `docs/screenshots/01-server-manager.png`

### Étape 1.2 — Installer Active Directory (AD DS) et promouvoir le domaine
1. **Gérer** $\rightarrow$ **Ajouter des rôles et des fonctionnalités** $\rightarrow$ Cocher **Services AD DS** et **Serveur DNS**.
2. Cliquer sur le **drapeau jaune** en haut $\rightarrow$ **Promouvoir ce serveur en contrôleur de domaine**.
3. Choisir **Ajouter une nouvelle forêt** $\rightarrow$ Nom de domaine : **`corp.local`**.

### Étape 1.3 — Créer l'arborescence de l'entreprise (OU, Groupes, Utilisateurs)
Dans **Outils** $\rightarrow$ **Utilisateurs et ordinateurs Active Directory** :
1. Clic droit sur `corp.local` $\rightarrow$ *Nouveau* $\rightarrow$ **Unité d'organisation (OU)** :
   - Créer `Direction`, `Informatique`, `Comptabilite`, `Postes-Clients`.
2. Dans chaque OU, créer le groupe correspondant (`GRP_Direction`, `GRP_IT_Admins`, `GRP_Comptabilite`) et 1 ou 2 employés (ex. `Jean Dupont` dans `Comptabilite`).
3. 📸 **Capture n°2 à prendre** : `docs/screenshots/02-ad-structure.png`

### Étape 1.4 — Joindre le PC Windows 10/11 Pro au domaine
Sur la machine cliente **Windows 10/11 Pro** :
1. Mettre `192.168.100.10` comme serveur DNS dans les paramètres de la carte réseau.
2. Aller dans *Paramètres > Système > Informations système > Renommer ce PC (avancé)* $\rightarrow$ bouton **Modifier**.
3. Cocher **Domaine**, taper `corp.local`, entrer le compte `Administrateur` du serveur et redémarrer.
4. Ouvrir une session avec l'employé créé (ex. `CORP\j.dupont`).
5. 📸 **Capture n°3 à prendre** : `docs/screenshots/03-client-domain.png`

---

## 🟡 PROJET AD N°2 (Niveau Intermédiaire) : Serveur DHCP & Partage de Fichiers Sécurisé

### Étape 2.1 — Installer et configurer le Serveur DHCP
1. Dans le Gestionnaire de serveur : **Ajouter des rôles** $\rightarrow$ Cocher **Serveur DHCP**.
2. Ouvrir **Outils** $\rightarrow$ **DHCP** :
   - Clic droit sur **IPv4** $\rightarrow$ **Nouvelle étendue**.
   - Plage d'adresses : `192.168.100.100` à `192.168.100.200`.
   - Serveur DNS distribué : `192.168.100.10` | Domaine : `corp.local`.
3. Sur le PC Windows 10/11, remettre la carte réseau en **Obtenir une adresse IP automatiquement** et vérifier qu'il reçoit bien l'IP `.100`.
4. 📸 **Capture n°4 à prendre** : `docs/screenshots/04-dhcp-dns.png`

### Étape 2.2 — Créer un Serveur de Fichiers d'entreprise (SMB / NTFS)
1. Sur `SRV-DC01`, créer le dossier `C:\Partages\Partage-Compta`.
2. Clic droit $\rightarrow$ **Propriétés** $\rightarrow$ onglet **Partage** $\rightarrow$ **Partage avancé** :
   - Cocher *Partager ce dossier*.
   - Dans **Autorisations**, retirer *Tout le monde* et ajouter uniquement **`GRP_Comptabilite`** (Lecture/Modification) et **`Administrateurs`** (Contrôle total).
3. Vérifier depuis le PC Windows 10/11 qu'en tapant `\\SRV-DC01\Partage-Compta` dans l'Explorateur, l'employé de la comptabilité y accède.
4. 📸 **Capture n°5 à prendre** : `docs/screenshots/05-file-share.png`

---

## 🔴 PROJET AD N°3 (Niveau Avancé) : Stratégies de Groupe (GPO) & Audit Sécurité

### Étape 3.1 — Créer des GPO de sécurité
Dans **Outils** $\rightarrow$ **Gestion des stratégies de groupe** :
1. **Politique de mot de passe et verrouillage** (sur la *Default Domain Policy*) :
   - *Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies de comptes* :
   - Longueur minimale du mot de passe : **12 caractères**.
   - Seuil de verrouillage du compte : **3 tentatives invalides**.
2. **Restriction du Poste Client** (nouvelle GPO liée à l'OU `Comptabilite`) :
   - *Configuration utilisateur > Modèles d'administration > Panneau de configuration* :
   - Activer **« Interdire l'accès au Panneau de configuration et à l'application Paramètres »**.
3. 📸 **Capture n°6 à prendre** : `docs/screenshots/06-gpo-security.png`
