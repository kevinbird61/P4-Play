#!/bin/bash
simple_switch_CLI --thrift-port 9090 < lb_rules_s1.txt
simple_switch_CLI --thrift-port 9091 < lb_rules_s2.txt
simple_switch_CLI --thrift-port 9092 < lb_rules_s3.txt