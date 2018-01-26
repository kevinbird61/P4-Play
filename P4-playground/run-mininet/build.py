#!/usr/bin/python

from mininet.cli import CLI
from mininet.topo import Topo 
from mininet.net import Mininet
from mininet.log import setLogLevel

class simpleSwitchTopo(Topo):
    def build(self):
        switch1 = self.addSwitch('s1')
        switch2 = self.addSwitch('s2')
        # create h1
        host1=self.addHost('h1')
        host2=self.addHost('h2')
        # create link
        self.addLink(host1,switch1)
        self.addLink(host2,switch2)
        self.addLink(switch1,switch2)

def createTopo():
    "Create our test Topo"
    topo=simpleSwitchTopo()
    net=Mininet(topo)
    net.start()
    # Open CLI
    CLI(net)
    # close
    print "Close the CLI"
    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    createTopo()