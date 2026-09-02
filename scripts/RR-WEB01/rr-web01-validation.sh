#!/usr/bin/env bash

# RR-WEB01 read-only validation script
# RapidRoute Logistics Network
# This script does not change the server configuration.

set -u

PASS=0
FAIL=0
INTERFACE="ens33"
EXPECTED_HOST="rr-web01"
EXPECTED_IP="192.168.186.30/24"
DNS_SERVER="192.168.186.10"
WEB_NAME="www.rapidroute.local"
CERT_FILE="/etc/ssl/certs/rapidroute.crt"

section() {
    printf '\n============================================================\n%s\n============================================================\n' "$1"
}

check() {
    local description="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        printf '[PASS] %s\n' "$description"
        PASS=$((PASS + 1))
    else
        printf '[FAIL] %s\n' "$description"
        FAIL=$((FAIL + 1))
    fi
}

service_active() {
    systemctl is-active --quiet "$1"
}

package_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q 'install ok installed'
}

dns_resolves() {
    getent ahostsv4 "$1" | awk '{print $1}' | grep -qx "$2"
}

listening_on() {
    ss -ltn | awk 'NR > 1 {print $4}' | grep -Eq ":$1$"
}

http_status() {
    local url="$1"
    local insecure="${2:-false}"
    local options=(-sS -o /dev/null -w '%{http_code}' --connect-timeout 5 --max-time 15)
    if [[ "$insecure" == "true" ]]; then
        options+=(-k)
    fi
    [[ "$(curl "${options[@]}" "$url")" == "200" ]]
}

cert_more_than_30_days() {
    openssl x509 -checkend 2592000 -noout -in "$CERT_FILE"
}

section "SYSTEM AND NETWORK"
check "Hostname is $EXPECTED_HOST" test "$(hostnamectl --static)" = "$EXPECTED_HOST"
check "Static IPv4 address is $EXPECTED_IP" bash -c "ip -4 -br address show '$INTERFACE' | grep -qw '$EXPECTED_IP'"
check "Default route uses 192.168.186.2" bash -c "ip route | grep -q '^default via 192.168.186.2 dev $INTERFACE'"
check "Gateway is reachable" ping -c 1 -W 2 192.168.186.2
check "RR-DC01 is reachable" ping -c 1 -W 2 "$DNS_SERVER"
check "Ubuntu archive is reachable" ping -c 1 -W 3 hu.archive.ubuntu.com

section "DNS"
check "DNS server on $INTERFACE is $DNS_SERVER" bash -c "resolvectl dns '$INTERFACE' | grep -qw '$DNS_SERVER'"
check "DNS search domain is rapidroute.local" bash -c "resolvectl domain '$INTERFACE' | grep -qw 'rapidroute.local'"
check "RR-DC01 resolves to $DNS_SERVER" dns_resolves rr-dc01.rapidroute.local "$DNS_SERVER"
check "$WEB_NAME resolves to 192.168.186.30" dns_resolves "$WEB_NAME" 192.168.186.30

section "PACKAGES AND SERVICES"
check "Apache package is installed" package_installed apache2
check "Apache service is active" service_active apache2
check "SSH service is active" service_active ssh
check "VMware Tools service is active" service_active open-vm-tools

section "FIREWALL AND PORTS"
check "UFW firewall is active" bash -c "ufw status | grep -q '^Status: active'"
check "Apache Full firewall profile is allowed" bash -c "ufw status | grep -q 'Apache Full.*ALLOW'"
check "TCP port 80 is listening" listening_on 80
check "TCP port 443 is listening" listening_on 443

section "APACHE CONFIGURATION"
check "Apache configuration is valid" apache2ctl configtest
check "RapidRoute HTTP virtual host is enabled" test -e /etc/apache2/sites-enabled/rapidroute.conf
check "RapidRoute HTTPS virtual host is enabled" test -e /etc/apache2/sites-enabled/rapidroute-ssl.conf

section "HTTP AND HTTPS TESTS"
check "HTTP website returns status 200" http_status "http://$WEB_NAME"
check "HTTPS website returns status 200" http_status "https://$WEB_NAME" true

section "TLS CERTIFICATE"
if openssl x509 -in "$CERT_FILE" -noout -subject -issuer -dates -ext subjectAltName 2>/dev/null; then
    printf '[PASS] TLS certificate is readable\n'
    PASS=$((PASS + 1))
else
    printf '[FAIL] TLS certificate is readable\n'
    FAIL=$((FAIL + 1))
fi
check "TLS certificate is valid for more than 30 days" cert_more_than_30_days

section "SYSTEM RESOURCES"
df -h /
free -h

section "VALIDATION SUMMARY"
printf 'Passed checks: %d\n' "$PASS"
printf 'Failed checks: %d\n' "$FAIL"

if ((FAIL == 0)); then
    printf 'OVERALL RESULT: PASS\n'
    exit 0
fi

printf 'OVERALL RESULT: FAIL\n'
exit 1
