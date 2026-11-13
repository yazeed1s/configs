;;; core.el -*- lexical-binding: t; -*-

;;; code


(set-terminal-coding-system 'utf-8) 
(set-keyboard-coding-system 'utf-8) 
(set-selection-coding-system 'utf-8) 
(set-default-coding-systems 'utf-8) 
(set-language-environment 'utf-8) 
(prefer-coding-system 'utf-8) 
(setq locale-coding-system 'utf-8) 
(setq native-comp-async-report-warnings-errors nil) 
(setq ring-bell-function 'ignore use-file-dialog nil use-dialog-box nil pop-up-windows nil backup-inhibited t create-lockfiles nil frame-resize-pixelwise t) 
(fset 'yes-or-no-p 'y-or-n-p) 
(setq confirm-kill-emacs nil) 
(global-auto-revert-mode 1) 
(electric-pair-mode 1) 
(setq auto-save-list-file-prefix "~/.config/emacs/autosave/") 
(setq auto-save-file-name-transforms '((".*" "~/.config/emacs/autosave/" t))) 
(setq-default indent-tabs-mode t tab-width 4 standard-indent 4 c-basic-offset 4) 
(setq c-tab-always-indent t)
;; tree-sitter modes only color function calls, variables, operators and
;; brackets at level 4 (default 3 leaves them in the plain text color)
(setq treesit-font-lock-level 4)

(when (fboundp 'windmove-default-keybindings) (windmove-default-keybindings)) 

(setq recentf-max-menu-items 25 recentf-max-saved-items 100 recentf-auto-cleanup 'never) 

(defun yaz/recentf-cleanup-silently () 
  (let ((inhibit-message t) (message-log-max nil)) (recentf-cleanup))) 

(add-hook 'emacs-startup-hook (lambda () (recentf-mode 1) (run-with-idle-timer 10 nil #'yaz/recentf-cleanup-silently))) 

(defun yaz/display-startup-time () 
  (with-current-buffer "*scratch*" 
    (insert (format "\n;; %d packages loaded in %.3f seconds\n"
        (length package-activated-list) 
        (float-time 
          (time-subtract after-init-time before-init-time)))))) 

(add-hook 'emacs-startup-hook #'yaz/display-startup-time) 
(provide 'core) 
;;; core.el ends here
