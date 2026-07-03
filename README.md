
# 🛡️ Bastionado y Securización de Servidor Corporativo
### Azure Linux 4.0 (Preview)

![Azure Linux](https://img.shields.io/badge/Azure%20Linux-4.0-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Hardening-red?style=for-the-badge&logo=linux&logoColor=white)
![Nftables](https://img.shields.io/badge/Nftables-Firewall-orange?style=for-the-badge)

> [!IMPORTANT]
> Proyecto orientado al **Server Hardening** utilizando **Azure Linux 4.0**, Docker, OpenSSH, Bash y Nftables.

---

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

## 📐 Arquitectura de Seguridad Implementada

### 1️⃣ Modelo de Privilegios Mínimos (Zero Trust)

- Acceso remoto al usuario `root` deshabilitado.
- Grupo `sysadmins`.
- Usuario operador.
- Permisos mediante `sudoers.d`.

### 2️⃣ Bastionado SSH

- Puerto 2222.
- `MaxAuthTries 3`
- `X11Forwarding no`

### 3️⃣ Firewall

Política `DROP` por defecto permitiendo únicamente:

- SSH 2222
- established
- related

---

## 📂 Estructura

```text
.
├── Dockerfile
├── README.md
└── scripts/
    └── hardening.sh
```

## 🚀 Despliegue

```bash
sudo docker build -t azure4_secure_server .

sudo docker run -d \
  --name azure4_server \
  --privileged \
  -p 2222:2222 \
  azure4_secure_server
```

## 🔍 Auditoría

```bash
ssh operador@localhost -p 2222
```

```bash
nmap -p 1-3000 localhost
```

Resultado esperado:

```text
2222/tcp open ssh
```

---

# ⚠️ Troubleshooting

## 🔴 Problema Detectado

```text
modprobe: FATAL: Module ip_tables not found...
iptables v1.8.11 (legacy): can't initialize iptables table 'filter'
```

## 🔬 Análisis Técnico

Los kernels Linux modernos utilizan **Netfilter + Nftables**, dejando obsoletos los módulos `iptables-legacy`.

## 🟢 Solución Aplicada

```bash
tdnf install nftables

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

## 👨‍💻 Autor

Proyecto académico enfocado en Administración de Servidores Linux y Hardening de Infraestructura.
