# WatchGuard SFTP Forwarding For Duplicati FC1

This runbook documents the WatchGuard rule used to let `format-cloud-1` send encrypted Duplicati backups to the Synology NAS over SFTP.

Last verified: 2026-04-18.

## Purpose

Duplicati on `format-cloud-1` uses SFTP to write backup archives to the on-prem Synology NAS. Because the NAS is behind the WatchGuard T45, the firewall must allow a narrowly scoped inbound SFTP path from the Hetzner host to the Synology.

## Desired Traffic Flow

```text
format-cloud-1 -> WatchGuard WAN TCP/22 -> Synology NAS TCP/22 -> SFTP user FormatBU
```

The SFTP service is used only as the transport. Backup contents are encrypted by Duplicati before upload.

## Firewall Rule Requirements

The WatchGuard rule should be as narrow as possible:

```text
Source: format-cloud-1 public IP only
Destination: WatchGuard WAN address
External port: TCP/22
Internal target: Synology NAS private IP, TCP/22
Protocol: TCP
Users: not applicable at firewall layer
Logging: enabled, at least for denies and initial verification
```

Do not allow inbound SFTP from `Any-External` unless temporarily troubleshooting. The rule should be restricted to the Hetzner host IP used by `format-cloud-1`.

The exact public IPs and firewall object names are intentionally not stored in this public repository. Keep those details in Bitwarden or WatchGuard configuration management.

## Synology Side

Synology account:

```text
FormatBU
```

Destination folder:

```text
/FORMATBF/duplicati/format-cloud-1
```

SSH public keys are stored in:

```text
/var/services/homes/FormatBU/.ssh/authorized_keys
```

The account does not need shell login. SFTP key-based access is sufficient.

## Hetzner Side

Private key path on `format-cloud-1`:

```text
/root/.ssh/duplicati_synology_backup_ed25519
```

Manual connectivity test from `format-cloud-1`:

```bash
sftp -i /root/.ssh/duplicati_synology_backup_ed25519 -o IdentitiesOnly=yes -P 22 FormatBU@<watchguard-wan-host-or-ip>
```

Expected result:

```text
Connected to <watchguard-wan-host-or-ip>.
sftp>
```

If the command asks for a password, check the Synology `authorized_keys` file, key permissions, and whether the Duplicati/Hetzner public key is installed for the correctly cased `FormatBU` user.

## Duplicati Destination

The Duplicati job uses the Synology SFTP destination and the mounted private key inside the container:

```text
Key inside container: /sshkeys/synology_backup_ed25519
Remote path: /FORMATBF/duplicati/format-cloud-1
```

The exact destination URL is part of the Duplicati job configuration and encrypted config export, but sensitive endpoint details should be kept in Bitwarden rather than committed here.

## Verification Checklist

After WatchGuard changes, verify:

```bash
sftp -i /root/.ssh/duplicati_synology_backup_ed25519 -o IdentitiesOnly=yes -P 22 FormatBU@<watchguard-wan-host-or-ip>
```

Then from the Duplicati UI:

- test the SFTP destination
- run a small backup or confirm the latest scheduled run
- confirm files appear under `/FORMATBF/duplicati/format-cloud-1`
- run a small file restore test

## Security Notes

- Restrict the WatchGuard SFTP rule to `format-cloud-1` only.
- Prefer SSH key authentication; do not rely on password auth for the backup path.
- Keep the Synology `FormatBU` user limited to the backup share/folder.
- Keep Duplicati backup encryption enabled.
- Store Duplicati passphrase, SMTP password, Synology password, and firewall details in Bitwarden.
- Consider replacing public SFTP forwarding with a site-to-site VPN later if the environment grows.

## Troubleshooting

If SFTP fails from Hetzner:

1. Check WatchGuard traffic monitor for denied TCP/22 traffic from `format-cloud-1`.
2. Confirm the rule source is the current Hetzner public IP.
3. Confirm Synology SSH/SFTP is enabled.
4. Confirm the destination folder exists and `FormatBU` has write access.
5. Confirm `/var/services/homes/FormatBU/.ssh/authorized_keys` contains the Hetzner public key.
6. Confirm ownership and permissions:

```bash
sudo chown -R FormatBU:users /var/services/homes/FormatBU/.ssh
sudo chmod 700 /var/services/homes/FormatBU/.ssh
sudo chmod 600 /var/services/homes/FormatBU/.ssh/authorized_keys
```

If normal `ssh FormatBU@...` fails but `sftp FormatBU@...` works, that is acceptable. The account can be SFTP-only for this use case.
