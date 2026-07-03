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

# 2. FIREWALL PERIMETRAL (Nftables Nativo)
echo "[+] Aplicando políticas estrictas de Firewall con Nftables (Zero-Trust)..."

# Limpiar cualquier regla previa en el kernel
nft flush ruleset

# Crear la tabla base 'filter' para tráfico unificado (IPv4/IPv6)
nft add table inet filter

# Configurar cadenas y establecer política DROP por defecto (Bloquear Entrada y Reenvío)
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

# Permitir tráfico local en la interfaz de loopback
nft add rule inet filter input iif lo accept

# Mantener vivas conexiones establecidas y relacionadas
nft add rule inet filter input ct state established,related accept

# ABRIR ÚNICAMENTE EL PUERTO SSH SEGURO (2222)
nft add rule inet filter input tcp dport 2222 accept

echo "[✔] Firewall Nftables configurado. Matriz de reglas activas:"
nft list ruleset

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