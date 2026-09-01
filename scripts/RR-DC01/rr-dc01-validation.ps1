#requires -version 4.0
#requires -modules ActiveDirectory,GroupPolicy

# RR-DC01 read-only validation script
# RapidRoute Logistics Network
# Updated after the RR-FS01 and 7-Zip deployment GPO configuration.
# This script does not change the server configuration.

$ErrorActionPreference = "Continue"

Write-Host "=== RR-DC01 ALAPADATOK ===" -ForegroundColor Cyan
hostname
Get-NetIPConfiguration

Write-Host "`n=== ATJARO ELLENORZESE ===" -ForegroundColor Cyan
Test-Connection -ComputerName 192.168.186.2 -Count 4

Write-Host "`n=== ACTIVE DIRECTORY ===" -ForegroundColor Cyan
Get-ADDomain | Select-Object DNSRoot, NetBIOSName, DomainMode
Get-ADForest | Select-Object RootDomain, ForestMode

Write-Host "`n=== RR-FS01 AD OBJEKTUM ===" -ForegroundColor Cyan
Get-ADComputer -Identity "RR-FS01" -Properties Enabled, DistinguishedName |
    Select-Object Name, Enabled, DistinguishedName

Write-Host "`n=== DNS TESZTEK ===" -ForegroundColor Cyan
nslookup RR-DC01.rapidroute.local 192.168.186.10
nslookup 192.168.186.10 192.168.186.10
nslookup microsoft.com 192.168.186.10

Write-Host "`n=== RR-FS01 ES SZOFTVERCSOMAG ===" -ForegroundColor Cyan
Test-Connection -ComputerName "RR-FS01" -Count 4

$packagePath = '\\RR-FS01\Software$\7-Zip-x64.msi'
$packageAvailable = Test-Path -LiteralPath $packagePath

[PSCustomObject]@{
    PackagePath = $packagePath
    Available   = $packageAvailable
} | Format-List

Write-Host "`n=== GROUP POLICY OBJEKTUMOK ===" -ForegroundColor Cyan
$gpoNames = @(
    "GPO_RapidRoute_Client_Baseline",
    "GPO_RapidRoute_7Zip_Deployment"
)

foreach ($gpoName in $gpoNames) {
    try {
        Get-GPO -Name $gpoName -ErrorAction Stop |
            Select-Object DisplayName, GpoStatus, CreationTime, ModificationTime
    }
    catch {
        Write-Warning "A GPO nem talalhato: $gpoName"
    }
}

Write-Host "`n=== COMPUTERS OU GPO KAPCSOLATOK ===" -ForegroundColor Cyan
$computersOu = "OU=Computers,OU=RapidRoute,DC=rapidroute,DC=local"

try {
    (Get-GPInheritance -Target $computersOu -ErrorAction Stop).GpoLinks |
        Where-Object { $_.DisplayName -in $gpoNames } |
        Select-Object DisplayName, Enabled, Enforced, Order
}
catch {
    Write-Warning "A Computers OU GPO kapcsolatai nem kerdezhetok le: $($_.Exception.Message)"
}

Write-Host "`n=== CSOPORTTAGSAGOK ===" -ForegroundColor Cyan
$groups = @(
    "GG_Budapest_Users",
    "GG_Debrecen_Logisztika_Users",
    "GG_Debrecen_Depo_Users"
)

foreach ($group in $groups) {
    Write-Host "--- $group ---" -ForegroundColor Yellow
    Get-ADGroupMember $group | Select-Object Name, SamAccountName
}

Write-Host "`n=== TARTOMANYVEZERLO SZOLGALTATASOK ===" -ForegroundColor Cyan
Get-Service ADWS, DNS, DFSR, KDC, Netlogon, NTDS |
    Select-Object Name, Status

Write-Host "`n=== DCDIAG KIEMELT TESZTEK ===" -ForegroundColor Cyan
dcdiag /test:Connectivity /test:Advertising /test:SysVolCheck /test:Services

Write-Host "`nAz ellenorzes befejezodott." -ForegroundColor Green
