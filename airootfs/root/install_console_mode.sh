#!/bin/bash
set -euo pipefail

echo "=================================================="
echo "    INITIALIZING CONSOLE MODE ON NVME DRIVE       "
echo "=================================================="

# 1. Mount the P: drive (GAMES) to grab the backup
mkdir -p /mnt/p
if ! mountpoint -q /mnt/p; then
    echo "[+] Mounting P Drive..."
    mount -t ntfs3 /dev/nvme0n1p6 /mnt/p || mount -t ntfs /dev/nvme0n1p6 /mnt/p || { echo "❌ Failed to mount P drive"; exit 1; }
fi

# 2. Install the Proprietary NVIDIA Drivers
echo "[+] Installing NVIDIA Drivers (this requires internet)..."
pacman -S --noconfirm --needed nvidia nvidia-utils

# 3. Copy UI Scripts
echo "[+] Restoring Console UI Scripts..."
cp /mnt/p/ArchSave/configs/.xinitrc /root/
chmod +x /root/.xinitrc

# Create .bash_profile to auto-start X
cat > /root/.bash_profile << PROFILE
if [ -z "\$DISPLAY" ] && [ "\$(tty)" = "/dev/tty1" ]; then
    # Force CPU Performance
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "\$cpu" 2>/dev/null || true; done
    exec startx /root/.xinitrc -- :1
fi
PROFILE

# 4. Copy shadPS4 Configs
echo "[+] Restoring shadPS4 Configs..."
mkdir -p /root/.local/share/shadPS4
cp /mnt/p/ArchSave/configs/shadPS4/config.json /root/.local/share/shadPS4/

# 5. Download/Copy the Emulator
echo "[+] Setting up shadPS4 AppImage..."
if [ -f "/mnt/p/ArchSave/root_home/shadPS4QtLauncher-qt.AppImage" ]; then
    cp /mnt/p/ArchSave/root_home/shadPS4QtLauncher-qt.AppImage /root/
else
    wget https://github.com/shadps4-emu/shadps4-qtlauncher/releases/latest/download/shadPS4QtLauncher-qt.AppImage -O /root/shadPS4QtLauncher-qt.AppImage
fi
chmod +x /root/shadPS4QtLauncher-qt.AppImage

# 6. Enable SSH
echo "[+] Enabling SSH..."
systemctl enable sshd

# 7. Unmount P Drive
echo "[+] Unmounting P Drive..."
umount /mnt/p

echo "=================================================="
echo " ✅ CONSOLE MODE INSTALLED SUCCESSFULLY!"
echo " Type 'reboot' to boot directly into the UI."
echo "=================================================="
