# cl-rebonoise

![Logo](cl-rebonoise-logo.png?raw=true)

This is an implementation of Amit Patel's [Making maps with noise
functions](https://www.redblobgames.com/maps/terrain-from-noise/),
using Simplex Noise (through `black tie`).

The first goal is to cover the same functionality as the interactive
demo; future versions can eventually address other aspects like
biomes or forcing islands.


## Installation

The package can be loaded using `quicklisp`. [ABCL](https://common-lisp.net/project/armedbear/) and [SBCL](http://www.sbcl.org/) have been tested, others should "just work" as long as the depencies are available (`black-tie` and `zpng`, plus their dependencies).

```common-lisp
Armed Bear Common Lisp 1.8.0
Java 17.0.1 Debian
OpenJDK 64-Bit Server VM
Low-level initialization completed in 0.127 seconds.
Startup completed in 0.669 seconds.
Type ":help" for a list of available commands.
(ql:quickload 'cl-rebonoise)
To load "cl-rebonoise":
  Load 1 ASDF system:
    cl-rebonoise
; Loading "cl-rebonoise"
[package black-tie]...............................
[package impl-specific-gray]......................
[package trivial-gray-streams]....................
[package salza2]..................................
[package zpng]....................................
[package cl-rebonoise]
(CL-REBONOISE)
(in-package cl-rebonoise)

#<PACKAGE CL-REBONOISE>
(elevation 10 20)

0.6721937
```

## How to use it

There are two main entry points to the library:

* `elevation`: calculates the elevation for a single x/y point.
* `elevation-grid`: returns a 2d array of WIDTHxHEIGHT in which each
  element has the elevation value.
  
Since actually looking at the result is useful there is also an
utility function (the only ony that depends on zpng) `grid-to-file`
that creates a PNG file in which each pixel is an element of the
elevation grid.

Most of them share the same optional keyword arguments, all of which
are described at [Red Blob
Games(https://www.redblobgames.com/maps/terrain-from-noise) page:

*`coefs`: an alist composed of (Frequency Amplitude) values. The
number of such pairs determines the numbert of octaves, and the values
are used for the calculation of that octave,
* `power`: used for height redistribution, reshapes elevation.
*`offset`: the offset to apply to the noise functions, different
offsets will pick up differente noise spaces.

Biomes are implemented but superficially so: there's no moisture map
and it's still not adequately integrated into the functions. Still,
since it makes such a different visually it's included via a
customisable association list of colours and an option in
`grid-to-file`.

## Walkthrough

(This content is also in `examples/create-map.lisp` for interactive explorarion).

### Single octave
Single octave, 500x500; we override the defaults since they are set to produce multiple octaves

```common-lisp
(grid-to-file 500 500 "./examples/img/1-single-pass.png" :coefs '((1 1)))
```
![Single pass](examples/img/1-single-pass.png?raw=true)

### Default octaves
Using the defaults, 3 octaves are used, producing noise at different frequencies.

```common-lisp
(grid-to-file 500 500 "./examples/img/2-three-octaves.png")
```
![Octaves](examples/img/2-three-octaves.png?raw=true)

### Offset

The same but using a small offset: it's almost the same as the previous one but moved slightly. Higher offset values will pick up a different noise space.

```common-lisp
(grid-to-file 500 500 "./examples/img/3-offset.png" :offset -0.6)
```
![Offset](examples/img/3-offset.png?raw=true)


### More octaves

More octaves result in more interesting terrain features.
```common-lisp
(grid-to-file 500 500 "./examples/img/4-more-octaves.png" :coefs '((1 1) (2 0.5) (4 0.25) (8 0.125) (16 0.0625)))
```
![More octaves](examples/img/4-more-octaves.png?raw=true)


### Redistribution

Using a different `power` will redistribute middle values, creating more abrupt "valleys".


```common-lisp
(grid-to-file 500 500 "./examples/img/5-noise1.png" :coefs '((1 1) (2 0.5) (4 0.25) (8 0.125) (16 0.0625)) :power 2)
```
![Redistribution](examples/img/5-noise1.png?raw=true)


### Custom frequency, amplitudes and number of octaves
Different values can be used for each "octave" amplitude and frequency; playing with them and the rest produces different maps, obviouly.

```common-lisp
(grid-to-file 500 500 "./examples/img/6-coefs.png" :coefs '((1 3) (3 1) (4 1.25) (8 0.3) ) :power 1.5 :offset 10)
```
![Custom octaves](examples/img/6-coefs.png?raw=true)

### Biomes

Biomes map colors to elevation; using different settings we can get a more forest-heavy landmass.
```common-lisp
(grid-to-file 500 500 "./examples/img/7-biome1.png" :coefs '((1 1) (2 1) (4 8) (18 2) ) :power 0.75 :offset 90 :biomes t)
```
![Biome land](examples/img/7-biome1.png?raw=true)

... or a more island-like map.

```common-lisp
(grid-to-file 500 500 "./examples/img/7-biome2.png" :coefs '((1 6) (2 11) (4 8) (18 2) ) :power 1.45 :offset 166 :biomes t)
```
![Biome islands](examples/img/7-biome2.png?raw=true)

## TODO

* Biome support is very basic: moisture influence (as per the original page) should be added and a more robust configuration mechanism implemented.
* Island mode: forcing maps to islands via shaping.
* Ridged noise and terraces
* 
## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.


