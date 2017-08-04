(message "Start init.el")
(setq debug-on-error t)
(defun init () 
	(message "Init function")
	; setup vars
	(setq color-init "~/.emacs.d/color-theme/init.el")
	(setq clock-init "~/.emacs.d/el/bh.el")
	(setq start-file "~/.emacs.d/org/main.org")
	(setq backup-dir "~/.emacs.d/backup/")
	
	; set up backups 
	(setq
	  backup-by-copying t      ; don't clobber symlinks
	  backup-directory-alist
	  '(("." . "~/.emacs.d/backup/"))    ; don't litter my fs tree
	  delete-old-versions t
	  kept-new-versions 6
	  kept-old-versions 2
	  version-control t)       ; use versioned backups
	
	
	(message "Load init files")
	(load-file color-init)
	(load-file clock-init)
	(add-to-list 'default-frame-alist '(fullscreen . maximized))
	(find-file start-file)
	(setq inhibit-startup-screen t)
	(setq initial-buffer-choice start-file)
)

(init)



