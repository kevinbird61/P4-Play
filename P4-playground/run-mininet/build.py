#!/usr/bin/python

import argparse

from mininet.cli import CLI
from mininet.topo import Topo 
from mininet.net import Mininet
from mininet.log import setLogLevel, info
from time import sleep

# Loading self-defined module
from p4_mininet import P4Switch, P4Host

# Using argparse to parse the argument
parser = argparse.ArgumentParser(description='Run Mininet with P4 Support')
parser.add_argument('--behavioral-exe',help='Specify the behaviroal executable',
                    type=str,action="store",required=True)
parser.add_argument('--thrift-port',help='Thrift server port for CLI tool to update table entries',
                    type=int,action="store",default="9090")
parser.add_argument('--num-hosts',help='Number of hosts to connect to switch',
                    type=int,action="store",default=2)
parser.add_argument('--mode',choices=['12','13'],type=str,default='13')
parser.add_argument('--json', help='Path to JSON config file',
                    type=str, action="store", required=True)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
                    type=str, action="store", required=False, default=False)

args = parser.parse_args()

class singleSwitchTopo(Topo):
    def __init__(self, sw_path, json_path, thrift_port, pcap_dump, n, **opts):
        # initialize topology and default options
        Topo.__init__(self, **opts)

        switch = self.addSwitch('s1',
                        sw_path=sw_path,
                        json_path=json_path,
                        thrift_port=thrift_port,
                        pcap_dump=pcap_dump)
        # Create hosts
        for h in xrange(n):
            host = self.addHost('h%d' % (h+1),
                        ip="10.0.%d.10/24" % (h),
                        mac='00:04:00:00:00:%02x' % (h))
            self.addLink(host,switch)

def main():
    "Create our test Topo"
    num_hosts = args.num_hosts
    mode = args.mode

    # Create topology of our network environment
    topo = singleSwitchTopo(args.behavioral_exe,
                            args.json,
                            args.thrift_port,
                            args.pcap_dump,
                            num_hosts)
    
    # Build mininet by topo (using our self-defined class)
    net = Mininet(topo=topo,
            host= P4Host,
            switch= P4Switch,
            controller= None)
    net.start()

    sw_mac = ["00:aa:bb:00:00:%02x" % n for n in xrange(num_hosts)]

    sw_addr = ["10.0.%d.1" % n for n in xrange(num_hosts)]

    # set routing table
    for n in xrange(num_hosts):
        h = net.get('h%d' % (n + 1))
        if mode == "l2":
            h.setDefaultRoute("dev eth0")
        else:
            h.setARP(sw_addr[n], sw_mac[n])
            h.setDefaultRoute("dev eth0 via %s" % sw_addr[n])
    
    # show
    for n in xrange(num_hosts):
        h = net.get('h%d' % (n + 1))
        h.describe()

    sleep(1)

    print "====== Building process end ======"

    CLI(net)

    print "====== Close topology ======"
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    main()