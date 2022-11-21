# Documentation

## Actors

Actors can be **static** or **dynamic**.  
Static actors are immutable while dynamic have a link to their status. Both react to the player's actions. For instance a floor or an opened door will let the player pass, while a table or a monster will block him. Dynamic actors can also have a behavior which can evolute by itself each turn, driven by a finite state machine.

There can be 128 actors of 128 different kinds in a single level. Actor #0 is always the player.

As there are immutable, many instances of a static actor can be represented by a single ID, while each instance of a dynamic actor require a unique ID.

In memory, tiles contain the actor ID, which serves as an offset to render the tile, compute its behavior, and so on.

## Level generation

Read [this page](https://www.xtof.info/random-level-generation-on-apple-ii.html) for a presentation of the general principle concerning the random level generation.  

The level configuration is given by the *level.conf* file.

### LEVELS.CONF

Description of the levels for the random builder.
All values are 8-bit integers.

```text
[NB_LEVELS]
# level conf * NB_LEVELS
    [NUMBER]
    [SIZE]
    # number of actors of each types * NB_ACTORS_MAX (128)
        [NB_ACTORS]
             .
             .
             .
        [NB_ACTORS]     
```

### STATES

State of the levels

```text
"LVLS"
CURRENT_LEVEL   1 byte
NB_LEVELS       1 byte
# level state * NB_LEVELS
    "LVL"
    VISITED     1 byte
    PLAYER_TILE 1 byte
    LAYOUT      4096 bytes
"ACTS"
# actor state * NB_LEVELS
    "ACT"
    STATE       sizeof(actor_t)
```
