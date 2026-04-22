# New Thread Prompt

We are maintaining the servers.com ESST Cloud X VPS fleet in
`/Users/czibulapeter/Documents/GitHub/format-server-ops/servers.com/esst-cloud-x`.

Hosts:

- `esst-cloud-1`: public `188.42.62.40`, local `192.168.0.101`, plan `SSD.120`
- `esst-cloud-2`: public `188.42.62.39`, local `192.168.0.5`, plan `SSD.180`
- `esst-cloud-3`: public `188.42.62.60`, local `192.168.0.20`, plan `SSD.80`
- `esst-cloud-4`: public `172.255.248.244`, local `192.168.0.14`, plan `SSD.100`

Use the SSH aliases `esst-cloud-1` through `esst-cloud-4`. The servers.com SSH
user is `cloud-user`, not `root`. Private keys are in `~/.ssh`; never commit key
material or passwords. Start by reading `README.md`, `ssh-access.md`, and the
relevant host `maintenance-log.md`.
