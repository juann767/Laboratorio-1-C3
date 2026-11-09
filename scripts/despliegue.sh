#!/usr/bin/env bash
# despliegue.sh - Rol de Despliegue (Semana 15, Software Libre UGB)
# Instala Apache y Git, prueba AdminLTE, publica el sitio del caso en
# /var/www/html/pupuseria e instala el respaldo semanal.
#
# Uso:
#   sudo bash despliegue.sh                      # copia el sitio desde ./pupuseria
#   sudo bash despliegue.sh https://github.com/USUARIO/pupuseria.git   # clona el repo del equipo
set -euo pipefail

CARPETA=pupuseria
DESTINO=/var/www/html/$CARPETA
REPO="${1:-}"
DIR_SCRIPT="$(cd "$(dirname "$0")" && pwd)"

if [[ $EUID -ne 0 ]]; then
  echo "Ejecuta con sudo: sudo bash $0 [URL-REPO]"; exit 1
fi

echo "== 1. Apache =="
apt update
apt install -y apache2
systemctl enable --now apache2
systemctl --no-pager status apache2 | head -n 5

echo "== 2. Git =="
apt install -y git
git --version

echo "== 3. Repositorio de prueba AdminLTE =="
cd /var/www/html
if [[ ! -d AdminLTE ]]; then
  git clone https://github.com/samuelkno/AdminLTE.git
fi

echo "== 4. Sitio del caso en $DESTINO =="
if [[ -n "$REPO" ]]; then
  if [[ -d "$DESTINO/.git" ]]; then
    git -C "$DESTINO" pull
  else
    git clone "$REPO" "$DESTINO"
  fi
else
  ORIGEN="$DIR_SCRIPT/../pupuseria"
  [[ -d "$ORIGEN" ]] || { echo "No encuentro $ORIGEN"; exit 1; }
  mkdir -p "$DESTINO"
  cp -r "$ORIGEN"/. "$DESTINO"/
fi
# Apache solo necesita leer; Seguridad ajusta después la escritura para las cuentas FTP
chown -R root:www-data "$DESTINO"
find "$DESTINO" -type d -exec chmod 775 {} \;
find "$DESTINO" -type f -exec chmod 664 {} \;
git config --system --add safe.directory "$DESTINO" || true

echo "== 5. Respaldo semanal =="
install -m 755 "$DIR_SCRIPT/respaldo.sh" /usr/local/bin/respaldo_pupuseria.sh
echo "0 23 * * 0 root /usr/local/bin/respaldo_pupuseria.sh" > /etc/cron.d/respaldo_pupuseria
chmod 644 /etc/cron.d/respaldo_pupuseria
/usr/local/bin/respaldo_pupuseria.sh

IP="$(hostname -I | awk '{print $1}')"
echo
echo "Listo. Comparte con el equipo:"
echo "  Página por defecto: http://$IP"
echo "  Prueba AdminLTE:    http://$IP/AdminLTE"
echo "  Sitio del caso:     http://$IP/$CARPETA"
