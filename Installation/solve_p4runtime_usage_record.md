# Aim to Learn PI/P4Runtime

## Solve the p4runtime problem occurs in p4lang/tutorial

* On my machine, I reverse my `grpc`, `protobuf` version to [p4lang/PI recommended](https://github.com/p4lang/PI), and then re-compile `PI` for enabling `p4runtime.proto` usage.

* Then I got some error when I execute [`mycontroller.py`](https://github.com/p4lang/tutorials/blob/master/P4D2_2017_Fall/exercises/p4runtime/solution/mycontroller.py) (after I using `make` to build the scenario) ! The error message shows:

```python
Traceback (most recent call last):
  File "./mycontroller.py", line 202, in <module>
    main(args.p4info, args.bmv2_json)
  File "./mycontroller.py", line 147, in main
    s1 = p4runtime_lib.bmv2.Bmv2SwitchConnection('s1', address='127.0.0.1:50051')
  File "/home/kevin/workspace/tutorials/P4D2_2017_Fall/exercises/p4runtime/p4runtime_lib/switch.py", line 28, in __init__
    self.client_stub = p4runtime_pb2.P4RuntimeStub(self.channel)
AttributeError: 'module' object has no attribute 'P4RuntimeStub'
```

* The method I have tried:
    * downgrade `grpc`, `protobuf` to recommended version, and then reinstall `PI` repository with suggestions [here](https://github.com/p4lang/PI#building-p4runtimeproto)

## 2/8 Update 

* Found the differences between different version `p4runtime.proto` in `PI` repository
* If you want to run `tutorials` on the latest version, then you need to modify the controller code (mostly on its dependent libraries)
* Need to figure out how to use the attributes with the generated grpc code (e.g. `p4runtime_pb2.py` )