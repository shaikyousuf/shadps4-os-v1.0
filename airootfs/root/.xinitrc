#!/bin/sh
export VK_DRIVER_FILES="/usr/share/vulkan/icd.d/nvidia_icd.json"
export VK_ICD_FILENAMES="/usr/share/vulkan/icd.d/nvidia_icd.json"
export __NV_PRIME_RENDER_OFFLOAD=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export SDL_VIDEODRIVER=x11
export MESA_VK_WSI_PRESENT_MODE=immediate
export vblank_mode=0

# Launch the UI
exec /root/shadPS4QtLauncher-qt.AppImage -b
