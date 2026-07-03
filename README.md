# 🛡️ Bastionado y Securización de Servidor Corporativo — Azure Linux 4.0 (Preview)

Este proyecto implementa y automatiza un entorno virtualizado y altamente seguro (*Server Hardening*) utilizando la distribución empresarial **Azure Linux 4.0** (desarrollada por Microsoft con fuentes derivadas de **Fedora Linux**). 

A través de un enfoque ágil y aislado mediante contenedores, se despliega un entorno robusto aplicando políticas estrictas de control de acceso, auditorías criptográficas de red y un firewall perimetral avanzado de última generación.

---

## 🛠️ Tecnologías Utilizadas

* **Sistema Operativo Base:** Azure Linux 4.0 Core (Ecosistema RPM/Fedora Cloud-Native).
* **Virtualización/Aislamiento:** Docker CLI (Privileged Network Mode).
* **Seguridad Perimetral:** Nftables (Netfilter Framework nativo del Kernel).
* **Gestión de Accesos:** OpenSSH Server, SSHd Hardening Policies, Linux ACLs & Sudoers Restringidos.
* **Automatización:** Bash Scripting Avanzado.

---

## 📐 Arquitectura de Seguridad Implementada

1.  **Modelo de Privilegios Mínimos (Zero-Trust):** Se restringe por completo el acceso remoto directo al usuario `root`. Se automatiza la creación de un grupo de administración técnica (`sysadmins`) y un usuario operador con credenciales cifradas y permisos `sudo` estrictamente controlados mediante archivos `sudoers.d`.
2.  **Bastionado de Directivas SSH (sshd_config):** * Migración del servicio al puerto seguro alternativo `2222`.
    * Límite estricto de intentos de autenticación (`MaxAuthTries 3`) para mitigar ataques de fuerza bruta.
    * Desactivación de reenvío gráfico (`X11Forwarding no`) para reducir la superficie de ataque.
3.  **Firewall de Capa de Red (Microsegmentación):** Implementación de una política por defecto de denegación absoluta (`DROP`) en cadenas de entrada y reenvío, permitiendo única y exclusivamente el tráfico SSH sobre el puerto configurado y conexiones del estado (`established,related`).

---

## 📂 Estructura del Repositorio

```text
├── Dockerfile           # Definición de dependencias e infraestructura base de Azure Linux 4
├── README.md            # Documentación técnica del proyecto
└── scripts/
    └── hardening.sh     # Script automatizado de inyección de seguridad perimetral


## Despliegue del Laboratorio
Para compilar el entorno e iniciar el servidor seguro de forma aislada, ejecute los siguientes comandos en su terminal local:

**1. Compilación de la imagen corporativa:
Bash
sudo docker build -t azure4_secure_server .
**2. Despliegue del contenedor con privilegios de red:
Bash
sudo docker run -d \
  --name azure4_server \
  --privileged \
  -p 2222:2222 \
  azure4_secure_server
🔍 Auditoría y Pruebas de Concepto (PoC)
Validación del Acceso SSH Seguro
Inicie sesión remota utilizando el puerto alternativo y las credenciales del operador del sistema configurado de forma segura:

Bash
ssh operador@localhost -p 2222
(Contraseña por defecto en laboratorio: PasswordSeguro123)

Escaneo de Vulnerabilidades Perimetrales con Nmap
Realice un escaneo de puertos desde el host externo para verificar la efectividad del Firewall:

Bash
nmap -p 1-3000 localhost
Resultado esperado: Toda la superficie del servidor se mantendrá invisible o en estado cerrado, exponiendo únicamente el puerto 2222/tcp como open.

⚠️ Lecciones Aprendidas y Solución de Problemas (Troubleshooting)
Durante el despliegue en entornos de desarrollo modernos, se identificó y resolvió un desafío técnico crítico relacionado con la evolución del Kernel de Linux.

🔴 Problema Detectado: Fallo de Módulos Iptables
Al ejecutar el contenedor sobre sistemas operativos host con kernels modernos (ej. Arch Linux, CachyOS con Kernel >= 6.x/7.x), el contenedor lanzaba el siguiente error en sus registros internos (docker logs):

Plaintext
modprobe: FATAL: Module ip_tables not found in directory /lib/modules/...
iptables v1.8.11 (legacy): can't initialize iptables table `filter': Table does not exist
🔬 Análisis Técnico
Los kernels de vanguardia han depreciado por completo los módulos heredados (legacy) de iptables en favor del framework unificado Nftables. Dado que el contenedor intentaba compilar reglas a través de la capa de traducción antigua de iptables-legacy, el kernel del host denegaba la operación al carecer de dichos módulos de red enlazados.

🟢 Solución Aplicada (Migración Tecnológica)
En lugar de forzar la carga de módulos obsoletos en el host, la infraestructura se actualizó aplicando buenas prácticas modernas de administración de sistemas. Se sustituyó iptables por nftables de forma nativa tanto en el gestor de paquetes de Azure Linux (tdnf install nftables) como en el script automatizado de bastionado:

```
Bash
# Implementación nativa en nftables
nft flush ruleset
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add rule inet filter input tcp dport 2222 accept
Esta actualización resolvió el conflicto de comunicación con el kernel, optimizó el rendimiento del procesamiento de paquetes y alineó el proyecto con los estándares vigentes de seguridad en entornos Linux empresariales y Cloud-Native.

```
---

### 🔥 ¿Por qué este README te hace destacar?
1. **Terminología Impecable:** Habla de *Bastionado, Zero-Trust, Microsegmentación y Capa de red*, palabras clave que buscan los ingenieros líderes al revisar perfiles.
2. **Muestra Resiliencia:** El bloque de *Troubleshooting* le demuestra al reclutador que si algo falla, no te rindes; investigas el comportamiento del kernel (`modprobe`, compatibilidad de sockets) y migras el proyecto a tecnologías modernas como `nftables`.

¡Copia este código en tu `README.md`, haz el `git push` y tu portafolio dará un salto de calidad enorme!