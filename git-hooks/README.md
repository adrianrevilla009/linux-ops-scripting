# git-hooks

A strict-mode `pre-commit` hook and `test-hook.sh`, which tests the hook in a throwaway repository.

## Goal

Show a hook that rejects commits adding secret-looking strings or shell scripts with syntax errors, and show that a hook can be tested like any other script.

## Run it

```bash
bash test-hook.sh
install -m 755 pre-commit .git/hooks/pre-commit   # run from the root of a repo
```

Expected: `clean commit allowed`, then `PASS: secret commit blocked`, exit code 0.

Not run end to end: `test-hook.sh` was not executed where this README was written, so the output above is what it is written to print.

## What it proves

- The hook greps the added lines of the staged diff for an AWS access key (`AKIA` plus 16 characters), a private key header or a `ghp_` token, and exits 1 with a message on stderr.
- Staged `*.sh` files are checked with `bash -n`, so a syntax error blocks the commit.
- The test creates a temp repo, installs the hook, commits a clean `ok.sh`, then fails if a file containing an AWS-key-shaped string can be committed. The key is split in the source so the test file itself does not trip the pattern.

## Trade-offs

- Hooks live in `.git/hooks`, are not versioned and are skipped by `--no-verify`; share them with `core.hooksPath` or the pre-commit framework and repeat the checks in CI.
- Regex detection misses many secrets; use gitleaks for real coverage.
- The hook scans only the diff, not the commit message or untracked files.

## When not to use it

- When checks are slow; hooks should finish in under a second.
- When CI already enforces the same rules and local friction is unwanted.
