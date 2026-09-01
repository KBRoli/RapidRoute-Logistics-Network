#requires -version 4.0

# RR-FS01 final validation script
# RapidRoute Logistics

$ErrorActionPreference = "Continue"

function Show-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Output ""
    Write-Output ("=" * 70)
    Write-Output $Title
    Write-Output ("=" * 70)
}

Show-Section "RR-FS01 FINAL VALIDATION"
Write-Output "Validation time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Show-Section "SYSTEM INFORMATION"

Get-WmiObject Win32_ComputerSystem |
    Select-Object Name, Domain, PartOfDomain |
    Format-Table -AutoSize

Get-NetIPConfiguration -InterfaceAlias "Ethernet0" |
    Select-Object `
        InterfaceAlias,
        @{Name="IPv4Address";Expression={$_.IPv4Address.IPAddress}},
        @{Name="PrefixLength";Expression={$_.IPv4Address.PrefixLength}},
        @{Name="DefaultGateway";Expression={$_.IPv4DefaultGateway.NextHop}},
        @{Name="DNSServers";Expression={$_.DNSServer.ServerAddresses -join ", "}} |
    Format-List

Show-Section "INSTALLED SERVER ROLES"

Get-WindowsFeature `
    FS-FileServer,
    FS-Resource-Manager,
    Print-Server,
    Windows-Server-Backup |
    Select-Object DisplayName, InstallState |
    Format-Table -AutoSize

Show-Section "SERVER SERVICES"

Get-Service LanmanServer, Spooler |
    Select-Object Name, Status |
    Format-Table -AutoSize

Show-Section "SMB SHARES"

$ShareNames = @(
    "Budapest",
    "Debrecen_Logisztika",
    "Debrecen_Depo",
    'Software$'
)

Get-SmbShare |
    Where-Object { $_.Name -in $ShareNames } |
    Select-Object Name, Path, FolderEnumerationMode, CachingMode |
    Format-Table -AutoSize

Show-Section "SMB SHARE PERMISSIONS"

foreach ($ShareName in $ShareNames) {
    Write-Output ""
    Write-Output "Share: $ShareName"

    Get-SmbShareAccess -Name $ShareName |
        Select-Object AccountName, AccessControlType, AccessRight |
        Format-Table -AutoSize
}

Show-Section "SOFTWARE DEPLOYMENT PACKAGE"

Get-Item "E:\Software\Packages\7-Zip-x64.msi" |
    Select-Object Name, Length, LastWriteTime |
    Format-Table -AutoSize

Get-FileHash "E:\Software\Packages\7-Zip-x64.msi" -Algorithm SHA256 |
    Format-List Algorithm, Hash, Path

$PackageAvailable = Test-Path '\\RR-FS01\Software$\7-Zip-x64.msi'
Write-Output "Network package available: $PackageAvailable"

Show-Section "SHARED PRINTER"

Get-Printer -Name "RR-Office-Printer" |
    Format-List `
        Name,
        Shared,
        ShareName,
        Published,
        DriverName,
        PortName,
        Location,
        Comment

Show-Section "WINDOWS SERVER BACKUP"

wbadmin.exe get versions

Show-Section "VALIDATION COMPLETED"
