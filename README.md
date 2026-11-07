# base-template

Labset base template: an [Nx](https://nx.dev) + [pnpm](https://pnpm.io) monorepo with a mise-pinned polyglot toolchain (Node, Go, protobuf/buf codegen), CI pipelines and an optional Docker sandbox for agent work.

## Requirements

- [mise](https://mise.jdx.dev), which installs the pinned toolchain (Go, Node, pnpm and the code generators)
- Optional, to run an agent in a sandbox: [Docker](https://docs.docker.com/get-docker/) and [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) (`sbx`)

### Installing mise

```bash
brew install mise
```

Then [activate mise in your shell](https://mise.jdx.dev/getting-started.html#activate-mise). For other install methods, see the [mise installation docs](https://mise.jdx.dev/installing-mise.html).

### Installing Docker Sandboxes (optional)

```bash
brew install docker/tap/sbx
sbx login
```

For other install methods, see the [Docker Sandboxes docs](https://docs.docker.com/ai/sandboxes/).

## Getting started

```bash
# 1. Install the pinned toolchain
mise install

# 2. Install JS dependencies
pnpm install

# 3. Run tasks across the workspace
pnpm dev     # start everything in dev mode
pnpm lint
pnpm test
pnpm build
```

## Task graph

Code generation (protobuf/buf, sqlc, ...) is an Nx `generate` target, and `build`, `lint` and `test` each depend on it. Nx runs a project's `generate` first, so generated code is always present and fresh. `build`, `lint` and `test` also depend on the `build` of the project's dependencies (`^build`), including nested ones, so they are built first. The wiring is in [`nx.json`](nx.json):

```text
build, lint, test  ──►  generate        (same project)
build, lint, test  ──►  ^build          (dependencies' build)
```

`dev` is a [continuous](https://nx.dev/docs/concepts/mental-model#continuous-tasks) task (a long-running server or watcher), so it never blocks the tasks that depend on it. It depends on `^build` and `generate` too, so its dependencies are built before it starts.

`generate`, `build`, `lint` and `test` are cached (`dev` is not). A cache hit replays the output and restores the `build` outputs (`dist`, `build`, `out` under each project) instead of re-running the task. Projects whose `generate` writes files should declare them as `outputs` so they are restored from cache as well. The local cache lives in `.nx/cache` (gitignored).

```bash
pnpm exec nx graph                  # explore the project graph
pnpm exec nx build <project> --graph  # preview the tasks a build would run
```

## Developing in a sandbox

Run your agent in a [Docker Sandbox](https://docs.docker.com/ai/sandboxes/) so it only reaches the network hosts listed in [`.sandbox/network-policy`](.sandbox/network-policy/network-policy.yaml).

```bash
# From the repo root: create the sandbox, or reopen it if it already exists
.sandbox/run.sh [name]

# Inside the sandbox: install the toolchain and dependencies as usual
mise install
pnpm install
```

When the Claude kit asks to approve its Anthropic credentials, select **3. No** (start without them).

See [`.sandbox/README.md`](.sandbox/README.md) for how the kits work, changing the network policy and debugging blocked requests.

## CI

- **pr-build**: on pull requests to `main`, checks formatting and runs `pnpm affected`.
- **main-build**: on every push to `main`, full verification.
