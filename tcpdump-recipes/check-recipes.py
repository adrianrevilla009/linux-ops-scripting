#!/usr/bin/env python3
"""Offline sanity check: every tcpdump command in recipes.md has balanced quotes and no unknown flags."""
import re
import shlex
import sys
from pathlib import Path

KNOWN = {"-i", "-nn", "-A", "-w", "-r", "-c", "-C", "-W"}
text = Path(__file__).with_name("recipes.md").read_text()
cmds = [l.replace("sudo ", "", 1) for l in text.splitlines() if "tcpdump" in l and not l.startswith(("Replace", "#"))]
cmds = [c for c in cmds if c.startswith(("tcpdump", "ip netns"))]
bad = 0
for c in cmds:
    try:
        toks = shlex.split(c)
    except ValueError as e:
        print(f"FAIL quoting: {c} ({e})")
        bad += 1
        continue
    flags = {t for t in toks if re.fullmatch(r"-[A-Za-z]+", t)}
    if flags - KNOWN:
        print(f"FAIL unknown flags {flags - KNOWN}: {c}")
        bad += 1
print(f"{len(cmds)} recipes checked, {bad} bad")
sys.exit(1 if bad else 0)
