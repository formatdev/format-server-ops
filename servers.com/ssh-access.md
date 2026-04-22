# ESST Cloud X SSH Access

SSH access is configured around one local servers.com provider key per VPS.
Private keys stay outside this repository in `~/.ssh`.

## Provider Keys

Validated locally with `ssh-keygen -y` on 2026-04-19:

| Host | Private key | SSH user |
| --- | --- | --- |
| `esst-cloud-1` | `~/.ssh/esst-cloud-1` | `cloud-user` |
| `esst-cloud-2` | `~/.ssh/esst-cloud-2` | `cloud-user` |
| `esst-cloud-3` | `~/.ssh/esst-cloud-3` | `cloud-user` |
| `esst-cloud-4` | `~/.ssh/esst-cloud-4` | `cloud-user` |

The local key files use the same canonical names that were found in the
previous DevOps Bitwarden SSH config.

## Local SSH Aliases

`~/.ssh/config` contains:

```text
Host esst-cloud-1
    HostName 188.42.62.40
    User cloud-user
    Port 22
    IdentityFile ~/.ssh/esst-cloud-1
    IdentitiesOnly yes

Host esst-cloud-2
    HostName 188.42.62.39
    User cloud-user
    Port 22
    IdentityFile ~/.ssh/esst-cloud-2
    IdentitiesOnly yes

Host esst-cloud-3
    HostName 188.42.62.60
    User cloud-user
    Port 22
    IdentityFile ~/.ssh/esst-cloud-3
    IdentitiesOnly yes

Host esst-cloud-4
    HostName 172.255.248.244
    User cloud-user
    Port 22
    IdentityFile ~/.ssh/esst-cloud-4
    IdentitiesOnly yes
```

## Current Access Status

- `esst-cloud-1`: key login works as `cloud-user`; passwordless sudo works.
- `esst-cloud-2`: public TCP/22 times out; private TCP/22 from `esst-cloud-1`
  also times out.
- `esst-cloud-3`: public TCP/22 times out; private TCP/22 from `esst-cloud-1`
  also times out.
- `esst-cloud-4`: public TCP/22 times out; private TCP/22 from `esst-cloud-1`
  also times out.

## Verify Provider Keys

```sh
ssh-keygen -y -f ~/.ssh/esst-cloud-1 >/dev/null && echo OK
ssh-keygen -y -f ~/.ssh/esst-cloud-2 >/dev/null && echo OK
ssh-keygen -y -f ~/.ssh/esst-cloud-3 >/dev/null && echo OK
ssh-keygen -y -f ~/.ssh/esst-cloud-4 >/dev/null && echo OK
```

## Verify Login

```sh
ssh esst-cloud-1 'hostnamectl --static; whoami; id -nG; uname -sr'
```

For the remaining hosts, first confirm SSH exposure in servers.com or through
the host console.

## Bitwarden Notes

Generate a Bitwarden-ready note locally when needed:

```sh
bw_ssh_note() {
  local alias="$1"
  local host="$2"
  local user="${3:-cloud-user}"
  local key_path="${4:-$HOME/.ssh/${alias}}"

  key_path="${key_path/#\~/$HOME}"

  cat <<EOF
Name: ${alias} SSH
Host: ${host}
Alias: ${alias}
User: ${user}
Fingerprint: $(ssh-keygen -lf "${key_path}.pub" | awk '{print $2}')
Usage: ssh ${alias}

Public key:
$(cat "${key_path}.pub")

Private key:
$(cat "${key_path}")
EOF
}
```

Example:

```sh
bw_ssh_note esst-cloud-1 188.42.62.40 cloud-user ~/.ssh/esst-cloud-1 | pbcopy
```
