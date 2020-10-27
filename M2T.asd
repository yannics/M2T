;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(in-package :ASDF)

(defsystem :M2T
  :name "M2T"
  :description "Melody to Tone"
  :long-description "https://www.overleaf.com/read/sjhfhthgkgdj"
  :version "1.4"
  :author "Yann Ics"
  :licence "GNU GPL"
  :maintainer "Yann Ics"

  ;; :serial t means that each component is only compiled, when the
  ;; predecessors are already loaded
  :serial t
  :components
  (
         (:FILE "package")
         (:FILE "read-file")
 	 (:FILE "harmonic-profile") 
 	 (:FILE "energy-profile") 
        (:FILE "sorting-melody") 
       	 (:FILE "M2T"))
  )
