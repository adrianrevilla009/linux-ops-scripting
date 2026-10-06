# python-ops

`diskwatch.py`, a standard-library Python script that checks disk usage against a threshold, with tests in `test_diskwatch.py`.

## Goal

Show an ops script that is easy to test and to schedule: logic in pure functions, JSON on stdout and the result signalled through the exit code.

## Run it

```bash
python3 -m unittest -v
python3 diskwatch.py / /tmp --threshold 80
```

Run both from this folder. Observed output: `Ran 4 tests ... OK` for the tests, and for `python3 diskwatch.py / --threshold 99.9` the line `[{"path": "/", "used_pct": 6.1, "ok": true}]` with exit code 0 (the percentage depends on your disk).

## What it proves

- `check(paths, threshold)` returns one row per path; a path above the threshold gets `"ok": false` and the exit code becomes 1.
- A missing path is reported as a row with an `error` field instead of crashing the script.
- `main(argv)` returns the exit code (0, 1, or 2 for a threshold outside (0, 100]) instead of calling `sys.exit`, and the tests mock `shutil.disk_usage` at the edge.

## Trade-offs

- No dependencies means no `psutil`, so no inode counts or per-mount details.
- The script reports usage percent only, not trends.
- It needs Python 3.10+ for the `list[str] | None` annotations.

## When not to use it

- For fleet-wide monitoring; use node_exporter and alerting.
- For a one-off check, `df -h` is enough.
