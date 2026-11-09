# Pupusería El Comal – Servidor Web (Semana 15)

Software Libre · Universidad Gerardo Barrios · Caso 2: Pupusería con pedidos en línea.

## Contenido
- `index.html` – portada (Desarrollo)
- `despliegue.html`, `seguridad.html`, `datos.html`, `calidad.html` – sección de cada rol
- `scripts/despliegue.sh` – Apache, Git, publicación y respaldo semanal
- `scripts/seguridad.sh` – vsftpd, cuentas FTP y permisos
- `scripts/respaldo.sh` – respaldo del sitio y la configuración
- `scripts/verificar_sitio.sh` – prueba de enlaces desde otra laptop
- `bd/pupuseria.sql` – base de datos (productos, clientes, pedidos)

## Publicar en el servidor (VM del rol Despliegue)
```bash
sudo apt install -y git
sudo git clone https://github.com/juann767/pupuseria.git /tmp/pupuseria
sudo bash /tmp/pupuseria/scripts/despliegue.sh https://github.com/Walt99/pupuseria.git
sudo bash /var/www/html/pupuseria/scripts/seguridad.sh
```
Actualizar cuando alguien sube cambios: `cd /var/www/html/pupuseria && sudo git pull`

## Equipo
| Rol | Integrante | Código |
|---|---|---|
| Despliegue | Walter Alexander Ramírez Benítez | SMSS082124 |
| Seguridad | Brandom Gamaliel Sánchez Guevara  | SMSS017424 |
| Desarrollo | Franklin Aldahir Portillo Flores | SMSS011624 |
| Base de datos | Diego Martín López Moreno     | SMSS097824 |
| Calidad | Juan Ramón Espinal Coto             | SMSS102323 |
