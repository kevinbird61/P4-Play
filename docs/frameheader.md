## IP/MAC Header

* MAC Layer - **Ethernet Type II** Frame, which contain:
    ![](../Resource/res/ethernet_t.png)
    * `MAC Header`: (14 bytes)
        * Destination MAC Address: `6` bytes
        * Source MAC Address: `6` bytes
        * EtherType: `2` bytes
        這也是為什麼在範例中，使用的 `ethernet_t` 中使用的是 ( 48 + 48 + 16 ) bits 的格式（e.g. = MAC Header）
    * `Data`: (46~1500 bytes)
        * Payload(IP, ARP, etc.)
    * `CRC Checksum`: 4 bytes

* IP Header 
    ![](../Resource/res/ipv4_t.png)
    * `ip version`: 4 bits
    * `hdr lens`: 4 bits
    * `TOS (Type of Service)`: 8 bits
    * `Total Length`: 16 bits
    * `identification (Fragment ID)`: 16 bits
    * `flags (R, DF, MF)`: 3 bits
    * `fragment offset`: 13 bits
    * `TTL (Time-To-Live)`: 8 bits
    * `Protocol`: 8 bits
    * `Header Checksum`: 16 bits
    * `Source IP Address`: 32 bits
    * `Destination ID Address`: 32 bits
    ( P4 tutorial 擷取到這部份 )
    * `Options`: 32 bits
    * `Data`: leftover part (from 24 bytes ~ end)