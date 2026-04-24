# 01-initial-setup.ps1
# Windows Server 2022 - Initial Baseline Setup
# AZ-802 Lab Environment
# Run as Administrator after clean OS install

#Requires -RunAsAdministrator

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  MS Lab Server - Initial Baseline Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Set server name
$ServerName = "MS-LAB-DC01"
Write-Host "[ STEP 1 ] Setting computer name to $ServerName" -ForegroundColor Yellow
Rename-Computer -NewName $ServerName -Force
Write-Host "✓ Computer name set - will apply after restart`n"

# Set timezone
Write-Host "[ STEP 2 ] Setting timezone to Central Standard Time" -ForegroundColor Yellow
Set-TimeZone -Id "Central Standard Time"
Write-Host "✓ Timezone configured`n"

# Configure NTP
Write-Host "[ STEP 3 ] Configuring NTP time sync" -ForegroundColor Yellow
w32tm /config /manualpeerlist:"time.windows.com" /syncfromflags:manual /reliable:YES /update
Start-Service w32time
w32tm /resync
Write-Host "✓ NTP configured and synced`n"

# Disable IE Enhanced Security (lab only)
Write-Host "[ STEP 4 ] Disabling IE Enhanced Security (lab environment)" -ForegroundColor Yellow
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Write-Host "✓ IE Enhanced Security disabled`n"

# Enable Remote Desktop
Write-Host "[ STEP 5 ] Enabling Remote Desktop" -ForegroundColor Yellow
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Write-Host "✓ Remote Desktop enabled`n"

# Disable Windows Firewall (lab only)
Write-Host "[ STEP 6 ] Configuring Windows Firewall for lab" -ForegroundColor Yellow
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-Host "✓ Firewall configured for lab environment`n"

# Set static IP placeholder
Write-Host "[ STEP 7 ] Network configuration" -ForegroundColor Yellow
Write-Host "  Current IP configuration:" -ForegroundColor Gray
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"} | 
    Select-Object InterfaceAlias, IPAddress, PrefixLength | Format-Table
Write-Host "  Note: Configure static IP manually after review`n"

# Windows Update settings
Write-Host "[ STEP 8 ] Configuring Windows Update for lab" -ForegroundColor Yellow
$WUSettings = (New-Object -ComObject "Microsoft.Update.AutoUpdate").Settings
Write-Host "✓ Review Windows Update settings in Server Manager`n"

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Baseline Setup Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Review network settings above" -ForegroundColor Gray
Write-Host "  2. Restart to apply computer name" -ForegroundColor Gray
Write-Host "  3. Run 02-install-roles.ps1 after restart" -ForegroundColor Gray
Write-Host ""

$Restart = Read-Host "Restart now to apply changes? (yes/no)"
if ($Restart -eq "yes") {
    Restart-Computer -Force
}