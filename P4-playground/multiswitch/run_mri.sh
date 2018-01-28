#!/bin/bash
chmod +x ./mri/build_mri.py
# compile
p4c-bm2-ss --p4v 16 mri/mri.p4 -o mri/mri.p4.json
# run build
sudo ./mri/build_mri.py --behavioral-exe simple_switch --json mri/mri.p4.json

# For debugger 
# sudo ./mri/build_mri.py --behavioral-exe simple_switch --json basic_forwarding/simple_router.p4.json