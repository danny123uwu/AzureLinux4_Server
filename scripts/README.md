# 🛡️ Azure Linux 4.0 Secure Server & Automated Hardening Laboratory

Este repositorio contiene un entorno de laboratorio contenerizado y automatizado para el despliegue de un servidor seguro basado en **Azure Linux 4.0 (CBL-Mariner Core)**. El proyecto implementa políticas estrictas de seguridad bajo el enfoque **Zero-Trust**, control de acceso basado en roles (RBAC), endurecimiento de OpenSSH y un firewall perimetral avanzado utilizando **Nftables**.

Este entorno está diseñado para demostrar principios avanzados de hardening de infraestructura, automatización con Docker Compose y la resolución de problemas de red complejos en entornos Cloud-Native.

---

## 🏗️ Arquitectura técnica y Matriz de Seguridad

El contenedor se compila de forma nativa sobre la imagen de Microsoft y aplica las siguientes capas de seguridad durante su inicialización:

* **Sistema Operativo Base:** `mcr.microsoft.com/azurelinux-beta/base/core:4.0`.
* **Segmentación de Red (Firewall Perimetral):** Implementación de **Nftables** nativo con políticas por defecto `DROP` en las cadenas de `INPUT` y `FORWARD`. Solo se permite tráfico por la interfaz de loopback y conexiones establecidas.
* **Acceso Remoto Seguro (OpenSSH):**
    * Migración del servicio al puerto seguro alternativo **2222**.
    * Bloqueo absoluto del acceso directo al usuario `root`.
    * Límite estricto de mitigación contra fuerza bruta (`MaxAuthTries 3`).
    * Restricción de acceso exclusivo al grupo técnico `sysadmins`.
* **Control de Accesos (RBAC):** Creación del usuario restringido `operador`, aislado del usuario root y mapeado a políticas administrativas limitadas mediante configuraciones en `/etc/sudoers.d/`.

---

## 📂 Estructura del Proyecto

```text
Proyect_Azure_Conteiner/
├── docker-compose.yml       # Orquestación del contenedor, redes puentes y privilegios de red.
├── Dockerfile               # Aprovisionamiento, gestión de paquetes (tdnf) y llaves criptográficas.
├── README.md                # Documentación técnica del entorno.
├── img/                     # Almacenamiento de evidencias criptográficas y de red (PoC).
└── scripts/
    └── hardening.sh         # Script automatizado de hardening (Firewall, SSH, Sudoers y Usuarios).
```

##🚀 Guía de Despliegue Rápido

Prerrequisitos
*Docker y Docker Compose instalados.

Cliente SSH y Nmap para la fase de auditoría.

Navega hasta la raíz del proyecto y levanta el servicio asegurando la recreación limpia de la pila de red y compilación de dependencias:

```text
Bash

cd AzureLinux4_Server
sudo docker-compose up -d --build --force-recreate

```
---

**🔍 Fase de Auditoría y Pruebas de Concepto (PoC)
Esta sección documenta la validación funcional del entorno de seguridad, demostrando el comportamiento real del Firewall y la escalación controlada de privilegios.

1. Auditoría Perimetral de Puertos (Vía Nmap)
Desde el host externo se ejecuta un escaneo de rango para verificar que las reglas de microsegmentación del firewall descartan el tráfico no autorizado.

```text
Bash
automatizacion ❯ nmap -p 2220-2225 localhost
Starting Nmap 7.99 ( [https://nmap.org](https://nmap.org) ) at 2026-07-03 09:57 -0600
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000035s latency).

PORT     STATE  SERVICE
2220/tcp closed netiq
2221/tcp closed rockwell-csp1
2222/tcp open   EtherNetIP-1
2223/tcp closed rockwell-csp2
2224/tcp closed efi-mg
2225/tcp closed rcip-itu

Nmap done: 1 IP address (1 host up) scanned in 0.02 seconds
Análisis del Resultado:
Puerto 2222/tcp (OPEN): El túnel seguro de SSH está expuesto correctamente hacia el exterior.

Puertos Adyacentes (CLOSED): Nftables e interfaces de red bloquean activamente cualquier otro intento de conexión.

```

##Aquí puedes ver la captura de pantalla del escaneo perimetral:

2. Validación de Acceso SSH y Reglas Internas del Firewall
Acceso remoto mediante el usuario restringido configurado y auditoría del estado del framework de red desde el interior del contenedor.

```text
Bash
automatizacion ❯ ssh operador@localhost -p 2222
operador@localhost's password: 
Last login: Fri Jul  3 15:46:52 2026 from 172.18.0.1

[operador@e4e976889273 ~]$ whoami 
operador

[operador@e4e976889273 ~]$ sudo nft list ruleset
[sudo] password for operador: 
table inet filter {
        chain input {
                type filter hook input priority filter; policy drop;
                iif "lo" accept
                ct state established,related accept
                tcp dport 2222 accept
        }

        chain forward {
                type filter hook forward priority filter; policy drop;
                }

        chain output {
                type filter hook output priority filter; policy accept;
        }
}

```
---

Análisis del Resultado:
Identidad Aislada: El comando whoami confirma el acceso bajo la identidad de operador, mitigando riesgos asociados al uso directo de root.

Escalación Controlada Sudoers: La lectura del conjunto de reglas mediante sudo nft demuestra que el archivo inyectado en /etc/sudoers.d/ concede únicamente los privilegios de administración requeridos para auditoría de infraestructura.

Aquí puedes ver la captura de pantalla del acceso y el ruleset activo:

🛠️ Bitácora de Troubleshooting (Lecciones Aprendidas)
Durante el ciclo de desarrollo de este proyecto de infraestructura, se resolvieron dos desafíos críticos de nivel de ingeniería de sistemas:

Bug 1: Incompatibilidad de Iptables con Kernels Modernos
Problema: Al intentar aplicar reglas con iptables, el contenedor fallaba arrojando errores críticos en modprobe debido a la ausencia de módulos legados en el kernel del host moderno.

Solución: Se realizó una reingeniería del Dockerfile para purgar componentes antiguos e instalar el motor moderno de Nftables. Se reescribió por completo el script hardening.sh utilizando la sintaxis jerárquica orientada a familias de tablas (inet filter), logrando compatibilidad total y mejor rendimiento en el procesamiento de paquetes.

Bug 2: Fallo Crítico en el Demonio de OpenSSH por Parseo de Sintaxis
Problema: El contenedor se mantenía activo pero rechazaba las conexiones (Connection refused). Los logs revelaron que el demonio sshd fallaba al inicializarse.

Solución: Se identificó que sshd no tolera comentarios en la misma línea que las directivas de configuración (ej. Port 2222 # comentario). Se reestructuró la inyección del archivo sshd_config colocando los comentarios de forma aislada en líneas superiores, permitiendo un parseo limpio por parte del binario de OpenSSH.


---

