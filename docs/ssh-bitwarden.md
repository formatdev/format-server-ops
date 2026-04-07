# SSH To Bitwarden

This runbook shows how to generate a complete SSH host note in one go and paste it into Bitwarden as a `Secure Note`.

The output is generated locally from files already present in `~/.ssh`. No key material is written into this repository.

By default, the helper assumes the SSH key files are named like this:

```text
~/.ssh/<alias>_ed25519
~/.ssh/<alias>_ed25519.pub
```

If the key does not exist yet, create it first with the setup helper in [`ssh-config.md`](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-config.md).

If you use the setup helper from [`ssh-config.md`](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-config.md), it can already print the same Bitwarden-ready note immediately after finishing the SSH setup.

## One-Off Example For `hetzner-cloud-1`

Copy a complete Bitwarden-ready note to the macOS clipboard:

```bash
cat <<EOF | pbcopy
Name: hetzner-cloud-1 SSH
Host: 188.245.43.92
Alias: hetzner-cloud-1
User: root
Fingerprint: $(ssh-keygen -lf ~/.ssh/hetzner-cloud-1_ed25519.pub | awk '{print $2}')
Usage: ssh hetzner-cloud-1

Public key:
$(cat ~/.ssh/hetzner-cloud-1_ed25519.pub)

Private key:
$(cat ~/.ssh/hetzner-cloud-1_ed25519)
EOF
```

After running the command:

1. open Bitwarden
2. create a new `Secure Note`
3. paste the clipboard contents
4. save it in a vault with the right access scope

## Reusable Template

Use this shell function for future hosts:

```bash
bw_ssh_note() {
  local alias="$1"
  local host="$2"
  local user="$3"
  local key_path="${4:-$HOME/.ssh/${alias}_ed25519}"

  key_path="${key_path/#\~/$HOME}"

  if [ -z "$alias" ] || [ -z "$host" ] || [ -z "$user" ]; then
    echo "usage: bw_ssh_note <alias> <host> <user> [key_path]" >&2
    return 1
  fi

  if [ ! -f "$key_path" ] || [ ! -f "${key_path}.pub" ]; then
    echo "missing key files for alias: $alias" >&2
    echo "expected: $key_path and ${key_path}.pub" >&2
    return 1
  fi

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

Example usage:

```bash
bw_ssh_note "hetzner-cloud-1" "188.245.43.92" "root" | pbcopy
```

## Notes

- use `pbcopy` on macOS to send the generated note straight to the clipboard
- remove `| pbcopy` if you want to inspect the output in the terminal first
- the default key convention is `~/.ssh/<alias>_ed25519`
- do not commit private keys or pasted note contents into this repo
- for the matching SSH alias workflow, see [`ssh-config.md`](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-config.md)
