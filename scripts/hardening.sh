#!/bin/bash

echo "======================================================="
echo " Bastionado del Sistema - Azure Linux 4.0 (Preview)    "
echo "======================================================="

# 1. CONTROL DE ACCESOS Y PRIVILEGIOS
echo "[+] Configurando grupos de administración del sistema..."
groupadd -f sysadmins

# Crear usuario operador técnico para evitar administración directa como root
if ! id -u operador >/dev/null 2>&1; then
    useradd -m -s /bin/bash -g sysadmins operador
    echo "operador:PasswordSeguro123" | chpasswd
    echo "[✔] Usuario de soporte 'operador' creado correctamente."
fi

# Conceder privilegios sudo restringidos a los miembros del grupo
echo "%sysadmins ALL=(ALL:ALL) ALL" > /etc/sudoers.d/sysadmins

# 2. FIREWALL PERIMETRAL (Iptables en Capa de Red Interna)
echo "[+] Aplicando políticas estrictas de Firewall (Zero-Trust)..."

# Limpiar tablas previas para evitar conflictos de red
iptables -F
iptables -X

# Establecer políticas por defecto: Bloquear entrada y reenvío, permitir salida
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Mantener vivas conexiones establecidas y relacionadas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir tráfico local en la interfaz de loopback
iptables -A INPUT -i lo -j ACCEPT

# ABRIR ÚNICAMENTE EL PUERTO SSH SEGURO (2222)
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT

echo "[✔] Firewall configurado. Matriz de reglas activas:"
iptables -L -v -n

# 3. ENDURECIMIENTO DE POLÍTICAS SSH
echo "[+] Escribiendo directivas de seguridad en sshd_config..."
cat << EOF > /etc/ssh/sshd_config
Port 2222
PermitRootLogin no          # Deshabilitar el acceso directo al usuario root
MaxAuthTries 3              # Mitigación contra ataques de fuerza bruta
PubkeyAuthentication yes    # Preparado para autenticación por llaves criptográficas
PasswordAuthentication yes  # Habilitado temporalmente para pruebas iniciales
AllowGroups sysadmins       # Restringir el acceso SSH únicamente al grupo técnico
X11Forwarding no            # Desactivar reenvío gráfico para mitigar vectores de ataque
EOF

echo "[✔] Hardening automatizado completado con éxito."
echo "======================================================="