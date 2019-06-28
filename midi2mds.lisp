(in-package :M2T)
;;------------------------------------------------------------
;;                                         CONVERT MIDI TO MDS

(defun get-note-on-off (track &optional res)
  (if (null track) res
      (let ((al (loop for i in (cdr track) when (equalp (cadar track) (cadr i)) collect i)))
	(push (list (caar track) (- (caar al) (caar track)) (cadar track)) res)
	(get-note-on-off (cdr (remove (car al) track :count 1 :test #'equalp)) res))))
 
(defun add-duration (data)
  (mapcar #'(lambda (track) (reverse (get-note-on-off track))) data))

(defun add-silence-start (track) 
  (if (= 0 (caar track)) track (cons '(0 0) (cons (list (caar track) 0) track))))
 
(defun add-silence-end (lst)
  (let ((tmp (loop for i in lst collect (apply #'+ (mapcar #'cadr i)))))
    (loop for track in lst
	 collect
	 (if (= (apply #'max tmp) (apply #'+ (mapcar #'cadr track)))
	     (mapcar #'cdr track)
	     (reverse (cons (list (- (apply #'max tmp) (apply #'+ (mapcar #'cadr track))) '(0)) (mapcar #'cdr (reverse track))))))))
 
(defun add-rest (track &optional r)
  (loop for a in (butlast track)
     for i from 1
     do
       (let* ((tdiff (- (car (nth i track)) (car a)))
	      (rdiff (- tdiff (cadr a))))
	 (cond
	   ((= rdiff 0) (push a r))
	   ((> rdiff 0) (push a r) (push (list (+ (car a) (cadr a)) (- tdiff (cadr a)) '(0)) r))
	   (t (push (list (car a) tdiff (caddr a)) r)))))
  (reverse (append (last track) r)))

;;------------------------------------------------------------
;; group note(s) as chord

(defun group-notes (track &key (fun #'max)) ;; fun allows to select one duration among the durations of each note of the chord.
  (let ((tmp (list (car track))) r)
    (loop for n in (reverse (butlast (cons '(0 0 0) (reverse track))))
       for i from 1
       do	 
	 (cond
	   ((= (car n) (caar tmp)) (push n tmp))
	   (t (push tmp r) (setf tmp (list (nth i track))))))
    (mapcar #'(lambda (x) (list (caar x) (apply fun (mapcar #'cadr x)) (remove-duplicates (mapcar #'caddr x)))) (reverse r))))

;;------------------------------------------------------------ 
;; write result ...

(defun group-list (lst len-lst)
  (let ((tmp lst) (res nil))
    (catch 'it
      (loop for segment in len-lst
	 while tmp
	 do (push (loop for i from 1 to segment
		     when (null tmp)
		     do  (push sublist res) (throw 'it 0)
		     end
		     collect (pop tmp) into sublist
		     finally (return sublist))
		  res)))
    (nreverse res)))

(defun format-score-file (score pathname) 
  (with-open-file (stream (make-pathname :directory (pathname-directory pathname)
					 :name (pathname-name pathname)
					 :type "score")
			  :direction :output
			  :if-exists :supersede
			  :if-does-not-exist :create) 
    (loop for i in score
       for j in (group-list (scoring-duration (apply #'append (mapcar #'car score))) (mapcar #'length (mapcar #'car score)))
       do
	 (format stream "~{~a~^ ~}~&" j)
	 (format stream "~{[~{~a~^,~}]~^ ~}~&" (cadr i)))))

;;----------------------------END-----------------------------
