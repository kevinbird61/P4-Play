// implementation of FPI: fetch packet info
#include <core.p4>
#include <v1model.p4>

// define
const bit<16> TYPE_IPV4 = 0x0800;

// data type
typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;

// ethernet
header ethernet_t{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

// ipv4
header ipv4_t{
    bit<4> version;
    bit<4> ihl;
    bit<8> tos;
    bit<16> totallen;
    bit<16> id;
    bit<3> ip_flags;
    bit<13> frag_offset;
    bit<8> ttl;
    bit<8> protoc;
    bit<16> checksum;
    ipv4Addr_t srcAddr;
    ipv4Addr_t dstAddr;
}

header packet_info_t{
    // record some information about this packet( in switch)
    bit<32> enq_timestamp;
    bit<19> enq_qdepth;
    bit<32> deq_timedelta;
    bit<19> deq_qdepth;
}

struct metadata{
    /* empty */
}

// wrap our headers
struct headers{
    ethernet_t ethernet;
    ipv4_t ipv4;
    packet_info_t packet_info;
}

/* Parser */
parser FPI_Parser(packet_in packet,
    out headers hdr,
    inout metadata meta,
    inout standard_metadata_t standard_metadata){
    
    // start
    state start{
        transition parse_ethernet;
    }

    state parse_ethernet{
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType){
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4{
        packet.extract(hdr.ipv4);
        transition parse_packet_info;
    }

    state parse_packet_info{
        packet.extract(hdr.packet_info);
        transition accept;
    }
}

// Verify Checksum
control FPI_VerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}

// Ingress
control FPI_Ingress(inout headers hdr,
                    inout metadata meta,
                    inout standard_metadata_t standard_metadata){
    action drop(){
        mark_to_drop();
    }

    action copy_pkt_info(){
        hdr.packet_info.enq_timestamp = standard_metadata.enq_timestamp;
        hdr.packet_info.enq_qdepth = standard_metadata.enq_qdepth;
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
        // call another action
        copy_pkt_info();
    }

    table ipv4_lpm{
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    apply{
        if(hdr.ipv4.isValid()){
            ipv4_lpm.apply();
        }
    }
}

// Egress
control FPI_Egress(inout headers hdr,
        inout metadata meta,
        inout standard_metadata_t standard_metadata){
    // table
    table swtrace{
        actions = {
            NoAction;
        }
        default_action = NoAction();
    }

    // apply the table 
    apply{
        if(hdr.packet_info.isValid()){
            swtrace.apply();
        }
    }
}

// Compute Checksum
control FPI_ComputeChecksum(inout headers hdr,inout metadata meta){
    apply{
        update_checksum(
            hdr.ipv4.isValid(),
            {
                hdr.ipv4.version,
                hdr.ipv4.ihl,
                hdr.ipv4.tos,
                hdr.ipv4.totallen,
                hdr.ipv4.id,
                hdr.ipv4.ip_flags,
                hdr.ipv4.frag_offset,
                hdr.ipv4.ttl,
                hdr.ipv4.protoc,
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr
            },
            hdr.ipv4.checksum,
            HashAlgorithm.csum16
        );
    }
}

// Deparser
control FPI_Deparser(packet_out packet, in headers hdr){
    apply{
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.packet_info);
    }
}

V1Switch(
FPI_Parser(),
FPI_VerifyChecksum(),
FPI_Ingress(),
FPI_Egress(),
FPI_ComputeChecksum(),
FPI_Deparser()
) main;