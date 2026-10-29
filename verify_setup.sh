#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m"

echo "=================================================="
echo "    CUSTOM ARCH ISO - VERIFICATION SCRIPT         "
echo "=================================================="

# 1. Directory Check
if [ ! -f "profiledef.sh" ] || [ ! -f "packages.x86_64" ]; then
    echo -e "${RED}[!] CRITICAL ERROR: You are not in the Archiso profile directory.${NC}"
    echo "    Please run: cd ~/custom_arch_iso"
    exit 1
fi
echo -e "${GREEN}[+] Archiso profile directory detected.${NC}"

# 2. Package Verification
echo -e "\n--- [ Package Verification ] ---"
REQUIRED_PKGS=("nvidia" "nvidia-utils" "mesa" "vulkan-intel" "vulkan-icd-loader" "vulkan-tools" "xorg-server" "xorg-xinit")
for pkg in "${REQUIRED_PKGS[@]}"; do
    if grep -q "^$pkg$" packages.x86_64; then
        echo -e "  ${GREEN}✅ $pkg is in the ISO.${NC}"
    else
        echo -e "  ${RED}❌ $pkg is MISSING from packages.x86_64!${NC}"
    fi
done

# 3. Cross-reference with Live USB backup (installed_explicit.txt)
echo -e "\n--- [ Cross-referencing with your Live USB Backup ] ---"
# We check /mnt/p and /mnt/c/Users/ to find the P drive backup
if [ -f "/mnt/p/ArchSave/installed_explicit.txt" ]; then
    BACKUP_FILE="/mnt/p/ArchSave/installed_explicit.txt"
elif [ -f "/mnt/c/Users/Sikander/Desktop/ArchSave/installed_explicit.txt" ]; then
    BACKUP_FILE="/mnt/c/Users/Sikander/Desktop/ArchSave/installed_explicit.txt"
else
    BACKUP_FILE=""
fi

if [ -n "$BACKUP_FILE" ]; then
    echo "  Found backup at: $BACKUP_FILE"
    # Look for specific non-base packages you might have installed
    grep -E "vulkan|mesa|xorg|shadps4|nvidia" "$BACKUP_FILE" | while read -r line; do
        if ! grep -q "^$line$" packages.x86_64; then
            echo -e "  ${YELLOW}⚠️  WARNING: '$line' was in your backup but is NOT in the ISO packages list.${NC}"
        fi
    done
    echo -e "  ${GREEN}Cross-reference complete.${NC}"
else
    echo -e "  ${YELLOW}⚠️  Could not find installed_explicit.txt on P: drive. Skipping cross-reference.${NC}"
fi

# 4. Configuration Scripts
echo -e "\n--- [ Configuration Scripts ] ---"

# Check .xinitrc
if [ -f "airootfs/root/.xinitrc" ]; then
    if grep -q "shadPS4QtLauncher-qt.AppImage -b" airootfs/root/.xinitrc; then
        echo -e "  ${GREEN}✅ .xinitrc exists and launches Big Picture Mode.${NC}"
    else
        echo -e "  ${RED}❌ .xinitrc exists but does NOT launch shadPS4 Big Picture Mode.${NC}"
    fi
else
    echo -e "  ${RED}❌ MISSING: airootfs/root/.xinitrc${NC}"
fi

# Check .bash_profile
if [ -f "airootfs/root/.bash_profile" ]; then
    if grep -q "startx" airootfs/root/.bash_profile; then
        echo -e "  ${GREEN}✅ .bash_profile exists and contains auto-start (startx).${NC}"
    else
        echo -e "  ${RED}❌ .bash_profile exists but does NOT auto-start X.${NC}"
    fi
else
    echo -e "  ${RED}❌ MISSING: airootfs/root/.bash_profile${NC}"
fi

# Check customize_airootfs.sh
if [ -f "airootfs/root/customize_airootfs.sh" ]; then
    if grep -q "scaling_governor" airootfs/root/customize_airootfs.sh; then
        echo -e "  ${GREEN}✅ customize_airootfs.sh contains CPU performance tweaks.${NC}"
    else
        echo -e "  ${YELLOW}⚠️  customize_airootfs.sh is missing CPU performance tweaks.${NC}"
    fi
else
    echo -e "  ${RED}❌ MISSING: airootfs/root/customize_airootfs.sh${NC}"
fi

# 5. Emulator Binary (AppImage)
echo -e "\n--- [ Emulator Binary ] ---"
if [ -f "airootfs/root/shadPS4QtLauncher-qt.AppImage" ]; then
    if [ -x "airootfs/root/shadPS4QtLauncher-qt.AppImage" ]; then
        echo -e "  ${GREEN}✅ shadPS4QtLauncher-qt.AppImage exists and is executable.${NC}"
    else
        echo -e "  ${RED}❌ shadPS4QtLauncher-qt.AppImage exists but is NOT executable (run: chmod +x).${NC}"
    fi
else
    echo -e "  ${RED}❌ MISSING: airootfs/root/shadPS4QtLauncher-qt.AppImage (did you download it?).${NC}"
fi

echo "=================================================="
echo " Verification Complete. Review the output above. "
echo "=================================================="
