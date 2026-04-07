# SSH Config

This runbook shows how to create or update a convenient SSH host alias by pasting a shell function and running it from anywhere.

The helper does three things in one go:

- creates an Ed25519 key if it does not already exist
- installs the public key on the target server
- writes or updates the matching `Host` block in `~/.ssh/config`
- prints a complete Bitwarden-ready note for copy and paste

The workflow is intentionally similar to [`ssh-bitwarden.md`](/Users/czibulapeter/Documents/GitHub/lportainer/docs/ssh-bitwarden.md): paste once, run once, and avoid changing into the repository directory.

## Information Needed

Minimum inputs:

- alias, for example `hetzner-cloud-1`
- host, for example `188.245.43.92`
- user, for example `root`

Optional inputs:

- custom private key path if you are not using the default naming convention
- port if it is not `22`
- SSH config path if you do not want to write to `~/.ssh/config`

On the first run, SSH may prompt for the server password if the key is not installed yet.

By default, the helper assumes the private key path is:

```text
~/.ssh/<alias>_ed25519
```

## Pasteable Helper

Paste this function into your shell:

```bash
bw_ssh_config() {
  local alias_name="$1"
  local host_name="$2"
  local user_name="$3"
  local key_path="${4:-$HOME/.ssh/${alias_name}_ed25519}"
  local port="${5:-}"
  local config_path="${6:-$HOME/.ssh/config}"
  local ssh_target tmp_file new_file

  key_path="${key_path/#\~/$HOME}"

  if [ -z "$alias_name" ] || [ -z "$host_name" ] || [ -z "$user_name" ]; then
    echo "usage: bw_ssh_config <alias> <host> <user> [key_path] [port] [config_path]" >&2
    return 1
  fi

  mkdir -p "$(dirname "$key_path")"

  if [ ! -f "$key_path" ]; then
    echo "creating ssh key: $key_path"
    ssh-keygen -t ed25519 -f "$key_path" -C "$alias_name" -N ""
  fi

  if [ ! -f "${key_path}.pub" ]; then
    echo "public key not found: ${key_path}.pub" >&2
    return 1
  fi

  mkdir -p "$(dirname "$config_path")"
  touch "$config_path"
  chmod 600 "$config_path"

  ssh_target="${user_name}@${host_name}"

  echo "installing public key on ${ssh_target}"
  if [ -n "$port" ]; then
    if ! cat "${key_path}.pub" | ssh -p "$port" "$ssh_target" '
      umask 077
      mkdir -p ~/.ssh
      touch ~/.ssh/authorized_keys
      chmod 600 ~/.ssh/authorized_keys
      key=$(cat)
      grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys
    '; then
      echo "failed to install public key on ${ssh_target}" >&2
      return 1
    fi
  else
    if ! cat "${key_path}.pub" | ssh "$ssh_target" '
      umask 077
      mkdir -p ~/.ssh
      touch ~/.ssh/authorized_keys
      chmod 600 ~/.ssh/authorized_keys
      key=$(cat)
      grep -qxF "$key" ~/.ssh/authorized_keys || printf "%s\n" "$key" >> ~/.ssh/authorized_keys
    '; then
      echo "failed to install public key on ${ssh_target}" >&2
      return 1
    fi
  fi

  tmp_file="$(mktemp)"
  new_file="$(mktemp)"

  awk -v alias_name="$alias_name" '
    BEGIN {
      skip = 0
    }
    $1 == "Host" && $2 == alias_name {
      skip = 1
      next
    }
    $1 == "Host" && skip == 1 {
      skip = 0
    }
    skip == 0 {
      print
    }
  ' "$config_path" > "$tmp_file"

  cat "$tmp_file" > "$new_file"

  if [ -s "$new_file" ]; then
    printf '\n' >> "$new_file"
  fi

  {
    printf 'Host %s\n' "$alias_name"
    printf '    HostName %s\n' "$host_name"
    printf '    User %s\n' "$user_name"
    if [ -n "$port" ]; then
      printf '    Port %s\n' "$port"
    fi
    printf '    IdentityFile %s\n' "$key_path"
    printf '    IdentitiesOnly yes\n'
  } >> "$new_file"

  mv "$new_file" "$config_path"
  rm -f "$tmp_file"

  echo "configured ssh alias: $alias_name"
  echo
  echo "Bitwarden note:"
  cat <<EOF
Name: ${alias_name} SSH
Host: ${host_name}
Alias: ${alias_name}
User: ${user_name}
Fingerprint: $(ssh-keygen -lf "${key_path}.pub" | awk '{print $2}')
Usage: ssh ${alias_name}

Public key:
$(cat "${key_path}.pub")

Private key:
$(cat "${key_path}")
EOF
}
```

## One-Off Example For `hetzner-cloud-1`

Run:

```bash
bw_ssh_config "hetzner-cloud-1" "188.245.43.92" "root"
```

This will:

- create `~/.ssh/hetzner-cloud-1_ed25519` if it is missing
- install the public key on `root@188.245.43.92`
- create or update this SSH config entry:
- print the full Bitwarden note content after setup finishes

```text
Host hetzner-cloud-1
    HostName 188.245.43.92
    User root
    IdentityFile /Users/your-user/.ssh/hetzner-cloud-1_ed25519
    IdentitiesOnly yes
```

After that, connect with:

```bash
ssh hetzner-cloud-1
```

## Example With A Custom Port

```bash
bw_ssh_config "example-host" "example.com" "ubuntu" "$HOME/.ssh/example-host_ed25519" "2222"
```

## Example With Only The Default Key Path

For an alias named `example-host`, the helper automatically uses:

```text
~/.ssh/example-host_ed25519
```

So this is enough:

```bash
bw_ssh_config "example-host" "example.com" "ubuntu"
```

## Notes

- rerunning the function reuses the same key and updates the matching `Host` block instead of blindly appending duplicates
- the default key convention is `~/.ssh/<alias>_ed25519`
- the function writes to `~/.ssh/config` by default
- the function appends the public key to `~/.ssh/authorized_keys` on the target server if it is not already present
- if the server-side key installation fails, the function stops before writing SSH config or printing the Bitwarden note
- the function prints the private key into your terminal output, so keep shell history and screen sharing in mind
- if you want to inspect the resulting config, run `sed -n '/^Host hetzner-cloud-1$/,/^Host /p' ~/.ssh/config`
