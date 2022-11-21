## What is it?

**Escape** (working title) is a homebrew *Rogue-Like** game developed for the Apple II computers.

It is written in assembly and serves two purposes:
1. Be fun
2. Document the proccess of coding for the Apple II on [my blog](https://www.xtof.info):
 - [A tile engine for the Apple II](https://www.xtof.info/an-hires-tile-engine-for-the-apple-ii.html) 
 - [Raycasting a Line of Sight](https://www.xtof.info/appleii-roguelike-line-of-sight.html)
 - [Random level generation on Apple II](https://www.xtof.info/random-level-generation-on-apple-ii.html)

## How to build

### Prerequisites

* The build process relies on the assembler provided by the [CC65 compiler suite](https://github.com/cc65/cc65).
  * Set the environment variable **CC65_HOME** to the root folder of CC65
  * Builds are guaranteed to be successful using version 2.19 (commit 555282497c3ecf8). They should also work with any subsequent versions.
* A makefile compatible with GNU Make is provided.
* [AppleCommander](http://applecommander.sourceforge.net/) is used to produce a disk image that can be loaded in any emulator. Apple Commander requires a Java Runtime.
  *  Export the variable **APPLE_COMMANDER** to the path of the jar file.

### How to build

```bash
make
```

This will produce *bin/escape.a2* which is a binary executable for Apple's II PRODOS.

```bash
make install
```

Will produce the executable binary and copy it along with all the required files into the floppy image *escape.dsk*

### How to play

You can navigate the levels using the IJKL keys and display a map by pressing TAB.
