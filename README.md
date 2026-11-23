## What gets deployed

| File | Resources |
|---|---|
| `main.tf` | Resource group `RG-Katies-Kitchens-Backups` |
| `network.tf` | VNet `vnet-kk` with a VM subnet and a PE subnet, a Private Endpoint for `blob` at a static `10.0.0.70`, and the private DNS zone `privatelink.blob.core.windows.net` linked to the VNet |
| `nsg.tf` | ASGs for the router and the PE. VM subnet: deny all inbound. PE subnet: allow only `asg-vpn → asg-pe` on TCP 443 |
| `vm.tf` | `kk-vpn`: Ubuntu 24.04, `Standard_B2ts_v2`, IP forwarding on, static `10.0.0.5`. Its public IP is used for outbound only (Tailscale direct connections, apt); the NSG blocks all inbound |
| `cloud-init.yaml` | nftables (own table, leaves tailscaled rules alone), IP forwarding, Tailscale install. Advertises **only `10.0.0.70/32`** and enables Tailscale SSH |
| `blob.tf` | Storage account: public network access off, shared keys off (Entra ID only), TLS 1.2, GRS, versioning, 30-day blob and container soft delete |
| `restic.tf` | App registration and SP `sp-kk-restic` that authenticates with a certificate (`certs/kk-restic.crt`), with **Storage Blob Data Contributor on the container only** |
