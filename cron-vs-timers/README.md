# cron-vs-timers

The same nightly cleanup of old Orders exports written twice: `orders-cleanup.cron` and the pair `orders-cleanup.service` and `orders-cleanup.timer`.

## Goal

Compare cron and systemd timers side by side for one job: delete files under `/var/lib/orders-api/exports` older than 7 days at 02:30.

## Run it

```bash
systemd-analyze verify orders-cleanup.service orders-cleanup.timer
systemd-analyze calendar '*-*-* 02:30:00'
```

Expected: `verify` prints nothing when the units are valid; `calendar` prints the normalized form and the next time it fires.

Not run end to end: neither command was executed where this README was written, and the units were never started. The cron file needs a user named `orders` on the host and goes in `/etc/cron.d/`.

## What it proves

- `Persistent=true` in the timer runs a missed job after the machine was off, and `RandomizedDelaySec=10m` spreads load.
- The service is a `Type=oneshot` with `DynamicUser=yes`, `ProtectSystem=strict` and `NoNewPrivileges=yes`, and its output goes to the journal (`journalctl -u orders-cleanup`).
- The cron version is a single line using the same `find ... -mtime +7 -delete` command.

## Trade-offs

- Timers need two files and systemd; cron works almost everywhere.
- Cron has no catch-up (anacron covers that) and needs mail or manual logging for output.
- The service sets `StateDirectory=orders-api`, which makes systemd manage that directory's ownership.

## When not to use it

- On systems without systemd (Alpine, most containers).
- For distributed scheduling; use Kubernetes CronJobs or a workflow engine.
