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
sudo git clone https://github.com/USUARIO/pupuseria.git /tmp/pupuseria
sudo bash /tmp/pupuseria/scripts/despliegue.sh https://github.com/USUARIO/pupuseria.git
sudo bash /var/www/html/pupuseria/scripts/seguridad.sh
```
Actualizar cuando alguien sube cambios: `cd /var/www/html/pupuseria && sudo git pull`

## Equipo
| Rol | Integrante | Código |
|---|---|---|
| Despliegue | [Nombre 1] | [Código 1] |
| Seguridad | [Nombre 2] | [Código 2] |
| Desarrollo | [Nombre 3] | [Código 3] |
| Base de datos | [Nombre 4] | [Código 4] |
| Calidad | [Nombre 5] | [Código 5] |

Plantilla base: New Rise de Template World (Creative Commons Attribution 2.5).
