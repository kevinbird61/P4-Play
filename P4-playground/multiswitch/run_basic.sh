#!/bin/bash
chmod +x ./build.py
# compile
p4c-bm2-ss --p4v 16 basic_forwarding/simple_router.p4 -o basic_forwarding/simple_router.p4.json
# run build
sudo ./build.py --behavioral-exe simple_switch --json basic_forwarding/simple_router.p4.json