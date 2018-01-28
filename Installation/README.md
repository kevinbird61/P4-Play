# 安裝教學

如果在使用 `install.sh` 時發生錯誤，可以找尋下方連結內的說明做參考！

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


## 其他項目

* mininet 的圖形化介面： `miniedit`
    * 抓取 mininet 原始碼專案 `git clone https://github.com/mininet/mininet.git`
    * 安裝相依性 `sudo apt install python-tk`
    * 啟動！ `sudo ./mininet/examples/miniedit.py` 即可使用