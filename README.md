# homeiac

## Provisioning a new machine

Not a super ideal solution, but follow the Raspberry Pi recommended installation instructions, then once fully installed and connected to the network deploy the config you *actually want* from here.

## Deploy configuration

```bash
nix run github:serokell/deploy-rs -- .#pi1 --remote-build
```