# Windows SSH

This runbook covers two related Windows SSH tasks:

- using a Windows PC as the SSH client so the same shortcuts work there as on the Mac
- enabling OpenSSH Server on a Windows host and allowing key-based login for administrative access

The recommended setup is:

- one shared Windows admin key on the Mac: `~/.ssh/windows-admin_ed25519`
- one SSH alias per Windows server in `~/.ssh/config`
- the public key installed in `C:\ProgramData\ssh\administrators_authorized_keys`

This keeps Windows access separate from Linux and Hetzner keys while still making it easy to manage multiple Windows servers.

## SSH Shortcuts On A Windows PC

To keep working from an office Windows machine, recreate the same SSH aliases there with the built-in OpenSSH client.

The Windows OpenSSH client reads:

```text
C:\Users\<your-windows-user>\.ssh\config
```

and private keys from the same `.ssh` folder.

### 1. Confirm OpenSSH Client Is Available

Open PowerShell and run:

```powershell
ssh -V
```

If `ssh` is not available, install the optional Windows feature:

```powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

### 2. Create The SSH Folder

In PowerShell:

```powershell
New-Item -ItemType Directory -Force "$HOME\.ssh"
```

### 3. Copy Your Existing Private Keys To Windows

For each alias you want to keep using, copy the matching private key into:

```text
C:\Users\<your-windows-user>\.ssh\
```

Typical examples:

```text
C:\Users\<your-windows-user>\.ssh\exchange3_ed25519
C:\Users\<your-windows-user>\.ssh\file_ed25519
```

Recommended source:

- copy the private key contents from Bitwarden if you already stored them there
- otherwise copy them securely from the current Mac and remove any temporary plaintext copies afterwards

Do not commit private keys into this repository.

### 4. Create The Windows SSH Config

Create or edit:

```text
C:\Users\<your-windows-user>\.ssh\config
```

Minimal example:

```text
Host exchange3
    HostName YOUR_EXCHANGE3_HOST_OR_IP
    User YOUR_USERNAME
    IdentityFile ~/.ssh/exchange3_ed25519
    IdentitiesOnly yes

Host file
    HostName YOUR_FILE_HOST_OR_IP
    User YOUR_USERNAME
    IdentityFile ~/.ssh/file_ed25519
    IdentitiesOnly yes
```

If both aliases use the same key, that is also fine:

```text
Host exchange3
    HostName YOUR_EXCHANGE3_HOST_OR_IP
    User YOUR_USERNAME
    IdentityFile ~/.ssh/office_admin_ed25519
    IdentitiesOnly yes

Host file
    HostName YOUR_FILE_HOST_OR_IP
    User YOUR_USERNAME
    IdentityFile ~/.ssh/office_admin_ed25519
    IdentitiesOnly yes
```

The easiest way to avoid mistakes is:

1. inspect the matching `Host` blocks on the current Mac
2. copy the same values into the Windows `config`
3. make sure the `IdentityFile` path matches the key name you copied onto the Windows PC

From the Mac, you can inspect the existing alias blocks with:

```bash
sed -n '/^Host exchange3$/,/^Host /p' ~/.ssh/config
sed -n '/^Host file$/,/^Host /p' ~/.ssh/config
```

### 5. Lock Down Key Permissions If Needed

Windows OpenSSH is usually happy with files created in your own profile, but if it complains about permissions, run:

```powershell
icacls "$HOME\.ssh" /inheritance:r
icacls "$HOME\.ssh" /grant "$env:USERNAME:(OI)(CI)F"
icacls "$HOME\.ssh\exchange3_ed25519" /inheritance:r
icacls "$HOME\.ssh\exchange3_ed25519" /grant "$env:USERNAME:F"
icacls "$HOME\.ssh\file_ed25519" /inheritance:r
icacls "$HOME\.ssh\file_ed25519" /grant "$env:USERNAME:F"
```

Adjust filenames if you use different key names.

### 6. Test The Shortcuts

From PowerShell or Windows Terminal:

```powershell
ssh exchange3
ssh file
```

Or force key-only authentication while testing:

```powershell
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no exchange3
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no file
```

### Notes For Moving Between Macs And Windows PCs

- the alias names can stay exactly the same across both machines
- the host, user, and port values should match your working Mac setup
- the private keys do not need to have the same absolute path, but the `IdentityFile` in each machine's SSH config must match the local filename
- if you keep the keys in Bitwarden, Windows setup is mostly just "restore private key, restore `config`, test with `ssh <alias>`"

## Public Key On This Mac

The shared Windows admin public key currently lives here:

```text
~/.ssh/windows-admin_ed25519.pub
```

To inspect it on the Mac:

```bash
cat ~/.ssh/windows-admin_ed25519.pub
```

To copy it to the macOS clipboard:

```bash
pbcopy < ~/.ssh/windows-admin_ed25519.pub
```

## Enable OpenSSH Server

Run this in elevated PowerShell on the Windows server:

```powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

New-NetFirewallRule -Name sshd-In-TCP `
  -DisplayName "OpenSSH Server (sshd)" `
  -Enabled True `
  -Direction Inbound `
  -Protocol TCP `
  -Action Allow `
  -LocalPort 22
```

Verify:

```powershell
Get-Service sshd
Test-NetConnection -ComputerName localhost -Port 22
```

Expected:

- `Status : Running`
- `TcpTestSucceeded : True`

## Install The Admin Key

For administrative accounts on Windows, OpenSSH commonly uses:

```text
C:\ProgramData\ssh\administrators_authorized_keys
```

First confirm the active OpenSSH behavior:

```powershell
Get-Content C:\ProgramData\ssh\sshd_config |
  Select-String "AuthorizedKeysFile|Match Group administrators" -Context 0,3
```

If the config contains `Match Group administrators`, install the key here:

```powershell
Set-Content -Path C:\ProgramData\ssh\administrators_authorized_keys -Value 'PASTE_WINDOWS_ADMIN_PUBLIC_KEY_HERE'

icacls C:\ProgramData\ssh\administrators_authorized_keys /inheritance:r
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant *S-1-5-32-544:F
icacls C:\ProgramData\ssh\administrators_authorized_keys /grant SYSTEM:F

Restart-Service sshd
```

The SID `*S-1-5-32-544` is used instead of the localized Administrators group name so this works on non-English Windows installations too.

Optional permission check:

```powershell
icacls C:\ProgramData\ssh\administrators_authorized_keys
```

## Verify From The Mac

Test key-only login from the Mac:

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no <alias>
```

Or with the configured aliases:

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no win-pdc
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no win-bdc
```

Successful output should log in directly without prompting for a password.

## Current Aliases

The current Mac SSH config includes:

```text
Host win-pdc
    HostName 192.168.1.5
    User Administrateur
    IdentityFile ~/.ssh/windows-admin_ed25519
    IdentitiesOnly yes

Host win-bdc
    HostName 192.168.1.4
    User Administrateur
    IdentityFile ~/.ssh/windows-admin_ed25519
    IdentitiesOnly yes
```

## Notes

- administrative Windows SSH access is currently shared across Windows servers with one dedicated key
- this runbook intentionally uses the public key from `~/.ssh/windows-admin_ed25519.pub` but does not store the key contents in this repository
- for future Windows servers, repeat the same setup and then add a new SSH alias on the Mac
