# Run with mininet support 

## Build 

* 透過 build.py 來完成網路環境的建置工作
    * 把建置的動作放在 mininet 當中完成
    * 使用單一一個 switch 的 scenario (Single Switch Topo)
    * 實作 bmv2 專案中， `1sw_demo.py` 的動作

* 檔案配置：
    * `build.py`: 建立可使用的網路環境（ with P4 Switch）
    * `p4_mininet.py`: 提供 P4 相關物件的實作
    * `simple_router.p4`: 執行簡單 routing 動作的 switch，提供給 *simple_switch* 做呼叫使用
    * `basic_rules.txt`: 提供給 *simple_switch_CLI* 做載入

## Run

* Step 1: 運行 `build.py` 來建立網路環境，並且編譯 P4 程式

```bash
# (optional) change mode
chmod +x build.py

# compile P4 program
p4c-bm2-ss --p4c 16 simple_router.p4 -o simple_router.p4.json

# execute it by sudoer or root
sudo ./build.py --behavioral-exe simple_switch --json simple_router.p4.json
```

* Step 2: 程式運行完成後，會進入到 mininet CLI 當中； 這時透過 xterm 的輔助開啟兩個新的視窗，個別給與 h1(host1), h2(host2)
    * 執行結束後，進入 mininet CLI：
    ```bash
    mininet> xterm h1 h2
    ```
    * 分別於各自的視窗中，執行 `send.py`, `receive.py`
        * h1 為例
            * 由於 h1 的 ip 位置為 `10.0.0.10` (由 `p4_mininet.py` 做設定)，`10.0.1.10` 則是 h2
        ```bash
        ./send.py 10.0.1.10 "P4"
        ```
        * 而 h2 則先開啟 receive.py 做接收
        ```bash
        ./receive.py
        ```
    * 到這邊運行結果是 h1 無法正確的傳送封包到 h2 上；原因為內部的配對表沒有建立，接下來便是透過 `simple_switch_CLI` 來動態加入！

* Step 3: 透過 `simple_switch_CLI` 來加入規則
    * 這邊可以看到目錄中的 `basic_rules.txt` 內部寫的規則，告訴 simple_switch 在這些機制成功配對的情況下，該做哪些動作
    * 有了這些規則，我們便可以呼叫 simple_switch_CLI 並且把 basic_rules.txt 的規則 pipe 給它
    ```bash
    simple_switch_CLI < basic_rules.txt
    ```
    * 加入後，再次嘗試 Step 2 後半的步驟，就可以看到傳送成功了！

## Why ?

* 關鍵的部份除了我們已知的 `simple_router.p4` 這支程式外，重要的是匯入的這個規則！
* `simple_router.p4` 內定義的是一個 "規矩"，可以看到 `MyIngress` 的 control block 中， ipv4_forward 的配對條件是 `lpm`；表示在這個 key 值符合 "規矩" 之後，就可以進到 ipv4_forward 當中！
* 而這時比對的項目: `hdr.ipv4.dstAddr` 要找誰來做比對呢？ 這時就需要透過 **simple_switch_CLI** 來匯入規則啦！
    * 讓我們來看看 `basic_rules.txt` 內寫了什麼吧！
    ```bash
    table_set_default ipv4_lpm drop
    table_add ipv4_lpm ipv4_forward 10.0.0.10/32 => 00:04:00:00:00:00 1
    table_add ipv4_lpm ipv4_forward 10.0.1.10/32 => 00:04:00:00:00:01 2
    ```
    * 和 iptables 的用法有點類似， 第1行先行設定全部做 drop； 再來第2行則是設定剛剛提到的規矩：
        * simple_switch_CLI 的 `table_add` 語法為：
        ```bash
        table_set_default <table name> <action name> <action parameters>
        table_add <table name> <action name> <match fields> => <action parameters> [priority]
        table_delete <table name> <entry handle>
        ```
        * 可以看到我們在 ipv4_lpm 的 table 中， ipv4_forward 這個 action 內加入 key 值：
            * `10.0.0.10/32` 為 h1 的 IP 位置，表示當看到 dstAddr 的時候，會把這個封包導向 00:04:00:00:00:00 的對口中（也就是 h1 的 MAC addr）
            * 以此類推，下面的那個是 h2 的版本
        * 目標與 parameter 這部份主要依據你寫的 P4 內容而異
            * 並且在最後面能夠加上 priority!