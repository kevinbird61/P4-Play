# 安裝教學

## 透過 P4 tutorial 內的 vagrant 腳本改寫

* 改寫 p4lang/tutorials 內專案中 vm 提供的安裝腳本 `root-bootstrap.sh`, `user-bootstrap.sh` 來做修改，並可以直接適用於 **ubuntu 16.04** 的環境上

```bash
# Step 1 - install dependencies
./root-bootstrap.sh

# Step 2 - install environment for p4
./user-bootstrap.sh
```

## 先前的個人安裝方式

修正部份安裝腳本內容，並且分解成多個安裝腳本使用！
* Step 1
    * 需要先安裝 grpc, 以及 protobuf 的相依性
    * 可以使用 `install_grpc.sh` 腳本來提供這兩個部份的安裝！
    * 再來安裝 nanomsg： `install_nanomsg.sh` (這部份不確定有沒有包含在 `bmv2` 官方提供的 install_dep.sh 當中 )
* Step 2
    * 安裝 p4c: `install_p4c.sh`
* Step 3
    * 安裝 PI: `install_PI.sh`
* Step 4
    * 安裝 bmv2: `install_bmv2.sh`
* `Other`
    * [如何安裝 `simple_switch_grpc`?](install_simple_switch_grpc.md)

> [補充] 如果要使用 PI 的功能，則需要先使用 install_PI.sh 再使用 install_bmv2.sh
> 
> [補充] 啟用 simple_switch_grpc 需要額外編譯 grpc 模組！ 以及使用 install_gNMI_support.sh 來安裝 gNMI 的支援！ (詳細參考 bmv2 的專案資料夾內 targets/simple_switch_grpc 內的說明文件)
>
> [補充] 使用 P4Runtime: 重新編譯後的 PI, 在[p4lang/tutorial 教學](https://github.com/p4lang/tutorials/tree/master/P4D2_2017_Fall/exercises/p4runtime)中一直無法讓 `mycontroller.py` 正確執行, 並且目前沒有人 focus 在這部份做討論; 目前的 issue 只看到[這個](https://github.com/p4lang/tutorials/issues/109)有討論到這個問題，但最後結論是回到使用 VM
> -> Solution : 使用 P4 官方提供的 vm
> -> 2018/2/8 : 發現問題在 PI/proto/ 底下使用 `p4runtime.proto` 在新的版本有改動過，進而使得 tutorial 當中的 controller 程式無法使用（ mycontroller.py 使用的相關 library, 會使用編譯產生的 grpc python 相依性，其中由於原始 `p4runtime.proto` 的改動，導致後來的 behavior 產生異常; 如果要在最新的環境上使用 P4Runtime，需要額外修改 mycontroller 的相依性中的內容！ ） 往後的 P4Runtime 研究會放到[這裡做紀錄](solve_p4runtime_usage_record.md)

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