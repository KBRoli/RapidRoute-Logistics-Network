# RR-CLIENT01 műszaki dokumentáció

**Készítette:** Szénás Szabolcs  
**Konfigurálás dátuma:** 2026. szeptember 2–5.  
**Dokumentáció frissítve:** 2026. szeptember 5.
**Projekt:** RapidRoute Logistics Network

## 1. A kliens célja

Az RR-CLIENT01 a RapidRoute VMware-labor Windows 10 kliensgépe. Feladata a tartományi bejelentkezés, a Group Policy-beállítások, a szoftverterítés, az RR-FS01 fájl- és nyomtatási szolgáltatásai, valamint az RR-WEB01 HTTP/HTTPS-szolgáltatásának végponttól végpontig történő ellenőrzése.

## 2. Virtuális gép és operációs rendszer

| Beállítás | Érték |
|---|---|
| Hypervisor | VMware Workstation 17 Player |
| Virtuális gép neve | `RR-CLIENT01` |
| Operációs rendszer | Windows 10 Pro x64 |
| WindowsVersion | `2009` |
| Virtuális processzor | 2 mag |
| Memória | 3 GB |
| Virtuális lemez | 60 GB |
| Hálózati mód | NAT |
| Helyi rendszergazdai fiók | `rrlocaladmin` |

A VM létrehozási varázsló képe még a kezdeti 2 GB memóriát mutatja. A végleges kliens a tesztek előtt 3 GB memóriát kapott.

## 3. Gépnév és hálózat

| Beállítás | Érték |
|---|---|
| Gépnév | `RR-CLIENT01` |
| Interfész | `Ethernet0` |
| IPv4-cím | `192.168.186.40/24` |
| Alapértelmezett átjáró | `192.168.186.2` |
| DNS-kiszolgáló | `192.168.186.10` (`RR-DC01`) |

Az RR-DC01, RR-FS01 és RR-WEB01 hálózati elérése sikeres. A kliens a tartományi DNS használatával oldja fel a belső neveket.

## 4. Tartománytagság

Az RR-CLIENT01 csatlakozott a `rapidroute.local` tartományhoz. A számítógépobjektum helye:

```text
CN=RR-CLIENT01,OU=Computers,OU=RapidRoute,DC=rapidroute,DC=local
```

A `Test-ComputerSecureChannel -Verbose` eredménye `True`, ezért a kliens és a tartomány közötti biztonságos csatorna megfelelő.

## 5. Tartományi felhasználó

A kliensoldali vizsgálatot a következő felhasználóval végeztük:

| Tulajdonság | Érték |
|---|---|
| Megjelenített név | Teszt Budapest |
| Bejelentkezési név | `RAPIDROUTE\teszt.budapest` |
| Biztonsági csoport | `RAPIDROUTE\GG_Budapest_Users` |
| Fiók állapota | Engedélyezve, nincs zárolva |

A fiókhoz a tartomány jelszóházirendjének megfelelő jelszó került beállításra. A dokumentáció és a képernyőképek nem tartalmazzák a jelszót.

## 6. Group Policy

Az RR-CLIENT01 számítógépre az alábbi házirendek alkalmazódtak:

- `GPO_RapidRoute_Client_Baseline`;
- `GPO_RapidRoute_7Zip_Deployment`.

A kliens-alapházirend ellenőrzött beállításai:

| Beállítás | Eredmény |
|---|---|
| Jogi üzenet címe | `RapidRoute Logistics` |
| Jogi üzenet szövege | `Authorized RapidRoute users only.` |
| Gépinaktivitási korlát | `900` másodperc |

A szoftverterítési GPO a következő hálózati MSI-csomagot telepítette:

```text
\\RR-FS01\Software$\7-Zip-x64.msi
```

A kliensen a 7-Zip 26.02 x64 telepítése és a `C:\Program Files\7-Zip\7zFM.exe` fájl megléte egyaránt ellenőrzött.

## 7. Fájlmegosztási jogosultságok

A `teszt.budapest` felhasználóval végzett tesztek igazolták a csoportalapú hozzáférést:

| Útvonal | Elvárt eredmény | Tényleges eredmény |
|---|---|---|
| `\\RR-FS01\Budapest` | Hozzáférés és fájl létrehozása | Sikeres |
| `\\RR-FS01\Debrecen_Logisztika` | Hozzáférés megtagadva | Sikeres tiltás |
| `\\RR-FS01\Debrecen_Depo` | Hozzáférés megtagadva | Sikeres tiltás |

A létrehozott bizonyító tesztfájl:

```text
\\RR-FS01\Budapest\RR-CLIENT01_teszt.txt
```

## 8. Megosztott nyomtató

A klienshez sikeresen csatlakozott a következő megosztott nyomtató:

| Tulajdonság | Érték |
|---|---|
| Kapcsolat | `\\RR-FS01\RR-Office-Printer` |
| Illesztőprogram | Generic / Text Only |
| Állapot | Normal |
| Kiszolgálói port | LPT1: |

## 9. RR-WEB01 és HTTPS

A tartományi DNS a következő eredményeket adja:

| Név | Rekord | Eredmény |
|---|---|---|
| `RR-WEB01.rapidroute.local` | A | `192.168.186.30` |
| `www.rapidroute.local` | CNAME + A | `RR-WEB01.rapidroute.local`, `192.168.186.30` |

A `http://www.rapidroute.local` és `https://www.rapidroute.local` cím egyaránt `200` státuszkódot ad.

Az RR-WEB01 saját aláírású nyilvános tanúsítványa a kliens `Cert:\LocalMachine\Root` megbízható gyökértárolójába került. A HTTPS-vizsgálat tanúsítvány-ellenőrzés megkerülése nélkül sikerült.

| Tanúsítványadat | Érték |
|---|---|
| Subject / Issuer | `CN=www.rapidroute.local, OU=IT, O=RapidRoute Logistics, C=HU` |
| Érvényesség vége | 2028. december 4. |
| Ujjlenyomat | `A633E7F5B90D3AA6E57AA6B8DEEAA915C52E343A8` |

Csak a nyilvános `/etc/ssl/certs/rapidroute.crt` fájl került át a kliensre. A `/etc/ssl/private/rapidroute.key` privát kulcs nem hagyta el a webszervert. A letöltéshez létrehozott ideiglenes webes tanúsítványmásolatot az importálás után eltávolítottuk.

> [!NOTE]
> A saját aláírású tanúsítvány közvetlen megbízhatóvá tétele az elszigetelt vizsgalaborhoz megfelelő. Éles környezetben belső hitelesítésszolgáltató és központi, Group Policy-alapú tanúsítványterítés javasolt.

## 10. Végső validáció

A megismételhető, csak olvasási műveleteket végző ellenőrző script:

[`rr-client01-validation.ps1`](../../scripts/RR-CLIENT01/rr-client01-validation.ps1)

A script nem módosítja a kliens vagy a szerverek konfigurációját. A `RAPIDROUTE\teszt.budapest` felhasználóval futtatva ellenőrzi:

- a gépnevet, az operációs rendszert és a hálózati beállításokat;
- a három szerver elérését;
- a tartománytagságot, a biztonságos csatornát és a csoporttagságot;
- a GPO-beállítások eredményét és a 7-Zip telepítését;
- a fájlmegosztási engedélyeket és tiltásokat;
- a megosztott nyomtatót;
- a DNS-, HTTP-, HTTPS- és tanúsítvány-megbízhatóságot.

Végső eredmény:

```text
Sikeres ellenorzesek: 25
Sikertelen ellenorzesek: 0
OVERALL RESULT: PASS
```

## 11. Jelenlegi készültség

Az RR-CLIENT01 elkészült, és a RapidRoute VMware-környezet végponttól végpontig tartó ellenőrzése sikeresen lezárult.

## 12. Bizonyítékok

A telepítés és az ellenőrzések válogatott képeinek tartalomjegyzéke a [`KEPEK.md`](KEPEK.md) fájlban található.
