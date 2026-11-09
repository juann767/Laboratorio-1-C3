#!/usr/bin/env bash
# seguridad.sh - Rol de Seguridad (Semana 15, Software Libre UGB)
# Instala y configura vsftpd, crea una cuenta FTP por integrante y da permisos
# de escritura solo sobre /var/www/html/pupuseria.
#
# Uso:
#   sudo bash seguridad.sh                       # crea las 5 cuentas por defecto
#   sudo bash seguridad.sh ana luis maria        # o las cuentas que indiques
#   sudo TLS=si bash seguridad.sh                # además activa FTPS (cifrado TLS)
set -euo pipefail

SITIO=/var/www/html/pupuseria
GRUPO=webequipo
CONF=/etc/vsftpd.conf
LISTA=/etc/vsftpd.chroot_list
USUARIOS=("$@")
[[ ${#USUARIOS[@]} -eq 0 ]] && USUARIOS=(despliegue seguridad desarrollo basedatos calidad)

if [[ $EUID -ne 0 ]]; then echo "Ejecuta con sudo"; exit 1; fi

echo "== 1. Instalar vsftpd =="
apt update
apt install -y vsftpd
[[ -f $CONF.original ]] || cp "$CONF" "$CONF.original"   # copia del archivo original

echo "== 2. Configurar $CONF =="
poner() {  # poner clave valor: descomenta o agrega la línea
  local k="$1" v="$2"
  if grep -qE "^#?\s*$k=" "$CONF"; then
    sed -i -E "s|^#?\s*$k=.*|$k=$v|" "$CONF"
  else
    echo "$k=$v" >> "$CONF"
  fi
}
poner listen YES
poner listen_ipv6 NO
poner anonymous_enable NO
poner local_enable YES
poner write_enable YES
poner local_umask 022
poner ftpd_banner "Bienvenido al servidor FTP de Software Libre"
poner chroot_local_user YES
poner chroot_list_enable YES
poner chroot_list_file "$LISTA"
poner allow_writeable_chroot YES
poner userlist_enable YES
poner userlist_file /etc/vsftpd.userlist
poner userlist_deny NO
poner xferlog_enable YES
poner pasv_min_port 40000
poner pasv_max_port 40100

if [[ "${TLS:-no}" == "si" ]]; then
  apt install -y ssl-cert
  poner ssl_enable YES
  poner rsa_cert_file /etc/ssl/certs/ssl-cert-snakeoil.pem
  poner rsa_private_key_file /etc/ssl/private/ssl-cert-snakeoil.key
  poner force_local_logins_ssl YES
  poner force_local_data_ssl YES
fi

echo "== 3. Grupo y cuentas individuales =="
getent group "$GRUPO" >/dev/null || groupadd "$GRUPO"
: > "$LISTA"
: > /etc/vsftpd.userlist
for u in "${USUARIOS[@]}"; do
  if ! id "$u" >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G "$GRUPO" "$u"
    echo "Contraseña para $u:"
    passwd "$u"
  else
    usermod -aG "$GRUPO" "$u"
  fi
  echo "$u" >> "$LISTA"              # sin chroot: pueden llegar a /var/www/html
  echo "$u" >> /etc/vsftpd.userlist  # solo estas cuentas pueden entrar por FTP
done

echo "== 4. Permisos sobre el sitio =="
mkdir -p "$SITIO"
chown -R root:"$GRUPO" "$SITIO"
find "$SITIO" -type d -exec chmod 2775 {} \;   # setgid: lo nuevo hereda el grupo
find "$SITIO" -type f -exec chmod 664 {} \;
# /var/www/html sigue siendo de root: el equipo solo escribe en su carpeta
chmod 755 /var/www/html

echo "== 5. Reiniciar y verificar =="
systemctl restart vsftpd
systemctl enable vsftpd
systemctl --no-pager status vsftpd | head -n 5
ss -tlnp | grep ':21 ' || true

IP="$(hostname -I | awk '{print $1}')"
echo
echo "FileZilla -> Servidor: $IP  Puerto: 21  Usuario: (cuenta)  Contraseña: (la asignada)"
echo "Carpeta de trabajo: $SITIO"
echo "Cuentas: ${USUARIOS[*]}"
