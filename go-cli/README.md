# go-cli

A small Go command, `orders-cli` (`main.go`, `main_test.go`), that totals `customer,total` lines per customer from stdin or a file.

## Goal

Show a standard-library-only Go CLI (module `example.com/orders-cli`, Go 1.22) structured around `run(args, stdin, stdout, stderr) int` so it can be tested without a subprocess.

## Run it

```bash
go test ./...
printf 'ana,10.5\nbo,4.25\nana,5\n' | go run .
CGO_ENABLED=0 go build -o orders-cli .
```

Expected: the tests pass; the pipeline prints `ana 15.50` and `bo 4.25`; the build produces one static binary. Use `-f file.csv` instead of stdin to read a file.

Not run end to end: the Go toolchain is not installed where this README was written, so neither the tests nor the build were executed.

## What it proves

- `main` is one line, `os.Exit(run(...))`; all behaviour sits in `run` and `Totals`, which tests drive with in-memory readers and buffers.
- `main_test.go` covers three cases: correct totals, a bad line (exit 1) and a missing `-f` file (exit 1); a flag parse error returns 2.
- Output is sorted by customer, so it is deterministic.

## Trade-offs

- The `flag` package has no subcommands or completions; use cobra or urfave/cli if you need them.
- Totals use `float64`, which is not suitable for real money.
- Input format is strict: exactly two comma-separated fields, no quoting.

## When not to use it

- For a few lines of glue, a Bash or Python script is quicker (see `bash-strict-mode-bats`, `python-ops`).
