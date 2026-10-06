# bash-strict-mode-bats

A strict-mode Bash script, `orders-report.sh`, that totals orders per customer from `orders.csv`, with a bats suite in `test/orders_report.bats`.

## Goal

Show a Bash script written defensively (`set -euo pipefail`, `IFS=$'\n\t'`, quoted expansions, distinct exit codes) and tested like any other program.

## Run it

```bash
bats test/                      # needs bats-core 1.10+
shellcheck orders-report.sh
./orders-report.sh orders.csv
```

Expected from the script: `ana 15.50` and `bo 4.25`, one per line, exit code 0. The bats run should report 4 passing tests.

Not run end to end: bats and shellcheck are not installed on the machine where this README was written, so the suite and the lint were not executed. The script itself was not executed either in that session.

## What it proves

- `orders-report.sh` exits 2 with a usage line when called without exactly one argument, and exits 1 when the file is unreadable (both covered in `orders_report.bats`).
- A row that does not have three fields or has a non-numeric total makes awk exit 3, and `pipefail` carries that failure out of the pipeline instead of dropping the row.
- Output is sorted by customer, so the test can assert exact lines.

## Trade-offs

- Strict mode has edge cases: `set -e` is ignored inside `if` conditions and some other contexts.
- The CSV parsing is naive: no quoted commas, no header validation beyond skipping line 1.
- Totals are printed with `%.2f` through awk floating point, which is fine for a demo but not for money.

## When not to use it

- When the logic grows past roughly 100 lines or needs real data structures; use Python or Go (see `python-ops`, `go-cli`).
- For CSV with quoting or embedded newlines; use a real CSV parser.
