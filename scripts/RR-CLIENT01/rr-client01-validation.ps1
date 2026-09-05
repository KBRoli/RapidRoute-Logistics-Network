#requires -version 5.1

# RR-CLIENT01 read-only validation script
# RapidRoute Logistics Network
# This script does not change the client or server configuration.
# Run it while signed in as RAPIDROUTE\teszt.budapest.

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

function Test-DeniedAccess {
    param([Parameter(Mandatory = $true)][string]$Path)

    try {
        Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop | Out-Null
        return $false
    }
    catch {
        $permissionDenied = $_.CategoryInfo.Category -eq [System.Management.Automation.ErrorCategory]::PermissionDenied
        $unauthorizedException = $_.Exception -is [System.UnauthorizedAccessException]
        $deniedMessage = $_.Exception.Message -match 'denied|megtagad'
        return ($permissionDenied -or $unauthorizedException -or $deniedMessage)
    }
}

Clear-Host
Write-Host '=== RR-CLIENT01 VEGSO VALIDACIO ===' -ForegroundColor Cyan
Write-Host ('Futtatas ideje: {0}' -f (Get-Date))

Write-Host "`n=== RENDSZER ES HALOZAT ===" -ForegroundColor Cyan
$computerSystem = Get-CimInstance Win32_ComputerSystem
$operatingSystem = Get-CimInstance Win32_OperatingSystem
Show-Result 'A gepnev RR-CLIENT01' ($env:COMPUTERNAME -eq 'RR-CLIENT01') $env:COMPUTERNAME
Show-Result 'Windows 10 Pro operacios rendszer' ($operatingSystem.Caption -like '*Windows 10 Pro*') $operatingSystem.Caption

$ipv4Addresses = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike '127.*' } |
    Select-Object -ExpandProperty IPAddress)
Show-Result 'A statikus IPv4-cim megfelelo' ($ipv4Addresses -contains '192.168.186.40') ($ipv4Addresses -join ', ')

$defaultGateways = @(Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty NextHop -Unique)
Show-Result 'Az alapertelmezett atjaro megfelelo' ($defaultGateways -contains '192.168.186.2') ($defaultGateways -join ', ')

$dnsServers = @(Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty ServerAddresses)
Show-Result 'Az RR-DC01 a DNS-kiszolgalo' ($dnsServers -contains '192.168.186.10') ($dnsServers -join ', ')
Show-Result 'Az RR-DC01 elerheto' (Test-PingQuiet '192.168.186.10') '192.168.186.10'
Show-Result 'Az RR-FS01 elerheto' (Test-PingQuiet '192.168.186.20') '192.168.186.20'
Show-Result 'Az RR-WEB01 elerheto' (Test-PingQuiet '192.168.186.30') '192.168.186.30'

Write-Host "`n=== TARTOMANY ES FELHASZNALO ===" -ForegroundColor Cyan
Show-Result 'A gep a rapidroute.local tartomany tagja' ($computerSystem.PartOfDomain -and $computerSystem.Domain -eq 'rapidroute.local') $computerSystem.Domain

try {
    $secureChannel = Test-ComputerSecureChannel -ErrorAction Stop
    Show-Result 'A tartomanyi biztonsagos csatorna megfelelo' ([bool]$secureChannel) ("Eredmeny: {0}" -f $secureChannel)
}
catch {
    Show-Result 'A tartomanyi biztonsagos csatorna megfelelo' $false $_.Exception.Message
}

$currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$currentUser = $currentIdentity.Name
Show-Result 'A teszt.budapest tartomanyi fiok van bejelentkezve' ($currentUser -ieq 'RAPIDROUTE\teszt.budapest') $currentUser

$currentGroups = @($currentIdentity.Groups | ForEach-Object {
    try { $_.Translate([System.Security.Principal.NTAccount]).Value }
    catch { $_.Value }
})
Show-Result 'A felhasznalo a GG_Budapest_Users tagja' ($currentGroups -icontains 'RAPIDROUTE\GG_Budapest_Users') 'RAPIDROUTE\GG_Budapest_Users'

Write-Host "`n=== GROUP POLICY ES SZOFTVER ===" -ForegroundColor Cyan
$policyPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$policy = Get-ItemProperty -LiteralPath $policyPath -ErrorAction SilentlyContinue
Show-Result 'A jogi bejelentkezesi cim alkalmazva' ($policy.LegalNoticeCaption -eq 'RapidRoute Logistics') $policy.LegalNoticeCaption
Show-Result 'A jogi bejelentkezesi szoveg alkalmazva' ($policy.LegalNoticeText -eq 'Authorized RapidRoute users only.') $policy.LegalNoticeText
Show-Result 'Az inaktivitasi zarolas 900 masodperc' ([int]$policy.InactivityTimeoutSecs -eq 900) ("{0} masodperc" -f $policy.InactivityTimeoutSecs)

$sevenZipExecutable = 'C:\Program Files\7-Zip\7zFM.exe'
$sevenZipPackage = @(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like '7-Zip*' } |
    Select-Object -First 1)
$sevenZipInstalled = (Test-Path -LiteralPath $sevenZipExecutable) -and ($sevenZipPackage.Count -eq 1)
$sevenZipDetails = if ($sevenZipPackage.Count -eq 1) {
    '{0}, verzio: {1}' -f $sevenZipPackage[0].DisplayName,$sevenZipPackage[0].DisplayVersion
}
else {
    $sevenZipExecutable
}
Show-Result 'A 7-Zip telepitve van' $sevenZipInstalled $sevenZipDetails

Write-Host "`n=== FAJL- ES NYOMTATASI SZOLGALTATASOK ===" -ForegroundColor Cyan
$budapestTestFile = '\\RR-FS01\Budapest\RR-CLIENT01_teszt.txt'
Show-Result 'A Budapest megosztas tesztfajlja elerheto' (Test-Path -LiteralPath $budapestTestFile) $budapestTestFile
Show-Result 'A Debrecen_Logisztika megosztas tiltott' (Test-DeniedAccess '\\RR-FS01\Debrecen_Logisztika') '\\RR-FS01\Debrecen_Logisztika'
Show-Result 'A Debrecen_Depo megosztas tiltott' (Test-DeniedAccess '\\RR-FS01\Debrecen_Depo') '\\RR-FS01\Debrecen_Depo'

try {
    $printer = Get-Printer -Name '\\RR-FS01\RR-Office-Printer' -ErrorAction Stop
    Show-Result 'Az RR-Office-Printer csatlakoztatva van' ($printer.PrinterStatus -eq 'Normal') ("Allapot: {0}; illesztoprogram: {1}" -f $printer.PrinterStatus,$printer.DriverName)
}
catch {
    Show-Result 'Az RR-Office-Printer csatlakoztatva van' $false $_.Exception.Message
}

Write-Host "`n=== DNS, HTTP ES HTTPS ===" -ForegroundColor Cyan
$webAddress = Get-ResolvedIPv4 'RR-WEB01.rapidroute.local'
Show-Result 'Az RR-WEB01 DNS-rekord megfelelo' ($webAddress -contains '192.168.186.30') ($webAddress -join ', ')

$wwwAddress = Get-ResolvedIPv4 'www.rapidroute.local'
Show-Result 'A www DNS-nev feloldasa megfelelo' ($wwwAddress -contains '192.168.186.30') ($wwwAddress -join ', ')

try {
    $httpResponse = Invoke-WebRequest -Uri 'http://www.rapidroute.local' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Show-Result 'A RapidRoute HTTP-oldal 200 valaszt ad' ($httpResponse.StatusCode -eq 200) ("Status: {0}" -f $httpResponse.StatusCode)
}
catch {
    Show-Result 'A RapidRoute HTTP-oldal 200 valaszt ad' $false $_.Exception.Message
}

$trustedCertificate = @(Get-ChildItem Cert:\LocalMachine\Root -ErrorAction SilentlyContinue |
    Where-Object { $_.Subject -like 'CN=www.rapidroute.local*' } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1)
$certificateTrusted = ($trustedCertificate.Count -eq 1) -and ($trustedCertificate[0].NotAfter -gt (Get-Date))
$certificateDetails = if ($trustedCertificate.Count -eq 1) {
    'Lejarat: {0}; ujjlenyomat: {1}' -f $trustedCertificate[0].NotAfter,$trustedCertificate[0].Thumbprint
}
else {
    'Nem talalhato a LocalMachine Root taroloban'
}
Show-Result 'A RapidRoute TLS-tanusitvany megbizhato' $certificateTrusted $certificateDetails

try {
    $httpsResponse = Invoke-WebRequest -Uri 'https://www.rapidroute.local' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Show-Result 'A RapidRoute HTTPS-oldal megbizhatoan 200 valaszt ad' ($httpsResponse.StatusCode -eq 200) ("Status: {0}; tanusitvany-ellenorzes megkerulese nelkul" -f $httpsResponse.StatusCode)
}
catch {
    Show-Result 'A RapidRoute HTTPS-oldal megbizhatoan 200 valaszt ad' $false $_.Exception.Message
}

Write-Host "`n=== ELLENORZESI OSSZESITO ===" -ForegroundColor Cyan
Write-Host ('Sikeres ellenorzesek: {0}' -f $script:Passed) -ForegroundColor Green
Write-Host ('Sikertelen ellenorzesek: {0}' -f $script:Failed) -ForegroundColor $(if ($script:Failed -eq 0) { 'Green' } else { 'Red' })

if ($script:Failed -eq 0) {
    Write-Host 'OVERALL RESULT: PASS' -ForegroundColor Green
    exit 0
}

Write-Host 'OVERALL RESULT: FAIL' -ForegroundColor Red
exit 1
