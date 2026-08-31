# RR-DC01 read-only validation script
# RapidRoute Logistics Network
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

Write-Host "`n=== DNS TESZTEK ===" -ForegroundColor Cyan
nslookup RR-DC01.rapidroute.local 192.168.186.10
nslookup 192.168.186.10 192.168.186.10
nslookup microsoft.com 192.168.186.10

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

