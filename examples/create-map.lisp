;;;; cl-rebonoise.lisp
;;;
;;; Examples on how to use cl-rebonoise.
;;;
;;;
;;; This program is free software: you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation, either version 3 of
;;; the License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program. If not, see
;;; <https://www.gnu.org/licenses/>.

(in-package :cl-rebonoise)

;;; Single octave, 500x500; we override the defaults since they are
;;; set to produce multiple octaves
(grid-to-file 500 500 "./examples/img/1-single-pass.png" :coefs '((1 1)))

;;; Using the defaults, 3 octaves are used, producing noise at
;;; different frequencies.
(grid-to-file 500 500 "./examples/img/2-three-octaves.png")

;;; The same but using a small offset: it's almost the same as the
;;; previous one but moved slightly. Higher offset values will pick up
;;; a different noise space.
(grid-to-file 500 500 "./examples/img/3-offset.png" :offset -0.6)

;;; More octaves result in more interesting terrain features.
(grid-to-file 500 500 "./examples/img/4-more-octaves.png" :coefs '((1 1) (2 0.5) (4 0.25) (8 0.125) (16 0.0625)))

;;; Using a different POWER will redistribute middle values, creating
;;; more abrupt "valleys"
(grid-to-file 500 500 "./examples/img/5-noise1.png" :coefs '((1 1) (2 0.5) (4 0.25) (8 0.125) (16 0.0625)) :power 2)

;;; Different values can be used for each "octave" amplitude and
;;; frequency; playing with them and the rest produces different maps,
;;; obviouly.
(grid-to-file 500 500 "./examples/img/6-coefs.png" :coefs '((1 3) (3 1) (4 1.25) (8 0.3) ) :power 1.5 :offset 10)
					
;; Biomes map colors to elevation; using different settings we can get
;; a more forest-heavy landmass.
(grid-to-file 500 500 "./examples/img/7-biome1.png" :coefs '((1 1) (2 1) (4 8) (18 2) ) :power 0.75 :offset 90 :biomes t)

;;... or a more island-like map.
(grid-to-file 500 500 "./examples/img/7-biome2.png" :coefs '((1 6) (2 11) (4 8) (18 2) ) :power 1.45 :offset 166 :biomes t)

