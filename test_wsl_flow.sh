#!/bin/bash
echo "=================================================="
echo "      WSL BOOT-FLOW & UI LAUNCH TEST              "
echo "=================================================="

# Simulate the /usr/bin path for WSL
export PATH="$(pwd)/airootfs/usr/bin:$PATH"
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/lvp_icd.x86_64.json"
export SDL_VIDEODRIVER=x11

echo "Launching QtLauncher UI in 3 seconds..."
sleep 3

# Launch the UI
./airootfs/root/shadPS4QtLauncher-qt.AppImage -b
