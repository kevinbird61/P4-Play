// include essential library
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x0800;

/* define header, ethernet + ipv4 + tcp */
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;
typedef bit<16> port_t;

// ethernet
header ethernet_t{
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

// ipv4
header ipv4_t {
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

// tcp
header tcp_t {
    port_t srcPort;
    port_t dstPort;
    bit<32> seq_number;
    bit<32> ack_number;
    bit<4> data_offset;
    bit<3> reserved;
    bit<1> ns_flag;
    bit<1> cwr_flag;
    bit<1> ece_flag;
    bit<1> urg_flag;
    bit<1> ack_flag;
    bit<1> psh_flag;
    bit<1> pst_flag;
    bit<1> syn_flag;
    bit<1> fin_flag;
    bit<16> window_size;
    bit<16> checksum;
    bit<16> urg_pointer;
}

// then define ecmp group/selection in metadata
struct metadata {
    bit<14> ecmp_select;
}

// wrap headers 
struct headers{
    ethernet_t ethernet;
    ipv4_t ipv4;
    tcp_t tcp;
}

/* Parser */
parser LB_Parser(packet_in packet,  
            out headers hdr,
            inout metadata meta,
            inout standard_metadata_t standard_metadata){
    state start{
        // Step 1: Parse ethernet header
        transition parse_ethernet;
    }

    state parse_ethernet{
        // Take those bits to hdr.ethernet
        packet.extract(hdr.ethernet);
        // select
        transition select(hdr.ethernet.etherType){
            /* If match, go to Step 2 -> parse IPV4 header */
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        // select
        transition select(hdr.ipv4.protoc){
            /* if match, go to next step */
            6: parse_tcp;
            default: accept;
        }
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        // nothing more, just go accept end condition
        transition accept;
    }
}

/* Verify checksum */
control LB_VerifyChecksum(inout headers hdr, inout metadata meta){
    apply {}
}

/* Ingress */
control LB_Ingress(inout headers hdr,
        inout metadata meta,
        inout standard_metadata_t standard_metadata){
    // drop 
    action drop(){
        mark_to_drop();
    }
    // set the ecmp select result into meta.ecmp_select
    action set_ecmp_select(bit<16> ecmp_base, bit<32> ecmp_count){
        hash(meta.ecmp_select,
            HashAlgorithm.crc16,
            ecmp_base,
            {
                hdr.ipv4.srcAddr,
                hdr.ipv4.dstAddr,
                hdr.ipv4.protoc,
                hdr.tcp.srcPort,
                hdr.tcp.dstPort
            },
            ecmp_count);
    }
    // set next hop (not directly set egress port)
    action set_nhop(macAddr_t nhop_dmac, ipv4Addr_t nhop_ipv4, bit<9> port){
        // if match, then set the action result to destination mac addr
        hdr.ethernet.dstAddr = nhop_dmac;
        // also set ipv4 dst
        hdr.ipv4.dstAddr = nhop_ipv4;
        // then set egress spec (output port of switch)
        standard_metadata.egress_spec = port;
        // standard_metadata.egress_port = port;
        // ttl dec
        hdr.ipv4.ttl = hdr.ipv4.ttl -1;
    }

    /* table - ecmp_group */
    table ecmp_group{
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions={
            drop;
            set_ecmp_select;
        }
        size=1024;
    }
    /* table - ecmp_nhop */
    table ecmp_nhop{
        // using the ecmp_select result (from table ecmp_group)
        key = {
            meta.ecmp_select: exact;
        }
        actions={
            drop;
            set_nhop;
        }
        // maximum only can hop 2 times 
        size=2;
    }
    
    // apply table
    apply{
        if(hdr.ipv4.isValid() && hdr.ipv4.ttl > 0){
            // apply first table 
            ecmp_group.apply();
            // then using the result to trigger nhop
            ecmp_nhop.apply();
        }
    }
}

/* Egress */
control LB_Egress(inout headers hdr,
        inout metadata meta,
        inout standard_metadata_t standard_metadata){
    action drop(){
        mark_to_drop();
    }
    // rewrite mac addr
    action rewrite_mac(macAddr_t smac){
        // rewrite source mac address
        hdr.ethernet.srcAddr = smac;
    }

    /* table - send_frame */
    table send_frame{
        /* if matching egress_port */
        /* FIXME: why egress_port? not using egress_spec? */
        key={
            standard_metadata.egress_port: exact;
            // standard_metadata.egress_spec: exact;
        }
        actions = {
            rewrite_mac;
            drop;
        }
    }

    /* apply table */
    apply{
        send_frame.apply();
    }
}

/* Compute Checksum */
control LB_ComputeChecksum(inout headers hdr, inout metadata meta){
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

/* Deparser */
control LB_Deparser(packet_out packet, in headers hdr){
    apply{
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
    }
}

V1Switch(
LB_Parser(),
LB_VerifyChecksum(),
LB_Ingress(),
LB_Egress(),
LB_ComputeChecksum(),
LB_Deparser()
) main;