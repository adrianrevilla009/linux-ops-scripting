# tcpdump-recipes

`recipes.md` is a short cookbook of tcpdump commands, and `check-recipes.py` is an offline lint for them.

## Goal

Give copy-pasteable capture commands for common ops questions: HTTP payloads on port 8080, SYN and RST problems, DNS, one host to a pcap file, ring-buffer captures, ICMP and captures inside a namespace.

## Run it

```bash
python3 check-recipes.py
```

Expected: `8 recipes checked, 0 bad` and exit code 0. The script parses every `tcpdump` or `ip netns` line in `recipes.md` with `shlex`, then rejects unbalanced quotes and flags outside an allow-list (`-i -nn -A -w -r -c -C -W`).

To use a recipe, run it with `sudo` on a host you own, after replacing `eth0` with your interface. No recipe was run against real traffic; only the lint was executed.

## What it proves

- All eight recipes have balanced quoting and use only the allowed flags.
- The recipes cover a BPF payload filter (`tcp port 8080 and ...`), a flags filter (`tcp[tcpflags] & (tcp-syn|tcp-rst) != 0`) and rotation with `-C 50 -W 10`.
- The last recipe pairs with `netns-iptables`: it captures on `veth-shop` inside the `shop` namespace.

## Trade-offs

- The lint checks syntax only; it never captures packets, so filter semantics are not proven.
- BPF filters are fast but limited; for deep protocol decoding open the pcap in Wireshark or tshark.
- Captures can contain secrets and personal data, so store and share them carefully.

## When not to use it

- For TLS traffic, where payloads are opaque.
- At scale, where flow logs or eBPF-based tooling fit better.
