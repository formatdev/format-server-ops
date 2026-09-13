# ESST Maintenance - 2026-09-13

Scope: the four servers.com ESST servers. Format/Hetzner hosts are separate.

## Host Work

Maintenance completed sequentially, workers first and the sole manager last. Cloud-3
was serviced before cloud-2 because cloud-2 was compressing the scheduled
production monitoring database backup.

| Host | Status | Kernel | Docker | Root disk |
| --- | --- | --- | --- | --- |
| esst-cloud-1 | Updated, rebooted, Ready | 6.8.0-139 | 29.8.0 | 57%, 47G free |
| esst-cloud-2 | Updated, rebooted, Ready | 6.8.0-139 | 29.8.0 | 86%, 25G free |
| esst-cloud-3 | Updated, rebooted, Ready | 6.8.0-139 | 29.8.0 | 50%, 38G free |
| esst-cloud-4 | Updated, rebooted, Leader | 6.8.0-139 | 29.8.0 | 39%, 56G free |

The standard apt upgrade installed 23 packages per host, including Docker Engine
and CLI 29.8.0, containerd 2.3.5, Buildx 0.37.1, Compose 5.5.1, snapd and Ubuntu
updates. The newer kernel was already installed before this round.

`fwupd` and `linux-firmware` are kept back by ordinary apt upgrade. A simulated
explicit upgrade on cloud-1 showed new dependencies and a split into multiple
hardware firmware packages. This transition was not forced.

All four hosts had zero failed systemd units before maintenance. UFW is
inactive and fail2ban is not installed on all four. This is observed existing
configuration, not evidence about custom iptables or provider firewall coverage.
The initial host-maintenance pass did not change firewall rules. The subsequent
firewall restoration below supersedes that initial state. SSH authentication,
application data and database retention settings were not changed.

## Post-Restart Firewall Correction

Following Ivan's report, inspection confirmed all custom SSH/Swarm restrictions
and cloud-4's Cloudflare restriction were absent. Restored the existing
`iptables-general.sh` on all hosts and `iptables-cloudflare.sh` on cloud-4.
Preserved all existing host-specific exceptions. Rule snapshots and timed
rollback protected each operation; all timers were canceled after validation.

Fresh office SSH succeeded on all hosts. Non-allowed public SSH probes timed
out with corresponding DROP-counter increases. Direct-origin HTTPS to cloud-4
timed out, while public Cloudflare-routed services continued working. The Swarm
remained healthy. No automatic persistence was installed; the maintenance
checklist now explicitly requires rule restoration/verification after restarts.

See [Firewall Maintenance](firewall-maintenance.md) for policy, procedure,
evidence, and the separate review needed for cloud-1's published LWP port 58917.

## Cloud-2 Disk Space

- Monitoring uploads occupy about 91G.
- The backup directory held 19 completed encrypted ZIP archives, approximately
  17.9 GB in decimal units, with the oldest dated August 29.
- The September 13 noon backup exported a 13.9 GB uncompressed SQL file before
  compressing it into an encrypted ZIP. This temporary file contributes to the
  disk-use peak. Maintenance waited for compression to finish.
- Removed only dangling Docker images older than seven days. Docker reclaimed
  1.07 GB. No volumes, application uploads, database files or backups deleted.
- The archive completed at approximately 10:17 UTC: 943,534,118 bytes, with a
  readable directory containing the 13,884,955,429-byte SQL export. The temporary
  SQL and partial archive disappeared normally; root usage dropped to 86%, with
  24G free. No backup process was interrupted.
- Recommend a capacity/retention review: baseline use is still high and the
  twice-daily dump temporarily consumes another approximately 13G. No retention
  reduction or storage purchase was performed in this round.

## Backup Evidence

Read-only Duplicati metadata records these last backup completions on September
12, in UTC. This confirms recorded completion, not a restore test.

| Host | Started | Finished |
| --- | --- | --- |
| cloud-1 | 19:30:00 | 19:33:28 |
| cloud-2 | 20:30:00 | 20:38:51 |
| cloud-3 | 21:30:00 | 21:30:05 |
| cloud-4 | 22:00:00 | 22:00:08 |

Cloud-1's September 12 GlitchTip and website gzip archives passed `gzip -t`.
The live backup script has EXIT-trap retention, guarded dumps, partial-file
promotion, and no active vtiger dump block.

The September 12 production monitoring ZIP has a readable central directory
and one 13.9 GB SQL member. It is AES-encrypted; the host's unzip utility could
not test its payload. Full decryption/integrity and restore are unverified.

## Application Review

| Application | Observed before maintenance | Available release |
| --- | --- | --- |
| Portainer server and agents | 2.44.0 STS | 2.45.0 LTS |
| Traefik | 3.6.22 | 3.7.13 |
| Vaultwarden | 1.37.1 | 1.37.2 |
| Duplicati | Unpinned latest | 2.4.0.0 stable |

Duplicati's unpinned `latest` service image caused Swarm to fetch a newer image
when recreating containers during host maintenance. All four instances now
report `Duplicati.Server/2.4.0.0-Stable-20260903` from the installed dependency
manifest. Cloud-1's image digest is
`sha256:eb0c1298a1974048332745b393897ae3cc1c20258e4fc26a796f2b5d75eb6218`.
Pinning images would make future application upgrades deliberate.

Portainer, Traefik and Vaultwarden upgrades remain pending. Portainer's available
release is LTS, whereas the previous user preference was STS. No explicit
application service image updates were deployed in this round. Other unpinned
service tags can also refresh during task recreation; this report does not
claim a full before/after digest comparison for every application.

## Final Verification

- All four nodes `Ready`, cloud-4 `Leader`, Docker `29.8.0` throughout.
- All four reboot-required markers cleared; no failed systemd units and no
  `dpkg --audit` findings. Apt simulations show only the two deferred packages.
- Portainer agents `4/4`; all active application services `1/1`.
- Existing disabled SFTP `0/0` and old Traefik delay-start helper `0/1` unchanged.
- Direct Duplicati backends and Portainer `/api/status` returned HTTP 200 from
  their container network namespaces.
- Public website, Vaultwarden and GlitchTip returned 200; production, beta and
  dev monitoring returned normal 302 redirects. Portainer and all Duplicati
  public URLs returned Cloudflare Access redirects.
- Cloud-2 monitoring briefly returned 404 after reboot, then recovered to 302
  as routing reconverged. Cloud-2 briefly appeared `Unknown` following the
  manager reboot and returned to `Ready` without intervention.
- No authenticated application workflows or backup restore tests performed.

Official release references, checked September 13:

- [Portainer 2.45.0 LTS](https://docs.portainer.io/release-notes)
- [Traefik 3.7.13](https://github.com/traefik/traefik/releases/tag/v3.7.13)
- [Vaultwarden 1.37.2](https://github.com/dani-garcia/vaultwarden/releases/tag/1.37.2)
- [Duplicati 2.4.0.0](https://github.com/duplicati/duplicati/releases/tag/v2.4.0.0_stable_2026-09-03)
