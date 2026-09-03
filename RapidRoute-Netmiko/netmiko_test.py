from netmiko import ConnectHandler
from getpass import getpass

r_bud = {
    "device_type": "cisco_ios",
    "host": "10.10.254.2",
    "username": "admin",
    "password": getpass("R-BUD jelszó: "),
}

print("Kapcsolódás az R-BUD routerhez...")

connection = ConnectHandler(**r_bud)

print("SSH kapcsolat létrejött.")

output = connection.send_command("show ip interface brief")

print("\n--- R-BUD interfészek ---")
print(output)

connection.disconnect()

print("\nKapcsolat bontva.")