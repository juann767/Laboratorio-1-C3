#!/usr/bin/env bash
# verificar_sitio.sh - Rol de Calidad: revisa que todas las páginas e imágenes respondan.
# Ejecutar desde otra laptop (Linux, macOS o Git Bash en Windows) en la misma red.
# Uso: bash verificar_sitio.sh 192.168.x.x
set -u
IP="${1:?Uso: bash verificar_sitio.sh IP-DEL-SERVIDOR}"
BASE="http://$IP/pupuseria"

RECURSOS=(
  index.html seguridad.html datos.html despliegue.html calidad.html
  style.css extra.css images/logo.gif images/banner.gif images/header.jpg
)

fallas=0
for r in "${RECURSOS[@]}"; do
  code="$(curl -s -o /dev/null -w '%{http_code}' "$BASE/$r")"
  if [[ "$code" == "200" ]]; then
    printf 'OK    %s  %s\n' "$code" "$r"
  else
    printf 'FALLA %s  %s\n' "$code" "$r"; fallas=$((fallas+1))
  fi
done

echo
if [[ $fallas -eq 0 ]]; then
  echo "Todo responde correctamente en $BASE"
else
  echo "$fallas recurso(s) con falla. Revisar nombres de archivo y permisos."
  exit 1
fi
