# Run with Docker

這邊使用 docker 代表 host，並以連線到同一個 bridge 上的 docker 作為同個 AS (Autonomous system) 使用

## 建立環境

* Requirement
    * 安裝 docker
    * 從 docker-hub 上面拉下實驗所需的 docker images

* 運行腳本 
    * scenario 1: `ipv4` <-> `ipv4/ipv6` 間的 translation 問題
        * `./ipv4_6_trans.sh`: 建立 bridge (ipv4, ipv6)
        * `make`：編譯所需的 p4 程式
