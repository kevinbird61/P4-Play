# P4 Playground

放置透過 python mininet API 使用的 P4，或是透過 ip netns 直接建置的專案！

## 目標

- [x] 學習如何直接用 linux 支援的 network 指令來使用 P4
    * 學習網路相關的 linux 指令集
    * 詳細可以參考 [`run-directly`](run-directly/)
- [x] 學習如何透過 mininet 來建立虛擬網路環境中使用 P4
    * 詳細可以參考 [`run-mininet`](run-mininet/), [`multiswitch`](multiswitch/)
    * 如果有其他有趣的專案，也會一併更新於此！
- [ ] 學習如何使用 P4Runtime 相關的操作（e.g. `simple_switch_grpc`, `P4Info` ... 等等的了解）
- 進一步使用在不同硬體裝置間使用
    - [ ] 一般數台主機間 ( 實際應用的 scenario )
    - [ ] NetFPGA

## 問題與解決

* 在 2018/2/1~ 2/2 的這段時間，剛好電腦重新安裝，所以順便重新整理一份安裝腳本，以及測試
* 發現在當下這個 [p4c 的 compiler 版本](https://github.com/p4lang/p4c/commit/5c61d1f65eeaff53b6755f816bcea28034622c3b) ，其產生的 json 格式會出現一個與以往不同的改動！
    * 在解析 p4c-bm2-ss 所編譯產生的 json 格式時發現，原本直接以 `table`, `action` 名稱直接命名的規則，在這版當中出現不同的結果！
    * 多了一個前綴： 用這個 table 或是 action 所在的 **control block** 的名稱作為其前綴！
    * 舉例來說，在 control block - `MyIngress` 內有 table - `ipv4_lpm` 以及 action `ipv4_forward`; 則原本的餵給 simple_switch_CLI 可以直接使用 `ipv4_lpm` 以及  `ipv4_forward`; 而在最新的改動後， 則需要加上 `MyIngress` 在前方，變成 `MyIngress.ipv4_lpm` 以及 `MyIngress.ipv4_forward` 來做使用！
> 所以專案內 `rules.txt` 可以依據你目前使用的 `p4c` 版本來做微調！
> 詳細可以參考: 
> 
> [p4lang/p4c - issue#1106](https://github.com/p4lang/p4c/pull/1106)
>     -> 解釋命名衝突的部份
> 
> [p4lang/tutorials - issue#113](https://github.com/p4lang/tutorials/issues/113#issuecomment-362638729)
>     -> 我在 p4lang/tutorial 所提出的問題處，作者提出的相關解釋

## 學習

* 針對 p4lang/tutorial/SIGCOMM2017 的學習紀錄：
    * [(dropbox paper)分析該專案使用的 python script](https://paper.dropbox.com/doc/P4-Tutorial-Python-Script-ERSVmVruRIjcoiFlUpj4T)
    * [(dropbox paper)範例練習紀錄](https://paper.dropbox.com/doc/SIGCOMM-2017-P4-Tutorial-FRFhXsQ8biI6uSeYIRhHn)
    
* mininet API 學習的專案：
    * [toolbuddy/mininet-python](https://github.com/toolbuddy/mininet-python)

* P4 Debugger 使用：
    * [P4 debugger manual](https://github.com/p4lang/behavioral-model/blob/master/docs/p4dbg_user_guide.md)

* grpc & protobuf 學習：
    * [grpc-practice](https://github.com/kevinbird61/grpc-practice)