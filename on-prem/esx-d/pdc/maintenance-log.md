# PDC Maintenance Log

## 2026-04-18 - Health Check, Remote Admin Repair, Temp Cleanup

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-pdc` and `winad-pdc` both returned `PDC`.
- Domain controller services checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, and `Netlogon` running.
- `sshd` checked: `Running`, `Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`, restored to `Running`/`Automatic`.
- WinRM listener checked: GPO HTTP listener on `5985`, listening on `127.0.0.1`, `192.168.1.5`, `::1`, and link-local IPv6.
- WinRM TCP checked from Mac: `192.168.1.5:5985` still timed out even though the service and listener are running and the `Allow remote Admin - WinRM 5985` firewall rule is enabled/scoped to `192.168.1.73,192.168.113.2`.
- Replication checked: `repadmin /replsummary` showed 0 failures for BDC source and PDC destination, largest delta about 38 minutes.
- `dcdiag /q` checked: failed test `Replications` because `DsBindWithSpnEx()` to BDC returned access denied.
- Time service checked: stratum 3, source `192.168.1.253,0x8`, last successful sync 2026-04-18 20:30:13.
- Disk space checked: C: 67 GB free of 89.4 GB.
- Pending reboot checked: `PendingFileRenameOperations` present.
- Recent updates checked: latest installed hotfixes included `KB5078763` and `KB5078766` on 2026-03-16.
- File cleanup performed: deleted 2 files older than 30 days from `C:\Windows\Temp`, about 0.2 MB. Post-cleanup `C:\Windows\Temp` measured about 1.3 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- No DNS, SYSVOL, GPO, firewall rule, FSMO, replication, or snapshot/reboot action was changed.

Follow-up:

- Investigate why remote TCP/5985 to PDC times out despite WinRM service/listener/firewall rule appearing correct.
- Re-run `dcdiag` with a credential/context that can bind to BDC, or verify BDC-side permissions/connectivity.
- Plan reboot/update work carefully because this DC has a pending reboot indicator.

## 2026-04-18 - Windows Update Install, No Reboot

Maintainer: Codex with Peter

Scope:

- Started Windows Update installation on PDC using a SYSTEM scheduled task, with no reboot command.

Results:

- Installed 3 visible updates successfully: Windows Malicious Software Removal Tool KB890830, .NET cumulative update KB5084071, and OS cumulative update KB5082142.
- Task log: `C:\ProgramData\Codex\windows-update-PDC-20260418-220831.log`.
- Install result: `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Post-install C: free space: about 63.7 GB.
- Post-install visible update scan still listed KB5082142 before reboot finalization.
- Pending reboot indicators after install: CBS reboot pending, Windows Update reboot required, and `PendingFileRenameOperations`.
- Reboot performed: No.

Notes:

- One-off task `Codex-WindowsUpdate-NoReboot` was removed after completion; the task log remains under `C:\ProgramData\Codex`.
- No DNS, SYSVOL, GPO, firewall rule, FSMO, replication, snapshot, or reboot action was changed.

Follow-up:

- Reboot PDC only in a planned DC maintenance window, then re-run replication, SYSVOL/DFSR, DNS, time, and Windows Update checks.

## 2026-05-03 - Bi-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-pdc` and `winad-pdc` both connected; `winad-pdc whoami` returned `format\administrateur`.
- Domain controller services checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, and `sshd` running; `WinRM` had drifted to `Stopped`/`Disabled`.
- `WinRM` checked: restored to `Running`/`Automatic`.
- WinRM listener checked after restore: GPO HTTP listener on `5985` listening on `127.0.0.1`, `192.168.1.5`, `::1`, and link-local IPv6.
- WinRM firewall scope checked: `Allow remote Admin - WinRM 5985` still scoped to `192.168.1.73,192.168.113.2`.
- WinRM TCP checked from the maintainer Mac after restore: `192.168.1.5:5985` still timed out.
- Local WinRM self-test checked: `Test-NetConnection 127.0.0.1 -Port 5985` succeeded and `Test-WSMan 127.0.0.1` returned server identity.
- Replication checked: `repadmin /replsummary` still showed 0 failed replications, but also reported operational error `1326` while retrieving info from `BDC.format.lu`.
- `dcdiag /q` checked: still failed `Replications` because `DsBindWithSpnEx()` to `BDC` returned access denied.
- `nltest /sc_query:format.lu` checked from PDC: returned `ERROR_NO_SUCH_DOMAIN`.
- Time service checked: stratum 4, source `192.168.1.253,0x8`, last successful sync `2026-05-03 08:23:52`.
- Disk space checked: C: about 67.3 GB free.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.
- File cleanup performed: no files older than 30 days remained in `C:\Windows\Temp`; remaining temp content about 1.1 MB.
- Updates installed by Codex: No.
- Reboot performed: No.

Notes:

- April update state appears finalized because visible updates and reboot flags are clear.
- WinRM drift recurred on the DC, and external TCP/5985 remains broken even though the local listener and firewall scope look correct.

Follow-up:

- Investigate the persistent PDC-to-BDC auth/replication oddity and the failed `nltest` result from the DC itself.
- Investigate why external TCP/5985 to PDC still times out despite a healthy local listener and the expected firewall scope.

## 2026-05-03 - Follow-Up Recheck

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `win-pdc` and `winad-pdc` both connected and returned `format\administrateur`.
- WinRM TCP checked from the maintainer Mac: `192.168.1.5:5985` reachable again.
- Domain controller services checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, `sshd`, and `WinRM` all `Running` and `Automatic`.
- WinRM listener checked: GPO HTTP listener still present on `5985`, listening on `127.0.0.1`, `192.168.1.5`, `::1`, and link-local IPv6.
- WinRM firewall scope checked: `Allow remote Admin - WinRM 5985` still scoped to `192.168.1.73,192.168.113.2`.
- SPN registration checked: `setspn -L PDC` now includes `WSMAN/PDC` and `WSMAN/PDC.format.lu`.
- Replication summary checked: `repadmin /replsummary` still showed 0 failed replications, smallest delta about 3 minutes, but also reported operational error `1326` while retrieving information from `BDC.format.lu`.
- `repadmin /showrepl` checked: all inbound naming contexts from `BDC` showed the last attempt as successful.
- `dcdiag /q` checked: still failed `DFSREvent` and `Replications`.
- DFSR event log checked: repeated transient communication failures to `BDC` (`5008`, `5014`, RPC `1722`/`1726`, and one `9036` paused-for-backup event) were followed by successful reconnection event `5004` at `2026-05-03 16:56:26`.
- `nltest /sc_query:format.lu` checked from PDC: still returned `ERROR_NO_SUCH_DOMAIN`.
- `nltest /dsgetdc:format.lu` checked from PDC: successfully returned `\\PDC.format.lu`.
- `Test-ComputerSecureChannel -Server PDC.format.lu` checked from the DC context: failed with `The specified domain either does not exist or could not be contacted.` This result was treated as non-authoritative for the DC because DC secure-channel semantics differ from member servers and the DC-discovery/replication checks are the more relevant signals here.
- AD topology checked: `Get-ADDomainController -Filter *` returned `PDC.format.lu` and `BDC.format.lu`, both global catalogs.
- Time service checked: source `192.168.1.253,0x8`; last successful sync `2026-05-03 17:51:21`.
- Disk space checked: C: about 67.3 GB free.
- Pending reboot checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Visible Windows updates checked: `0`.

Notes:

- The earlier PDC external WinRM reachability problem is resolved.
- The remaining issue is not a blanket replication failure, but intermittent BDC communication/auth noise that is still loud enough for `dcdiag` and DFSR event checks to complain.

Follow-up:

- Investigate BDC health directly, especially RPC/DFSR stability and the cause of the intermittent `1722`/`1726` communication failures.
- Treat `repadmin /showrepl` and successful inbound attempts as a better short-term health indicator than `nltest /sc_query` on the DC itself.

## 2026-05-03 - Cross-Check Against BDC

Maintainer: Codex with Peter

Scope:

- Compare `PDC` and `BDC` directly to determine whether the earlier replication/auth noise reflects a real directory outage or intermittent partner-side instability.

Checks:

- `BDC` SSH checked: both `win-bdc` and `winad-bdc` connected and returned `format\administrateur`.
- `BDC` core DC services checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, and `sshd` `Running`/`Automatic`; `WinRM` had drifted to `Stopped`/`Disabled`.
- `BDC` WinRM checked: restored to `Running`/`Automatic`; local listener and firewall scope matched the expected baseline, but external TCP/5985 from the maintainer Mac still timed out.
- `BDC` secure channel checked: `nltest /sc_query:format.lu` returned `NERR_Success` against `\\PDC.format.lu`.
- `BDC` DC discovery checked: `nltest /dsgetdc:format.lu` returned `\\BDC.format.lu`.
- `BDC` replication summary checked: `repadmin /replsummary` still showed `0` failed replications, but also reported operational error `1326` while retrieving information from `PDC.format.lu`.
- `BDC` `dcdiag /q` checked: failed `KnowsOfRoleHolders`, `Replications`, `RidManager`, and `SystemLog`, while the detailed warnings specifically complained that `PDC` was not responding to DS RPC/LDAP binds in that admin context.
- `BDC` DFSR event log checked: showed the same pattern seen from `PDC` in reverse:
  - transient `5014` warnings with errors `1726` and `9036`
  - followed by successful reconnection event `5004`
  - and fresh startup/registration events around `2026-05-03 16:56`
- `PDC` and `BDC` SPNs checked: both accounts now include `WSMAN/<hostname>` and `WSMAN/<fqdn>`.
- `BDC` WinRM event checked: warning `10154` still logged that WinRM failed to create `WSMAN/BDC` SPNs with error `8344`, even though those SPNs are already present on the computer account.

Interpretation:

- The strongest replication indicators (`repadmin /replsummary` and `repadmin /showrepl`) show that the directory is currently replicating successfully between `PDC` and `BDC`.
- The recurring `dcdiag` bind failures are likely influenced by the remote SSH/logon context used for the checks and do not line up with the live replication data.
- The remaining real problem is intermittent DFSR/RPC instability between the two DCs, not a sustained replication outage.

Notes:

- `BDC` also shows the same WinRM drift pattern seen on several other Windows hosts.
- `BDC` reported `vmwTimeProvider` errors in `dcdiag` system-log output, but `W32Time` was synchronizing from `PDC.format.lu` at the time of the check.

Follow-up:

- Investigate what backup/restore or other scheduled activity is causing the recurrent DFSR pause/RPC noise between `PDC` and `BDC`.
- Validate one `dcdiag` run from an interactive/local admin session on a DC to compare against the SSH-driven result set.
- Treat the DC pair as operational but noisy unless replication failures begin appearing in `repadmin /showrepl` or `repadmin /replsummary`.

## 2026-05-16 - Twice-Monthly Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `winad-pdc` connected and returned `format\administrateur`.
- Domain controller health checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, `sshd`, and `WinRM` were all `Running` after remoting recovery.
- DNS checked: no new DNS fault surfaced in this pass.
- Replication checked: `repadmin /replsummary` again showed `0` failed replications while still reporting operational error `1326` against `BDC`.
- SYSVOL/DFSR checked: no fresh deep dive was done beyond confirming the prior noisy-but-operational pattern remains.
- Time service checked: `W32Time` remained `Running`.
- Event logs reviewed: Windows Update task log under `C:\ProgramData\Codex`; replication-noise context carried forward from the 2026-05-03 cross-check.
- Updates installed: Yes. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` completed with `ResultCode=2`, `HResult=00000000`, `RebootRequired=True`.
- Reboot required: Yes.
- Notes: Installed payloads were MRT `KB890830`, .NET cumulative update `KB5088862`, and OS cumulative update `KB5087545`. `WinRM` had again drifted to `Stopped`/`Disabled`; this pass restored it to `Running`/`Automatic`, and external TCP `5985` is reachable again from the maintainer Mac.
- Follow-up: remove the one-off task if it is still present, reboot PDC only in a planned DC window, then re-run replication/DFSR/DNS/time checks afterward. Keep the `BDC`-side RPC/DFSR noise in the follow-up lane unless live replication failures appear.

## 2026-05-31 - End-Of-Month Maintenance Sweep

Maintainer: Codex with Peter

Checks:

- SSH aliases checked: `winad-pdc` connected and returned `FORMAT\Administrateur`.
- Domain controller health checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, `sshd`, and `WinRM` were all `Running` after remoting recovery.
- DNS checked: no new DNS fault surfaced in this pass.
- Replication checked: `repadmin /replsummary` again showed `0` failed replications while still reporting operational error `1326` against `BDC`. A direct cross-check on `BDC` showed the same pattern in reverse.
- SYSVOL/DFSR checked: no fresh SYSVOL failure surfaced; the directory pair remains noisy rather than outright broken.
- Time service checked: `W32Time` remained `Running`.
- Event logs reviewed: no deep event-log pass in this sweep; Windows Update task log under `C:\ProgramData\Codex` was checked.
- Updates installed: No. A one-off SYSTEM task `Codex-WindowsUpdate-NoReboot` ran successfully and logged `VisibleCount=0`.
- Reboot required: No reboot flag was present in this pass.
- Notes: `WinRM` had drifted again to `Stopped`/`Disabled` on both `PDC` and `BDC`; both were restored to `Running`/`Automatic` for maintenance visibility. Remote COM-based Windows Update queries still fail from the SSH admin context with `0x80240032`, but the SYSTEM-context update script completed normally.
- Follow-up: keep treating the `PDC`/`BDC` pair as operational but noisy unless live replication failures begin appearing. Continue watching the recurring `WinRM` drift on both DCs.

## 2026-05-31 - Post-Update/Reboot Validation

Maintainer: Codex with Peter

Checks:

- Peter completed manual Windows Update, cleanup, guest reboot, and ESX-D host reboot.
- Post-host-reboot SSH checked: `winad-pdc` and `win-pdc` returned `PDC`.
- Domain controller health checked: `DNS`, `NTDS`, `DFSR`, `W32Time`, `Netlogon`, `sshd`, and `WinRM` were all `Running`/`Automatic`.
- Replication checked: `repadmin /replsummary` reported `0 / 5` failures in both directions, while still reporting operational error `1326 - BDC.format.lu`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `False`.
- Latest hotfix checked: `KB5087545`, installed `2026-05-17`.

Notes:

- PDC is operational after the full guest/host reboot cycle.
- The known BDC credential/RPC noise remains present, but live replication summary still shows no replication failures.

## 2026-06-14 - Twice-Monthly Maintenance Discovery

Maintainer: Codex with Peter

Checks and actions:

- `winad-pdc` checked: returned `PDC` and `format\administrateur`.
- Domain controller services checked: `DFSR`, `DNS`, `Netlogon`, `NTDS`, `W32Time`, and `sshd` were `Running`/`Automatic`.
- `WinRM` checked: found `Stopped`/`Disabled`; restored to `Running`/`Automatic`; listener exists, but TCP/5985 from the maintainer Mac still timed out.
- Replication checked: `repadmin /replsummary` reported `0 / 5` failures in both directions, while still reporting operational error `58 - BDC.format.lu`.
- `dcdiag /q` checked: still failed `DFSREvent` and `Replications`, including `DsBindWithSpnEx()` error `1722` against `BDC`.
- Reboot flags checked: CBS `False`, Windows Update `False`, `PendingFileRenameOperations` `True`.
- Recent hotfixes checked: `KB5094147` and `KB5094128` installed on `2026-06-13`.
- Visible Windows updates checked: `0`.

Notes:

- PDC is operational but the known BDC-side RPC/DFSR noise remains.
- Pending file rename indicates a planned reboot is useful, but no reboot was performed.

## 2026-07-04 - Inspection Round

Maintainer: Codex with Peter

Checks:

- Network reachability checked: `192.168.1.5` responded to ping from the maintainer Mac.
- SSH checked: both `win-pdc` and `winad-pdc` timed out on TCP/22.
- Additional TCP checks from the maintainer Mac timed out on `22`, `5985`, `443`, and `80`.
- Cross-check from Admin to `PDC.format.lu:22` returned `TcpTestSucceeded : False`.

Notes:

- PDC appears network-present but remote management ports were not reachable from the maintainer path during this inspection.
- No PDC service, DNS, SYSVOL, replication, firewall, GPO, reboot, or update action was performed.
- Follow up from vCenter/console or another LAN host to confirm whether `sshd`/WinRM are stopped, firewall scope changed, or the DC is in a restricted network state.

## Maintenance Template

Date:

Maintainer:

Checks:

- SSH aliases checked:
- Domain controller health checked:
- DNS checked:
- Replication checked:
- SYSVOL/DFSR checked:
- Time service checked:
- Event logs reviewed:
- Updates installed:
- Reboot required:
- Notes:
- Follow-up:
