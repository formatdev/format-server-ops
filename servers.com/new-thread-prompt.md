# New Thread Prompt

We are maintaining the servers.com ESST fleet. Local historical records are in
`/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com`.

Read `AGENTS.md` in that directory first. The canonical repository for current
ESST topology, procedures and new intervention logs is
`https://github.com/esstdev/esst-infrastructure`.

Read its current `README.md`, `CLAUDE.md`, `servers/estate.md`,
`servers/access.md`, `runbooks/maintenance-checklist.md`, `runbooks/backups.md`,
and `logs/_template.md` before work. Read the relevant recent logs/open issues.
Create new intervention records there from the template and update them as work
proceeds. Link to its estate reference instead of duplicating topology.

Use the SSH aliases `esst-cloud-1` through `esst-cloud-4`. The servers.com SSH
user is `cloud-user`, not `root`. Private keys are in `~/.ssh`; never commit key
material or passwords. Local `firewall-maintenance.md` contains tested firewall
verification steps; these remain mandatory after host/Docker restarts.

Start with read-only discovery and observe upstream backup, rollback, image
pinning, window and execution rules. The current canonical reboot order is
3 -> 2 -> 1 -> 4, with recovery verified between hosts. Follow explicit user
execution authorization for the named scope. Format infrastructure is separate.
