# RR-WEB01 biztonságosan verziókezelhető konfigurációi

Ez a könyvtár az RR-WEB01 Apache virtuális gépeit és a RapidRoute kezdőlapját tartalmazza.

| Repozitóriumbeli fájl | Célhely az RR-WEB01-en |
|---|---|
| `apache/rapidroute.conf` | `/etc/apache2/sites-available/rapidroute.conf` |
| `apache/rapidroute-ssl.conf` | `/etc/apache2/sites-available/rapidroute-ssl.conf` |
| `website/index.html` | `/var/www/rapidroute/index.html` |

Az Apache-konfigurációk alkalmazása után:

```bash
sudo a2enmod ssl
sudo a2ensite rapidroute.conf rapidroute-ssl.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

## Titkos fájlok

A HTTPS virtuális gép a következő helyi fájlokra hivatkozik:

- nyilvános tanúsítvány: `/etc/ssl/certs/rapidroute.crt`;
- **privát kulcs:** `/etc/ssl/private/rapidroute.key`.

A privát kulcs szándékosan nincs ebben a csomagban, és nem kerülhet GitHubra. A tanúsítvány és a kulcs telepítésenként újragenerálható. Verziókezelés előtt mindig ellenőrizni kell, hogy nincs-e a változások között `.key`, `.pem`, jelszó vagy privát kulcsblokk.
