;;; session-config.el -*- lexical-binding: t; -*-

;;; desktop.el (built in): save/restore buffers, window layout, and history.
;;
;; The default session lives in `yaz/session-dir'. It is saved on exit, auto-saved
;; while idle, and restored on startup.
;; Named sessions live in `yaz/session-root/<name>/', and you can switch between them.

(require 'desktop)

(defvar yaz/session-root (expand-file-name "sessions" user-emacs-directory)
  "Directory holding all saved desktop sessions.")

(defvar yaz/session-dir (expand-file-name "default" yaz/session-root)
  "Directory of the default desktop session.")

(make-directory yaz/session-dir t)

(setq desktop-dirname             yaz/session-dir
      desktop-path                (list yaz/session-dir)
      desktop-base-file-name      "emacs.desktop"
      desktop-base-lock-name      "emacs.desktop.lock"
      desktop-save                t            ; save without asking
      desktop-load-locked-desktop 'check-pid   ; ignore stale locks from crashed emacs
      desktop-auto-save-timeout   30
      desktop-restore-eager       8            ; load the rest lazily, so startup stays fast
      desktop-restore-frames      t
      desktop-restore-in-current-display t
      desktop-restore-reuses-frames t
      desktop-files-not-to-save   "\\(\\`/[^/:]*:\\|(ftp)\\'\\|\\.gpg\\'\\)" ; skip tramp/remote
      desktop-buffers-not-to-save "\\` \\|\\*Messages\\*\\|\\*scratch\\*\\|\\*Help\\*\\|\\*Compile-Log\\*"
      desktop-modes-not-to-save   '(tags-table-mode dired-mode Info-mode info-lookup-mode
                                    magit-mode magit-status-mode compilation-mode))

;; Don't save/restore frame colors and fonts: the restored frame would keep the
;; old theme's colors and font instead of the current theme's.
(setq frameset-filter-alist
      (append '((background-color . :never)
                (foreground-color . :never)
                (background-mode  . :never)
                (cursor-color     . :never)
                (mouse-color      . :never)
                (border-color     . :never)
                (font             . :never)
                (alpha            . :never)
                (alpha-background . :never))
              frameset-filter-alist))

(defun yaz/session--after-read ()
  "Re-apply the theme and give keyboard focus back to the restored frame."
  (when (and (boundp 'yaz/saved-theme) yaz/saved-theme
             (not (memq yaz/saved-theme custom-enabled-themes)))
    (load-theme yaz/saved-theme t))
  (when (display-graphic-p)
    (select-frame-set-input-focus (selected-frame))))

(add-hook 'desktop-after-read-hook #'yaz/session--after-read)

;; extra history to keep across sessions
(dolist (var '(kill-ring search-ring regexp-search-ring
               extended-command-history file-name-history
               register-alist))
  (add-to-list 'desktop-globals-to-save var))

;; old elisp-tree-sitter is disabled (built-in treesit is used instead); don't
;; let sessions saved before the switch re-enable it on restored buffers.
(dolist (mode '(tree-sitter-mode tree-sitter-hl-mode))
  (add-to-list 'desktop-minor-mode-table (list mode nil)))

(desktop-save-mode 1)

;;; Named sessions

(defun yaz/session--dir (name)
  (file-name-as-directory (expand-file-name name yaz/session-root)))

(defun yaz/session--names ()
  (when (file-directory-p yaz/session-root)
    (seq-filter (lambda (n)
                  (file-exists-p (expand-file-name desktop-base-file-name
                                                   (yaz/session--dir n))))
                (directory-files yaz/session-root nil "\\`[^.]"))))

(defun yaz/session-current ()
  "Return the name of the current session."
  (if desktop-dirname
      (file-name-nondirectory (directory-file-name desktop-dirname))
    "none"))

(defun yaz/session-save ()
  "Save the current session."
  (interactive)
  (desktop-save desktop-dirname t)
  (message "session '%s' saved" (yaz/session-current)))

(defun yaz/session-save-as (name)
  "Save the current state as a session called NAME and make it current."
  (interactive
   (list (completing-read "save session as: " (yaz/session--names)
                          nil nil nil nil (yaz/session-current))))
  (let ((dir (yaz/session--dir name)))
    (make-directory dir t)
    (desktop-release-lock)
    (setq desktop-dirname dir)
    (desktop-save dir t)
    (message "session '%s' saved" name)))

(defun yaz/session-load (name)
  "Save the current session, then switch to session NAME."
  (interactive
   (list (completing-read "load session: " (yaz/session--names) nil t)))
  (when desktop-dirname
    (desktop-save desktop-dirname t))
  (desktop-change-dir (yaz/session--dir name))
  (message "session '%s' loaded" name))

(defun yaz/session-delete (name)
  "Delete the saved session NAME."
  (interactive
   (list (completing-read "delete session: " (yaz/session--names) nil t)))
  (let ((dir (yaz/session--dir name)))
    (when (and desktop-dirname
               (file-equal-p dir desktop-dirname))
      (user-error "Can't delete the current session; switch to another one first"))
    (when (y-or-n-p (format "delete session '%s'? " name))
      (delete-directory dir t)
      (message "session '%s' deleted" name))))

(defun yaz/session-reload ()
  "Reload the current session from disk, discarding unsaved layout changes."
  (interactive)
  (desktop-revert)
  (message "session '%s' reloaded" (yaz/session-current)))

(defun yaz/session-clear ()
  "Kill all buffers and windows covered by desktop, leaving an empty session."
  (interactive)
  (when (y-or-n-p "clear all buffers in this session? ")
    (desktop-clear)
    (delete-other-windows)
    (message "session cleared")))

(defun yaz/session-info ()
  "Show which session is current and where it lives."
  (interactive)
  (message "session: %s  (%s)  auto-save: %s"
           (yaz/session-current)
           (abbreviate-file-name (or desktop-dirname "none"))
           (if desktop-save-mode "on" "off")))

(provide 'session-config)
;;; session-config.el ends here
