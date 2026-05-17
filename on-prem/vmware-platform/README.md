# VMware Platform Runbook

Runbook for ESXi 8.x host and vCenter maintenance that sits above the
per-VM maintenance threads.

Last updated: 2026-05-03

## Scope

Use this folder for VMware platform work:

- ESXi host access and health checks
- vCenter Server Appliance access and health checks
- vSphere 8 security advisory review
- host/vCenter backup and recovery checks
- licensing and patch entitlement notes

Do not use this folder for normal guest VM maintenance. Guest VM work remains in
the matching `on-prem/esx-*/<vm>/` folder.

## Known Platform Entries

| System | Known address | Suggested SSH alias | Notes |
| --- | --- | --- | --- |
| ESX-D host | `192.168.5.203` | `esx-d-host` | ESXi 8.x host, visible in vCenter as `192.168.5.203`. |
| ESX-E host | `192.168.5.205` | `esx-e-host` | ESXi 8.x host for the Veeam VM. |
| vCenter Server Appliance | `192.168.5.15` | `vcenter` | VM named `VMware vCenter Server` on ESX-D. |

## Safety Rules

- Keep ESXi and vCenter SSH disabled except during a documented maintenance
  window or active troubleshooting session.
- Prefer vSphere Client, VAMI, and APIs for routine management.
- Do not reboot hosts, restart management agents, enter maintenance mode,
  change lockdown mode, alter certificates, or patch ESXi/vCenter without an
  explicit maintenance decision.
- Do not edit ESXi `/etc/ssh/sshd_config`; ESXi 8.0.2 and later use supported
  `esxcli system ssh server config` settings for SSH server options.
- Do not commit private keys, license keys, support portal data, screenshots
  with secrets, host UUIDs if sensitive, or unredacted customer data.

## SSH Login Path For ESXi 8 Hosts

This path creates a key-based local SSH alias for the ESXi host. Use it only
after confirming the host, management IP, and root password in the password
manager.

### 1. Create A Dedicated Local Key

Use one RSA 4096 key per ESXi host. Do not use Ed25519 for ESXi host login:
Broadcom documents that `ssh-ed25519` is not supported for ESXi SSH.

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/esx-d-host_rsa -C esx-d-host -N ""
```

For ESX-E, use:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/esx-e-host_rsa -C esx-e-host -N ""
```

Expected local SSH config for ESX-E, because VCSA `ProxyJump` is currently
blocked:

```sshconfig
Host esx-e-host
    HostName 192.168.5.205
    User root
    IdentityFile ~/.ssh/esx-e-host_rsa
    IdentitiesOnly yes
```

### 2. Temporarily Enable SSH On The ESXi Host

Preferred path from vCenter:

1. Open the vSphere Client.
2. Select the ESXi host.
3. Go to `Configure` -> `System` -> `Services`.
4. Select `SSH`.
5. Click `Start`.

Avoid changing the startup policy to start with the host unless there is a
clear operational reason.

### 3. Install The Public Key On ESXi

For root login on ESXi, the key file is not the normal Linux path. Use
`/etc/ssh/keys-root/authorized_keys`.

```bash
cat ~/.ssh/esx-d-host_rsa.pub | ssh root@192.168.5.203 '
  umask 077
  mkdir -p /etc/ssh/keys-root
  touch /etc/ssh/keys-root/authorized_keys
  key=$(cat)
  grep -qxF "$key" /etc/ssh/keys-root/authorized_keys || printf "%s\n" "$key" >> /etc/ssh/keys-root/authorized_keys
'
```

### 4. Add The Local SSH Alias

Add this block to `~/.ssh/config`:

```sshconfig
Host esx-d-host
    HostName 192.168.5.203
    User root
    IdentityFile ~/.ssh/esx-d-host_rsa
    IdentitiesOnly yes
```

Then test:

```bash
ssh esx-d-host 'vmware -vl; hostname; esxcli system version get'
```

### 5. Record Fingerprints And Disable SSH

Record the public key fingerprint in the maintenance log:

```bash
ssh-keygen -lf ~/.ssh/esx-d-host_rsa.pub
```

When finished, stop SSH from vCenter:

1. Select the ESXi host.
2. Go to `Configure` -> `System` -> `Services`.
3. Select `SSH`.
4. Click `Stop`.

Confirm from your workstation:

```bash
ssh -o ConnectTimeout=5 esx-d-host true
```

This should fail once the service is stopped.

## SSH Login Path For vCenter Server Appliance

vCenter SSH is separate from ESXi SSH. Use it only when VAMI/API/UI access is
not enough.

If `ssh vcenter` already works for `192.168.5.15`, use that existing path
instead of creating a new key. The VCSA can be used as a convenient control
point because it sits on the same management network as the ESXi hosts.

### 1. Enable SSH Temporarily

Preferred path:

1. Open `https://<vcenter-fqdn-or-ip>:5480`.
2. Log in to the vCenter Server Appliance Management Interface.
3. Go to `Access`.
4. Enable `SSH Login`.
5. Enable shell only if the maintenance task requires Bash access.

Fallback from the VM console:

```text
appliancesh
ssh.get
ssh.set --enabled true
exit
```

### 2. Create A Dedicated Local Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/vcenter_ed25519 -C vcenter -N ""
```

### 3. Install The Public Key

VCSA root uses the normal appliance root home path:

```bash
cat ~/.ssh/vcenter_ed25519.pub | ssh root@<vcenter-fqdn-or-ip> '
  umask 077
  mkdir -p ~/.ssh
  touch ~/.ssh/authorized_keys
  key=$(cat)
  grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys
'
```

### 4. Add The Local SSH Alias

```sshconfig
Host vcenter
    HostName 192.168.5.15
    User root
    IdentityFile ~/.ssh/vcenter_ed25519
    IdentitiesOnly yes
```

Test:

```text
ssh vcenter
system.version.get
logout
```

When finished, disable SSH again in VAMI or run:

```text
ssh.set --enabled false
```

from the appliance shell.

## Using VCSA As A Control Point

VCSA access helps in three ways:

- inspect vCenter appliance health directly
- inspect vSphere inventory through the vSphere Client, VAMI, or API
- test network reachability from VCSA to the ESXi management addresses

VCSA access does not automatically provide ESXi shell access. ESXi root
credentials or an existing ESXi key are still required to install host SSH keys.

From the VCSA shell, first identify reachable ESXi management addresses without
changing anything:

```text
ssh vcenter
shell
for host in 192.168.5.203 <esx-c-ip> <esx-e-ip>; do
  echo "== $host =="
  ping -c 2 "$host"
  nc -zvw3 "$host" 443
  nc -zvw3 "$host" 22
done
exit
logout
```

Port `443` confirms the host management API is reachable. Port `22` only
confirms SSH is currently listening; it may be closed when SSH is stopped.

If host SSH is not running, start it from the vSphere Client:

1. Open `https://192.168.5.15/ui`.
2. Select the ESXi host.
3. Go to `Configure` -> `System` -> `Services`.
4. Select `SSH`.
5. Click `Start`.

Then install the ESXi public key either directly from your workstation or
through VCSA as an SSH jump point.

Directly from the workstation:

```bash
cat ~/.ssh/esx-d-host_rsa.pub | ssh root@192.168.5.203 '
  umask 077
  mkdir -p /etc/ssh/keys-root
  touch /etc/ssh/keys-root/authorized_keys
  key=$(cat)
  grep -qxF "$key" /etc/ssh/keys-root/authorized_keys || printf "%s\n" "$key" >> /etc/ssh/keys-root/authorized_keys
'
```

Via VCSA as the network jump point, only if VCSA allows SSH TCP forwarding:

```bash
cat ~/.ssh/esx-d-host_rsa.pub | ssh -J vcenter root@192.168.5.203 '
  umask 077
  mkdir -p /etc/ssh/keys-root
  touch /etc/ssh/keys-root/authorized_keys
  key=$(cat)
  grep -qxF "$key" /etc/ssh/keys-root/authorized_keys || printf "%s\n" "$key" >> /etc/ssh/keys-root/authorized_keys
'
```

If this fails with:

```text
channel 0: open failed: administratively prohibited: open failed
stdio forwarding failed
```

then VCSA is blocking SSH TCP forwarding. Do not change VCSA SSH daemon policy
just for convenience. Use direct workstation-to-ESXi SSH, or log into VCSA
interactively, launch `shell`, and SSH from VCSA to the ESXi host.

Prefer the direct workstation path when it works. Use the VCSA jump path only
when the ESXi management network is reachable from VCSA but not from the
workstation.

After key installation, the permanent local alias can also use VCSA as a jump
only when forwarding is allowed:

```sshconfig
Host esx-d-host
    HostName 192.168.5.203
    User root
    IdentityFile ~/.ssh/esx-d-host_rsa
    IdentitiesOnly yes
    ProxyJump vcenter
```

## First Read-Only Platform Checks Over SSH

For an ESXi host:

```bash
ssh esx-d-host 'vmware -vl'
ssh esx-d-host 'esxcli system version get'
ssh esx-d-host 'esxcli hardware platform get'
ssh esx-d-host 'esxcli storage filesystem list'
ssh esx-d-host 'esxcli network ip interface ipv4 get'
ssh esx-d-host 'vim-cmd hostsvc/hostsummary'
```

For vCenter:

```text
ssh vcenter
system.version.get
system.health.get
shell
df -h
exit
logout
```

Record only sanitized results in [maintenance-log.md](maintenance-log.md).

## Add ESXi SSH Key Through vCenter PowerCLI

Use this when an ESXi host is connected to vCenter but direct SSH command
execution or console paste is not practical.

From PowerShell with VMware PowerCLI installed:

```powershell
Connect-VIServer -Server 192.168.5.15

$vmhost = Get-VMHost -Name "192.168.5.201"
$pubkey = (Get-Content "$HOME/.ssh/esx-c-host_rsa.pub" -Raw).Trim()
$esxcli = Get-EsxCli -VMHost $vmhost -V2

$esxcli.system.ssh.key.add.Invoke(@{
    username = "root"
    authkey = $pubkey
})

$esxcli.system.ssh.key.list.Invoke(@{
    username = "root"
})

Disconnect-VIServer -Server 192.168.5.15 -Confirm:$false
```

Then test from the Mac:

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no esx-c-host
```

If the installed PowerCLI version reports different argument names, inspect the
method help:

```powershell
$esxcli.system.ssh.key.add.Help()
$esxcli.system.ssh.key.list.Help()
```

## Patch And Entitlement Notes

- vSphere 8.x is the supported line to monitor for current vSphere security
  advisories.
- With expired Support and Subscription, normal Broadcom Support Portal access
  to new patches, security updates, and major/minor releases may be restricted.
- Broadcom documents a critical security patch exception for supported vSphere
  8.x perpetual-license customers with expired support contracts. Treat that as
  emergency security patch access only, not as a general upgrade path.

## Files

- [maintenance-log.md](maintenance-log.md): ongoing VMware platform maintenance
  history
