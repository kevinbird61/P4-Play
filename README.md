# P4-Play
Record something useful information and experiments on P4. 

## Usage

This repository will record some information about how I learn P4 from hardly without any knowledge about networking. 
So it will have some basic concept about `networking command in Linux`, `mininet API learning`, and some `P4 spec` knowledge I read from [`p4.org/specs`](https://p4.org/specs/), like `PSA`, `P4_16`. All the practices will base on `P4_16` to illustrate.

* Repository configuration
    * [Installation](Installation/)
    * [P4-playground](P4-playground/)
```
P4-Play -
| - Installation
|   - install.sh
| - P4-playground
|   - ... 
```

* build the P4 develop environment:
    * It will install `p4c`, `bmv2`, `PI` for you.
```bash
# add execute mode to scripts
chmod +x Installation/install.sh
# execute
./Installation/install.sh
```

## Some notes 

* Check out docs/
    * using command `make` to generate it.
    * using `papogen` as generator.

## About me

* [kevinbird61(Kevin Cyu, 瞿旭民)](https://github.com/kevinbird61)
    * Nation Cheng-Kung University. Major in `Software-defined network`, especially focus on `P4`.

## Reference

Record some good website about catch up P4 concept.

* [Official website of P4](https://p4.org/specs/)
    * The latest specification about P4.
* [SDNLAB - P4](https://www.sdnlab.com/tag/p4/)
    * Some useful information in Chinese.
* [p4lang - github](https://github.com/p4lang)
    * tutorials about P4 goes here.
* [Some good learning materials](LEARNING_MATERIALS.md)