# .sandbox

[Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) setup for this workspace: Docker's Claude kit as the workload, plus two [mixin kits](https://docs.docker.com/ai/sandboxes/customize/use-kits/) of ours.

## Usage

From the repo root, create the sandbox or reopen it if it already exists:

```bash
.sandbox/run.sh [name]   # name defaults to "monorepo"
```

The Claude kit asks to approve its Anthropic credentials. Select **3. No** (start without them).

Inside the sandbox, run `mise install` and `pnpm install`. Use `sbx ls` to list sandboxes and `sbx rm <name>` to remove one.

## Kits

Both are attached by `run.sh`.

### mise

Sets up the toolchain pinned in `mise.toml`:

- installs the [mise](https://mise.jdx.dev) binary to `/usr/local/bin` (release pinned by `version` in `mise/mise.yaml`)
- puts the mise shims on `PATH`, so installed tools resolve in every shell without `mise activate`
- exports `GOPATH=/home/agent/go`, since the base image's `/go` isn't writable by the agent user

### network-policy

A declaration-only kit listing the outbound hosts the toolchain may reach: what mise needs to install the tools, plus the Go and npm registries and the shadcn component registry. Anything not listed stays blocked by the sandbox's default-deny policy, so the allowlist is reviewable in git. Hosts the agent itself needs, such as `api.anthropic.com`, come with the Claude kit.

To change it:

1. Add or remove a host in `network-policy/network-policy.yaml`.
2. Create a new sandbox with `.sandbox/run.sh <new-name>`, since a sandbox keeps the kits it was created with.
3. Commit the change.

Kit rules can't grant access beyond your organization's policy. To debug a blocked request:

```bash
sbx policy log   # recent connections and why they were blocked
sbx policy ls    # active rules
```
