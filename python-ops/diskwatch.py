#!/usr/bin/env python3
"""Report filesystems above a usage threshold. Exit 0 if all fine, 1 if any exceed, 2 on bad usage."""
import argparse
import json
import shutil
import sys


def usage_pct(path: str) -> float:
    total, used, _ = shutil.disk_usage(path)
    return round(100 * used / total, 1) if total else 0.0


def check(paths: list[str], threshold: float) -> list[dict]:
    rows = []
    for p in paths:
        try:
            pct = usage_pct(p)
        except OSError as e:
            rows.append({"path": p, "error": str(e), "ok": False})
            continue
        rows.append({"path": p, "used_pct": pct, "ok": pct < threshold})
    return rows


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("paths", nargs="*", default=["/"])
    ap.add_argument("--threshold", type=float, default=90.0, help="percent used that counts as failing")
    args = ap.parse_args(argv)
    if not 0 < args.threshold <= 100:
        print("threshold must be in (0, 100]", file=sys.stderr)
        return 2
    rows = check(args.paths, args.threshold)
    print(json.dumps(rows))
    return 0 if all(r["ok"] for r in rows) else 1


if __name__ == "__main__":
    sys.exit(main())
