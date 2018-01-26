# Run with mininet support 

## Build 

* 透過 build.py 來完成網路環境的建置工作
    * 把建置的動作放在 mininet 當中完成
    * 一樣是 `run-directly` 的 scenario 來做實現

* 由於建立起 switch 間的連結後， host1 就可以直接傳送封包到 host2 上
    * 考慮如何在這個環境中使用 P4