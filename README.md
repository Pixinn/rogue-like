# What is it?

**Escape** (working title) is a homebrew *Rogue-Like** game developped for the Apple II computers.

It is written in assembly and serves two purposes:
1. Be fun
2. Document the proccess of coding for the Apple II on [my blog](https://www.xtof.info):
    - [A tile engine for the Apple II](https://www.xtof.info/blog/?p=1044) 
    - [Raycasting a Line of Sight](https://www.xtof.info/blog/?p=1071)

# How to build

## Building

Just type

    make

This will produce *bin/escape.a2* which is a binary executable for Apple's II PRODOS.

## Prerequisite in order to build:

The [cc65 compiler suite](https://github.com/cc65/cc65), with the environment variable *CC65_HOME* set to its folder

## Prerequisite in order to produce the disk image

- Java Runtime
- [AppleCommander](http://applecommander.sourceforge.net/)

## Embedding the Apple II' executable  into the disk image

Run 

    scripts/add-to-disk.sh
