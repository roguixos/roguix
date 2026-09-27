# roguix

Roguix's hand-maintained Guix modules: packages Guix does not have yet,
built by GitHub Actions and served by `https://roguix.frolow.dev`.

| Repository | What it is |
| --- | --- |
| [roguixos/roguix](https://github.com/roguixos/roguix) | this one: packages, CI |
| [rofrol/try-roguix](https://github.com/rofrol/try-roguix) | the macOS app and the Roguix desktop guest |
| [rofrol/roguix-channel](https://github.com/rofrol/roguix-channel) | the desktop's channel, generated from try-roguix |

## Layout

| Path | What it is |
| --- | --- |
| `channels.scm` | the Guix commit CI builds with and the VPS runs |
| `modules/roguix/packages/` | packages: `postgresql-17` in `(roguix packages databases)`, `node-22` in `(roguix packages node)` |
| `manifests/x86_64.scm` | what CI builds for x86_64 |
| `modules/roguix/builder.pub` | CI's archive signing key; the secret half is the `BUILDER_SIGNING_KEY` Actions secret |
| `scripts/vps-import` | on the VPS: import CI's newest release into guix publish |

## Guix pin

Every store path depends on the Guix commit, so CI and the VPS use the one
in `channels.scm`; otherwise the VPS asks roguix.frolow.dev for paths CI
never built and compiles them itself. To move on: change the commit, let
CI build and publish, `scripts/vps-import` on the VPS, then
`guix pull -C channels.scm` there and reconfigure.

## Publishing

On a push to `main` touching packages, the manifest or the pin,
`.github/workflows/build-x86_64.yml` builds `manifests/x86_64.scm` without
grafts (grafts are not substitutable; the VPS grafts locally) and makes a
release `x86_64-DATE-COMMIT-ATTEMPT` with:

- `roguix-x86_64.nar.zst`: `guix archive --export` of `publish.txt`,
  signed with the builder key;
- `publish.txt`: the closure's items bordeaux does not serve;
- `vps-fetch.txt`: the rest, which the VPS substitutes from bordeaux,
  since an import needs every reference valid.

The VPS pulls it with `scripts/vps-import`; CI has no access to the VPS.
The importing daemon must trust the builder key
(`modules/roguix/builder.pub`): on Guix System through `authorized-keys` in
`guix-service-type` (`guix archive --authorize` lasts only until the next
reconfigure), elsewhere with `guix archive --authorize`.

The builder key signs what the VPS imports and republishes under its own
key, which Roguix VMs trust: keep `BUILDER_SIGNING_KEY` to workflows on
`main`.
