# RR-FS01 képernyőképes bizonyítékok

Az alábbi **53 eredeti képernyőkép** az RR-FS01 teljes elkészítési folyamatát dokumentálja a virtuális gép létrehozásától a végső mentési és szolgáltatás-validációig.

## 1. Virtuális gép, Windows, hálózat és tartomány

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 01 | [`01_RR-FS01_VM_letrehozas.png`](screenshots/01_RR-FS01_VM_letrehozas.png) | Az RR-FS01 VMware-gép neve, 60 GB-os rendszerlemeze, 2 GB memóriája, 2 processzormagja és NAT-hálózata |
| 02 | [`02_RR-FS01_Windows_telepites_kesz.png`](screenshots/02_RR-FS01_Windows_telepites_kesz.png) | A Windows Server 2012 telepítése elkészült, a Server Manager elindult |
| 03 | [`03_RR-FS01_gepnev_ellenorzes.png`](screenshots/03_RR-FS01_gepnev_ellenorzes.png) | A beállított `RR-FS01` gépnév |
| 04 | [`04_RR-FS01_IP_ellenorzes.png`](screenshots/04_RR-FS01_IP_ellenorzes.png) | A `192.168.186.20` cím, a `192.168.186.2` átjáró, a `192.168.186.10` DNS és a sikeres átjáró-ping |
| 05 | [`05_RR-FS01_DC_DNS_kapcsolat.png`](screenshots/05_RR-FS01_DC_DNS_kapcsolat.png) | Az RR-DC01 elérhetősége, valamint a `rapidroute.local` és az RR-DC01 DNS-feloldása |
| 06 | [`06_RR-FS01_tartomanyi_tagsag_ellenorzes.png`](screenshots/06_RR-FS01_tartomanyi_tagsag_ellenorzes.png) | A `rapidroute.local` tartománytagság és a működő biztonságos tartományi csatorna |
| 07 | [`07_RR-FS01_AD_Servers_OU.png`](screenshots/07_RR-FS01_AD_Servers_OU.png) | Az RR-FS01 számítógépobjektuma a `RapidRoute/Servers` OU-ban |
| 08 | [`08_RR-FS01_szerepkorok_telepitve.png`](screenshots/08_RR-FS01_szerepkorok_telepitve.png) | A File Server, FSRM, Print Server és Windows Server Backup sikeres telepítése |

## 2. Lemezek, mappák és SMB-megosztások

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 09 | [`09_RR-FS01_DATA_virtualis_lemez.png`](screenshots/09_RR-FS01_DATA_virtualis_lemez.png) | A különálló, 20 GB-os `RR-FS01-DATA.vmdk` adatlemez |
| 10 | [`10_RR-FS01_BACKUP_virtualis_lemez.png`](screenshots/10_RR-FS01_BACKUP_virtualis_lemez.png) | A különálló, 15 GB-os `RR-FS01-BACKUP.vmdk` mentési lemez |
| 11 | [`11_RR-FS01_adat_es_mentes_kotetek.png`](screenshots/11_RR-FS01_adat_es_mentes_kotetek.png) | Az `E:` RR-DATA és az `F:` RR-BACKUP NTFS-kötet a Lemezkezelőben |
| 12 | [`12_RR-FS01_mappastruktura.png`](screenshots/12_RR-FS01_mappastruktura.png) | Az `E:\Shares` és `E:\Software\Packages` alatt létrehozott mappastruktúra |
| 13 | [`13_RR-FS01_Budapest_megosztas_es_jogosultsag.png`](screenshots/13_RR-FS01_Budapest_megosztas_es_jogosultsag.png) | A Budapest-megosztás, ABE, kikapcsolt gyorsítótár és a csoportalapú megosztási/NTFS-jogosultságok |
| 14 | [`14_RR-FS01_Logisztika_megosztas_es_jogosultsag.png`](screenshots/14_RR-FS01_Logisztika_megosztas_es_jogosultsag.png) | A Debrecen_Logisztika-megosztás és a megfelelő csoport jogosultságai |
| 15 | [`15_RR-FS01_Depo_megosztas_es_jogosultsag.png`](screenshots/15_RR-FS01_Depo_megosztas_es_jogosultsag.png) | A Debrecen_Depo-megosztás és a megfelelő csoport jogosultságai |
| 16 | [`16_RR-FS01_Software_megosztas_es_jogosultsag.png`](screenshots/16_RR-FS01_Software_megosztas_es_jogosultsag.png) | A rejtett `Software$` megosztás, a Domain Computers olvasási és a Domain Admins teljes joga |
| 17 | [`17_RR-FS01_megosztasok_vegso_ellenorzese.png`](screenshots/17_RR-FS01_megosztasok_vegso_ellenorzese.png) | Mind a négy megosztás beállításai és sikeres UNC-elérhetőségi tesztje |

## 3. Biztonsági mentés és fájlvisszaállítás

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 18 | [`18_RR-FS01_mentesi_tesztfajl.png`](screenshots/18_RR-FS01_mentesi_tesztfajl.png) | A mentés és visszaállítás ellenőrzéséhez létrehozott tesztfájl |
| 19 | [`19_RR-FS01_mentendo_adatlemez.png`](screenshots/19_RR-FS01_mentendo_adatlemez.png) | Az RR-DATA kötet kiválasztása a biztonsági mentés tartalmának |
| 20 | [`20_RR-FS01_automatikus_mentes_idopontja.png`](screenshots/20_RR-FS01_automatikus_mentes_idopontja.png) | A napi automatikus mentés `20:00` időpontja |
| 21 | [`21_RR-FS01_mentesi_cellemez_kivalasztasa.png`](screenshots/21_RR-FS01_mentesi_cellemez_kivalasztasa.png) | A különálló RR-BACKUP lemez kiválasztása mentési célként |
| 22 | [`22_RR-FS01_automatikus_mentes_osszefoglalo.png`](screenshots/22_RR-FS01_automatikus_mentes_osszefoglalo.png) | Az automatikus mentési ütemezés végleges összefoglalója |
| 23 | [`23_RR-FS01_automatikus_mentes_letrehozva.png`](screenshots/23_RR-FS01_automatikus_mentes_letrehozva.png) | A napi mentési ütemezés sikeres létrehozása |
| 24 | [`24_RR-FS01_elso_biztonsagi_mentes_sikeres.png`](screenshots/24_RR-FS01_elso_biztonsagi_mentes_sikeres.png) | Az első kézzel indított biztonsági mentés sikeres befejezése |
| 25 | [`25_RR-FS01_mentesi_allapot_es_utemezes.png`](screenshots/25_RR-FS01_mentesi_allapot_es_utemezes.png) | A Windows Server Backup állapota, céllemeze és napi ütemezése |
| 26 | [`26_RR-FS01_tesztfajl_torolve.png`](screenshots/26_RR-FS01_tesztfajl_torolve.png) | A tesztfájl törlése a helyreállítási próba előtt |
| 27 | [`27_RR-FS01_visszaallitasi_pont_kivalasztasa.png`](screenshots/27_RR-FS01_visszaallitasi_pont_kivalasztasa.png) | A visszaállításhoz használt mentési időpont kiválasztása |
| 28 | [`28_RR-FS01_visszaallitando_fajl_kivalasztva.png`](screenshots/28_RR-FS01_visszaallitando_fajl_kivalasztva.png) | A visszaállítandó tesztfájl kijelölése |
| 29 | [`29_RR-FS01_visszaallitasi_beallitasok.png`](screenshots/29_RR-FS01_visszaallitasi_beallitasok.png) | A fájlvisszaállítás helyének és viselkedésének beállítása |
| 30 | [`30_RR-FS01_fajlvisszaallitas_osszefoglalo.png`](screenshots/30_RR-FS01_fajlvisszaallitas_osszefoglalo.png) | A helyreállítás indítás előtti összefoglalója |
| 31 | [`31_RR-FS01_fajlvisszaallitas_sikeres.png`](screenshots/31_RR-FS01_fajlvisszaallitas_sikeres.png) | A fájl-visszaállítás sikeres befejezése |
| 32 | [`32_RR-FS01_visszaallitott_fajl_ellenorzese.png`](screenshots/32_RR-FS01_visszaallitott_fajl_ellenorzese.png) | A visszaállított tesztfájl és annak olvasható tartalma |

## 4. Központi tesztnyomtató

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 33 | [`33_RR-FS01_Print_Management.png`](screenshots/33_RR-FS01_Print_Management.png) | A Print Management konzol és az RR-FS01 nyomtatószerver kezelése |
| 34 | [`34_RR-FS01_tesztnyomtato_port.png`](screenshots/34_RR-FS01_tesztnyomtato_port.png) | Az `LPT1:` port kiválasztása a fizikai eszköz nélküli tesztnyomtatóhoz |
| 35 | [`35_RR-FS01_Generic_nyomtato_driver.png`](screenshots/35_RR-FS01_Generic_nyomtato_driver.png) | A `Generic / Text Only` illesztőprogram kiválasztása |
| 36 | [`36_RR-FS01_nyomtato_megosztasi_beallitasok.png`](screenshots/36_RR-FS01_nyomtato_megosztasi_beallitasok.png) | Az `RR-Office-Printer` név, megosztási név, hely és megjegyzés |
| 37 | [`37_RR-FS01_nyomtato_megosztas_ellenorzese.png`](screenshots/37_RR-FS01_nyomtato_megosztas_ellenorzese.png) | A megosztott és Active Directoryban közzétett nyomtató PowerShell-ellenőrzése |
| 38 | [`38_RR-FS01_halozati_megosztasok_es_nyomtato.png`](screenshots/38_RR-FS01_halozati_megosztasok_es_nyomtato.png) | Az RR-FS01 hálózati mappái és megosztott nyomtatója az Intézőben |

## 5. 7-Zip telepítőcsomag és Group Policy

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 39 | [`39_RR-FS01_7Zip_MSI_hash_es_halozati_eleres.png`](screenshots/39_RR-FS01_7Zip_MSI_hash_es_halozati_eleres.png) | A 7-Zip x64 MSI jelenléte, SHA-256 hash-e és a `Software$` UNC-útvonal elérhetősége |
| 40 | [`40_RR-DC01_FS01_MSI_halozati_eleres.png`](screenshots/40_RR-DC01_FS01_MSI_halozati_eleres.png) | Az RR-FS01 és az MSI-csomag elérhetősége az RR-DC01-ről |
| 41 | [`41_RR-DC01_7Zip_GPO_letrehozva_es_linkelve.png`](screenshots/41_RR-DC01_7Zip_GPO_letrehozva_es_linkelve.png) | A `GPO_RapidRoute_7Zip_Deployment` létrehozása és kapcsolása a Computers OU-hoz |
| 42 | [`42_RR-DC01_7Zip_GPO_Assigned.png`](screenshots/42_RR-DC01_7Zip_GPO_Assigned.png) | A számítógépes szoftvertelepítés Assigned módja |
| 43 | [`43_RR-DC01_7Zip_GPO_csomag_hozzarendelve.png`](screenshots/43_RR-DC01_7Zip_GPO_csomag_hozzarendelve.png) | A 7-Zip 26.02 x64 csomag és a `\\RR-FS01\Software$\7-Zip-x64.msi` forrás |
| 44 | [`44_RR-DC01_7Zip_GPO_eltavolitasi_beallitas.png`](screenshots/44_RR-DC01_7Zip_GPO_eltavolitasi_beallitas.png) | A csomag automatikus eltávolítása a házirend hatóköréből kikerülő gépekről |
| 45 | [`45_RR-DC01_7Zip_GPO_nyelvi_beallitas.png`](screenshots/45_RR-DC01_7Zip_GPO_nyelvi_beallitas.png) | A csomag nyelvének figyelmen kívül hagyása telepítéskor |
| 46 | [`46_RR-DC01_GPO_halozatra_varakozas.png`](screenshots/46_RR-DC01_GPO_halozatra_varakozas.png) | Az „Always wait for the network at computer startup and logon” házirend engedélyezése |
| 47 | [`47_RR-DC01_7Zip_GPO_vegso_beallitasok.png`](screenshots/47_RR-DC01_7Zip_GPO_vegso_beallitasok.png) | A hozzárendelt alkalmazás összesített GPO-beállításai |
| 48 | [`48_RR-DC01_GPO_halozatra_varakozas_ellenorizve.png`](screenshots/48_RR-DC01_GPO_halozatra_varakozas_ellenorizve.png) | A hálózatra várakozási beállítás a GPO Settings összesítő nézetében |

## 6. Végső validáció

| # | Képernyőkép | Mit igazol? |
|---:|---|---|
| 49 | [`49_RR-FS01_szerepkorok_es_szolgaltatasok_vegso_ellenorzese.png`](screenshots/49_RR-FS01_szerepkorok_es_szolgaltatasok_vegso_ellenorzese.png) | A négy telepített szerepkör és a futó LanmanServer/Spooler szolgáltatás |
| 50 | [`50_RR-FS01_megosztasok_szoftver_es_nyomtato_vegso_ellenorzese.png`](screenshots/50_RR-FS01_megosztasok_szoftver_es_nyomtato_vegso_ellenorzese.png) | A megosztások, az MSI-elérés és a megosztott/közzétett nyomtató végső ellenőrzése |
| 51 | [`51_RR-FS01_validation_script_elmentve.png`](screenshots/51_RR-FS01_validation_script_elmentve.png) | A `rr-fs01-validation.ps1` script elmentése és fájladatai |
| 52 | [`52_RR-FS01_validation_script_es_output_elmentve.png`](screenshots/52_RR-FS01_validation_script_es_output_elmentve.png) | A script futtatása és a `rr-fs01-validation-output.txt` eredményfájl létrejötte |
| 53 | [`53_RR-FS01_validation_es_backup_verziok.png`](screenshots/53_RR-FS01_validation_es_backup_verziok.png) | A nyomtató részletes állapota, két visszaállítható backup-verzió és a sikeres validáció lezárása |
