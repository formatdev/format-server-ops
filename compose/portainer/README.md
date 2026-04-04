# Portainer

Portainer is running on the live VM, and the compose file in this directory is a reconstruction based on live container inspection.

Observed live facts:

- container name: `portainer`
- image: `portainer/portainer-ce:latest`
- published ports:
  - `8000/tcp`
  - `9443/tcp`
- data volume: `portainer_data`
- docker socket is mounted

This definition should be treated as an audited reconstruction until you redeploy Portainer from the repository-managed compose file.
