# Step 1
sudo ip netns add h1
sudo ip netns add h2

# Step 2 (optional)
sudo ip netns exec h1 ip link set lo up
sudo ip netns exec h2 ip link set lo up

# Step 3
# build namespace for switch
# sudo ip netns add s1

# build first link: s1-eth1 <-> h1-eth0
sudo ip link add s1-eth1 type veth peer name h1-eth0
# sudo ip link set s1-eth1 netns s1
sudo ip link set h1-eth0 netns h1

# activate with IP address assign
sudo ip netns exec h1 ip link set dev h1-eth0 up
sudo ip netns exec h1 ip link set h1-eth0 address 00:0a:00:00:01:01
sudo ip netns exec h1 ip addr add 10.0.1.1/24 dev h1-eth0
# sudo ip netns exec s1 ip link set dev s1-eth1 up
sudo ip link set dev s1-eth1 up
# sudo ip netns exec s1 ip link set s1-eth1 address 00:00:00:00:10:10
sudo ip link set s1-eth1 address 00:00:00:00:10:10
#sudo ip netns exec s1 ip addr add 10.0.1.2/24 dev s1-eth1
sudo ip addr add 10.0.1.2/24 dev s1-eth1

# build second link: s1-eth2 <-> h2-eth0
sudo ip link add s1-eth2 type veth peer name h2-eth0
# sudo ip link set s1-eth2 netns s1
sudo ip link set h2-eth0 netns h2

# activate with IP address assign
sudo ip netns exec h2 ip link set dev h2-eth0 up
sudo ip netns exec h2 ip link set h2-eth0 address 00:0a:00:00:02:02
sudo ip netns exec h2 ip addr add 10.0.2.1/24 dev h2-eth0
#sudo ip netns exec s1 ip link set dev s1-eth2 up
#sudo ip netns exec s1 ip link set s1-eth2 address 00:00:00:00:20:20
#sudo ip netns exec s1 ip addr add 10.0.2.2/24 dev s1-eth2
sudo ip link set dev s1-eth2 up
sudo ip link set s1-eth2 address 00:00:00:00:10:10
sudo ip addr add 10.0.1.2/24 dev s1-eth2

## disable all ipv6 
sudo ip netns exec h1 sysctl net.ipv6.conf.h1-eth0.disable_ipv6=1
sudo ip netns exec h2 sysctl net.ipv6.conf.h2-eth0.disable_ipv6=1
sudo sysctl net.ipv6.conf.s1-eth1.disable_ipv6=1
sudo sysctl net.ipv6.conf.s1-eth2.disable_ipv6=1

# Step 4 (working, need to add routing table to h1,h2)
p4c-bm2-ss --p4v 16 forwarding.p4 -o forwarding.p4.json

## h1 routing table 
sudo ip netns exec h1 ip route add default via 10.0.1.2
#sudo ip netns exec h1 ip route add 10.0.2.2 via 10.0.1.2

## h2 routing table
sudo ip netns exec h2 ip route add default via 10.0.2.2
#sudo ip netns exec h2 ip route add 10.0.1.2 via 10.0.2.2

# Step 5 - Open terminal for h1,h2, for next step
sudo ip netns exec h1 xterm -xrm 'XTerm.vt100.allowTitleOps: false' -T host1 &
sudo ip netns exec h2 xterm -xrm 'XTerm.vt100.allowTitleOps: false' -T host2 &

# Run switch 
# Can't not run simple_switch in subprocess -> can not open thrift server in correct channel
# sudo ip netns exec s1 simple_switch -i 1@s1-eth1 -i 2@s1-eth2 --pcap --thrift-port 9090 --nanolog ipc:///tmp/bm-0-log.ipc --device-id 0 forwarding.p4.json --log-console
