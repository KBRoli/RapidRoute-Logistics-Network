# RR-FS01 fájl-, nyomtató- és mentési szerver – műszaki dokumentáció

**Készítette:** Szénás Szabolcs  
**Konfigurálás dátuma:** 2026. augusztus 31. – szeptember 1.  
**Projekt:** RapidRoute Logistics Network

## 1. A szerver célja

Az RR-FS01 a RapidRoute VMware-labor központi fájl-, nyomtató- és mentési szervere. Feladata a budapesti és debreceni részlegek elkülönített hálózati mappáinak biztosítása, egy központi tesztnyomtató megosztása, a szerveradatok ütemezett mentése, valamint a tartományi szoftverterítéshez szükséges telepítőcsomag kiszolgálása.

## 2. Alapadatok

| Beállítás | Érték |
|---|---|
| Gépnév | `RR-FS01` |
| Operációs rendszer | Windows Server 2012 R2 Standard Evaluation |
| IPv4-cím | `192.168.186.20` |
| Maszk | `255.255.255.0` (`/24`) |
| Alapértelmezett átjáró | `192.168.186.2` |
| Elsődleges DNS | `192.168.186.10` (`RR-DC01`) |
| Tartomány | `rapidroute.local` |
| Active Directory-hely | `RapidRoute/Servers` OU |

Az RR-FS01 és az RR-DC01 a VMware-labor `192.168.186.0/24` hálózatában működik. Ez a Windows-kiszolgálói labor szándékosan elkülönül a Packet Tracerben modellezett hálózattól; a két környezet ugyanannak a RapidRoute projektnek két külön megvalósítási rétege.

### VMware-környezet és telepítés

| Virtuális hardver | Beállítás |
|---|---|
| VMware-verzió | Workstation 17.5.x |
| Vendég operációs rendszer | Windows Server 2012 |
| Processzor | 2 virtuális processzormag |
| Memória | 2 GB |
| Rendszerlemez | 60 GB, több fájlra bontva |
| Hálózati mód | NAT |

A Windows Server telepítése után a gépnevet `RR-FS01` értékre állítottuk, majd konfiguráltuk a statikus IPv4-beállításokat. Az átjáró, az RR-DC01 és a belső DNS-névfeloldás sikeres ellenőrzése után a kiszolgáló csatlakozott a `rapidroute.local` tartományhoz. A biztonságos tartományi csatorna tesztje `True` eredményt adott, az RR-FS01 számítógépobjektuma pedig a `RapidRoute/Servers` OU-ba került.

## 3. Telepített szerepkörök és szolgáltatások

A szerveren a következő összetevők készültek el:

- File Server;
- File Server Resource Manager;
- Print Server;
- Windows Server Backup.

A fájlmegosztások működéséhez szükséges `LanmanServer`, valamint a nyomtatási feladatokhoz szükséges `Spooler` szolgáltatás fut.

## 4. Lemezek és mappastruktúra

| Kötet | Méret | Funkció |
|---|---:|---|
| `C:` | 60 GB | Operációs rendszer |
| `E:` (`RR-DATA`) | 20 GB | Megosztott adatok és szoftvercsomagok |
| `F:` (`RR-BACKUP`) | 15 GB | Dedikált Windows Server Backup cél |

Az adatlemezen létrehozott fő mappák:

```text
E:\Shares\Budapest
E:\Shares\Debrecen_Logisztika
E:\Shares\Debrecen_Depo
E:\Software\Packages
```

A mentési cél külön virtuális lemez, ezért a biztonsági másolat nem ugyanazon a köteten található, mint a mentett adatok.

## 5. SMB-megosztások és jogosultságok

| Megosztás | Helyi elérési út | Célcsoport | Csoportjog | Adminisztráció |
|---|---|---|---|---|
| `Budapest` | `E:\Shares\Budapest` | `GG_Budapest_Users` | módosítás | Domain Admins: teljes hozzáférés |
| `Debrecen_Logisztika` | `E:\Shares\Debrecen_Logisztika` | `GG_Debrecen_Logisztika_Users` | módosítás | Domain Admins: teljes hozzáférés |
| `Debrecen_Depo` | `E:\Shares\Debrecen_Depo` | `GG_Debrecen_Depo_Users` | módosítás | Domain Admins: teljes hozzáférés |
| `Software$` | `E:\Software\Packages` | Domain Computers | olvasás | Domain Admins: teljes hozzáférés |

A három részlegi megosztáson az Access-Based Enumeration engedélyezett, az offline gyorsítótárazás pedig ki van kapcsolva. A rejtett `Software$` megosztás csak a központilag terített telepítőcsomagok olvasására szolgál.

## 6. Központi nyomtató

A laborban egy fizikai eszközt nem igénylő tesztnyomtató készült:

| Beállítás | Érték |
|---|---|
| Nyomtatónév | `RR-Office-Printer` |
| Megosztási név | `RR-Office-Printer` |
| Illesztőprogram | `Generic / Text Only` |
| Port | `LPT1:` |
| Hely | `RapidRoute Logistics` |
| Megjegyzés | `Kozponti tesztnyomtato` |
| Megosztva | igen |
| Közzétéve az Active Directoryban | igen |

A nyomtató hálózati elérési útja: `\\RR-FS01\RR-Office-Printer`.

## 7. Windows Server Backup

A Windows Server Backup napi ütemezése `20:00`. A mentés dedikált, körülbelül 15 GB-os mentési lemezre készül.

Az ellenőrzés során:

- kézi mentés sikeresen lefutott;
- a mentési példány megjelent a `wbadmin get versions` kimenetében;
- a tesztfájlt az adatlemezről töröltük;
- a fájlt a mentésből sikeresen visszaállítottuk;
- az eredeti tartalom olvasható maradt.

A végső validáció két visszaállítható mentési verziót jelzett: `2026-08-31 16:53` és `2026-09-01 08:44`.

## 8. 7-Zip telepítőcsomag és GPO

A 7-Zip 26.02 x64 MSI-csomag a következő helyen található:

```text
E:\Software\Packages\7-Zip-x64.msi
\\RR-FS01\Software$\7-Zip-x64.msi
```

A csomag elérhetőségét helyben és az RR-DC01-ről UNC-útvonalon is ellenőriztük. A validációs script SHA-256 ellenőrzőösszeget is készít róla.

Az RR-DC01-en létrejött a `GPO_RapidRoute_7Zip_Deployment` házirend, amely a `RapidRoute/Computers` OU-hoz kapcsolódik.

Fő beállításai:

- Computer Configuration alapú szoftvertelepítés;
- csomagforrás: `\\RR-FS01\Software$\7-Zip-x64.msi`;
- telepítési mód: Assigned;
- a csomag eltávolítása, ha a számítógép kikerül a házirend hatóköréből;
- nyelv figyelmen kívül hagyása telepítéskor;
- az „Always wait for the network at computer startup and logon” beállítás engedélyezve.

## 9. Validációs script

A csak olvasási és ellenőrzési feladatokat végző PowerShell-script a repository következő útvonalán található:

```text
scripts/RR-FS01/rr-fs01-validation.ps1
```

A script ellenőrzi:

- a gépnevet, tartománytagságot és hálózati beállításokat;
- a telepített szerver-szerepköröket és fontos szolgáltatásokat;
- az SMB-megosztásokat és megosztási jogosultságokat;
- a 7-Zip MSI jelenlétét, hashét és hálózati elérhetőségét;
- a megosztott nyomtató beállításait;
- a Windows Server Backup visszaállítási verzióit.

Futtatás RR-FS01-en, emelt jogosultságú PowerShellből:

```powershell
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\RapidRoute\Scripts\rr-fs01-validation.ps1" |
    Out-File "C:\RapidRoute\Scripts\rr-fs01-validation-output.txt" -Encoding UTF8
```

## 10. Elvégzett végső ellenőrzések

A szerveroldali ellenőrzések eredménye:

- az RR-FS01 a `rapidroute.local` tartomány tagja;
- a fájl-, FSRM-, nyomtató- és mentési szerepkör telepítve van;
- a `LanmanServer` és `Spooler` szolgáltatás fut;
- mind a négy tervezett SMB-megosztás elérhető;
- a 7-Zip MSI elérhető a `Software$` megosztáson;
- az `RR-Office-Printer` megosztott és közzétett;
- a mentési verziók lekérdezhetők, a fájlvisszaállítás sikeres volt;
- a 7-Zip telepítési GPO létrejött és a Computers OU-hoz kapcsolódik.

## 11. Jelenlegi készültség és hátralévő klienspróbák

Az **RR-FS01 szerveroldali konfigurációja elkészült**. A teljes rendszer végponttól végpontig történő lezárásához az RR-CLIENT01 elkészülte után még az alábbi kliensoldali próbák szükségesek:

1. a három tesztfelhasználó csak a saját részlegi megosztását érje el;
2. fájl létrehozása és módosítása a megfelelő megosztáson;
3. illetéktelen részlegi megosztás hozzáférésének megtagadása;
4. az `RR-Office-Printer` csatlakoztatása és tesztoldal küldése;
5. a 7-Zip automatikus telepítésének ellenőrzése újraindítás és `gpupdate /force` után;
6. a GPO eredményének dokumentálása `gpresult` vagy Group Policy Results segítségével.

## 12. Bizonyítékok

A dokumentációhoz **53 eredeti képernyőkép** tartozik. Ezek nemcsak a végállapotot, hanem az RR-FS01 teljes elkészítési folyamatát is bizonyítják.

| Képtartomány | Dokumentált munkafázis |
|---|---|
| 01–08 | Virtuális gép, Windows, hálózat, tartomány és szerepkörök |
| 09–17 | Adat- és mentési lemezek, mappák, SMB-megosztások és jogosultságok |
| 18–32 | Automatikus mentés, kézi mentés és sikeres fájlvisszaállítás |
| 33–38 | Központi tesztnyomtató telepítése és megosztása |
| 39–48 | 7-Zip MSI, hálózati csomagforrás és telepítési GPO |
| 49–53 | Végső szerepkör-, megosztás-, nyomtató-, script- és backup-validáció |

A képek teljes, fájlonkénti tartalomjegyzéke a [`KEPEK.md`](KEPEK.md) fájlban található.
