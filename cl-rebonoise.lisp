;;;; cl-rebonoise.lisp
;;;
;;; Terrain generation through noise, based on Red Blob Games from
;;; Amit Patel (https://www.redblobgames.com/maps/terrain-from-noise/)
;;;
;;; Author: Frederico Muñoz <fsmunoz@gmail.com>

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

(in-package #:cl-rebonoise)

;;; Biomes

(defparameter *terrain-colors*
  '((water . (50 150 255))
    (beach . (255 244 170))
    (forest . (34 139 34))
    (jungle . (41 171 135))
    (savannah . (209 189 146))
    (desert . (108  84 30))
    (snow . (255 255 255)))
  "Association list that maps a biome name to an RGB value (a list)")

(defun biome (e &optional (threshold 0.3) (step 0.1))
  "Defines biomes, starting at THRESHOLD and using STEP"
  (cond
    ((< e (+ threshold (* 1 step))) 'water)
    ((< e (+ threshold (* 1.5 step))) 'beach)
    ((< e (+ threshold (* 3 step))) 'forest)
    ((< e (+ threshold (* 5 step))) 'jungle)
    ((< e (+ threshold (* 6 step))) 'savannah)
    (t 'snow)))

(defun biome-color (name &optional (colors *terrain-colors*))
  "Map biome NAME with its color, through a lookup in the COLORS
alist."
  (cdr (assoc name colors :test 'equal)))

;;; Noise & elevation

(defun normalize-value (noise)
  "Normalizes a value from the [-1...1] range to [0...1]"
  (/ (+ noise 1) 2))

(defun normalized-noise (x y)
  "Use simplex noise with X Y (a [-1..1] value) and return a
normalized [0...1] value."
  (normalize-value
   (black-tie:simplex-noise-2d x y)))

(defun octave (x y &optional (frequency 1) (amplitude))
  "Returns an elevation value (between 0..1) based on FREQUENCY and
AMPLITUDE (by default 1 and 0.5, and if only the frequency is provided
the amplitude is calculated as 1/frequency)"
  (let ((amplitude (or amplitude (/ 1 frequency))))
    (* (normalized-noise (* x frequency)
			 (* y frequency))
       amplitude)))

(defun octaves (x y &key (coefs '((1  1) (2  0.5) (4  0.25))))
  "Returns the combination of multiple \"octaves\", each with
the (FRENQUENCY AMPLITUDE) values in the COEFS list. By default 3
octaves are used with amplitudes 1 0.5 0.25, but it's possible to
specify both frequency and amplitude values."
  (loop for (frequency amplitude) in coefs
	sum amplitude into amplitudes
	;; Adding frequency and amplitude merely as a quick way to add
	;; a different offset to each octave - it could use random or
	;; a fixed value.
	sum (octave (+ x frequency) (+ y amplitude) frequency amplitude)
	  into elevation
	finally (return (/ elevation amplitudes))))

(defun redistribution (e power &optional (fudge 1.0))
  "Raises the elevation to POWER, with higher values pushing
mid-elevations down. Optionally multiplies elevation by FUDGE factor
before exponentiation."
  (expt (* e fudge) power))

(defun distance (x y &optional (cx 0.5) (cy 0.5))
  "Euclidean distance between points X Y and the centre of the
map (defaults to 0.5 0.5)"
  (sqrt (+ (expt(- x cx) 2) (expt(- y cy) 2))))

(defun elevation (x y &key (coefs '((1  1) (2  0.5) (4  0.25))) (power 1))
  "Returns an elevation value calculated through adding all the
octaves with their frequency and amplitude (each cons is composed of
FREQUENCY and AMPLITUDE), optionally raised to POWER for
redistribution."
  (expt (octaves x y :coefs coefs) power))

(defun elevation-grid (width height  &key (coefs '((1  1) (2  0.5) (4  0.25))) (power 1) (offset -0.5))
  "Returns a WIDTHxHEIGHT where each element has an elevation value,
optionally using COEFS and POWER for octaves and redistribution, plus
OFFSET to chose a different noise space."
  (let ((grid (make-array (list width height))))
    (dotimes (x width)
      (dotimes (y height)
	(let* ((nx (+ (/ x width) offset))
	       (ny (+ (/ y height) offset))
	       (e (elevation nx ny :coefs coefs :power power)))
	  (setf (aref grid x y) e))))
    grid))


;;; PNG creation functions

(defun e->rgb (e)
  "Takes a value between 0..1 and returns an integer between 0..255"
  (truncate (* e 255)))

;;; From black-tie textures.lisp example

(defun set-blue (image x y value)
  (setf (aref image y x 2) value))

(defun set-green (image x y value)
  (setf (aref image y x 1) value))

(defun set-red (image x y value)
  (setf (aref image y x 0) value))

(defun set-rgb (image x y red green blue)
  (set-blue image x y blue)
  (set-green image x y green)
  (set-red image x y red))

;;; Create and save a PNG file

(defun grid-to-file (width height filename &key (coefs '((1  1) (2  0.5) (4  0.25))) (power 1) (offset -0.5) (biomes nil))
  "Creates a PNG file with FILENAME that is the visual representation
of an elevation map of dimensions WIDTHxHEIGHT, optionally using
options for the elevation calculation. If BIOMES is not nil, use
specific biome colors."
  (let* ((png (make-instance 'zpng:png :color-type :truecolor
				       :width width :height height))
         (image (zpng:data-array png))
	 (elevations (elevation-grid width height :coefs coefs :power power :offset offset)))
    (black-tie::with-2d (x width y height)
      (let* ((e (aref elevations x y))
	     (biome-color (and biomes (biome-color (biome e))))
	     (rgb (e->rgb e)))
	(if biome-color
	     (apply #'set-rgb image x y biome-color)
	     (set-rgb image x y rgb rgb rgb))))
    (zpng:write-png png filename)))
