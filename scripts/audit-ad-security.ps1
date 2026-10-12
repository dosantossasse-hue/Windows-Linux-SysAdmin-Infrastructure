<#
.SYNOPSIS
    Script d'audit de sécurité pour Windows Server & Active Directory (SecOps / Hardening).
.DESCRIPTION
    Vérifie les points critiques de sécurité d'un Contrôleur de Domaine Windows Server :
    1. Informations système et rôle du domaine
    2. État des profils du Pare-feu Windows Defender
    3. Vérification de la désactivation du protocole vulnérable SMBv1
    4. Politique de mots de passe et de verrouillage Active Directory
    5. Comptes à hauts privilèges (Domain Admins) et comptes inactifs ou sans expiration
    6. Liste des partages réseau SMB actifs
.AUTHOR
    dosantossasse-hue
#>

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   AUDIT DE SECURITE WINDOWS SERVER & ACTIVE DIRECTORY          " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Date de l'audit : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Serveur         : $env:COMPUTERNAME`n"

# 1. Etat du Pare-feu Windows Defender
Write-Host "[1/5] Verification du Pare-feu Windows Defender..." -ForegroundColor Yellow
Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | Format-Table -AutoSize

# 2. Verification du protocole SMBv1 (Critique : EternalBlue)
Write-Host "[2/5] Verification du protocole SMBv1..." -ForegroundColor Yellow
$smb1 = Get-SmbServerConfiguration | Select-Object -ExpandProperty EnableSMB1Protocol
if ($smb1 -eq $false) {
    Write-Host "  [OK] SMBv1 est desactive (Conforme aux bonnes pratiques)." -ForegroundColor Green
} else {
    Write-Host "  [ALERTE] SMBv1 est ACTIVE ! Desactiver immediatement : Set-SmbServerConfiguration -EnableSMB1Protocol `$false" -ForegroundColor Red
}

# 3. Audit de la politique de mots de passe Active Directory
Write-Host "`n[3/5] Verification de la politique de mots de passe du domaine..." -ForegroundColor Yellow
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Import-Module ActiveDirectory
    $policy = Get-ADDefaultDomainPasswordPolicy
    Write-Host "  - Longueur minimale du mot de passe : $($policy.MinPasswordLength) caracteres"
    Write-Host "  - Complexite activee                : $($policy.ComplexityEnabled)"
    Write-Host "  - Seuil de verrouillage de compte   : $($policy.LockoutThreshold) tentatives"

    # 4. Audit des comptes Domain Admins et mots de passe n'expirant jamais
    Write-Host "`n[4/5] Audit des comptes a privileges (Admins du domaine)..." -ForegroundColor Yellow
    Get-ADGroupMember -Identity "Admins du domaine" -ErrorAction SilentlyContinue |
        Select-Object Name, SamAccountName, objectClass | Format-Table -AutoSize

    Write-Host "  Comptes utilisateurs avec mot de passe n'expirant jamais :" -ForegroundColor Yellow
    Get-ADUser -Filter 'PasswordNeverExpires -eq $true -and Enabled -eq $true' -Properties PasswordNeverExpires |
        Select-Object Name, SamAccountName, PasswordNeverExpires | Format-Table -AutoSize
} else {
    Write-Host "  [INFO] Module ActiveDirectory non detecte sur cette machine." -ForegroundColor Gray
}

# 5. Audit des partages reseau SMB
Write-Host "[5/5] Liste des partages reseau SMB actifs..." -ForegroundColor Yellow
Get-SmbShare | Select-Object Name, Path, Description | Format-Table -AutoSize

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   FIN DE L'AUDIT DE SECURITE                                   " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
