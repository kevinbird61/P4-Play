# Step 1
sudo ip netns add h1
sudo ip netns add h2

# Step 2 (optional)
sudo ip netns exec h1 ip link set lo up
sudo ip netns exec h2 ip link set lo up

# Step 3
# build namespace for switch
sudo ip netns add s1

# build first link: s1-eth1 <-> h1-eth0
sudo ip link add s1-eth1 type veth peer name h1-eth0
sudo ip link set s1-eth1 netns s1
sudo ip link set h1-eth0 netns h1

# activate with IP address assign
sudo ip netns exec h1 ip link set h1-eth0 up
sudo ip netns exec h1 ip addr add 10.0.1.1/24 dev h1-eth0
sudo ip netns exec s1 ip link set s1-eth1 up
sudo ip netns exec s1 ip addr add 10.0.1.2/24 dev s1-eth1

# build second link: s1-eth2 <-> h2-eth0
sudo ip link add s1-eth2 type veth peer name h2-eth0
sudo ip link set s1-eth2 netns s1
sudo ip link set h2-eth0 netns h2

# activate with IP address assign
sudo ip netns exec h2 ip link set h2-eth0 up
sudo ip netns exec h2 ip addr add 10.0.2.1/24 dev h2-eth0
sudo ip netns exec s1 ip link set s1-eth2 up
sudo ip netns exec s1 ip addr add 10.0.2.2/24 dev s1-eth2

# Step 4 (working, need to add routing table to h1,h2)
p4c-bm-ss --p4v 16 forwarding.p4 -o forwarding.p4.json