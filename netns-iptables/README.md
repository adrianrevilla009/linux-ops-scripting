# netns-iptables

`netns-demo.sh` builds two network namespaces joined by a veth pair and uses iptables to block one port between them.

## Goal

Test a firewall rule safely and repeatably on a single machine, without touching the host's own network or rules.

## Run it

```bash
sudo bash netns-demo.sh
```

Expected: `ping ok`, then the rule `-A INPUT -s 10.200.0.2/32 -p tcp -m tcp --dport 8080 -j DROP`, then `PASS: port 8080 blocked, ping still allowed`.

Requires Linux, iproute2, iptables, python3 and root (or CAP_NET_ADMIN). Not run end to end: root was not available where this README was written, so the output above is what the script is written to print, not a captured run.

## What it proves

- The `shop` namespace (10.200.0.1) and the `client` namespace (10.200.0.2) each have their own interfaces and netfilter tables, so the rule is added inside `shop` only.
- A ping from `client` succeeds, while a TCP connect to `shop` on 8080 times out; the script exits 1 with `FAIL` if the port is reachable.
- A `trap` kills the test web server and deletes both namespaces on exit, so reruns start clean.

## Trade-offs

- It needs privileges, so it cannot run in unprivileged CI containers.
- It uses legacy `iptables` syntax; on modern hosts this may be mapped to nftables.
- The check is one blocked port; it does not cover stateful rules, NAT or IPv6.

## When not to use it

- For production firewall policy; prefer nftables or a managed firewall.
- For application-level network tests; Docker networks or Testcontainers are simpler.
