# New Thread Prompt

Use this prompt when opening a dedicated maintenance thread from the
`format-server-ops` repository.

```text
We are in /Users/czibulapeter/Documents/GitHub/format-server-ops.

Continue with the Hetzner Wazuh VPS documentation and maintenance work. The host is format-wazuh and is reachable through ssh alias format-wazuh. It is believed to run Wazuh without Portainer, but do not assume the deployment model is verified yet.

First inspect git status and the repo layout under hetzner/format-wazuh/_host. Read:
- hetzner/format-wazuh/_host/README.md
- hetzner/format-wazuh/_host/maintenance-log.md

Then connect to the host only after confirming the SSH alias. Run discovery-first checks: hostnamectl, IP addresses, OS/kernel, uptime, disk/memory, failed systemd units, firewall, fail2ban, listening ports, whether Docker/Docker Compose/Swarm exists, and how Wazuh is deployed. Do not apply upgrades, reboot, prune Docker, or delete data until the deployment model and backup locations are documented.

If the host is healthy, record the verified facts and checks in hetzner/format-wazuh/_host/maintenance-log.md. If package updates are requested, run apt update/upgrade carefully, verify Wazuh afterward, and report whether a reboot is required.
```
