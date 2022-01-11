;;;; cl-rebonoise.asd

(asdf:defsystem #:cl-rebonoise
  :description "Making maps with noise functions"
  :author "Frederico Muñoz <fsmunoz@gmail.com>"
  :license  "GPLv3"
  :version "0.0.1"
  :serial t
  :depends-on (#:black-tie #:zpng)
  :components ((:file "package")
               (:file "cl-rebonoise")))
