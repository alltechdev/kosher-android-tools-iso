# Kosher Live ISO with mtkclient/autobooter/ADB & Fastboot/SCRCPY (no Internet access)

Made using mxlinux snapshot to iso.

Let me know if there are any vulnerabilities or performance issues.


# What works? 

- ADB/Fastboot
- SCRCPY
- mtkclient
- autobooter
- using external drives


# What doesn't work?
- mounting internal drives without superuser


Below are my notes:


# Here's what I got so far

**1.** Changed root password

**2.** Removed user from /etc/sudoers (can't use sudo)

**3.** Blocked all outbound traffic for non-root users using firewall

**4.** removed nmcli, wget, curl and ping

**5.** Removed the network icon from the panel (taskbar)

**6.** Stopped user from manually turning network interfaces back on

**7.** Auto elevate autobooter to use without sudo

**8.** Added iptables rule to allow ADB/Fastboot/SCRCPY


**Password:** *demo*



I am putting aside auto-mounting internal drives. Too many issues unless I'm just missing something. External drives work fine.

https://github.com/alltechdev/kosher-android-tools-iso
