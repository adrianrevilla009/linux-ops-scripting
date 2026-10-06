# systemd-unit

`orders-api.service`, a hardened systemd unit that serves a directory with `python3 -m http.server` as a stand-in for an Orders API.

## Goal

Show a service unit where every sandboxing directive is explicit and reviewable: dynamic user, read-only filesystem, no capabilities and a filtered set of syscalls.

## Run it

```bash
systemd-analyze verify orders-api.service
systemd-analyze security --offline=true orders-api.service
```

Expected: `verify` prints nothing when the unit is valid; `security` prints a table of directives and an overall exposure score (lower is better).

To install it for real, copy it to `/etc/systemd/system/`, then run `systemctl daemon-reload && systemctl enable --now orders-api`.

Not run end to end: the unit was never loaded by systemd and neither command above was executed, so the exposure score is unknown.

## What it proves

- `DynamicUser=yes` with `StateDirectory=orders-api` gives the process a throwaway user and a writable `/var/lib/orders-api`, while `ProtectSystem=strict` makes the rest of the filesystem read-only.
- `CapabilityBoundingSet=` is empty, `NoNewPrivileges=yes` is set and `SystemCallFilter` allows `@system-service` minus `@privileged @resources`.
- The server binds to `127.0.0.1:8080` only, and `ExecStart` uses the absolute path `/usr/bin/python3` as systemd requires.

## Trade-offs

- Tight sandboxes break software that needs `/home`, raw sockets or JIT compilation (`MemoryDenyWriteExecute=yes`).
- `--offline` needs a recent systemd (v250+).
- `http.server` is a stand-in; a real service needs its own tuning of the syscall filter.

## When not to use it

- In containers without systemd.
- For one-shot jobs, where a timer-activated oneshot service fits better (see `cron-vs-timers`).
