# CIS / ANSSI-BP-028 Controls Reference

## SSH Hardening (/etc/ssh/sshd_config)

```text
# Authentication
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
MaxSessions 4
LoginGraceTime 60
PermitEmptyPasswords no

# Protocol
Protocol 2
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no

# Crypto (ANSSI-BP-028 compliant)
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Logging
LogLevel VERBOSE
SyslogFacility AUTH

# Timeouts
ClientAliveInterval 300
ClientAliveCountMax 2

# Access control
AllowGroups sshusers
```

## Kernel Parameters (/etc/sysctl.d/99-hardening.conf)

```ini
# Network stack hardening
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1

# IPv6 (disable if not used)
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Kernel hardening
kernel.randomize_va_space = 2
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 2
kernel.perf_event_paranoid = 3
kernel.unprivileged_bpf_disabled = 1
kernel.sysrq = 0

# Filesystem hardening
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
```

## Filesystem Mounts (/etc/fstab hardening)

```text
# Separate partitions with mount options
/tmp        tmpfs   defaults,noexec,nosuid,nodev    0 0
/var/tmp    /tmp    none    bind,noexec,nosuid,nodev 0 0
/dev/shm    tmpfs   defaults,noexec,nosuid,nodev    0 0
/home       ext4    defaults,nosuid,nodev            0 2
/var/log    ext4    defaults,nosuid,nodev,noexec     0 2
/var/log/audit ext4 defaults,nosuid,nodev,noexec     0 2
```

## Audit Rules (/etc/audit/rules.d/)

```bash
# Time change
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change

# User/group changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Network configuration
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale

# Login monitoring
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/wtmp -p wa -k logins
-w /var/log/btmp -p wa -k logins

# Sudo usage
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

# Privileged commands (auto-generate with find)
# find / -xdev -type f -perm /6000 2>/dev/null | awk '{print "-a always,exit -F path="$1" -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged"}'

# File deletion by users
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete

# Kernel module loading
-w /sbin/insmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-w /sbin/rmmod -p x -k modules
-a always,exit -F arch=b64 -S init_module -S delete_module -k modules

# Make audit configuration immutable (must be last)
-e 2
```

## PAM Configuration (/etc/pam.d/)

```bash
# Password complexity (pam_pwquality)
# /etc/security/pwquality.conf
minlen = 14
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 3
maxclassrepeat = 4
minclass = 4
dictcheck = 1
enforcing = 1

# Account lockout (pam_faillock)
# /etc/security/faillock.conf
deny = 5
fail_interval = 900
unlock_time = 600
```

## SELinux (RHEL/AlmaLinux)

```bash
# Verify enforcing
getenforce  # Must return "Enforcing"
sestatus    # Detailed status

# Set to enforcing permanently
sed -i 's/SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Common troubleshooting
ausearch -m AVC -ts recent          # Find denials
sealert -a /var/log/audit/audit.log # Analyze denials
semanage port -l                     # List port labels
semanage fcontext -l                 # List file contexts
restorecon -Rv /path                 # Restore contexts
```

## Windows Security Baseline (Key GPO Settings)

```powershell
# Account Policies
# Minimum password length: 14
# Password complexity: Enabled
# Account lockout threshold: 5
# Account lockout duration: 30 minutes
# Maximum password age: 60 days

# Audit Policy (via auditpol)
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"Credential Validation" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable

# Disable unnecessary services
Set-Service -Name "Spooler" -StartupType Disabled
Set-Service -Name "RemoteRegistry" -StartupType Disabled
Set-Service -Name "lltdsvc" -StartupType Disabled

# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow
```

## ANSSI-BP-028 Specific (Beyond CIS)

| Control | Requirement |
| --------- | ------------- |
| R1 | Minimize installed packages |
| R5 | Dedicated partitions (/tmp, /var, /var/log, /home) |
| R8 | Disable USB storage (`blacklist usb-storage` in modprobe.d) |
| R11 | Configure AIDE file integrity monitoring |
| R28 | Restrict cron to authorized users only |
| R30 | Configure banner (/etc/issue, /etc/issue.net) |
| R67 | Enable IOMMU for DMA protection |
| R68 | Restrict kernel module loading at runtime |
