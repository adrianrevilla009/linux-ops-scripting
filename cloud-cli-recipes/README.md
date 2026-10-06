# cloud-cli-recipes

`recipes.md` holds read-only inspection commands for the AWS, Azure and GCP CLIs, and `check-recipes.sh` lints them offline.

## Goal

Collect one-liners for identity, compute, storage and logs that use `--query` or `--format` to keep output small, and make sure none of them changes anything.

## Run it

```bash
bash check-recipes.sh
```

Expected: `syntax ok`, then `PASS: recipes parse and are read-only`, exit code 0. The script extracts the `bash` blocks from `recipes.md`, checks them with `bash -n`, then fails if any of `delete`, `terminate`, `destroy`, `rm`, `put`, `create` or `update` appears.

Not run end to end: the lint was not executed where this README was written, and no recipe was run against a cloud account. To use the recipes, log in with your own profile first; the AWS ones use `--profile dev`.

## What it proves

- The recipes cover `aws sts get-caller-identity`, `az account show` and `gcloud config list`, then compute listings, an S3 listing and log reads on each cloud.
- The code blocks are valid shell syntax and contain none of the mutating words above.
- Cost: none. The commands only read metadata, so nothing is created and there is nothing to destroy.

## Trade-offs

- Nothing calls a cloud API, so flags are not checked against current CLI versions.
- The mutating-verb check is a coarse word match and can reject harmless text.
- `aws logs tail --follow` keeps running until interrupted.

## When not to use it

- For repeatable changes; use infrastructure as code such as Terraform or Bicep.
- For auditing at scale, where a dedicated inventory or cloud asset service is better.
