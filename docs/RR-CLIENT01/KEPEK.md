# RR-CLIENT01 képernyőképek

**Projekt:** RapidRoute Logistics Network  
**Dokumentáció frissítve:** 2026. szeptember 5.

Az alábbi válogatott képernyőképek az RR-CLIENT01 létrehozását, tartományba léptetését, Group Policy-beállításait és a teljes végponttól végpontig tartó ellenőrzést dokumentálják.

| # | Képernyőkép | Tartalom |
|---:|---|---|
| 01 | [Windows ISO kiválasztása](screenshots/01_RR-CLIENT01_Windows_ISO_kivalasztasa.png) | A Windows 10 x64 telepítőkép kiválasztása a VMware varázslóban. |
| 02 | [Virtuális gép neve és helye](screenshots/02_RR-CLIENT01_VM_nev_es_hely.png) | Az `RR-CLIENT01` név és az `E:\Virtual Machines\RR-CLIENT01` tárolási hely. |
| 03 | [VM létrehozási összefoglaló](screenshots/03_RR-CLIENT01_VM_letrehozasi_osszefoglalo.png) | A 60 GB-os lemez, NAT-hálózat és két processzormag; a kezdeti 2 GB memória a végső tesztek előtt 3 GB-ra nőtt. |
| 04 | [Windows 10 Pro telepítve](screenshots/04_RR-CLIENT01_Windows_10_Pro_telepites_kesz.png) | A sikeresen telepített Windows 10 asztala. |
| 05 | [Gépnév és Windows-verzió](screenshots/05_RR-CLIENT01_gepnev_es_Windows_verzio.png) | `RR-CLIENT01`, Windows 10 Pro, 64 bites architektúra. |
| 06 | [IPv4 és átjáró](screenshots/06_RR-CLIENT01_IP_es_atjaro_ellenorzes.png) | Statikus `192.168.186.40/24`, `192.168.186.2` átjáró és `192.168.186.10` DNS. |
| 07 | [RR-DC01 és tartományi DNS](screenshots/07_RR-CLIENT01_DC_es_DNS_kapcsolat.png) | Az RR-DC01 és a `rapidroute.local` tartomány DNS-feloldásának ellenőrzése. |
| 08 | [GPO bejelentkezési üzenet](screenshots/08_RR-CLIENT01_GPO_bejelentkezesi_uzenet.png) | A `RapidRoute Logistics` jogi bejelentkezési figyelmeztetés. |
| 09 | [Tartománytagság](screenshots/09_RR-CLIENT01_tartomanyi_tagsag_ellenorzes.png) | `rapidroute.local` tagság és megfelelő biztonságos tartományi csatorna. |
| 10 | [AD Computers OU](screenshots/10_RR-CLIENT01_AD_Computers_OU.png) | Az RR-CLIENT01 engedélyezett számítógépobjektuma a `RapidRoute/Computers` OU-ban. |
| 11 | [Tartományi bejelentkezés](screenshots/11_RR-CLIENT01_tartomanyi_bejelentkezes_es_csoporttagsag.png) | A `RAPIDROUTE\teszt.budapest` bejelentkezés és a `GG_Budapest_Users` csoporttagság. |
| 12 | [7-Zip GPO-telepítés](screenshots/12_RR-CLIENT01_7Zip_GPO_telepites_ellenorzes.png) | A GPO-val telepített 7-Zip 26.02 x64 és a programfájl megléte. |
| 13 | [Alkalmazott GPO-k](screenshots/13_RR-CLIENT01_GPO_k_es_inaktivitas_ellenorzes.png) | A kliens-alapházirend, a 7-Zip-terítés, a jogi üzenet és a 900 másodperces zárolás. |
| 14 | [Megosztási jogosultságok](screenshots/14_RR-CLIENT01_megosztasi_jogosultsagok_ellenorzes.png) | Írás a Budapest megosztásba, valamint elvárt hozzáférés-megtagadás a két debreceni megosztáson. |
| 15 | [Hálózati nyomtató](screenshots/15_RR-CLIENT01_halozati_nyomtato_ellenorzes.png) | A `\\RR-FS01\RR-Office-Printer` sikeres csatlakoztatása és normál állapota. |
| 16 | [Webes DNS és HTTP](screenshots/16_RR-CLIENT01_WEB_DNS_es_HTTP_ellenorzes.png) | Az RR-WEB01 és a `www` név feloldása, valamint HTTP `200` válasz. |
| 17 | [HTTPS-megbízhatóság](screenshots/17_RR-CLIENT01_HTTPS_tanusitvany_megbizhatosag.png) | A megbízható gyökértárolóban lévő RapidRoute-tanúsítvány és HTTPS `200` válasz megkerülés nélkül. |
| 18 | [Végső validáció – rendszer](screenshots/18_RR-CLIENT01_validation_rendszer_tartomany_GPO.png) | A rendszer-, hálózati, tartományi, GPO-, fájl- és nyomtatási ellenőrzések sikeres eredményei. |
| 19 | [Végső validáció – összesítő](screenshots/19_RR-CLIENT01_validation_szolgaltatasok_es_vegso_eredmeny.png) | A DNS-, HTTP-, HTTPS- és tanúsítványtesztek, végül **25 sikeres, 0 sikertelen ellenőrzés**. |

Részletes leírás: [`RR-CLIENT01_dokumentacio.md`](RR-CLIENT01_dokumentacio.md).
