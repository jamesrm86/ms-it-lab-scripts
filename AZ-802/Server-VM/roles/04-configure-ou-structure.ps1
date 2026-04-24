# 04-configure-ou-structure.ps1
# Windows Server 2022 - OU Structure Configuration
# AZ-802 Lab Environment
# Run as Administrator after DC promotion and restart

#Requires -RunAsAdministrator

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  MS Lab Server - OU Structure Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Domain root
$Domain = "DC=lab,DC=local"

# OU Structure
$OUStructure = @(
    # Top level OUs
    @{Name="LAB-Users";     Path=$Domain;                          Desc="All lab user accounts"},
    @{Name="LAB-Computers"; Path=$Domain;                          Desc="All lab computer accounts"},
    @{Name="LAB-Groups";    Path=$Domain;                          Desc="All lab security groups"},
    @{Name="LAB-Servers";   Path=$Domain;                          Desc="All lab server accounts"},
    @{Name="LAB-Service";   Path=$Domain;                          Desc="Service accounts"},

    # User sub OUs
    @{Name="Admins";        Path="OU=LAB-Users,$Domain";           Desc="Administrator accounts"},
    @{Name="Standard";      Path="OU=LAB-Users,$Domain";           Desc="Standard user accounts"},
    @{Name="Test";          Path="OU=LAB-Users,$Domain";           Desc="Test user accounts"},

    # Computer sub OUs
    @{Name="Workstations";  Path="OU=LAB-Computers,$Domain";       Desc="Workstation endpoints"},
    @{Name="Laptops";       Path="OU=LAB-Computers,$Domain";       Desc="Laptop endpoints"},
    @{Name="Kiosks";        Path="OU=LAB-Computers,$Domain";       Desc="Kiosk devices"}
)

Write-Host "[ STEP 1 ] Creating OU Structure" -ForegroundColor Yellow

foreach ($OU in $OUStructure) {
    try {
        New-ADOrganizationalUnit `
            -Name $OU.Name `
            -Path $OU.Path `
            -Description $OU.Desc `
            -ProtectedFromAccidentalDeletion $true `
            -ErrorAction Stop
        Write-Host "  ✓ Created: OU=$($OU.Name),$($OU.Path)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed or exists: $($OU.Name) - $_" -ForegroundColor Red
    }
}

# Create base security groups
Write-Host "`n[ STEP 2 ] Creating Base Security Groups" -ForegroundColor Yellow

$Groups = @(
    @{Name="LAB-Admins";        Path="OU=LAB-Groups,$Domain"; Desc="Lab administrators"},
    @{Name="LAB-Users";         Path="OU=LAB-Groups,$Domain"; Desc="Standard lab users"},
    @{Name="LAB-Helpdesk";      Path="OU=LAB-Groups,$Domain"; Desc="Helpdesk staff"},
    @{Name="LAB-Workstations";  Path="OU=LAB-Groups,$Domain"; Desc="Workstation computer group"}
)

foreach ($Group in $Groups) {
    try {
        New-ADGroup `
            -Name $Group.Name `
            -Path $Group.Path `
            -GroupScope Global `
            -GroupCategory Security `
            -Description $Group.Desc `
            -ErrorAction Stop
        Write-Host "  ✓ Created: $($Group.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Failed or exists: $($Group.Name) - $_" -ForegroundColor Red
    }
}

# Create lab admin user
Write-Host "`n[ STEP 3 ] Creating Lab Admin User" -ForegroundColor Yellow

$AdminPass = ConvertTo-SecureString "Lab@dm1n2024!" -AsPlainText -Force

try {
    New-ADUser `
        -Name "Lab Admin" `
        -GivenName "Lab" `
        -Surname "Admin" `
        -SamAccountName "labadmin" `
        -UserPrincipalName "labadmin@lab.local" `
        -Path "OU=Admins,OU=LAB-Users,$Domain" `
        -AccountPassword $AdminPass `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -ErrorAction Stop
    
    Add-ADGroupMember -Identity "LAB-Admins" -Members "labadmin"
    Add-ADGroupMember -Identity "Domain Admins" -Members "labadmin"
    Write-Host "  ✓ Lab admin user created and added to Domain Admins" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $_" -ForegroundColor Red
}

# Verify structure
Write-Host "`n[ VERIFICATION ] OU Structure:" -ForegroundColor Yellow
Get-ADOrganizationalUnit -Filter * | 
    Select-Object Name, Distinguish