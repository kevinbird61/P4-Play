#!/bin/bash
chmod +x ./load_balance/build_lb.py
# compile
p4c-bm2-ss --p4v 16 load_balance/load_balance.p4 -o load_balance/load_balance.p4.json
# run build
sudo ./load_balance/build_lb.py --behavioral-exe simple_switch --json load_balance/load_balance.p4.json

# For debugger 
#sudo ./load_balance/build_lb.py --behavioral-exe simple_switch --json basic_forwarding/simple_router.p4.json