#!/bin/bash
set -e
#Added marker
MARKER_FILE="/var/lib/ldap/.configured"

if [ -f "$MARKER_FILE" ]; then
  echo "[INFO] LDAP already configured — skipping reinitialization."
else
  echo "[INFO] First time setup — configuring LDAP slapd"

  LDAP_DOMAIN=${LDAP_DOMAIN:-"itcommunity.ro"}
  LDAP_ORGANISATION=${LDAP_ORGANISATION:-"ITcommunity SRL"}
  LDAP_ADMIN_PASSWORD=$(cat /run/secrets/ldap_admin_password)

debconf-set-selections <<EOF
slapd slapd/no_configuration boolean false
slapd slapd/domain string $LDAP_DOMAIN
slapd shared/organization string $LDAP_ORGANISATION
slapd slapd/password1 password $LDAP_ADMIN_PASSWORD
slapd slapd/password2 password $LDAP_ADMIN_PASSWORD
slapd slapd/backend select mdb
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
EOF

dpkg-reconfigure -f noninteractive slapd
touch "$MARKER_FILE"

fi

exec slapd -h "ldap://0.0.0.0:389 ldapi:///" -u openldap -g openldap -d 25
echo "[INFO] LDAP slapd started successfully."
