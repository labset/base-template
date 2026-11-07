# base-template

Labset base template: an [Nx](https://nx.dev) + [pnpm](https://pnpm.io) monorepo with a mise-pinned polyglot toolchain (Node, Go, protobuf/buf codegen), CI pipelines and an optional Docker sandbox for agent work.

## Prerequisites

- [mise](https://mise.jdx.dev), which installs every tool pinned in `mise.toml` (Node, pnpm, Go, buf, sqlc, atlas, air, golangci-lint, protoc plugins, OpenSpec)

## Getting started

```bash
mise install   # toolchain
pnpm install   # dependencies
```

## Scripts

Run from the repo root. Most delegate to Nx across all projects.

| Script              | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| `pnpm dev`          | Run the `dev` target of every project                            |
| `pnpm lint`         | Lint all projects                                                |
| `pnpm build`        | Build all projects                                               |
| `pnpm test`         | Test all projects                                                |
| `pnpm affected`     | Lint, build and test only projects affected versus `origin/main` |
| `pnpm format`       | Format the repo with Prettier                                    |
| `pnpm format:check` | Check formatting without writing                                 |
| `pnpm clean`        | Run project `clean` targets, reset Nx, remove `node_modules`     |
| `pnpm sign`         | Re-sign commits on top of `origin/main` (GPG)                    |

## Layout

| Path                  | Purpose                                                              |
| --------------------- | -------------------------------------------------------------------- |
| `mise.toml`           | Pinned toolchain versions                                            |
| `pnpm-workspace.yaml` | pnpm workspace and shared store config                               |
| `nx.json`             | Nx workspace config                                                  |
| `go.work`             | Go workspace                                                         |
| `.github/workflows`   | CI pipelines                                                         |
| `.sandbox/`           | Docker Sandboxes setup, see [.sandbox/README.md](.sandbox/README.md) |

## CI

- **pr-build**: on pull requests to `main`, checks formatting and runs `pnpm affected`.
- **main-build**: on every push to `main`, full verification.

## Sandbox

To work inside an isolated [Docker Sandbox](https://docs.docker.com/ai/sandboxes/):

```bash
.sandbox/run.sh [name]
```

See [.sandbox/README.md](.sandbox/README.md) for details.

## License

Unlicensed.
