# Programmable Switch Architecture

放置一些自己設計的 PSA 架構，以及一些 p4c 的使用

## 目錄

* [`fetch_packet_info_switch.p4`]()
    * 主要目的實作一個能夠在 ingress/egress 時紀錄 packet 在 switch 內的內容 packet

## 筆記

* 在 `v1model.p4` 中，可以看到使用的 metadata 之一： `standard_metadata_t` 內使用到一個叫作 `@alias` 的前綴，而其註解如下：

```
// @alias is used to generate the field_alias section of the BMV2 JSON.
// Field alias creates a mapping from the metadata name in P4 program to
// the behavioral model's internal metadata name. Here we use it to
// expose all metadata supported by simple switch to the user through
// standard_metadata_t.
```

* 繼續往下解析 BMv2 當中的 `internal metadata name`; 可以從官方的 bmv2 專案中找到相關的內容：
    * [field_alias](https://github.com/p4lang/behavioral-model/blob/master/docs/JSON_format.md#field_aliases)
* 並且可以看到 `queuing_metadata` 的 header:
    * [`queuing_metadata`](https://github.com/p4lang/behavioral-model/blob/master/docs/simple_switch.md#queueing_metadata-header)
    * 而這邊可以看到幾項性質：
        * `enq_timestamp`: 當一個 packet 第一次 enqueued 時的 timestamp (ms)
        * `enq_qdepth`: 當這個 packet 第一次 enqueued 時，目前的 queue 長度
        * `dep_timedelta`: 目前這個 packet 在 queue 中所花費的時間 (ms)
        * `dep_qdepth`: 當這個 packet dequeued 時，目前 queue 的長度
        * `qid`: 當有多個 queue 在服務每個 egress port （e.g. 當啟用 priority queuing），每個 queue 會賦予一個固定的 id; 而這個值則會存在 `qid`
    > 這部份可以看到，在 `simple_switch` 中可以獲得如同真實 switch 上可以得到的資訊