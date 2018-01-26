# clean all namespace
sudo ip netns delete h1
sudo ip netns delete h2

# using mn to clean
sudo mn -c

# remove *.p4.json
rm rf *.p4.json