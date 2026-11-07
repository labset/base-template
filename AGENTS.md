# AGENTS.md

Monorepo of Go services and TypeScript surfaces, orchestrated with Nx and pnpm, with the toolchain pinned by mise. Setup is in [README.md](README.md).

## Toolchain

- Tool versions are pinned in `mise.toml`. Install them with `mise install`, then `pnpm install`.
- Run tasks through Nx from the root: `pnpm dev`, `pnpm lint`, `pnpm test`, `pnpm build`.
- The task graph is defined in `nx.json`: `lint`, `test` and `build` depend on `generate` and on their dependencies' `build` (`^build`), so workspace packages are consumed built, as they would be from a registry. Don't run `generate` separately, Nx runs it first.
- `dev` targets are marked `continuous` in `nx.json`, so `pnpm dev` starts all of them at once rather than filling the parallel slots with tasks that never finish. Keep any new long-running target continuous.
- `pnpm affected` runs `lint`, `build` and `test` for projects changed since `origin/main`. CI runs this on pull requests, along with `pnpm format:check`, so run both before pushing.

## Working in a sandbox

Agents run in a [Docker Sandbox](https://docs.docker.com/ai/sandboxes/) that the user starts from the host with `.sandbox/run.sh` (see [.sandbox/README.md](.sandbox/README.md)).

### Go cache

The base image sets `GOPATH=/go`, which isn't writable, and a kit can't override it. The mise kit exports `GOPATH=/home/agent/go` on startup. If Go still fails to create its cache, run `export GOPATH=$HOME/go` first.

### Network access

- Outbound traffic is default-deny. The allowed hosts live in `.sandbox/network-policy/network-policy.yaml`, so widening access is a reviewed change to that file, not an ad-hoc workaround.
- A blocked request returns HTTP 403 with an explanation in the body. Read it, then check `sbx policy log`.
- Agents cannot approve their own access. Ask the user to approve on the host (`sbx policy approval ls`, then `sbx policy approval respond`), or to run `sbx policy allow network <domain>`.
- A sandbox keeps the kits it was created with. After editing the network policy, ask the user to create a new sandbox with `.sandbox/run.sh <new-name>`.

### Git and GitHub

Use HTTPS for all GitHub operations. Do not change the `origin` remote.

```bash
git push -u https://github.com/labset/base-template.git <branch>
gh pr create --repo labset/base-template --base main --head <branch>
```

## Commits and pull requests

- Work on a feature branch, never directly on `main`.
- Keep commit messages short and lowercase, in the imperative (for example `add sandbox network policy kit`).
- Commit and push only when asked.
- Do not run `pnpm sign`. The author signs commits outside the sandbox.
