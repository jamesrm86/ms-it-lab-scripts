# 03-configure-adds.ps1
# Windows Server 2022 - AD DS Domain Controller Promotion
# AZ-802 Lab Environment
# Run as Administrator after role installation

#Requires -RunAsAdministrator

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  MS Lab Server - AD DS Configuration" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Lab domain settings
$DomainName     = "lab.local"
$NetBiosName    = "LAB"
$DSRMPassword   = ConvertTo-SecureString "Lab@dm1n2024!" -AsPlainText -Force

Write-Host "[ CONFIGURATION ]" -ForegroundColor Yellow
Write-Host "  Domain Name    : $DomainName"
Write-Host "  NetBIOS Name   : $NetBiosName"
Write-Host "  Forest Level   : Windows2016Forest"
Write-Host "  Domain Level   : Windows2016Domain`n"

# Confirm before proceeding
$Confirm = Read-Host "Promote this server to Domain Controller? (yes/no)"

if ($Confirm -ne "yes") {
    Write-Host "`n✗ Operation cancelled by operator" -ForegroundColor Red
    exit
}

Write-Host "`n[ STEP 1 ] Promoting to Domain Controller" -ForegroundColor Yellow
Write-Host "  This will restart the server automatically...`n"

try {
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $NetBiosName `
        -ForestMode "WinThreshold" `
        -DomainMode "WinThreshold" `
        -InstallDns:$true `
        -SafeModeAdministratorPassword $DSRMPassword `
        -Force:$true

    Write-Host "✓ Domain Controller promotion initiated" -ForegroundColor Green
    Write-Host "  Server will restart automatically`n"

} catch {
    Write-Host "✗ Promotion failed: $_" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  After restart run:" -ForegroundColor Cyan
Write-Host "  04-configure-ou-structure.ps1" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan