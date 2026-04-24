# 02-install-roles.ps1
# Windows Server 2022 - Role Installation
# AZ-802 Lab Environment
# Run as Administrator after baseline setup and restart

#Requires -RunAsAdministrator

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  MS Lab Server - Role Installation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Install AD DS
Write-Host "[ STEP 1 ] Installing Active Directory Domain Services" -ForegroundColor Yellow
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Write-Host "✓ AD DS installed`n"

# Install DNS
Write-Host "[ STEP 2 ] Installing DNS Server" -ForegroundColor Yellow
Install-WindowsFeature -Name DNS -IncludeManagementTools
Write-Host "✓ DNS installed`n"

# Install DHCP
Write-Host "[ STEP 3 ] Installing DHCP Server" -ForegroundColor Yellow
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Write-Host "✓ DHCP installed`n"

# Install GPMC
Write-Host "[ STEP 4 ] Installing Group Policy Management" -ForegroundColor Yellow
Install-WindowsFeature -Name GPMC
Write-Host "✓ GPMC installed`n"

# Install Certificate Services
Write-Host "[ STEP 5 ] Installing Certificate Services" -ForegroundColor Yellow
Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools
Write-Host "✓ Certificate Services installed`n"

# Install RSAT tools
Write-Host "[ STEP 6 ] Installing RSAT Management Tools" -ForegroundColor Yellow
Install-WindowsFeature -Name RSAT -IncludeAllSubFeature
Write-Host "✓ RSAT tools installed`n"

# Verify installations
Write-Host "[ VERIFICATION ] Installed roles and features:" -ForegroundColor Yellow
Get-WindowsFeature | Where-Object {$_.Installed -eq $True} | 
    Select-Object Name, DisplayName | Format-Table -AutoSize

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Role Installation Complete" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Run 03-configure-adds.ps1 to promote to Domain Controller" -ForegroundColor Gray
Write-Host "  2. Configure DHCP scope" -ForegroundColor Gray
Write-Host "  3. Configure DNS zones" -ForegroundColor Gray
Write-Host ""