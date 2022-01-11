# cl-rebonoise

This is an implementation of Amit Patel's [Making maps with noise
functions](https://www.redblobgames.com/maps/terrain-from-noise/),
using Simplex Noise (through `black tie`).

The first goal is to cover the same functionality as the interactive
demo; future versions can eventually address other aspects like
biomes or forcing islands.

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

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.


