# How to install `simple_switch_grpc` ?

* Step 1
    * Fetch the latest `bmv2` code and build
    * using configure options: `./configure --with-pi`
* Step 2
    * install gNMI support 
    * You can use the scripts [here](install_gNMI_support.sh).
* Step 3
    * After bmv2 building process is finished, then you can get into the repository `targets/simple_switch_grpc` under the `bmv2`, and then using the script below:
    ```bash 
    ./autogen.sh
    ./configure --with-sysrepo
    make 
    sudo make install
    ```

If there are no error occur, then congratulate ! You have built a `simple_switch_grpc` on your own develop platform!


## FAQ

1. Go see [`this issue`](https://github.com/p4lang/behavioral-model/issues/545) I have encountered before ! Using [the advise](https://github.com/p4lang/behavioral-model/pull/546) provided by `P4/bmv2` repository owner !

In my case, when I use the dependencies with:
```
Compiler: gcc version 7.2.0
protoc: 3.5.0
grpc: v1.8.x
```
And I fixed the error with the branch: [`origin/antonin/simple-switch-grpc-dp-proto-remove-empty-dep`](https://github.com/p4lang/behavioral-model/tree/antonin/simple-switch-grpc-dp-proto-remove-empty-dep)

Just change to this branch and then rebuild the `simple_switch_grpc`!