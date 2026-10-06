# linux-ops-scripting

Nine small, self-contained Linux operations examples: strict-mode Bash, a hardened systemd unit, network namespaces with iptables, tcpdump recipes, cron versus timers, a Go CLI, a Python ops script, a git hook and cloud CLI recipes. They share a tiny Orders domain (order CSVs, an Orders API, export cleanup).

## What is inside

| Folder | What it shows | Run |
| --- | --- | --- |
| [`bash-strict-mode-bats`](./bash-strict-mode-bats) | `set -euo pipefail` script that totals orders per customer, with bats tests | `bats test/` |
| [`systemd-unit`](./systemd-unit) | Sandboxed service unit (dynamic user, read-only filesystem, syscall filter) | `systemd-analyze verify orders-api.service` |
| [`netns-iptables`](./netns-iptables) | Two network namespaces and a veth pair, with an iptables drop rule | `sudo bash netns-demo.sh` |
| [`tcpdump-recipes`](./tcpdump-recipes) | Capture filters for HTTP, handshakes, DNS, rotation | `python3 check-recipes.py` |
| [`cron-vs-timers`](./cron-vs-timers) | The same nightly cleanup as a cron.d entry and as a systemd timer | `systemd-analyze verify orders-cleanup.service orders-cleanup.timer` |
| [`go-cli`](./go-cli) | Standard-library Go CLI built around a testable `run` function | `go test ./...` |
| [`python-ops`](./python-ops) | Disk usage checker with JSON output and exit codes | `python3 -m unittest -v` |
| [`git-hooks`](./git-hooks) | Pre-commit hook blocking secret-looking strings, tested in a temp repo | `bash test-hook.sh` |
| [`cloud-cli-recipes`](./cloud-cli-recipes) | Read-only AWS, Azure and GCP CLI one-liners with an offline lint | `bash check-recipes.sh` |

## Prerequisites

- Bash 4+, Python 3.11+ (3.10 also works for the tests), git
- bats-core 1.10+ and shellcheck for `bash-strict-mode-bats`
- systemd (v250+ for `--offline` security scoring) for `systemd-unit` and `cron-vs-timers`
- Linux with iproute2, iptables and root for `netns-iptables`
- Go 1.22 for `go-cli`
- tcpdump only if you run the recipes themselves; the AWS, Azure and GCP CLIs only if you run the cloud recipes

## How to read it

Start with `bash-strict-mode-bats`, then compare it with `go-cli` and `python-ops`, which solve a similar task in other languages. The systemd, namespace and tcpdump folders are independent. Each folder README says which of its commands were run end to end.
