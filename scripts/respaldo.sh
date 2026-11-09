#!/usr/bin/env bash
# respaldo.sh - Respaldo semanal del servidor del equipo (rol de Despliegue)
# Guarda el sitio, la configuración de Apache y la de vsftpd en un .tar.gz con fecha.
# Conserva las 8 copias más recientes.
set -euo pipefail

DIR=/var/backups/pupuseria
FECHA="$(date +%Y-%m-%d_%H%M)"
ARCHIVO="$DIR/pupuseria_$FECHA.tar.gz"

mkdir -p "$DIR"
RUTAS=()
for r in /var/www/html/pupuseria /etc/apache2 /etc/vsftpd.conf /etc/vsftpd.chroot_list; do
  [[ -e "$r" ]] && RUTAS+=("$r")
done

tar -czf "$ARCHIVO" "${RUTAS[@]}" 2>/dev/null
ls -1t "$DIR"/pupuseria_*.tar.gz | tail -n +9 | xargs -r rm -f

echo "Respaldo creado: $ARCHIVO ($(du -h "$ARCHIVO" | cut -f1))"
