# RR-WEB01 képkatalógus

**Projekt:** RapidRoute Logistics Network  
**Dokumentáció frissítve:** 2026. szeptember 2.

Az alábbi válogatott képernyőképek az RR-WEB01 létrehozását, Ubuntu Server telepítését, hálózati és webkiszolgáló-konfigurációját, valamint a végső ellenőrzéseket dokumentálják.

| # | Képernyőkép | Tartalom |
|---:|---|---|
| 1 | [VM létrehozása](screenshots/01_RR-WEB01_VM_letrehozas.png) | Az RR-WEB01 virtuális gép létrehozása VMware Workstationben. |
| 2 | [Ubuntu telepítő indítása](screenshots/02_RR-WEB01_Ubuntu_telepito_inditasa.png) | Az Ubuntu Server telepítő rendszerindító képernyője. |
| 3 | [Telepítési nyelv](screenshots/03_RR-WEB01_telepitesi_nyelv.png) | Az angol telepítési nyelv kiválasztása. |
| 4 | [Billentyűzet](screenshots/04_RR-WEB01_billentyuzet_beallitasa.png) | Magyar billentyűzetkiosztás beállítása. |
| 5 | [Server telepítési mód](screenshots/05_RR-WEB01_Ubuntu_Server_telepitesi_mod.png) | A teljes Ubuntu Server telepítési mód kiválasztása. |
| 6 | [DHCP felismerés](screenshots/06_RR-WEB01_DHCP_halozati_felismeres.png) | Az `ens33` interfész kezdeti DHCP-konfigurációja. |
| 7 | [Statikus IP](screenshots/07_RR-WEB01_statikus_IP_beallitva.png) | A `192.168.186.30/24` statikus cím beállítása. |
| 8 | [Ubuntu csomagtükör](screenshots/08_RR-WEB01_Ubuntu_tukor_es_internet_eleres.png) | A magyar Ubuntu tükör sikeres elérési tesztje. |
| 9 | [LVM beállítás](screenshots/09_RR-WEB01_LVM_lemezbeallitas.png) | Teljes lemezes, LVM-alapú irányított kiosztás. |
| 10 | [Partíciós összefoglaló](screenshots/10_RR-WEB01_particios_osszefoglalo.png) | A kibővített gyökérkötet és a `/boot` végleges mérete. |
| 11 | [Ubuntu Pro kihagyása](screenshots/11_RR-WEB01_Ubuntu_Pro_kihagyasa.png) | Az Ubuntu Pro csatlakoztatásának kihagyása. |
| 12 | [Snap-csomagok kihagyása](screenshots/12_RR-WEB01_snap_csomagok_kihagyasa.png) | Kiemelt szerveres Snap-csomagok telepítésének kihagyása. |
| 13 | [Telepítés kész](screenshots/13_RR-WEB01_Ubuntu_telepites_kesz.png) | Az Ubuntu 24.04.3 LTS első bejelentkezési képernyője. |
| 14 | [Első bejelentkezés](screenshots/14_RR-WEB01_elso_bejelentkezes_es_IP.png) | Bejelentkezés, gépnév és a `192.168.186.30` cím megjelenése. |
| 15 | [Hálózat és DNS](screenshots/15_RR-WEB01_halozati_es_DNS_ellenorzes.png) | Útvonal, DNS, RR-DC01 és külső elérés ellenőrzése. |
| 16 | [Rendszerfrissítés](screenshots/16_RR-WEB01_rendszerfrissites_kesz.png) | A csomagfrissítés sikeres befejezése. |
| 17 | [Apache és VMware Tools](screenshots/17_RR-WEB01_Apache_es_VMware_Tools_telepites.png) | Apache2 és open-vm-tools telepítése, szolgáltatás- és HTTP-teszt. |
| 18 | [Apache alapoldal](screenshots/18_RR-WEB01_Apache_alapoldal.png) | Az Apache alapértelmezett oldala a kliens böngészőjében. |
| 19 | [RR-DC01 DNS-rekordok](screenshots/19_RR-DC01_RR-WEB01_DNS_rekordok.png) | Az RR-WEB01 A rekordja és a `www` CNAME az RR-DC01 DNS-ben. |
| 20 | [DNS és HTTP ellenőrzés](screenshots/20_RR-DC01_RR-WEB01_DNS_es_HTTP_ellenorzes.png) | DNS-feloldás, ping és HTTP 200 válasz az RR-DC01-ről. |
| 21 | [UFW tűzfal](screenshots/21_RR-WEB01_UFW_tuzfal_beallitas.png) | OpenSSH és Apache Full engedélyezése, aktív tűzfal. |
| 22 | [RapidRoute weboldal](screenshots/22_RR-WEB01_RapidRoute_sajat_weboldal.png) | Az egyedi RapidRoute Infrastructure Portal. |
| 23 | [HTTPS és tanúsítvány](screenshots/23_RR-WEB01_HTTPS_es_tanusitvany_ellenorzes.png) | Virtuális gépek, 80/443 portok, tanúsítvány és HTTPS 200 válasz. |
| 24 | [Végső validáció](screenshots/24_RR-WEB01_validation_vegso_eredmeny.png) | 25 sikeres, 0 sikertelen ellenőrzés. |

Részletes leírás: [`RR-WEB01_dokumentacio.md`](RR-WEB01_dokumentacio.md).
