# tcpdump recipes

Replace `eth0` with your interface. Add `-nn` to skip DNS and port-name lookups, `-c N` to stop after N packets.

```bash
# HTTP requests to the Orders API on 8080
sudo tcpdump -i eth0 -nn -A 'tcp port 8080 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# TCP handshake problems: SYNs and RSTs only
sudo tcpdump -i eth0 -nn 'tcp[tcpflags] & (tcp-syn|tcp-rst) != 0'

# DNS queries and answers
sudo tcpdump -i eth0 -nn udp port 53

# One host, both directions, saved to a file for Wireshark
sudo tcpdump -i eth0 -nn host 10.0.0.5 -w orders.pcap

# Read a capture, filter to a conversation
tcpdump -nn -r orders.pcap 'host 10.0.0.5 and tcp port 5432'

# Rotate captures: 10 files of 50 MB
sudo tcpdump -i any -nn -C 50 -W 10 -w ring.pcap

# ICMP only (ping, unreachable)
sudo tcpdump -i eth0 -nn icmp

# Inside a namespace (see netns-iptables)
sudo ip netns exec shop tcpdump -i veth-shop -nn -c 20
```
