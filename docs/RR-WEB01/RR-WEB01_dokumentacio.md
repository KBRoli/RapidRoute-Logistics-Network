# RR-WEB01 webszerver – műszaki dokumentáció

**Készítette:** Szénás Szabolcs  
**Konfigurálás dátuma:** 2026. szeptember 1.  
**Dokumentáció frissítve:** 2026. szeptember 5.  
**Projekt:** RapidRoute Logistics Network

## 1. A szerver célja

Az RR-WEB01 a RapidRoute VMware-labor belső Ubuntu webszervere. Feladata a vállalati infrastruktúra-portál HTTP- és HTTPS-kiszolgálása, valamint a Windows tartományi DNS-sel való együttműködés bemutatása.

## 2. Virtuális gép és operációs rendszer

| Beállítás | Érték |
|---|---|
| Virtuális gép neve | `RR-WEB01` |
| Hypervisor | VMware Workstation 17 Player |
| Operációs rendszer | Ubuntu Server 24.04.3 LTS, 64 bit |
| Processzor | 2 vCPU |
| Memória | 2 GB |
| Virtuális lemez | 20 GB |
| Hálózati mód | NAT |
| Linux-gépnév | `rr-web01` |
| Rendszergazdai felhasználó | `rradmin` |

Az Ubuntu Server szöveges telepítővel készült. A telepítő nyelve angol, a billentyűzetkiosztás magyar lett. Az Ubuntu Pro csatlakoztatását és a kiemelt Snap-csomagok telepítését kihagytuk.

## 3. Lemezkiosztás

A teljes 20 GB-os virtuális lemez LVM-alapú kiosztást használ.

| Csatolási pont | Fájlrendszer | Méret | Megjegyzés |
|---|---|---:|---|
| `/` | ext4 LVM logikai kötet | 18,222 GB | A rendelkezésre álló LVM-terület teljes méretére bővítve |
| `/boot` | ext4 partíció | 1,771 GB | Rendszerindító fájlok |
| BIOS boot terület | BIOS grub spacer | 1 MB | GRUB rendszerindítás |

## 4. Hálózati konfiguráció

| Beállítás | Érték |
|---|---|
| Interfész | `ens33` |
| IPv4-cím | `192.168.186.30/24` |
| Alapértelmezett átjáró | `192.168.186.2` |
| DNS-kiszolgáló | `192.168.186.10` (`RR-DC01`) |
| Keresési tartomány | `rapidroute.local` |
| FQDN | `rr-web01.rapidroute.local` |
| Webes név | `www.rapidroute.local` |

A statikus cím beállítása után az RR-DC01, a belső névfeloldás és az Ubuntu csomagtükör is elérhető volt.

## 5. Telepített csomagok és szolgáltatások

Az alábbi fő csomagok kerültek telepítésre:

- `openssh-server` – távoli parancssori felügyelet;
- `open-vm-tools` – VMware-integráció;
- `apache2` – HTTP- és HTTPS-webkiszolgáló;
- `curl` – webes ellenőrzések;
- `ufw` – állapottartó gazdagép-tűzfal.

Az `ssh`, az `apache2` és az `open-vm-tools` szolgáltatás engedélyezett és fut.

## 6. DNS-integráció az RR-DC01 kiszolgálón

Az RR-DC01 `rapidroute.local` zónájában a következő rekordok készültek:

| Név | Típus | Cél |
|---|---|---|
| `RR-WEB01` | A | `192.168.186.30` |
| `www` | CNAME | `RR-WEB01.rapidroute.local` |

Az RR-DC01-ről végzett `Resolve-DnsName` ellenőrzés mindkét nevet a megfelelő kiszolgálóhoz rendelte, a `Test-Connection RR-WEB01` pedig 0% csomagvesztést mutatott.

## 7. Apache HTTP-konfiguráció

A webhely dokumentumgyökere:

```text
/var/www/rapidroute
```

A saját kezdőlap:

```text
/var/www/rapidroute/index.html
```

A HTTP virtuális gép konfigurációja:

```text
/etc/apache2/sites-available/rapidroute.conf
```

A webhely `www.rapidroute.local` elsődleges névvel és `rr-web01.rapidroute.local` alternatív névvel működik. A könyvtárlistázás tiltott, az Apache hozzáférési és hibanaplója külön fájlba kerül.

A GitHubra szánt, biztonságosan megosztható példányok a [`configs/RR-WEB01`](../../configs/RR-WEB01/README.md) könyvtárban találhatók.

## 8. UFW tűzfal

Az UFW aktív, alapértelmezés szerint tiltja a bejövő kapcsolatokat és engedélyezi a kimenő forgalmat.

Engedélyezett bejövő profilok:

- `OpenSSH` – TCP/22;
- `Apache Full` – TCP/80 és TCP/443.

Az IPv4- és IPv6-szabályok egyaránt létrejöttek.

## 9. HTTPS és tanúsítvány

Az Apache SSL-modulja és a `rapidroute-ssl.conf` virtuális gép engedélyezett. A kiszolgáló a 443/TCP porton fogad kapcsolatokat.

| Tanúsítványadat | Érték |
|---|---|
| Típus | Saját aláírású, belső labor-tanúsítvány |
| Subject / Issuer | `C=HU, O=RapidRoute Logistics, OU=IT, CN=www.rapidroute.local` |
| SAN | `www.rapidroute.local`, `rr-web01.rapidroute.local`, `192.168.186.30` |
| Érvényesség kezdete | 2026. szeptember 1. |
| Érvényesség vége | 2028. december 4. |
| Nyilvános tanúsítvány helye | `/etc/ssl/certs/rapidroute.crt` |
| Privát kulcs helye | `/etc/ssl/private/rapidroute.key` |

> [!IMPORTANT]
> A `/etc/ssl/private/rapidroute.key` fájl titkos privát kulcs. A dokumentációs csomag és a GitHub-repozitórium szándékosan nem tartalmazza. A konfiguráció csak a szerveren lévő útvonalára hivatkozik.

A saját aláírású tanúsítvány titkosított kapcsolatot biztosít. A nyilvános tanúsítványt az RR-CLIENT01 `Cert:\LocalMachine\Root` megbízható gyökértárolójába telepítettük; a privát kulcs nem hagyta el a webszervert. A kliensoldali HTTPS-kérés tanúsítványellenőrzés megkerülése nélkül `200` státuszkódot adott.

## 10. Ellenőrzések és eredmények

Az alábbi fő ellenőrzések sikeresen lefutottak:

```bash
hostnamectl --static
ip -4 -br address show ens33
ip route
resolvectl dns ens33
ping -c 4 192.168.186.10
getent hosts rr-dc01.rapidroute.local

sudo systemctl is-active ssh apache2 open-vm-tools
sudo apache2ctl -S
sudo ss -tulpn | grep -E ':80|:443'
sudo ufw status verbose

curl -I http://www.rapidroute.local
curl -k -I https://www.rapidroute.local
openssl x509 -in /etc/ssl/certs/rapidroute.crt \
    -noout -subject -issuer -dates -ext subjectAltName
```

Eredmények:

- a statikus hálózat, az átjáró és az RR-DC01 elérhető;
- a belső és külső DNS-névfeloldás működik;
- az Apache konfigurációja szintaktikailag helyes;
- a HTTP virtuális gép a 80/TCP, a HTTPS virtuális gép a 443/TCP porton aktív;
- a HTTP- és HTTPS-kérés egyaránt `200 OK` választ ad;
- a tanúsítvány SAN-mezői és érvényessége megfelelő;
- a mentett végső ellenőrzés eredménye: **25 sikeres, 0 sikertelen vizsgálat**.

A megismételhető ellenőrző script: [`rr-web01-validation.sh`](../../scripts/RR-WEB01/rr-web01-validation.sh).

## 11. Jelenlegi készültség

Az RR-WEB01 szerveroldali konfigurációja elkészült:

- statikus hálózat és tartományi DNS-integráció;
- SSH- és VMware-eszközök;
- Apache HTTP/HTTPS virtuális gépek;
- RapidRoute egyedi kezdőlap;
- UFW-szabályok;
- saját aláírású TLS-tanúsítvány;
- DNS-, hálózati, szolgáltatás-, HTTP-, HTTPS- és TLS-ellenőrzések.

Az **RR-CLIENT01** elkészült. A kliensoldali vizsgálat igazolta a tartományi bejelentkezést, a GPO-k és a 7-Zip telepítését, az RR-FS01 megosztásait és nyomtatóját, valamint a RapidRoute weboldal megbízható HTTPS-elérését. A teljes kliensvalidáció eredménye: **25 sikeres, 0 sikertelen ellenőrzés**.

## 12. Bizonyítékok

A telepítés és az ellenőrzések válogatott képeinek tartalomjegyzéke a [`KEPEK.md`](KEPEK.md) fájlban található.

Az RR-DC01 DNS-bejegyzéseihez és integrációs ellenőrzéseihez kapcsolódó összefoglaló az [`RR-DC01 dokumentációjában`](../RR-DC01/RR-DC01_dokumentacio.md) szerepel.

A kliensoldali HTTP/HTTPS- és tanúsítvány-megbízhatósági ellenőrzéseket az [`RR-CLIENT01 dokumentációja`](../RR-CLIENT01/RR-CLIENT01_dokumentacio.md) és [`képkatalógusa`](../RR-CLIENT01/KEPEK.md) tartalmazza.
