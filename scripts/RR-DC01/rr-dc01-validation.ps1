#requires -version 4.0
#requires -modules ActiveDirectory,GroupPolicy

# RR-DC01 read-only validation script
# RapidRoute Logistics Network
# Updated for RR-FS01, the 7-Zip deployment GPO and RR-WEB01.
# This script does not change the server configuration.

$ErrorActionPreference = 'Continue'
$script:Passed = 0
$script:Failed = 0

function Show-Result {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][bool]$Success,
        [string]$Details = ''
    )

    if ($Success) {
        $script:Passed++
        Write-Host ('[PASS] {0}' -f $Name) -ForegroundColor Green
    }
    else {
        $script:Failed++
        Write-Host ('[FAIL] {0}' -f $Name) -ForegroundColor Red
    }

    if ($Details) {
        Write-Host ('       {0}' -f $Details)
    }
}

function Test-PingQuiet {
    param([Parameter(Mandatory = $true)][string]$ComputerName)
    return [bool](Test-Connection -ComputerName $ComputerName -Count 2 -Quiet -ErrorAction SilentlyContinue)
}

function Get-ResolvedIPv4 {
    param([Parameter(Mandatory = $true)][string]$Name)

    try {
        return @(Resolve-DnsName -Name $Name -Server 192.168.186.10 -Type A -ErrorAction Stop |
            Where-Object { $_.IPAddress } |
            Select-Object -ExpandProperty IPAddress)
    }
    catch {
        return @()
    }
}

Write-Host '=== RR-DC01 ALAPADATOK ===' -ForegroundColor Cyan
hostname
Get-NetIPConfiguration | Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer

Write-Host "`n=== HALOZAT ES DNS ===" -ForegroundColor Cyan
Show-Result 'Az atjaro elerheto' (Test-PingQuiet '192.168.186.2') '192.168.186.2'

$dcAddress = Get-ResolvedIPv4 'RR-DC01.rapidroute.local'
Show-Result 'RR-DC01 DNS-rekord' ($dcAddress -contains '192.168.186.10') ($dcAddress -join ', ')

$webAddress = Get-ResolvedIPv4 'RR-WEB01.rapidroute.local'
Show-Result 'RR-WEB01 A rekord' ($webAddress -contains '192.168.186.30') ($webAddress -join ', ')

$wwwAddress = Get-ResolvedIPv4 'www.rapidroute.local'
Show-Result 'www CNAME feloldasa' ($wwwAddress -contains '192.168.186.30') ($wwwAddress -join ', ')

try {
    $externalAddress = @(Resolve-DnsName -Name 'microsoft.com' -Server 192.168.186.10 -Type A -ErrorAction Stop |
        Where-Object { $_.IPAddress } |
        Select-Object -ExpandProperty IPAddress)
    Show-Result 'Kulso DNS-feloldas' ($externalAddress.Count -gt 0) ($externalAddress -join ', ')
}
catch {
    Show-Result 'Kulso DNS-feloldas' $false $_.Exception.Message
}

Write-Host "`n=== ACTIVE DIRECTORY ===" -ForegroundColor Cyan
Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode | Format-List
Get-ADForest | Select-Object RootDomain,ForestMode | Format-List

try {
    $fsComputer = Get-ADComputer -Identity 'RR-FS01' -Properties Enabled,DistinguishedName -ErrorAction Stop
    $inServersOu = $fsComputer.Enabled -and ($fsComputer.DistinguishedName -like 'CN=RR-FS01,OU=Servers,OU=RapidRoute,*')
    Show-Result 'RR-FS01 AD-objektum a Servers OU-ban' $inServersOu $fsComputer.DistinguishedName
}
catch {
    Show-Result 'RR-FS01 AD-objektum a Servers OU-ban' $false $_.Exception.Message
}

Write-Host "`n=== RR-FS01 ES SZOFTVERCSOMAG ===" -ForegroundColor Cyan
Show-Result 'RR-FS01 halozaton elerheto' (Test-PingQuiet 'RR-FS01') '192.168.186.20'

$packagePath = '\\RR-FS01\Software$\7-Zip-x64.msi'
Show-Result 'A 7-Zip MSI elerheto' (Test-Path -LiteralPath $packagePath) $packagePath

Write-Host "`n=== GROUP POLICY OBJEKTUMOK ===" -ForegroundColor Cyan
$gpoNames = @(
    'GPO_RapidRoute_Client_Baseline',
    'GPO_RapidRoute_7Zip_Deployment'
)

foreach ($gpoName in $gpoNames) {
    try {
        $gpo = Get-GPO -Name $gpoName -ErrorAction Stop
        Show-Result ("A GPO letezik: {0}" -f $gpoName) $true ("Status: {0}; Modified: {1}" -f $gpo.GpoStatus,$gpo.ModificationTime)
    }
    catch {
        Show-Result ("A GPO letezik: {0}" -f $gpoName) $false $_.Exception.Message
    }
}

$computersOu = 'OU=Computers,OU=RapidRoute,DC=rapidroute,DC=local'
try {
    $linkedGpos = @((Get-GPInheritance -Target $computersOu -ErrorAction Stop).GpoLinks |
        Where-Object { $_.DisplayName -in $gpoNames })
    Show-Result 'Mindket GPO a Computers OU-hoz kapcsolodik' ($linkedGpos.Count -eq 2) (($linkedGpos | Select-Object -ExpandProperty DisplayName) -join ', ')
}
catch {
    Show-Result 'Mindket GPO a Computers OU-hoz kapcsolodik' $false $_.Exception.Message
}

Write-Host "`n=== CSOPORTTAGSAGOK ===" -ForegroundColor Cyan
$groups = @(
    'GG_Budapest_Users',
    'GG_Debrecen_Logisztika_Users',
    'GG_Debrecen_Depo_Users'
)

$membershipRows = foreach ($group in $groups) {
    try {
        Get-ADGroupMember -Identity $group -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                Group          = $group
                Name           = $_.Name
                SamAccountName = $_.SamAccountName
            }
        }
    }
    catch {
        [PSCustomObject]@{
            Group          = $group
            Name           = '[ERROR]'
            SamAccountName = $_.Exception.Message
        }
    }
}
$membershipRows | Format-Table Group,Name,SamAccountName -AutoSize

Write-Host "`n=== RR-WEB01 HTTP ES HTTPS ===" -ForegroundColor Cyan
Show-Result 'RR-WEB01 halozaton elerheto' (Test-PingQuiet 'RR-WEB01') '192.168.186.30'

try {
    $httpResponse = Invoke-WebRequest -Uri 'http://www.rapidroute.local' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Show-Result 'A RapidRoute HTTP-oldal 200 valaszt ad' ($httpResponse.StatusCode -eq 200) ("Status: {0}" -f $httpResponse.StatusCode)
}
catch {
    Show-Result 'A RapidRoute HTTP-oldal 200 valaszt ad' $false $_.Exception.Message
}

$previousCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
$previousProtocol = [System.Net.ServicePointManager]::SecurityProtocol
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
    $httpsResponse = Invoke-WebRequest -Uri 'https://www.rapidroute.local' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Show-Result 'A RapidRoute HTTPS-oldal 200 valaszt ad' ($httpsResponse.StatusCode -eq 200) ("Status: {0}; sajat alairasu tanusitvany elfogadva csak ehhez a teszthez" -f $httpsResponse.StatusCode)
}
catch {
    Show-Result 'A RapidRoute HTTPS-oldal 200 valaszt ad' $false $_.Exception.Message
}
finally {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $previousCallback
    [System.Net.ServicePointManager]::SecurityProtocol = $previousProtocol
}

Write-Host "`n=== TARTOMANYVEZERLO SZOLGALTATASOK ===" -ForegroundColor Cyan
$serviceNames = @('ADWS','DNS','DFSR','KDC','Netlogon','NTDS')
$serviceRows = Get-Service -Name $serviceNames -ErrorAction SilentlyContinue |
    Select-Object Name,Status
$serviceRows | Format-Table -AutoSize
Show-Result 'Minden kiemelt DC-szolgaltatas fut' (@($serviceRows | Where-Object { $_.Status -ne 'Running' }).Count -eq 0)

Write-Host "`n=== DCDIAG KIEMELT TESZTEK ===" -ForegroundColor Cyan
dcdiag /test:Connectivity /test:Advertising /test:SysVolCheck /test:Services

Write-Host "`n=== ELLENORZESI OSSZESITO ===" -ForegroundColor Cyan
Write-Host ('Sikeres ellenorzesek: {0}' -f $script:Passed) -ForegroundColor Green
Write-Host ('Sikertelen ellenorzesek: {0}' -f $script:Failed) -ForegroundColor $(if ($script:Failed -eq 0) { 'Green' } else { 'Red' })

if ($script:Failed -eq 0) {
    Write-Host 'OVERALL RESULT: PASS' -ForegroundColor Green
    exit 0
}

Write-Host 'OVERALL RESULT: FAIL' -ForegroundColor Red
exit 1
