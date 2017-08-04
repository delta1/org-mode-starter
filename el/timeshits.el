;Welcome to timeshits!!!


;regular table line:
;#+BEGIN: clocktable :indent t :maxlevel 2 :scope file :tstart "<2014-08-25 Mon>" :tend "<2014-09-25 Thu>" :step nil :tags nil :narrow 50

;I use this one to do a grand summary, so I can check tally of hours. A more normal one is:
;#+BEGIN: clocktable :indent t :maxlevel 2 :scope file :tstart "<2014-07-25 Fri>" :tend "<2014-08-25 Mon>" :step day :tags nil :narrow 50

;timeshits line:
;#+BEGIN: timetable :formatter org-clocktable-write-timetable :indent t :maxlevel 2 :scope file :tstart "<2014-07-25 Fri>" :tend "<2014-08-25 Mon>" :step day :tags nil :narrow 50
;you'll notice the :formatter and 'timetable' instead of 'clocktable'

;put #END: under both, so the clocktables have scope!

;You must have all your items in one file. You must have all your items in a 2 level structure, like: CLIENT->PROJECT. I suspect we'll eventually move to a 3 tier structure, but I only got around to 2 levels for now.

;Open this page, then do M-x eval-buffer
;then, run a regular clock table first
;then run this new one


(defun org-dblock-write:timetable (params)
  "Write the timetable clocktable."
  (setq params (org-combine-plists org-clocktable-defaults params))
  (catch 'exit
    (let* ((scope (plist-get params :scope))
	   (block (plist-get params :block))
	   (ts (plist-get params :tstart))
	   (te (plist-get params :tend))
	   (link (plist-get params :link))
	   (maxlevel (or (plist-get params :maxlevel) 3))
	   (step (plist-get params :step))
	   (timestamp (plist-get params :timestamp))
	   (formatter (or (plist-get params :formatter)
			  org-clock-clocktable-formatter
			  'org-clocktable-write-default))
	   cc range-text ipos pos one-file-with-archives
	   scope-is-list tbls level)
      ;; Check if we need to do steps
      (when block
	;; Get the range text for the header
	(setq cc (org-clock-special-range block nil t)
	      ts (car cc) te (nth 1 cc) range-text (nth 2 cc)))
      (when step
	;; Write many tables, in steps
	(unless (or block (and ts te))
	  (error "Clocktable `:step' can only be used with `:block' or `:tstart,:end'"))
                                        (org-clocktable-steps-tt params)
	(throw 'exit nil))

      (setq ipos (point)) ; remember the insertion position

      ;; Get the right scope
      (setq pos (point))
      (cond
       ((and scope (listp scope) (symbolp (car scope)))
	(setq scope (eval scope)))
       ((eq scope 'agenda)
	(setq scope (org-agenda-files t)))
       ((eq scope 'agenda-with-archives)
	(setq scope (org-agenda-files t))
	(setq scope (org-add-archive-files scope)))
       ((eq scope 'file-with-archives)
	(setq scope (org-add-archive-files (list (buffer-file-name)))
	      one-file-with-archives t)))
      (setq scope-is-list (and scope (listp scope)))
      (if scope-is-list
	  ;; we collect from several files
	  (let* ((files scope)
		 file)
	    (org-agenda-prepare-buffers files)
	    (while (setq file (pop files))
	      (with-current-buffer (find-buffer-visiting file)
		(save-excursion
		  (save-restriction
		    (push (org-clock-get-table-data file params) tbls))))))
	;; Just from the current file
	(save-restriction
	  ;; get the right range into the restriction
	  (org-agenda-prepare-buffers (list (buffer-file-name)))
	  (cond
	   ((not scope))  ; use the restriction as it is now
	   ((eq scope 'file) (widen))
	   ((eq scope 'subtree) (org-narrow-to-subtree))
	   ((eq scope 'tree)
	    (while (org-up-heading-safe))
	    (org-narrow-to-subtree))
	   ((and (symbolp scope) (string-match "^tree\\([0-9]+\\)$"
					       (symbol-name scope)))
	    (setq level (string-to-number (match-string 1 (symbol-name scope))))
	    (catch 'exit
	      (while (org-up-heading-safe)
		(looking-at org-outline-regexp)
		(if (<= (org-reduced-level (funcall outline-level)) level)
		    (throw 'exit nil))))
	    (org-narrow-to-subtree)))
	  ;; do the table, with no file name.
	  (push (org-clock-get-table-data nil params) tbls)))

      ;; OK, at this point we tbls as a list of tables, one per file
      (setq tbls (nreverse tbls))

      (setq params (plist-put params :multifile scope-is-list))
      (setq params (plist-put params :one-file-with-archives
			      one-file-with-archives))

      (funcall formatter ipos tbls params))))

(defun no-properties (txt)
  (set-text-properties 0 (length txt) nil txt)
  txt)

(defun org-clocktable-write-timetable (ipos tables params)
  (search-backward "Daily report:")
  (search-forward "[")
  (setq current-date (buffer-substring-no-properties (point) (progn (search-forward " ") (- (point) 1))))
  (setq current-day (buffer-substring-no-properties (point) (progn (search-forward "]") (- (point) 1))))
  (beginning-of-line)
  (next-line)
  (setq level-labels (list ""))
  (let ((tracking-level 1))
    (while (setq tbl (pop tables))
      (setq entries (nth 2 tbl))
      (while (setq entry (pop entries))
        (let ((current-level (car entry))
              (current-label  (no-properties (car (cdr entry)))))
          (cond ((> current-level tracking-level) (setq level-labels (push current-label level-labels)))
                ((< current-level tracking-level) (setq level-labels (progn (push current-label (cdr (cdr level-labels))))))
                ((= current-level tracking-level) (setq level-labels (push current-label (cdr level-labels)))))
          (when (= 2 current-level)
            (insert (concat "\n|" current-date "|" current-day "|" (car (last level-labels)) "|"))
            (mapcar (lambda (x) (insert (concat x " "))) (reverse level-labels))
            (insert "|")
            (insert (concat (format "%0.2f" (/ (nth 3 entry) 60.00)) "|")))
          (setq tracking-level current-level))))))


(defun org-clocktable-steps-tt (params)
  "Step through the range to make a number of clock tables."
  (let* ((p1 (copy-sequence params))
         (ts (plist-get p1 :tstart))
         (te (plist-get p1 :tend))
         (step0 (plist-get p1 :step))
         (step (cdr (assoc step0 '((day . 86400) (week . 604800)))))
         (stepskip0 (plist-get p1 :stepskip0))
         (block (plist-get p1 :block))
         cc range-text step-time)
    (when block
      (setq cc (org-clock-special-range block nil t)
            ts (car cc) te (nth 1 cc) range-text (nth 2 cc)))
    (cond
     ((numberp ts)
      ;; If ts is a number, it's an absolute day number from org-agenda.
      (destructuring-bind (month day year) (calendar-gregorian-from-absolute ts)
        (setq ts (org-float-time (encode-time 0 0 0 day month year)))))
     (ts
      (setq ts (org-float-time
                (apply 'encode-time (org-parse-time-string ts))))))
    (cond
     ((numberp te)
      ;; Likewise for te.
      (destructuring-bind (month day year) (calendar-gregorian-from-absolute te)
        (setq te (org-float-time (encode-time 0 0 0 day month year)))))
     (te
      (setq te (org-float-time
                (apply 'encode-time (org-parse-time-string te))))))
    (setq p1 (plist-put p1 :header ""))
    (setq p1 (plist-put p1 :step nil))
    (setq p1 (plist-put p1 :block nil))
    (while (< ts te)
      (or (bolp) (insert "\n"))
      (setq p1 (plist-put p1 :tstart (format-time-string
                                      (org-time-stamp-format nil t)
                                      (seconds-to-time ts))))
      (setq p1 (plist-put p1 :tend (format-time-string
                                    (org-time-stamp-format nil t)
                                    (seconds-to-time (setq ts (+ ts step))))))
      (insert "\n" (if (eq step0 'day) "Daily report: "
                     "Weekly report starting on: ")
              (plist-get p1 :tstart) "\n")
      (setq step-time (org-dblock-write:clocktable p1))
      (re-search-forward "^[ \t]*#\\+END:")
      (when (and (equal step-time 0) stepskip0)
        ;; Remove the empty table
        (delete-region (point-at-bol)
                       (save-excursion
                         (re-search-backward "^\\(Daily\\|Weekly\\) report"
                                             nil t)
                         (point))))
      (end-of-line 0))))
