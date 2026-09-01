# RR-DC01 tartományvezérlő – műszaki dokumentáció

**Készítette:** Szénás Szabolcs  
**Konfigurálás dátuma:** 2026. augusztus 30.  
**Dokumentáció frissítve:** 2026. szeptember 1.  
**Projekt:** RapidRoute Logistics Network

## 1. A szerver célja

Az RR-DC01 a RapidRoute VMware-labor központi Windows tartományvezérlője. Feladata a `rapidroute.local` tartomány, a felhasználók és csoportok, a belső DNS-névfeloldás, valamint a kliensgépekre vonatkozó Group Policy-beállítások kezelése.

## 2. Alapadatok

| Beállítás | Érték |
|---|---|
| Gépnév | `RR-DC01` |
| Operációs rendszer | Windows Server 2012 R2 Standard Evaluation |
| IPv4-cím | `192.168.186.10` |
| Maszk | `255.255.255.0` (`/24`) |
| Alapértelmezett átjáró | `192.168.186.2` |
| Elsődleges DNS | `192.168.186.10` |
| Tartomány | `rapidroute.local` |
| NetBIOS-név | `RAPIDROUTE` |
| Tartomány- és erdőszint | Windows Server 2012 R2 |

## 3. Telepített szerepkörök

- Active Directory Domain Services (AD DS);
- DNS Server;
- Group Policy Management;
- a szükséges felügyeleti eszközök és PowerShell-modulok.

A szervert a szerepkörök telepítése után új erdő első tartományvezérlőjévé léptettük elő. Az erdő és a gyökértartomány neve `rapidroute.local`.

## 4. DNS-konfiguráció

- az AD-integrált `rapidroute.local` előretekintési zóna létrejött;
- a szerver saját DNS-címe `192.168.186.10`;
- DNS-továbbító: `192.168.186.2`;
- visszakeresési zóna: `186.168.192.in-addr.arpa`;
- PTR-rekord: `192.168.186.10` → `RR-DC01.rapidroute.local`;
- a név szerinti, cím szerinti és külső névfeloldás is sikeresen lefutott.

Az RR-FS01 kiszolgáló a `192.168.186.20` statikus címet és az RR-DC01 `192.168.186.10` DNS-címét használja. Az RR-FS01 az RR-DC01-et, a tartományt és a belső DNS-neveket sikeresen eléri.

## 5. Active Directory-struktúra

A tartományban létrejött a `RapidRoute` szervezeti egység, benne:

- `Users`;
- `Groups`;
- `Computers`;
- `Servers`.

Az RR-FS01 számítógépobjektuma a `RapidRoute/Servers` OU-ban található. Tartománytagsága és biztonságos tartományi csatornája ellenőrzött.

### Biztonsági csoportok

- `GG_Budapest_Users`;
- `GG_Debrecen_Logisztika_Users`;
- `GG_Debrecen_Depo_Users`.

### Tesztfelhasználók

| Megjelenített név | Bejelentkezési név | Csoport |
|---|---|---|
| Teszt Budapest | `teszt.budapest` | `GG_Budapest_Users` |
| Teszt Logisztika | `teszt.logisztika` | `GG_Debrecen_Logisztika_Users` |
| Teszt Depo | `teszt.depo` | `GG_Debrecen_Depo_Users` |

A csoporttagságokat PowerShell-parancsokkal is ellenőriztük. Ezek a csoportok határozzák meg az RR-FS01 részlegi SMB-megosztásainak hozzáféréseit.

## 6. Group Policy

### Kliens-alapházirend

Létrejött a `GPO_RapidRoute_Client_Baseline` házirend, amely a `RapidRoute/Computers` OU-hoz kapcsolódik.

Beállításai:

- bejelentkezési üzenet címe: `RapidRoute Logistics`;
- bejelentkezési üzenet szövege: `Authorized RapidRoute users only.`;
- gépinaktivitási korlát: `900` másodperc.

### 7-Zip szoftverterítési házirend

Az RR-FS01 telepítőmegosztásának elkészülte után létrejött és véglegesítésre került a `GPO_RapidRoute_7Zip_Deployment` házirend. Ez szintén a `RapidRoute/Computers` OU-hoz kapcsolódik.

| Beállítás | Érték |
|---|---|
| Csomag | 7-Zip 26.02 x64 MSI |
| Hálózati forrás | `\\RR-FS01\Software$\7-Zip-x64.msi` |
| Telepítés típusa | Assigned, Computer Configuration |
| Hatókörből kikerülés | Az alkalmazás eltávolítása engedélyezve |
| Nyelvi beállítás | A csomag nyelvének figyelmen kívül hagyása engedélyezve |
| Indítási feldolgozás | Always wait for the network at computer startup and logon: Enabled |

Az RR-DC01-ről az RR-FS01 név szerint elérhető, és a telepítő UNC-útvonalára futtatott `Test-Path` eredménye `True`. A GPO kliensoldali telepítési próbája az RR-CLIENT01 elkészülte után történik.

## 7. Elvégzett ellenőrzések

Az alábbi parancsok és ellenőrzések sikeresen lefutottak:

```powershell
hostname
Get-NetIPConfiguration
ping 192.168.186.2

Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode
Get-ADForest | Select-Object RootDomain,ForestMode
Get-ADComputer RR-FS01 -Properties Enabled,DistinguishedName
Get-Service NTDS,DNS | Select-Object Name,Status
whoami

nslookup RR-DC01.rapidroute.local 192.168.186.10
nslookup 192.168.186.10 192.168.186.10
nslookup microsoft.com 192.168.186.10

Test-Connection RR-FS01 -Count 4
Test-Path '\\RR-FS01\Software$\7-Zip-x64.msi'

Get-GPO -Name "GPO_RapidRoute_Client_Baseline"
Get-GPO -Name "GPO_RapidRoute_7Zip_Deployment"
Get-GPInheritance -Target "OU=Computers,OU=RapidRoute,DC=rapidroute,DC=local"

dcdiag
Get-Service ADWS,DNS,DFSR,KDC,Netlogon,NTDS |
    Select-Object Name,Status
```

Eredmények:

- az átjáró 0% csomagvesztéssel elérhető;
- az AD-tartomány és az erdő neve helyes;
- az AD DS- és DNS-szolgáltatások futnak;
- a DNS előre- és visszakeresése működik;
- külső névfeloldás működik;
- az RR-FS01 számítógépobjektuma a Servers OU-ban található;
- az RR-FS01 hálózaton elérhető;
- a 7-Zip MSI UNC-útvonala az RR-DC01-ről elérhető;
- mindkét RapidRoute GPO létezik és a Computers OU-hoz kapcsolódik;
- a `dcdiag` Connectivity, Advertising, SysVolCheck és Services tesztje sikeres;
- az ADWS, DNS, DFSR, KDC, Netlogon és NTDS szolgáltatások futnak.

## 8. Jelenlegi készültség és függőségek

Az RR-DC01 tartományvezérlő-, DNS-, Active Directory- és Group Policy-funkciói elkészültek. Az RR-FS01 szerveroldali konfigurációja szintén elkészült, beleértve:

- a tartománytagságot;
- a részlegi fájlmegosztásokat és jogosultságokat;
- a rejtett szoftvermegosztást;
- a megosztott tesztnyomtatót;
- a napi biztonsági mentést és sikeres fájlvisszaállítást;
- a 7-Zip telepítőcsomagot és annak terítési GPO-ját.

A teljes rendszer végponttól végpontig történő lezárásához még a következő feladatok szükségesek:

1. **RR-WEB01:** DNS-rekord, HTTP- és HTTPS-elérés kialakítása és tesztelése;
2. **RR-CLIENT01:** tartományi bejelentkezés, kliens-alapházirend, részlegi megosztások, nyomtatókapcsolat, automatikus 7-Zip-telepítés és weboldal-elérés ellenőrzése.

## 9. Bizonyítékok

Az RR-DC01 eredeti telepítési és ellenőrzési képeinek tartalomjegyzéke a [`KEPEK.md`](KEPEK.md) fájlban található.

Az RR-FS01 tartományba léptetését, az RR-DC01-ről végzett MSI-elérési tesztet, valamint a 7-Zip Group Policy teljes beállítását az [`RR-FS01 képkatalógusa`](../RR-FS01/KEPEK.md) dokumentálja. Az RR-FS01 részletes műszaki leírása az [`RR-FS01_dokumentacio.md`](../RR-FS01/RR-FS01_dokumentacio.md) fájlban található.
