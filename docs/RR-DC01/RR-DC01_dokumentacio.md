# RR-DC01 tartományvezérlő – műszaki dokumentáció

**Készítette:** Szénás Szabolcs  
**Konfigurálás dátuma:** 2026. augusztus 30.  
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

## 5. Active Directory-struktúra

A tartományban létrejött a `RapidRoute` szervezeti egység, benne:

- `Users`;
- `Groups`;
- `Computers`;
- `Servers`.

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

A csoporttagságokat PowerShell-parancsokkal is ellenőriztük.

## 6. Group Policy

Létrejött a `GPO_RapidRoute_Client_Baseline` házirend, amely a `RapidRoute/Computers` OU-hoz kapcsolódik.

Beállításai:

- bejelentkezési üzenet címe: `RapidRoute Logistics`;
- bejelentkezési üzenet szövege: `Authorized RapidRoute users only.`;
- gépinaktivitási korlát: `900` másodperc.

A szoftvertelepítési GPO csak az RR-FS01 telepítőmegosztásának elkészülte után véglegesíthető és az RR-CLIENT01 gépen tesztelhető.

## 7. Elvégzett ellenőrzések

Az alábbi parancsok és ellenőrzések sikeresen lefutottak:

```powershell
hostname
Get-NetIPConfiguration
ping 192.168.186.2

Get-ADDomain | Select-Object DNSRoot,NetBIOSName,DomainMode
Get-ADForest | Select-Object RootDomain,ForestMode
Get-Service NTDS,DNS | Select-Object Name,Status
whoami

nslookup RR-DC01.rapidroute.local 192.168.186.10
nslookup 192.168.186.10 192.168.186.10
nslookup microsoft.com 192.168.186.10

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
- a `dcdiag` Connectivity, Advertising, SysVolCheck és Services tesztje sikeres;
- az ADWS, DNS, DFSR, KDC, Netlogon és NTDS szolgáltatások futnak.

## 8. Jelenlegi készültség és függőségek

Az RR-DC01 alapvető tartományvezérlő-, DNS- és kliens-alapházirend funkciói elkészültek. A végső rendszerpróba a következő gépek elkészülte után történik:

1. **RR-FS01:** tartományba léptetés, fájl- és nyomtatómegosztás, mentés és telepítőcsomagok;
2. **RR-WEB01:** DNS-rekord, HTTP- és HTTPS-elérés;
3. **RR-CLIENT01:** tartományi bejelentkezés, GPO, megosztások, programtelepítés és weboldal tesztelése.

## 9. Bizonyítékok

A képernyőképek részletes tartalomjegyzéke a [`KEPEK.md`](KEPEK.md) fájlban található.

