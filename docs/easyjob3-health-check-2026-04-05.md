# EASYJOB3 Health Check

This report captures the observed health state of `EASYJOB3` on `2026-04-05`.

## Summary

- host: `EASYJOB3`
- domain: `format.lu`
- operating system: `Microsoft Windows Server 2025 Standard`
- result: partially healthy
- important context: the original checklist described a domain controller, DNS server, and Exchange server, but this host is a domain member file and print server

## Role Validation

Observed locally:

- File Server role evidence present
- Print Spooler service present and running
- no local DNS Server role
- no local AD DS role
- no local Exchange services

This means the following original checks were not applicable on this host:

- replication health
- AD critical DC services
- DNS service health
- Exchange services and queues

## Service State

- `Spooler`: running
- `DNS`: not installed on this host
- `NTDS`: not installed on this host
- `DFSR`: not installed on this host
- `MSExchangeTransport`: not installed on this host

## Domain Health

- `Test-ComputerSecureChannel`: passed
- `nltest /sc_verify:format.lu`: passed
- trusted DC reached during verification: `BDC.format.lu`

The secure channel is healthy at the time of inspection.

## Disk Space

- `C:` total: `148.65 GB`
- `C:` free: `23.15 GB`
- `C:` free percent: `15.58%`

Assessment:

- above the `15%` alert threshold
- very close to the threshold and should be watched

## Event Review

Lookback used: last `24 hours`

### System Log Findings

- repeated `NETLOGON 5719` errors indicating intermittent failure to establish a secure session with a domain controller
- repeated `Microsoft-Windows-Time-Service` errors for `vmwTimeProvider`
- one `Service Control Manager 7031` error for `Windows Installer`, likely related to the WatchGuard removal attempts from the same session
- one `Kernel-Boot 124` and one `Hyper-V-Hypervisor 42` at boot, consistent with unsupported virtualization-based security or nested hypervisor expectations in a VMware guest

Important nuance:

- despite the `NETLOGON 5719` events, the secure channel check passed during this inspection
- despite the `vmwTimeProvider` errors, Windows time was also observed syncing successfully from `PDC.format.lu`

### Application Log Findings

- repeated `Folder Redirection 502` errors for `\\\\FILE\\Users\\Administrateur`
- `Security-SPP 16398` licensing/grace-period error
- `VSS 8193` and `VSS 13` errors around shutdown/startup timing

## Risks

- disk free space is close to the alert threshold
- recurring `NETLOGON 5719` errors suggest intermittent domain communication issues even though current trust is valid
- recurring `vmwTimeProvider` errors add noise and may indicate an unnecessary or misconfigured VMware time provider
- folder redirection for `Administrateur` is misconfigured

## Recommended Follow-Up

- confirm whether `EASYJOB3` should keep the current file and print server role only
- monitor `C:` capacity and plan cleanup before it falls below `15%`
- review the repeated `NETLOGON 5719` events with network or DC availability in mind
- review whether `vmwTimeProvider` should be disabled if `NtpClient` from the domain is the intended time source
- fix or remove the invalid folder redirection policy for `\\\\FILE\\Users\\Administrateur`

