#!/bin/bash
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"
ERRORS=0

echo "=================================================="
echo "      FINAL MASTER BUILD VERIFICATION             "
echo "=================================================="

# 1. Check Packages
echo -n "[1] Packages (Drivers & SSH)... "
if grep -q "^nvidia$" packages.x86_64 && grep -q "^nvidia-utils$" packages.x86_64 && grep -q "^vulkan-mesa-layers$" packages.x86_64 && grep -q "^openssh$" packages.x86_64; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (Missing packages)${NC}"; ERRORS=$((ERRORS+1))
fi

# 2. Check UEFI Boot Config (Cowspace)
echo -n "[2] UEFI Boot Config (cow_spacesize)... "
if grep -q "cow_spacesize=16G" efiboot/loader/entries/01-archiso-linux.conf; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (Missing in UEFI config)${NC}"; ERRORS=$((ERRORS+1))
fi

# 3. Check Legacy Boot Config (Cowspace)
echo -n "[3] Legacy Boot Config (cow_spacesize)... "
if grep -q "cow_spacesize=16G" syslinux/archiso_sys-linux.cfg; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (Missing in Syslinux config)${NC}"; ERRORS=$((ERRORS+1))
fi

# 4. Check Auto-boot scripts (.bash_profile)
echo -n "[4] Auto-Boot Terminal Bypass... "
if grep -q "startx" airootfs/root/.bash_profile; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (.bash_profile missing startx)${NC}"; ERRORS=$((ERRORS+1))
fi

# 5. Check X11 Environment (.xinitrc)
echo -n "[5] X11 Environment (Big Picture)... "
if grep -q "shadPS4QtLauncher-qt.AppImage -b" airootfs/root/.xinitrc && grep -q "__NV_PRIME_RENDER_OFFLOAD" airootfs/root/.xinitrc; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (.xinitrc incorrect)${NC}"; ERRORS=$((ERRORS+1))
fi

# 6. Check System Customization (CPU & SSH)
echo -n "[6] System Customization (CPU/SSH)... "
if grep -q "scaling_governor" airootfs/root/customize_airootfs.sh && grep -q "systemctl enable sshd" airootfs/root/customize_airootfs.sh; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (customize script incomplete)${NC}"; ERRORS=$((ERRORS+1))
fi

# 7. Check Emulator AppImage
echo -n "[7] Emulator AppImage Executable... "
if [ -x "airootfs/root/shadPS4QtLauncher-qt.AppImage" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (AppImage missing or not executable)${NC}"; ERRORS=$((ERRORS+1))
fi

# 8. Check Emulator Config
echo -n "[8] Emulator Config (720p/Cache)... "
if grep -q '"pipeline_cache_enabled": true' airootfs/root/.local/share/shadPS4/config.json 2>/dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (config.json missing or wrong)${NC}"; ERRORS=$((ERRORS+1))
fi

echo "=================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL SYSTEMS GO! YOU ARE READY TO BUILD.${NC}"
else
    echo -e "${RED}🛑 $ERRORS ERRORS FOUND. FIX THEM BEFORE BUILDING.${NC}"
fi
echo "=================================================="
