# Wazuh Retention

Tracked retention configuration for `format-wazuh`.

- Searchable `wazuh-alerts-*` indices: 90 days through Wazuh Indexer Index
  State Management.
- Rotated local files in `/var/ossec/logs/alerts/YEAR/MONTH`: 30 days through
  a daily systemd timer.
- Wazuh internal logs: the existing `monitord.keep_log_days=31` setting is
  unchanged.
- `/var/ossec/queue`: excluded from retention cleanup.

Deployed paths:

- `/usr/local/sbin/wazuh-local-alert-retention`
- `/etc/systemd/system/wazuh-local-alert-retention.service`
- `/etc/systemd/system/wazuh-local-alert-retention.timer`

The timer runs daily at approximately 03:35 UTC with up to 15 minutes of
randomized delay and catches up after downtime.

The local cleanup script only matches dated `ossec-alerts-*` log, JSON,
compressed, and checksum files exactly three levels below the alerts directory.
It does not match the live `alerts.log` or `alerts.json` files.

The initial enforcement on 2026-08-23 removed 104 alert indices older than 90
days and 694 dated local alert/checksum files older than 30 days. It did not
touch `/var/ossec/queue` or `/root/wazuh-backup-2025-08-03.tar.gz`.
