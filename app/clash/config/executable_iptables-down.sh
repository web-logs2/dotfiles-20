#!/bin/sh

iptables -D INPUT -i enp2s0 -d 192.168.1.7 -p tcp --dport 7892 -j REJECT
iptables -D OUTPUT -d 192.168.1.7 -p tcp --dport 7892 -m owner --gid-owner 2023 -j REJECT # 防止无线回环
iptables -t nat -D OUTPUT -p tcp -o enp2s0 -m owner ! --gid-owner 2023 -j CLASH

iptables -t nat -D PREROUTING -p tcp -j CLASH
iptables -t nat -F CLASH
iptables -t nat -X CLASH
iptables -t nat -D PREROUTING -p udp --dport 53 -j CLASH_DNS
iptables -t nat -F CLASH_DNS
iptables -t nat -X CLASH_DNS
echo 'iptables 已清理'
