from netmiko import ConnectHandler
from netmiko.exceptions import NetmikoTimeoutException
from netmiko.exceptions import NetmikoAuthenticationException
from getpass import getpass
from pathlib import Path
from datetime import datetime


# --------------------------------------------------
# 1. ADMIN JELSZÓ BEKÉRÉSE
# --------------------------------------------------

password = getpass("Admin jelszó: ")


# --------------------------------------------------
# 2. HÁLÓZATI ESZKÖZÖK
# --------------------------------------------------

devices = [
    {
        "name": "R-BUD",
        "device_type": "cisco_ios",
        "host": "10.10.254.2",
        "username": "admin",
        "password": password,
    },
    {
        "name": "R-DEB-01",
        "device_type": "cisco_ios",
        "host": "10.20.254.2",
        "username": "admin",
        "password": password,
    },
    {
        "name": "R-DEB-02",
        "device_type": "cisco_ios",
        "host": "10.30.254.2",
        "username": "admin",
        "password": password,
    },
    {
        "name": "MLS-BUD-01",
        "device_type": "cisco_ios",
        "host": "10.10.99.2",
        "username": "admin",
        "password": password,
    },
    {
        "name": "MLS-BUD-02",
        "device_type": "cisco_ios",
        "host": "10.10.99.3",
        "username": "admin",
        "password": password,
    },
    {
        "name": "MLS-DEB-01",
        "device_type": "cisco_ios",
        "host": "10.20.99.1",
        "username": "admin",
        "password": password,
    },
    {
        "name": "MLS-DEB-02",
        "device_type": "cisco_ios",
        "host": "10.30.99.1",
        "username": "admin",
        "password": password,
    },
]


# --------------------------------------------------
# 3. AUTOMATIKUSAN KIKÜLDENDŐ KONFIGURÁCIÓ
# --------------------------------------------------

config_commands = [
    "service timestamps log datetime msec",
    "service timestamps debug datetime msec",
    "banner motd #RapidRoute Logistics - Authorized access only#",
]


# VTY vonalak biztonsági beállítása
vty_commands = [
    "line vty 0 4",
    "exec-timeout 10 0",
]


# --------------------------------------------------
# 4. BACKUP MAPPA LÉTREHOZÁSA
# --------------------------------------------------

backup_folder = Path("backups")
backup_folder.mkdir(exist_ok=True)


# --------------------------------------------------
# 5. KAPCSOLÓDÁS ÉS KONFIGURÁLÁS
# --------------------------------------------------

for device in devices:

    name = device["name"]

    connection_data = {
        "device_type": device["device_type"],
        "host": device["host"],
        "username": device["username"],
        "password": device["password"],
    }

    print("\n----------------------------------------")
    print(f"Kapcsolódás: {name}")
    print("----------------------------------------")

    connection = None

    try:

        # SSH kapcsolat létrehozása
        connection = ConnectHandler(**connection_data)

        print(f"[OK] SSH kapcsolat létrejött: {name}")


        # --------------------------------------------------
        # 6. INTERFÉSZEK LEKÉRÉSE
        # --------------------------------------------------

        interface_output = connection.send_command(
            "show ip interface brief"
        )

        print("\n[INFO] Interfészállapot:")
        print(interface_output)


        # --------------------------------------------------
        # 7. AUTOMATIKUS KONFIGURÁCIÓ
        # --------------------------------------------------

        print(f"\n[INFO] Konfiguráció küldése: {name}")

        config_output = connection.send_config_set(
            config_commands
        )

        print(config_output)


        # --------------------------------------------------
        # 8. VTY TIMEOUT KONFIGURÁCIÓ
        # --------------------------------------------------

        connection.send_config_set(
            vty_commands
        )

        print("[OK] VTY timeout beállítva.")


        # --------------------------------------------------
        # 9. KONFIGURÁCIÓ MENTÉSE
        # --------------------------------------------------

        connection.save_config()

        print("[OK] Startup-config mentve.")


        # --------------------------------------------------
        # 10. RUNNING-CONFIG LEKÉRÉSE
        # --------------------------------------------------

        running_config = connection.send_command(
            "show running-config"
        )


        # --------------------------------------------------
        # 11. BACKUP FÁJL LÉTREHOZÁSA
        # --------------------------------------------------

        timestamp = datetime.now().strftime(
            "%Y-%m-%d_%H-%M-%S"
        )

        filename = backup_folder / (
            f"{name}_{timestamp}_running-config.txt"
        )

        with open(
            filename,
            "w",
            encoding="utf-8"
        ) as file:

            file.write(running_config)


        print(
            f"[OK] Konfigurációs backup elkészült: "
            f"{filename}"
        )


    # --------------------------------------------------
    # 12. HIBAKEZELÉS
    # --------------------------------------------------

    except NetmikoAuthenticationException:

        print(
            f"[HIBA] Sikertelen hitelesítés: {name}"
        )


    except NetmikoTimeoutException:

        print(
            f"[HIBA] Az eszköz nem érhető el: {name}"
        )


    except Exception as error:

        print(
            f"[HIBA] Ismeretlen hiba - {name}: {error}"
        )


    # --------------------------------------------------
    # 13. SSH KAPCSOLAT BONTÁSA
    # --------------------------------------------------

    finally:

        if connection:

            connection.disconnect()

            print(
                f"[INFO] SSH kapcsolat bontva: {name}"
            )


print("\n========================================")
print("RapidRoute hálózatautomatizáció befejezve.")
print("========================================")