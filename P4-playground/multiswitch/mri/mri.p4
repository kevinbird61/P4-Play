#include <core.p4>
#include <v1model.p4>

const bit<8> UDP_PROTOCOL = 0x11;
const bit<16> TYPE_IPV4 = 0x0800;
const bit<5> IPV4_OPTION_MRI = 31;

#define MAX_HOPS 9

// ============ Header ============

typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;
typedef bit<32> switchID_t;
typedef bit<32> qdepth_t;

// ethernet header
header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16> etherType;
}

// ipv4 header
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

// ipv4 option
header ipv4_option_t {
    bit<1> copyFlag;
    bit<2> optClass;
    bit<5> option;
    bit<8> optionLength;
}

// mri 
header mri_t{
    bit<16> count;
}

// switch
header switch_t{
    switchID_t swid;
    qdepth_t qdepth;
}

// ingress metadata
struct ingress_metadata_t{
    bit<16> count;
}

// parser metadata 
struct parser_metadata_t{
    bit<16> remaining;
}

struct metadata {
    ingress_metadata_t ingress_metadata;
    parser_metadata_t parser_metadata;
}

struct headers{
    ethernet_t ethernet;
    ipv4_t ipv4;
    ipv4_option_t ipv4_option;
    mri_t mri;
    switch_t[MAX_HOPS] swtraces;
}

error {IPHeaderTooShort}

// ============ Parser ============

parser MRIParser(packet_in packet,
            out headers hdr,
            inout metadata meta,
            inout standard_metadata_t standard_metadata){
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
        // verify
        verify(hdr.ipv4.ihl >= 5, error.IPHeaderTooShort);
        transition select(hdr.ipv4.ihl){
            5: accept;
            default: parse_ipv4_option;
        }
    }

    state parse_ipv4_option{
        packet.extract(hdr.ipv4_option);
        transition select(hdr.ipv4_option.option){
            IPV4_OPTION_MRI: parse_mri;
            default: accept;
        }
    }

    state parse_mri{
        packet.extract(hdr.mri);
        // specified the remaining count from mri.count!
        meta.parser_metadata.remaining = hdr.mri.count;
        // if remaining=0, then accept
        // else parse swtrace
        transition select(meta.parser_metadata.remaining){
            0: accept;
            default: parse_swtrace;
        }
    }

    state parse_swtrace{
        packet.extract(hdr.swtraces.next);
        meta.parser_metadata.remaining = meta.parser_metadata.remaining-1;
        // if remaining not goes to an end, then parse again
        transition select(meta.parser_metadata.remaining){
            0: accept;
            default: parse_swtrace;
        }
    }
}

// ============ Checksum (Verify) ============

control MRIVerifyChecksum(inout headers hdr, inout metadata meta){
    apply { }
}

// ============ Ingress ============

control MRIIngress(inout headers hdr,
        inout metadata meta,
        inout standard_metadata_t standard_metadata){
    action drop(){
        mark_to_drop();
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port){
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl-1;
    }

    // table part
    table ipv4_lpm{
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size=1024;
        default_action=NoAction();
    }

    // apply
    apply {
        if(hdr.ipv4.isValid()){
            ipv4_lpm.apply();
        }
    }
}

// ============ Egress ============

control MRIEgress(inout headers hdr,
        inout metadata meta,
        inout standard_metadata_t standard_metadata){
    action add_swtrace(switchID_t swid){
        hdr.mri.count = hdr.mri.count + 1;
        hdr.swtraces.push_front(1);
        hdr.swtraces[0].swid = swid;
        hdr.swtraces[0].qdepth = (qdepth_t) standard_metadata.deq_qdepth;

        // add the ihl
        hdr.ipv4.ihl = hdr.ipv4.ihl + 2;
        hdr.ipv4_option.optionLength = hdr.ipv4_option.optionLength + 8;
    }

    // table
    table swtrace{
        actions = {
            add_swtrace;
            NoAction;
        }
        default_action = NoAction();
    }

    // apply the table 
    apply{
        if(hdr.mri.isValid()){
            swtrace.apply();
        }
    }
}

// ============ Checksum (Compute) ============

control MRIComputeChecksum(inout headers hdr,inout metadata meta){
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

// ============ Deparser ============

control MRIDeparser(packet_out packet, in headers hdr){
    apply{
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.ipv4_option);
        packet.emit(hdr.mri);
        packet.emit(hdr.swtraces);
    }
}

// ============ Switch ============

V1Switch(
    MRIParser(),
    MRIVerifyChecksum(),
    MRIIngress(),
    MRIEgress(),
    MRIComputeChecksum(),
    MRIDeparser()
)main;