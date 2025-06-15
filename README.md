# kosher-android-tools-iso
mxlinux snapshot- with mtkclient/autobooter &amp; more

# Kosher Live ISO with mtkclient/autobooter (no Internet access)
*(and other tools, but not working 100 percent yet)*

Let me know if there are any vulnerabilities or performance issues.

# IMPORTANT: 

Your external drive will be mounted at /media/demo/your_drive. When using mtk client, go to that path to save or load.

# Included?

mtkclient

autobooter


# What doesn't work?

adb & fastboot (scrcpy included)

mounting internal drives without superuser


Below are my notes:


# What makes this kosher?

**1.** Changed root password

**2.** Removed user from /etc/sudoers (can't use sudo)

**3.** Blocked all outbound traffic for non-root users using firewall

**4.** Removed nmcli, wget, curl and ping

**5.** Removed the network icon from the panel (taskbar)

**6.** Stopped user from manually turning network interfaces back on

**7.** Removed mx-installer


**Link:**
[kosher-android-tools-1.1.iso](https://drive.google.com/drive/folders/15JVaaMVJDGimNhRS1JMXKvx8FPVbijOa)

**Password:** *demo*


# Update

I am putting aside auto-mounting internal drives. Too many issues unless I'm just missing something. External drives work fine.

# Source

[mxlinux iso](https://mxlinux.org/download-links)

**lockdown.sh**

`#!/bin/bash
# Root-only network lockdown script (hardened)
# Usage: sudo ./network-lockdown.sh [lock|unlock]

MODE="${1:-lock}"

if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Please run as root."
  exit 1
fi

lockdown() {
  echo "🔐 Applying full network lockdown (root-only)..."

  # 1. PolicyKit rule
  echo "[1/7] Setting PolicyKit rule..."
  tee /etc/polkit-1/rules.d/90-root-only-network.rules >/dev/null <<'EOF'
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.NetworkManager.enable" ||
         action.id == "org.freedesktop.NetworkManager.settings.modify.system" ||
         action.id == "org.freedesktop.NetworkManager.network-control") &&
        subject.user != "root") {
        return polkit.Result.NO;
    }
});
EOF

  # 2. Restrict binaries
  echo "[2/7] Restricting access to network tools..."
  BINS=(
    /usr/sbin/ip /usr/sbin/ifconfig /usr/bin/nmcli /usr/bin/wget
    /usr/bin/curl /usr/bin/ping /usr/bin/nmap
    /sbin/iwconfig /sbin/dhclient /sbin/wpa_supplicant
  )
  for BIN in "${BINS[@]}"; do
    if [[ -f "$BIN" ]]; then
      chmod 700 "$BIN"
      chown root:root "$BIN"
      echo "→ Restricted $BIN"
    fi
  done

  # 3. Udev rules to restrict device manipulation
  echo "[3/7] Installing udev rules..."
  tee /etc/udev/rules.d/80-network-root-only.rules >/dev/null <<'EOF'
SUBSYSTEM=="net", ACTION=="add", RUN+="/bin/chmod 600 /sys/class/net/%k/flags"
EOF
  udevadm control --reload
  udevadm trigger

  # 4. Disable NetworkManager autoconnect
  echo "[4/7] Disabling autoconnect for existing connections..."
  nmcli -t -f NAME c show | while read -r conn; do
    nmcli connection modify "$conn" connection.autoconnect no
  done

  # 5. Firewall: block all outbound for non-root
  echo "[5/7] Applying iptables outbound block (non-root)..."
  iptables -A OUTPUT -m owner ! --uid-owner 0 -j REJECT

  # 6. AppArmor: deny networking for select tools
  echo "[6/7] Installing AppArmor rules (wget, curl)..."
  for tool in wget curl; do
    PROFILE="/etc/apparmor.d/usr.bin.$tool"
    if [[ -f "/usr/bin/$tool" ]]; then
      tee "$PROFILE" >/dev/null <<EOF
#include <tunables/global>
/usr/bin/$tool {
  #include <abstractions/base>
  capability net_raw,
  deny network inet,
  deny network inet6,
  deny network raw,
  deny network packet,
}
EOF
      apparmor_parser -r "$PROFILE"
      echo "→ AppArmor locked: $tool"
    fi
  done

  # 7. Persist iptables (Debian-based)
  echo "[7/7] Saving iptables rules..."
  apt-get install -y iptables-persistent >/dev/null 2>&1 || true
  netfilter-persistent save

  echo "✅ Network is now fully restricted to root users only."
}

unlock() {
  echo "🔓 Reverting network lockdown..."

  echo "[1/7] Removing PolicyKit rule..."
  rm -f /etc/polkit-1/rules.d/90-root-only-network.rules

  echo "[2/7] Restoring tool permissions..."
  BINS=(
    /usr/sbin/ip /usr/sbin/ifconfig /usr/bin/nmcli /usr/bin/wget
    /usr/bin/curl /usr/bin/ping /usr/bin/nmap
    /sbin/iwconfig /sbin/dhclient /sbin/wpa_supplicant
  )
  for BIN in "${BINS[@]}"; do
    if [[ -f "$BIN" ]]; then
      chmod 755 "$BIN"
      echo "→ Restored $BIN"
    fi
  done

  echo "[3/7] Removing udev rules..."
  rm -f /etc/udev/rules.d/80-network-root-only.rules
  udevadm control --reload
  udevadm trigger

  echo "[4/7] Enabling autoconnect for all NetworkManager connections..."
  nmcli -t -f NAME c show | while read -r conn; do
    nmcli connection modify "$conn" connection.autoconnect yes
  done

  echo "[5/7] Removing iptables UID rule..."
  iptables -D OUTPUT -m owner ! --uid-owner 0 -j REJECT || true
  netfilter-persistent save

  echo "[6/7] Removing AppArmor restrictions..."
  for tool in wget curl; do
    PROFILE="/etc/apparmor.d/usr.bin.$tool"
    if [[ -f "$PROFILE" ]]; then
      rm -f "$PROFILE"
      apparmor_parser -R "$PROFILE" || true
      echo "→ AppArmor cleared: $tool"
    fi
  done

  echo "✅ Lockdown removed. All users can now access the Internet."
}

case "$MODE" in
  lock)   lockdown ;;
  unlock) unlock ;;
  *)
    echo "Usage: sudo $0 [lock|unlock]"
    exit 1
    ;;
esac`

**autobooter.sh**

`#!/bin/bash

# Auto elevate if not root
if [[ "$EUID" -ne 0 ]]; then
  exec sudo -H "$0" "$@"
fi

# Ensure correct PATH for the virtual environment
export PATH=/home/demo/.venv/bin:$PATH

# Activate venv (not strictly needed if PATH is set correctly)
. /home/demo/.venv/bin/activate

# Change to the script directory
cd /opt/autobooter

# Launch the Python script
./autobooter.py`
