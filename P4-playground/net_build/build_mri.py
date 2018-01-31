#!/usr/bin/python
import os
import sys
import argparse

from mininet.cli import CLI
from mininet.topo import Topo 
from mininet.net import Mininet
from mininet.link import TCLink
from mininet.log import setLogLevel, info
from time import sleep

# Loading self-defined module
from p4_mininet import P4Switch, P4Host

# Using argparse to parse the argument
parser = argparse.ArgumentParser(description='Run Mininet with P4 Support(Multiple Switch)')
parser.add_argument('--behavioral-exe',help='Specify the behaviroal executable',
                    type=str,action="store",required=True)
parser.add_argument('--thrift-port',help='Thrift server port for CLI tool to update table entries',
                    type=int,action="store",default="9090")
#parser.add_argument('--num-hosts',help='Number of hosts to connect to switch',
#                    type=int,action="store",default=2)
parser.add_argument('--mode',choices=['l2','l3'],type=str,default='l3')
parser.add_argument('--json', help='Path to JSON config file',
                    type=str, action="store", required=True)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
                    type=str, action="store", required=False, default=False)

args = parser.parse_args()

class multiSwitchTopo(Topo):
    def __init__(self, sw_path, json_path, thrift_port, pcap_dump, **opts):
        # initialize topology and default options
        Topo.__init__(self, **opts)
        
        # implement several switches
        s1 = self.addSwitch('s1',
                        sw_path=sw_path,
                        json_path=json_path,
                        thrift_port=thrift_port,
                        pcap_dump=pcap_dump)
        s2 = self.addSwitch('s2',
                        sw_path=sw_path,
                        json_path=json_path,
                        thrift_port=thrift_port+1,
                        pcap_dump=pcap_dump)
        s3 = self.addSwitch('s3',
                        sw_path=sw_path,
                        json_path=json_path,
                        thrift_port=thrift_port+2,
                        pcap_dump=pcap_dump)
        # Create hosts
        h1 = self.addHost('h1',
                    ip="10.0.1.10/24",
                    mac='00:04:00:00:00:01')
        h11 = self.addHost('h11',
                    ip="10.0.1.11/24",
                    mac='00:04:00:00:00:11')
        h2 = self.addHost('h2',
                    ip="10.0.2.10/24",
                    mac='00:04:00:00:00:02')
        h22 = self.addHost('h22',
                    ip="10.0.2.11/24",
                    mac='00:04:00:00:00:21')
        h3 = self.addHost('h3',
                    ip="10.0.3.10/24",
                    mac='00:04:00:00:00:03')
        # Create links
        self.addLink(h1,s1,addr1='00:04:00:00:00:01',addr2='00:aa:bb:00:01:01',intfName1="eth0",intfName2="s1-eth1")
        self.addLink(h11,s1,addr1='00:04:00:00:00:11',addr2='00:aa:bb:00:11:11',intfName1="eth0",intfName2="s1-eth11")
        self.addLink(h2,s2,addr1='00:04:00:00:00:02',addr2='00:aa:bb:00:02:02',intfName1="eth0",intfName2="s2-eth1")
        self.addLink(h22,s2,addr1='00:04:00:00:00:21',addr2='00:aa:bb:00:21:21',intfName1="eth0",intfName2="s2-eth22")
        self.addLink(h3,s3,addr1='00:04:00:00:00:03',addr2='00:aa:bb:00:03:03',intfName1="eth0",intfName2="s3-eth1")

        self.addLink(s1,s2,addr1='00:aa:bb:00:01:02',addr2='00:aa:bb:00:02:01',intfName1="s1-eth2",intfName2="s2-eth2",bw=0.5,latency='0ms',max_queue_size=1000)
        self.addLink(s2,s3,addr1='00:aa:bb:00:02:03',addr2='00:aa:bb:00:03:02',intfName1="s2-eth3",intfName2="s3-eth2")
        self.addLink(s3,s1,addr1='00:aa:bb:00:03:01',addr2='00:aa:bb:00:01:03',intfName1="s3-eth3",intfName2="s1-eth3")

def main():
    "Create our test Topo"
    mode = args.mode

    # Create topology of our network environment
    topo = multiSwitchTopo(args.behavioral_exe,
                            args.json,
                            args.thrift_port,
                            args.pcap_dump)
    
    # Build mininet by topo (using our self-defined class)
    net = Mininet(topo=topo,
            host= P4Host,
            switch= P4Switch,
            link = TCLink,
            controller= None)
    net.start()
    
    # set routing table on each host
    h1 = net.get('h1')
    h1.setARP("10.0.1.1","00:aa:bb:00:01:01")
    h1.setDefaultRoute("dev eth0 via %s" % "10.0.1.1")
    h11 = net.get('h11')
    h11.setARP("10.0.1.1","00:aa:bb:00:11:11")
    h11.setDefaultRoute("dev eth0 via %s" % "10.0.1.1")

    h2 = net.get('h2')
    h2.setARP("10.0.2.1","00:aa:bb:00:02:02")
    h2.setDefaultRoute("dev eth0 via %s" % "10.0.2.1")
    h22 = net.get('h22')
    h22.setARP("10.0.2.1","00:aa:bb:00:21:21")
    h22.setDefaultRoute("dev eth0 via %s" % "10.0.2.1")

    h3 = net.get('h3')
    h3.setARP("10.0.3.1","00:aa:bb:00:03:03")
    h3.setDefaultRoute("dev eth0 via %s" % "10.0.3.1")

    sleep(1)

    print "====== Building process end ======"

    CLI(net)

    print "====== Close topology ======"
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    main()