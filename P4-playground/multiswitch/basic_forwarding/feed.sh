#!/bin/bash
simple_switch_CLI --thrift-port 9090 < basic_rules_s1.txt
simple_switch_CLI --thrift-port 9091 < basic_rules_s2.txt
simple_switch_CLI --thrift-port 9092 < basic_rules_s3.txt