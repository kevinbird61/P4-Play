#!/bin/bash
# Using the same scenario of basic forwarding !
chmod +x ../net_build/build.py
# compile P4 program under psa/
p4c-bm2-ss --p4v 16 ../psa/fetch_packet_info_switch.p4 -o ../psa/fetch_packet_info_switch.p4.json
# run build
sudo ../net_build/build.py --behavioral-exe simple_switch --json ../psa/fetch_packet_info_switch.p4.json

# forwarding debug
#sudo ../net_build/build.py --behavioral-exe simple_switch --json basic_forwarding/simple_router.p4.json