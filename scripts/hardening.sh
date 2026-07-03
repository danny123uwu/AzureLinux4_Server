#!/bin/bash

echo "======================================================="
echo " Bastionado del Sistema - Azure Linux 4.0 (Preview)    "
echo "======================================================="

groupadd -f sysadmins

if ! id -u operador >/dev/null 2>&1; then
    useradd -m -s /bin/bash -g sysadmins operador
    echo "operador:PasswordSeguro123" | chpasswd
fi

echo "%sysadmins ALL=(ALL:ALL) ALL" > /etc/sudoers.d/sysadmins

nft flush ruleset
nft add table inet filter
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }
nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }
nft add chain inet filter output { type filter hook output priority 0 \; policy accept \; }

nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 2222 accept

echo "[✔] Firewall Nftables configurado. Matriz de reglas activas:"
nft list ruleset

cat << EOF > /etc/ssh/sshd_config
Port 2222
PermitRootLogin no          
MaxAuthTries 3              
PubkeyAuthentication yes    
PasswordAuthentication yes  
AllowGroups sysadmins       
X11Forwarding no            
EOF

echo "[✔] Hardening automatizado completado con éxito."
echo "======================================================="