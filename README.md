
# 🛡️ Bastionado y Securización de Servidor Corporativo
### Azure Linux 4.0 (Preview)

![Azure Linux](https://img.shields.io/badge/Azure%20Linux-4.0-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Hardening-red?style=for-the-badge&logo=linux&logoColor=white)
![Nftables](https://img.shields.io/badge/Nftables-Firewall-orange?style=for-the-badge)

> [!IMPORTANT]
> Proyecto orientado al **Server Hardening** utilizando **Azure Linux 4.0**, Docker Compose, OpenSSH, Bash y Nftables.-

## 📖 Descripción

Este proyecto implementa y automatiza un entorno virtualizado y altamente seguro (**Server Hardening**) utilizando la distribución empresarial **Azure Linux 4.0** (desarrollada por Microsoft con fuentes derivadas de **Fedora Linux**).

A través de un enfoque ágil y aislado mediante contenedores, se despliega un entorno robusto aplicando políticas estrictas de control de acceso, auditorías criptográficas de red y un firewall perimetral avanzado de última generación.

---

## 🔗 Recursos Oficiales

- Azure Linux: https://github.com/microsoft/azurelinux
- Docker: https://www.docker.com/
- OpenSSH: https://www.openssh.com/
- Nftables: https://wiki.nftables.org/
- Netfilter: https://netfilter.org/

---

## 🛠️ Tecnologías Utilizadas

| Componente | Tecnología |
|------------|------------|
| 🖥️ Sistema Operativo | Azure Linux 4.0 Core |
| 📦 Virtualización | Docker CLI |
| 🔥 Firewall | Nftables |
| 🔐 Acceso remoto | OpenSSH |
| 👤 Gestión de permisos | Linux ACLs + Sudoers |
| ⚙️ Automatización | Bash |
| 🌐 Networking | Netfilter |

---
## 📂 Estructura

```text
.
├── Dockerfile
├── README.md
└── scripts/
    └── hardening.sh
```

---

## 📐 Arquitectura de Seguridad Implementada

### 1️⃣ Modelo de Privilegios Mínimos (Zero Trust)

- Acceso remoto al usuario `root` deshabilitado.
Creación del grupo exclusivo de administración sysadmins.
- Despliegue del usuario de soporte auditado operador.
- Delegación de permisos granulares mediante políticas directas en sudoers.d

### 2️⃣ Bastionado SSH (Hardening)

- Migración del puerto por defecto al puerto seguro alternativo 2222.

- Límite estricto de intentos de autenticación mediante MaxAuthTries 3.

- Desactivación de reenvíos gráficos inseguros con X11Forwarding no
### 3️⃣ Firewall

Implementación de una política restrictiva DROP por defecto en la cadena de entrada (input), permitiendo estrictamente:

- Tráfico de la interfaz de loopback local (lo).

- Tráfico de retorno legítimo (established, related).

- Conexiones SSH entrantes únicamente en el puerto 2222.
---
## 🚀 Despliegue Automatizado del Laboratorio

Para clonar el repositorio y levantar toda la infraestructura automatizada e inmunizada con un solo comando, ejecute el siguiente bloque en su terminal:

```bash
# 1. Clonar el repositorio del portafolio técnico
git clone [https://github.com/danny123uwu/AzureLinux4_Server.git](https://github.com/danny123uwu/AzureLinux4_Server.git)

cd AzureLinux4_Server/Proyect_Azure_Conteiner

# 2. Compilar la imagen y desplegar el entorno aislado
sudo docker compose up -d --build
```

## 🔍 Auditoría

```bash
ssh operador@localhost -p 2222
```

- Contraseña: PasswordSeguro123


Volver a encender el contenedor 

```bash
sudo docker compose up -d
```
O tambien puden usar:
```bash
sudo docker compose start
```

# Escaneo de Puertos Perimetral


```bash
nmap -p 1-3000 localhost
```



```text
2222/tcp open ssh
```

Resultado esperado:

```text
Resultado esperado (Aislamiento verificado):

PORT     STATE SERVICE
2222/tcp open  EtherNet/IP-1
```

## 🔍 Auditoría y Pruebas de Concepto (PoC)

### Validación del Acceso SSH Seguro
Para ingresar al servidor de forma directa y evitar conflictos con registros previos de known_hosts o huellas criptográficas antiguas en su máquina host, ejecute la conexión omitiendo temporalmente la verificación estricta de llaves locales:

```Bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no operador@localhost -p 2222
```
- Contraseña por defecto: PasswordSeguro123


---

# ⚠️ Troubleshooting

## 🔴 Problema Detectado
Durante las fases de inicialización en kernels modernos, la ejecución clásica puede arrojar el siguiente error crítico:

```text
modprobe: FATAL: Module ip_tables not found...
iptables v1.8.11 (legacy): can't initialize iptables table 'filter'
```

## 🔬 Análisis Técnico

Los entornos de producción y kernels Linux modernos han migrado la gestión del filtrado de paquetes hacia la arquitectura Netfilter + Nftables, provocando que los módulos heredados de iptables-legacy no se encuentren presentes o estén completamente deshabilitados por defecto en el host.

## 🟢 Solución Aplicada

```bash
tdnf install nftables -y

nft flush ruleset
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 ; policy drop ; }
nft add rule inet filter input tcp dport 2222 accept
```

Esta migración eliminó la dependencia de iptables, resolvió el problema con el kernel y alineó el laboratorio con tecnologías modernas.

---

## 📚 Lecciones Aprendidas

- Administración segura de usuarios.
- OpenSSH Hardening.
- Linux ACLs y sudoers.
- Nftables.
- Docker.
- Bash.
- Compatibilidad con kernels modernos.
- Migración de iptables a Nftables.

---

## 🎯 Competencias Demostradas

- Linux Administration
- Server Hardening
- Docker
- OpenSSH
- Bash
- Network Security
- Troubleshooting
- Firewall Management

---

## 👨‍💻 Me

Proyecto académico enfocado en Administración de Servidores Linux y Hardening de Infraestructura.
