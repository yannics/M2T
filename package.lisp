(ignore-errors (require 'midi))
(if (find-package :midi)
    (defpackage :M2T (:use :cl :midi))
    (progn
      (warn "Package MIDI not installed!")
      (defpackage :M2T (:use :cl))))
