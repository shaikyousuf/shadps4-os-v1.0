startx /root/.xinitrc -- :1
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do echo performance > "$cpu" 2>/dev/null || true; done
systemctl enable sshd
