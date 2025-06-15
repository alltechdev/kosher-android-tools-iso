# kosher-android-tools-iso
mxlinux snapshot- with mtkclient/autobooter &amp; more

_(part of the lockdown script is not necessary anymore, as I removed wget, curl, nmcli, and ping from /usr/bin. Will edit later)_

My ideas, scripts written using AI.

# Source

[mxlinux iso](https://mxlinux.org/download-links)

# Kosher Live ISO with mtkclient/autobooter (no Internet access)
*(and other tools, but not working 100 percent yet)*

Let me know if there are any vulnerabilities or performance issues.

# IMPORTANT: 

Your external drive will be mounted at /media/demo/your_drive. When using mtk client, go to that path to save or load.

# Included

mtkclient

autobooter


# Not Working

adb & fastboot (scrcpy included)

mounting internal drives without superuser


Below are my notes:


# What makes this kosher?

**1.** Changed root password

**2.** Removed user from /etc/sudoers (can't use sudo)

**3.** Blocked all outbound traffic for non-root users using firewall

**4.** Removed nmcli, wget, curl and ping

**5.** Removed the network icon from the panel (taskbar) (nm-applet)

**6.** Stopped user from manually turning network interfaces back on

**7.** Removed mx-installer


# **Password:** *demo*


# Update

I am putting aside auto-mounting internal drives. Too many issues unless I'm just missing something. External drives work fine.


