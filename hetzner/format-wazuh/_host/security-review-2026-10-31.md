# Unrecognized Wazuh Enrollment - 2026-10-31

## Case Status

**Closed - contained and enrollment hardened, 2026-10-31**, at Peter's request.
Peter declined contacting the source network's provider. No abuse report was
sent, and no further incident investigation is scheduled by this closure.

The source remains blocked, agent 045's key remains revoked, and public
enrollment remains closed. Protected evidence is retained; closure does not
authorize its deletion. This is an operational closure, not a forensic finding
that the host was never compromised. The evidence limitations below still apply.

## Observed Facts

- Routine maintenance found disconnected agent `045 poc-f9b33373`, absent
  from the last recorded maintenance inventory. Peter confirmed he did not
  recognize this as an authorized test.
- The preserved manager log records an enrollment request from `46.55.225.40`
  at **2026-10-27 01:01:45 UTC** and generation of a key for that name.
- The registration database matches that creation time. Last keepalive was
  **01:01:54 UTC**, nine seconds later. Reported metadata: Linux 6.1.0,
  Wazuh 4.14.6, no configuration hash or known syscheck completion.
- `wazuh-remoted` initially logged invalid ID 045 from the same address before
  reloading its authentication keys.
- At discovery, UFW allowed public TCP 1515 on IPv4/IPv6; authd had
  `use_password=no`, `use_source_ip=no`, and no configured agent CA.

These facts establish an unrecognized remote enrollment. They do not establish
successful code execution, persistence, data access, or the absence of a host
compromise. Routine service checks are not a forensic clearance.

## Containment Applied

- Added a first-priority UFW inbound deny for `46.55.225.40`.
- Removed public TCP 1515 allow rules for both IPv4 and IPv6. The existing
  default incoming-deny policy now blocks public enrollment. An external probe
  timed out on 1515 while 1514 remained reachable.
- Stopped the manager and invalidated only agent 045's key by prefixing its
  name with `!`, following Wazuh's documented void-entry format. The row and
  original key are retained in protected recovery records; no key is included
  in this repository.
- After manager restart, 045 was absent from the valid agent roster. Existing
  registered agents reconnected normally using their existing keys.
- By the later enrollment-hardening check, the void row was also absent from
  live `client.keys`; the original key remains in the protected evidence copy.
  All 35 valid remote-agent key records remained unchanged during hardening.
- Applied Wazuh 4.14.9 and the reviewed Ubuntu maintenance updates.

## October 27 Investigation

Times below are UTC; October 27 local time was CET (UTC+1).

| Time | Verified event |
| --- | --- |
| 01:01:30 | UFW blocked a TCP SYN from `46.55.225.40` to API port 55000. |
| 01:01:45 | Passwordless enrollment created agent `045 poc-f9b33373`. |
| 01:01:46-01:01:51 | Remoted rejected the new ID before its key-file reload. |
| 01:01:54 | Last keepalive in the preserved registration database. |
| 01:14:44.856 | Indexed rule 504, level 3: agent disconnected. |

Review scope and results:

- Searched the retained alert indices for agent ID 045: exactly one alert,
  the disconnect above. No additional indexed activity for that agent was found.
- October 26 00:00 through October 29 00:00: no alerts matching the source
  through the searched source-IP fields or full-log phrase; no manager alerts
  at level 10 or higher. All reviewed index searches completed without failures.
- The journal search over that three-day window returned only the API-port
  firewall block for the source. The reviewed SSH log had no source match or
  accepted-login entries. The October 27 API log had no matching source/name.
  This does not establish the actor's identity or exclude other addresses.
- One manager file-integrity alert occurred in that window, for
  `/etc/ld.so.cache`, detected by a scheduled scan on October 28 at
  18:30:46.958. Its recorded file mtime, 06:58:38, matches the dpkg log's
  `libbrotli1` upgrade and `libc-bin` trigger at that exact second. This is
  consistent with the Ubuntu library update, not a demonstrated incident change.
- A bounded file-mtime scan of systemd overrides, cron paths, root SSH files,
  `/tmp`, `/var/tmp` and `/dev/shm` found no files modified between October 27
  00:00 and October 31 13:36. Only `root` had UID 0. This was not a full
  filesystem or memory forensic examination.
- Package verification was not clean: modified local configuration, missing
  package files and Python bytecode/cache differences were reported. Compared
  `ossec.conf`, `api.yaml` and shared `rootkit_trojans.txt` against the protected
  October 10 and pre-maintenance October 31 archives: hashes were identical
  across those copies and live files before hardening. Those specific config
  differences predate the activity. Current upgraded binaries cannot establish
  the integrity of the binaries that were running on October 27.

**Assessment:** unrecognized enrollment through an exposed passwordless service,
preceded by an API-port probe. No evidence of successful API/SSH access or host
compromise was found within the reviewed records. This is not a clean bill of
health: `logall=no` and `logall_json=no` meant unalerted raw agent messages were
not retained, so the payloads sent after enrollment cannot be reconstructed.
Do not infer successful exploitation or its absence from the `poc-` name.

## Enrollment Hardening And Verification

Applied October 31; manager restarted at approximately 13:59 UTC:

- Public 1515 remains blocked on IPv4/IPv6, with the source-IP deny retained.
  Authd still listens locally/on the host; firewall closure remains necessary.
- Enabled `use_password=yes`. Generated a 256-bit random secret directly into
  `/var/ossec/etc/authd.pass`, `0640 root:wazuh`. It was not printed, passed
  in command arguments, or added to this repository.
- Disabled automatic duplicate-registration replacement using
  `<force><enabled>no</enabled></force>` in the manager's auth section.
- Replaced the expired enrollment-only certificate and private key after
  preserving both originals. New RSA-3072/SHA-256 self-signed certificate:
  CN/SAN `wazuh-agent.format.lu`, also localhost/127.0.0.1; valid until
  **2027-10-31 13:59:33 UTC**. Its SHA-256 fingerprint is
  `9F:99:03:63:7B:2D:FF:32:7B:17:BC:97:05:96:13:45:9A:0B:F4:5E:E6:D9:A0:D1:0E:BC:56:F7:5B:DC:59:B4`.
  This did not change dashboard/indexer TLS or existing agent keys.
- Authd configuration test passed. Live TLS tests verified the exact certificate
  and DNS name: missing password rejected; wrong password rejected; correct
  password passed authentication but an existing `MBP-PCZ` name was rejected
  because replacement is disabled. No test registration was created and no
  valid client key changed. Test requests originated from 127.0.0.1 and may
  appear in the October 31 logs; they are authorized maintenance tests.
- SSH forwarding was already disabled. A tunnel test was rejected; SSH policy
  was not weakened. New agents must use approved manual client-key enrollment
  through SSH administration, as documented in the runbook.
- External event-port probe passed (1514); enrollment probe timed out (1515).
  UFW rules also confirm no IPv6 1515 exception; an external IPv6 probe was
  not performed.
- All four core services active, no failed units, Filebeat TLS/output test
  passed, dashboard/API/indexer `302/401/401`. All 397 primary shards active;
  31 unassigned single-node replica shards remain expected. Latest indexed
  alert at 14:01:07 UTC was four seconds old at verification. Roster remained
  16 active remote agents and 19 disconnected, with ID 045 absent.

## Preserved Records

Protected directory on `format-wazuh`:
`/root/wazuh-maintenance-20261031-8Iy6j8/`.

- `config-before.tgz`: manager/API/indexer/dashboard/Filebeat configuration,
  certificates and original client keys. Archive listing checked successfully.
- `global-before.db`: SQLite online-backup snapshot of the manager's registration
  database, captured before containment/key invalidation.
- `agent-045-before.txt`: agent-control metadata captured before invalidation.
- `ossec-before.log`: manager log captured before the upgrade.
- `ossec-27.log.gz`: original compressed October 27 manager log.
- `review/api.log-27.gz`: original compressed October 27 API log.
- `review/evidence-sha256.txt`: hashes of the pre-maintenance config archive,
  registration snapshot, and October 27 manager/API log copies.
- `review/journal-window.txt`, `review/ssh-window.txt`: scoped journal exports.
- `review/agent-045.json`, `source-IP.json`, `manager-fim.json`,
  `manager-high.json`: indexed-search responses; the latter three are also
  within `review/`.
- `review/dpkg-verify-manager.txt`: package verification output, including the
  differences described above.
- `review/enrollment-before-hardening/`: pre-hardening manager configuration,
  enrollment certificate/private key, client keys and firewall status.
- `review/enrollment-hardening-tests.json`: redacted authentication/key-safety
  test results, verified at 14:00:54 UTC. The password is not in this record.

These are scoped recovery/evidence copies on the same host, not an off-host
forensic acquisition or full index-data backup. No restore test was performed.

## Residual Risks And Routine Follow-up

- Keep public enrollment closed and retain the source block. Use the runbook's
  SSH-administered client-key process for approved new agents.
- Preserve an encrypted off-host copy of the evidence. This review did not
  create off-host evidence custody or a full disk/memory acquisition.
- Full assurance would require a deeper forensic review or clean rebuild with
  fresh secrets. Neither is established as necessary by these records, and
  neither was performed or claimed complete here.
- Review logging coverage and a bounded raw-event retention policy separately;
  do not enable unrestricted raw logging without sizing disk and retention.
- Renew the enrollment certificate before October 31, 2027.
- The existing source-IP block is containment, not an identity or compromise
  determination; reassess it as the review establishes more facts.

References:

- [Wazuh void key entries](https://documentation.wazuh.com/current/development/client-keys.html#void-entries)
- [Enrollment security options](https://documentation.wazuh.com/current/user-manual/agent/agent-enrollment/security-options/index.html)
- [Password authentication](https://documentation.wazuh.com/current/user-manual/agent/agent-enrollment/security-options/using-password-authentication.html)
- [Auth configuration and duplicate protection](https://documentation.wazuh.com/current/user-manual/reference/ossec-conf/auth.html)
- [Wazuh 4.14.9 release notes](https://documentation.wazuh.com/current/release-notes/release-4-14-9.html)
