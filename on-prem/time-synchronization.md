# On-Prem Time Synchronization

Last verified: 2026-09-13; fleet audit 12:19-12:22, Veeam correction 12:28-12:29, Veeam post-reboot check 12:45 Europe/Luxembourg.

Read-only audit requested during ESX-E/Veeam maintenance, expanded by the operator to the other on-prem servers. The operator subsequently approved gateway time for Veeam; only Veeam's time configuration was corrected as recorded below. The other machines were inspected only.

## Verified Windows and NAS State

| Machine | Time mode | Selected native time source | Native sync state | VMware periodic synchronization |
| --- | --- | --- | --- | --- |
| PDC | NTP | `192.168.1.253,0x8` | Synchronized, stratum 4 | Disabled |
| BDC | NT5DS | PDC | Synchronized, stratum 5 | Disabled |
| Admin | NT5DS | PDC | Synchronized, stratum 5 | Enabled |
| Tim | NT5DS | PDC | Synchronized, stratum 5 | Enabled |
| Easyjob3 | NT5DS | PDC | Synchronized, stratum 5 | Enabled |
| File | NT5DS | BDC | Synchronized, stratum 6 | Enabled |
| Exchange3 | NT5DS | BDC | Synchronized, stratum 6 | Enabled |
| Kuhnle | NT5DS | BDC | Synchronized, stratum 6 | Enabled |
| LMR | NT5DS | BDC | Synchronized, stratum 6 | Enabled |
| Veeam | NTP, standalone WORKGROUP | `192.168.90.253,0x8` | Synchronized, stratum 4 | Disabled |
| NAS4 | chrony | `192.168.90.253` | Synchronized, stratum 4, leap Normal | Not applicable |

- AD query confirmed `PDC.format.lu` owns the PDC emulator role. PDC directly uses the operator-identified WatchGuard address `192.168.1.253`.
- All other checked Windows machines except Veeam are members of `format.lu`. `NT5DS` selects the domain hierarchy; a leftover `time.windows.com` value in their manual peer registry field does not establish use of that peer. Their live source and successful synchronization records identify PDC or BDC.
- Veeam remains a standalone local-admin server. It has no domain time hierarchy to follow. Before correction, Windows Time was unsynchronized with an unreachable public peer while VMware periodic synchronization was enabled. It now uses explicit gateway NTP with VMware periodic synchronization disabled.
- Veeam's default gateway is `192.168.90.253`. Both `.90.253` and `.1.253` answered NTP probes from Veeam with offsets below one millisecond. Whether these addresses belong to the same physical firewall was not verified through firewall management.
- NAS4's chrony configuration explicitly selects `192.168.90.253`; reach was `377`, and tracking showed roughly 33 microseconds of system offset in the sampled output.
- Three diagnostic samples per domain machine against `.1.253` found absolute offsets below 4.5 ms. Largest observed offsets were Easyjob3 at about 4.43 ms and LMR at about 3.44 ms; the others were below 1 ms. These are spot measurements, not long-term accuracy guarantees.

## VMware Distinctions

The guest `VMwareToolboxCmd timesync status` result identifies periodic host synchronization. It does not establish the separate startup/resume synchronization setting or the ESXi host's own upstream time source.

Broadcom recommends using the guest's native time service and disabling VMware Tools periodic synchronization when that service is active. One-off synchronization at VM lifecycle events is separate and generally recommended, so disabling periodic synchronization must not be described as disabling every host-to-guest time correction. Correct host time remains necessary.

The registry also contained the `vmwTimeProvider` input provider on the checked Windows VMs. This is separate from the VMware Tools periodic setting. Prior Veeam events reported a missing VMware precision-clock device; provider registration alone does not prove that a precision-clock source is active. No provider was disabled during discovery.

## Unverified Systems

| System | Access result | Missing evidence |
| --- | --- | --- |
| ESX-C, `192.168.5.201` | SSH connection refused | NTP peers, selected source, synchronization health |
| ESX-D, `192.168.5.203` | SSH connection refused | NTP peers, selected source, synchronization health |
| ESX-E, `192.168.5.205` | SSH connection refused | NTP peers, selected source, synchronization health |
| vCenter, `192.168.5.15` | Configured private key absent; authentication denied | Appliance NTP configuration and host/VM settings via management |
| Lportainer, `192.168.1.9` | SSH reported Network is unreachable; route still selected the VPN | Guest time configuration and synchronization health |
| WatchGuard | NTP responses verified; management not inspected | External upstream peers and whether the two gateway addresses are interfaces on one device |

No service, route, firewall, or authentication setting was changed to obtain access. No authenticated vSphere browser tab was present in the available browser inventory.

## Recommended Arrangement

Veeam's correction is applied; recommendations for the other machines remain proposals.

1. Keep PDC synchronized to WatchGuard `.1.253`, and keep BDC and domain members in `NT5DS` mode. Domain members can select either DC through the hierarchy.
2. Completed for standalone Veeam: Windows Time uses `.90.253,0x8`, service startup is Automatic, and successful NTP synchronization was verified before disabling VMware periodic synchronization. Initial post-change diagnostic offsets were about 0.15-0.18 ms.
3. Disable VMware periodic synchronization on the seven domain members after reconfirming their working Windows Time source. Preserve and separately review startup/resume behavior.
4. Inspect ESX-C/D/E NTP configuration through authenticated vSphere access and confirm a reliable upstream source independent of guest DC startup. Verify vCenter and Lportainer when access is available.
5. Recheck sources and offsets after the pending Windows maintenance/reboots. Avoid a forced clock correction or time-service change during an active backup or servicing operation.

## Veeam Correction

At `2026-09-13 12:28`, the operator approved the gateway time source. No active backup worker or Windows TiWorker/TrustedInstaller process was observed before the change; the existing Windows update reboot requirement remained pending.

- Changed peer from `time.windows.com,0x9` to `192.168.90.253,0x8`, using manual NTP mode, and changed Windows Time startup from Manual to Automatic.
- First rediscovery overlapped a clean Windows Time service stop. Starting Windows Time again and repeating rediscovery succeeded; events 37 and 35 confirmed valid gateway time data and synchronization.
- Verified source `.90.253`, stratum 4, leap indicator 0, then disabled VMware Tools periodic synchronization on Veeam only. Startup/resume settings and registered time providers were not modified.
- No reboot, firewall change, domain join, GPO change, or Veeam application/repository change was made.
- Recorded prior settings for rollback if required: manual peer `time.windows.com,0x9`, Windows Time startup Manual, VMware periodic synchronization enabled. The old peer was unreachable during discovery and should not be restored without a reason.
- After the operator's Windows update reboot at `12:38:18`, verification at `12:45` confirmed Windows Time Automatic/Running, source `192.168.90.253,0x8`, stratum 4, leap indicator 0, and last successful sync `12:44:54`. VMware periodic synchronization remained Disabled without further intervention.

## Sources

- [Microsoft: How the Windows Time Service Works](https://learn.microsoft.com/en-us/windows-server/networking/windows-time-service/how-the-windows-time-service-works), domain hierarchy and standalone defaults.
- [Broadcom: Timekeeping Best Practices for Windows](https://knowledge.broadcom.com/external/article/315346), guest native time service and VMware periodic synchronization.
- [Broadcom: Disabling Time Synchronization for Virtual Machines](https://knowledge.broadcom.com/external/article/326306), periodic versus one-off corrections and the need for accurate host time.
