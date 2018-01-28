#!/bin/bash
simple_switch_CLI --thrift-port 9090 < mri_rules_s1.txt
simple_switch_CLI --thrift-port 9091 < mri_rules_s2.txt
simple_switch_CLI --thrift-port 9092 < mri_rules_s3.txt