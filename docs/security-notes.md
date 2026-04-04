# Security Notes

## Observed Live Posture

- Traefik is the shared reverse proxy
- Portainer is exposed directly on host ports
- databases are not published on host ports
- secrets are present on the live host and in running container environments, not in Git
- sanitized compose exports in this repo remove those live secrets and replace them with env placeholders

## Secret Handling

- keep production `.env` files only on the deployment host
- store master copies in a password manager or secret vault
- rotate database passwords and admin credentials periodically
- do not place secrets in Compose files
- treat any currently running container environment that contains credentials as sensitive operational state

## Network Guidance

- allow inbound access only from trusted admin and user networks
- use your VPN for remote access
- enforce network restrictions with your VM firewall policy, upstream firewall, or both
- keep Traefik's dashboard restricted to admin networks only
- review Portainer's direct host-port exposure separately from Traefik

## Host Hardening

- keep Ubuntu patched
- enable a host firewall such as `ufw` or your standard Linux firewall policy
- limit SSH access to admin networks and strong authentication
- review Docker group membership carefully

## Application Guidance

- configure `PAPERLESS_URL` correctly
- set trusted origins explicitly
- use long random values for `PAPERLESS_SECRET_KEY`
- create named admin accounts rather than shared credentials

## Risk Flags

- exposing Portainer broadly increases management-plane risk
- exposing Traefik's dashboard broadly increases management-plane risk
- multiple active application surfaces increase operational sprawl
- enabling AI add-ons without data-classification review may create privacy and compliance issues
- document ingestion may include sensitive data, so backup destinations must meet the same security standard as primary storage
