#!/usr/bin/env bash
# Two network namespaces joined by a veth pair; iptables in "shop" drops traffic from "client" to port 8080.
# Needs root (or CAP_NET_ADMIN). Cleans up after itself.
set -euo pipefail

cleanup() {
  ip netns del shop 2>/dev/null || true
  ip netns del client 2>/dev/null || true
}
trap cleanup EXIT

ip netns add shop
ip netns add client
ip link add veth-shop type veth peer name veth-client
ip link set veth-shop netns shop
ip link set veth-client netns client
ip -n shop addr add 10.200.0.1/24 dev veth-shop
ip -n client addr add 10.200.0.2/24 dev veth-client
ip -n shop link set veth-shop up
ip -n client link set veth-client up
ip -n shop link set lo up

echo "== baseline: client reaches shop"
ip netns exec client ping -c1 -W1 10.200.0.1 >/dev/null && echo "ping ok"

echo "== drop tcp/8080 from client"
ip netns exec shop iptables -A INPUT -s 10.200.0.2 -p tcp --dport 8080 -j DROP
ip netns exec shop iptables -S INPUT

ip netns exec shop python3 -m http.server 8080 --bind 10.200.0.1 >/dev/null 2>&1 &
server=$!
trap 'kill $server 2>/dev/null || true; cleanup' EXIT
sleep 1

if ip netns exec client python3 -c "
import socket,sys
s=socket.socket(); s.settimeout(2)
sys.exit(0 if s.connect_ex(('10.200.0.1',8080))==0 else 1)"; then
  echo "FAIL: port 8080 reachable"
  exit 1
fi
echo "PASS: port 8080 blocked, ping still allowed"
