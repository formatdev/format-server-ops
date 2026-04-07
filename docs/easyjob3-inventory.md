# EASYJOB3 Inventory

This inventory reflects the observed state of `EASYJOB3` on `2026-04-05`.

## Server

- name: `EASYJOB3`
- environment: Production
- owner: Infrastructure
- domain: `format.lu`
- platform: `Microsoft Windows Server 2025 Standard`
- server role class: Domain member server
- notes: this host is not a domain controller and does not run Exchange

## Observed Roles

- File Server
- Print Server

## Observed Services Of Interest

- `Spooler`
- domain secure channel to `format.lu`

## Not Present On This Host

- `DNS` service
- `NTDS` service
- `DFSR` service
- `MSExchangeTransport` service
- `MSExchange*` service set
- Exchange installation
- Active Directory Domain Services role

## Health Check Scope For This Host

- domain membership and secure channel
- print service state
- disk space
- system and application event log review

## Thresholds

- disk free space alert below: `15%`
- event log lookback: `24 hours`

