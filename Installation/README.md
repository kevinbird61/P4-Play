# 安裝教學

修正部份安裝腳本內容，並且分解成多個安裝腳本使用！
* Step 1
    * 需要先安裝 grpc, 以及 protobuf 的相依性
    * 可以使用 `install_grpc.sh` 腳本來提供這兩個部份的安裝！
    * 再來安裝 nanomsg： `install_nanomsg.sh` (這部份不確定有沒有包含在 `bmv2` 官方提供的 install_dep.sh 當中 )
* Step 2
    * 安裝 p4c: `install_p4c.sh`
* Step 3
    * 安裝 bmv2: `install_bmv2.sh`
* Step 4
    * 安裝 PI: `install_PI.sh`

相關安裝的紀錄可以在下方連結內的說明做參考！

---

* [p4c build from source](https://paper.dropbox.com/doc/p4c-Build-from-source-3EVmYVpUepVjM9ts93ZYp)
* [bmv2 build from source](https://paper.dropbox.com/doc/bmv2-build-from-source-cIjFvhmRliz7XLjn87ogR)
    * 如果要額外啟用幾項功能，在 configure 的時候記得加上：
        * code coverage tracking: `--enable-coverage`
        * simple_switch debugger 可啟用 debugger 功能: `--enable-debugger`
        * 啟用 PI（P4Runtime）: `--with-pi`
        * 啟用 thrift (預設值): `--with-thrift`
        * 如果想要額外啟用 P4Thrift，需要到 `p4lang/thrift` 底下編譯使用（為 P4 自行建立的 thrift 版本），再透過 `--with-p4thrift` 做配置使用
    * [`simple_switch_grpc` 相關使用](https://github.com/p4lang/behavioral-model/tree/master/targets/simple_switch_grpc)
        * 使用 gRPC 的溝通方式，而不使用 thrift server
        * gRPC 的部份有可能會和 thrift 衝突，所以建議擇一安裝
* [PI build from source](https://paper.dropbox.com/doc/PI-build-from-source-yfuGBukgVA5643tbCOhHD)

目前安裝過的幾個系統：
* ubuntu 16.04: `4.13.0-31-generic #34~16.04.1-Ubuntu SMP Fri Jan 19 17:11:01 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux`
* lubuntu 17.10: `4.13.0-25-generic #29-Ubuntu SMP Mon Jan 8 21:14:41 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux`

> 另外一些有趣的問題也會紀錄在 `P4-playground` 底下喔！

## 其他項目

* mininet 的圖形化介面： `miniedit`
    * 抓取 mininet 原始碼專案 `git clone https://github.com/mininet/mininet.git`
    * 安裝相依性 `sudo apt install python-tk`
    * 啟動！ `sudo ./mininet/examples/miniedit.py` 即可使用